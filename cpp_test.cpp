#include <iostream>
#include <string>
#include <thread>  // CS144 常用线程库
using namespace std;

int main() {
    string msg = "CS144 environment test (C++17)";
    cout << msg << endl;
    thread t([](){ cout << "POSIX thread works!" << endl; });
    t.join();
    return 0;
}