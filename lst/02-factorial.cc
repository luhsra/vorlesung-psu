// Rekursion: F<N> -> N * F<N-1>
template <int N> struct F {
    enum { value = N * F<N - 1>::value };
};

// Rekursionsabbruch: F<0>
template <> struct F<0> { enum { value = 1 }; };

int main(void) { return F<4>::value; } // == 24
