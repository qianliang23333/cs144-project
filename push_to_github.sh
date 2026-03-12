#!/bin/bash
# CS144/MINNOW 项目上传到 GitHub 的自动化脚本
# 修复：空仓库拉取、Git配置检查、详细日志、空提交判断

# ====================== 配置项（已填好，无需修改）======================
GITHUB_REPO_URL="https://github.com/qianliang23333/cs144-project.git"
BRANCH_NAME="main"
COMMIT_MESSAGE="feat: 完成 CS144 MINNOW 项目的环境测试，能够正常运行c++基本环境"
# 可选：填写你的GitHub用户名/邮箱（首次使用自动配置）
GIT_USER_NAME="qianliang23333"
GIT_USER_EMAIL="3405046449@qq.com"  # 替换为真实邮箱
# ================================================================

# 兼容终端颜色输出
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# 步骤 0：检查 Git 配置（核心修复）
check_git_config() {
    if [ -z "$(git config --global user.name)" ]; then
        echo -e "${YELLOW}提示：Git 未配置用户名，正在自动配置...${NC}"
        git config --global user.name "$GIT_USER_NAME"
    fi
    if [ -z "$(git config --global user.email)" ]; then
        echo -e "${YELLOW}提示：Git 未配置邮箱，正在自动配置...${NC}"
        git config --global user.email "$GIT_USER_EMAIL"
    fi
}

# 步骤 1：检查项目根目录
if [ ! -f "CMakeLists.txt" ]; then
    echo -e "${RED}错误：当前目录不是项目根目录（未找到 CMakeLists.txt）${NC}"
    exit 1
fi

# 步骤 2：初始化 Git + 配置用户信息
check_git_config
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}提示：当前目录未初始化 Git，正在初始化...${NC}"
    git init
    git branch -M $BRANCH_NAME
fi

# 步骤 3：关联远程仓库
git remote | grep -q "origin"
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}提示：未关联远程仓库，正在关联...${NC}"
    git remote add origin $GITHUB_REPO_URL
fi

# 步骤 4：检查工作区是否有变更（优化）
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}提示：工作区无变更，无需提交${NC}"
    exit 0
fi

# 步骤 5：添加文件到暂存区
echo -e "${GREEN}步骤 1/4：添加文件到暂存区...${NC}"
git add .

# 步骤 6：提交代码
echo -e "${GREEN}步骤 2/4：提交代码到本地仓库...${NC}"
git commit -m "$COMMIT_MESSAGE" -v  # -v 显示提交的文件详情

# 步骤 7：拉取远程代码（核心修复：仅远程分支存在时拉取）
echo -e "${GREEN}步骤 3/4：检查远程分支并拉取最新代码...${NC}"
if git ls-remote --heads origin $BRANCH_NAME | grep -q $BRANCH_NAME; then
    git pull origin $BRANCH_NAME --rebase || {
        echo -e "${RED}拉取代码冲突！请手动解决冲突后重新运行脚本${NC}"
        exit 1
    }
else
    echo -e "${YELLOW}提示：远程分支不存在，跳过拉取（首次推送）${NC}"
fi

# 步骤 8：推送到 GitHub（核心修复：添加详细日志）
echo -e "${GREEN}步骤 4/4：推送到 GitHub 远程仓库...${NC}"
git push -u origin $BRANCH_NAME -v  # -v 显示详细推送日志

# 完成提示
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ 代码成功上传到 GitHub！"
    echo -e "仓库地址：${GITHUB_REPO_URL}"
    echo -e "分支：${BRANCH_NAME}${NC}"
else
    echo -e "\n${RED}❌ 推送失败！常见原因："
    echo -e "1. 网络问题（切换热点/用SSH）"
    echo -e "2. PAT 无 repo 权限（重新生成）"
    echo -e "3. 仓库地址错误（检查 GITHUB_REPO_URL）${NC}"
fi