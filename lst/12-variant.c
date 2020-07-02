#+begin_src C
#include <stdio.h>

typedef enum {XY, XYZ} PointKind;
struct Point {
    PointKind tag;
    union {
        struct {
            int x;
            int y;
        } XY;
        struct {
            int x;
            int y;
            int z;
        } XYZ;
    };
};

struct Point makeXY(int x, int y) {
    struct Point ret = {
        .tag = XY,
        .XY = { x, y }
    };
    return ret;
}

struct Point makeXYZ(int x, int y, int z) {
    struct Point ret = {
        .tag = XYZ,
        .XYZ = { x, y, z}
    };
    return ret;
}

void handle(struct Point p) {
    switch(p.tag) {
    case XY:
        printf("XY(%d, %d)\n", p.XY.x, p.XY.y);
        break;
    case XYZ:
        printf("XYZ(%d, %d, %d)\n", p.XYZ.x, p.XYZ.y, p.XYZ.z);
        break;
    }
}

int main() {
    struct Point p1 = makeXY(1,2);
    struct Point p2 = makeXYZ(1,2,3);
    handle(p1); handle(p2);
}

#+end_src
