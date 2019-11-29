#include<string>
#include<iostream>

using namespace std;

//range0
bool isNeg(int x);
bool isNeg(double x);
bool isNeg(string x);
//range1

bool isNeg(int x)    { return x    <  0;   }
bool isNeg(double x) { return x    <  0.0; }
bool isNeg(string x) { return x[0] == '-'; }
bool isNeg(int x, int y) { return x < y; }

//range2
bool fn() {
  string value = "-3";
  return isNeg(value);
}
//range3

bool bar() {
    return isNeg(2.0);
}
int main() {
    fn();
    cout << isNeg(-2) << isNeg(-0.3) << isNeg("-3") << isNeg(2,3) << endl;
}
