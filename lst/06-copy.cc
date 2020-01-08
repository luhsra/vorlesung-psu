#include<iostream>
using namespace std;

struct obj_t {
  obj_t()       { cout << "init\n"; }
  obj_t(const obj_t&) { cout << "copy\n"; }
};

obj_t id(obj_t x) { return x; }

int main(){
    obj_t x;
    obj_t y = id(x);
}
