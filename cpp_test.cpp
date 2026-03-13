#include <iostream>
#include <string>
#include <thread>  // CS144 常用线程库

int main() {
    std::string msg = "CS144 environment test (C++17)";
    std::cout << msg << std::endl;
    std::thread t([](){ std::cout << "POSIX thread works!" << std::endl; });
    t.join();
    return 0;
}