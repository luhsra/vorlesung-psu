#include <string.h>

size_t (*func(int param)) (const char* ) {
    return &strlen;
}
