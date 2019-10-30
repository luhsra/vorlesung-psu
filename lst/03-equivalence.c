typedef struct { int x; } fooA_t;
typedef struct { int x; } fooB_t;

int main(void){
    struct { int x; } fA;
    struct { int x; } fB;
    fA = fB;
}
