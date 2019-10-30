struct Base { int x; };
struct Derived : public Base { int y; };

int getX(Base* y) {
    return y->x;
}

int getY(Derived* y) {
    return y->y;
}
