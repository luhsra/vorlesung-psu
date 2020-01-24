// https://godbolt.org/z/_yWCzw

//s0
int foo(int c, int a, int b) {
    int i = 0;
    i += c;
    if (a > 30) {
        i += 2;
        if (b > 13) {
            i += 10;
        }
    }
    do {
        i *= 2;
    } while(c--);
    return i;
}
//e0
