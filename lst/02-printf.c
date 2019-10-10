#include <stdio.h>
int main(int argc, char *argv[]){
    int width=10;
    int precision=2;
    printf("%3$*1$.*2$f\n", 10, 2, 1.11111);
}
