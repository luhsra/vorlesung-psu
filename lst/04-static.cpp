class O {
  public:
    class I {
       public: static int A;
    } objI;
};

int O::I::A;

int main() {
    O objO;
    O objX;
    objO.objI.A = 23;
    return objX.objI.A;
}
