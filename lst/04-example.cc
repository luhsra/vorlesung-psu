namespace A {
    typedef int type_t;
    class B {
       private:   int x;
       protected: int y;
       public:    int z;
        virtual type_t func();
    };
}

class C : public A::B {
    virtual A::type_t func();
};

using ret_t = A::type_t;

ret_t A::B::func() {
    return this->x;
}

ret_t C::func() {
    return y;
}

int main() {
    A::B *obj = new C();
    obj->z = 42;
    return obj->func();
}
