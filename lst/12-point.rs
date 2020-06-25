#[derive(Copy, Clone, Debug)]
enum Point {
    XY(i32, i32),
    XYZ(i32, i32, i32)
}

fn handle(p : Point) {
    match p {
        Point::XYZ(a,b,c) => println!("{} {} {}", a,b,c),
        Point::XY(a,b) => println!("{} {}", a,b),
    }
}

fn get_x(p : Point) -> Point {
    let x = match p {
        Point::XY(x,y) => Point::XYZ(x,y,0),
        x => x
    };
    return x;
}

fn main() {
    let p1 : Point =
        Point::XY(2, 3);
    let p2 : Point =
        Point::XYZ(3,4,5);

    handle(p1);
    handle(p2);
    println!("pp {:?}", get_x(p1));

    let obj = ObjT{a: 1, b:2};
    
    let (x0, x1) = (1, 2);
    
    struct ObjT { a : i32, b : i32 }
    let ObjT {a: y0, b: y1} = obj;

    println!("{} {} {} {}", x0, x1, y0, y1);
}
