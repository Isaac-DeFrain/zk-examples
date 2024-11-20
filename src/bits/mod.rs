mod shift;

use quickcheck::{Arbitrary, Gen};
use rand;
use shift::Shift;

pub fn ops_examples() {
    // shift (lsl/lsr)
    println!("===== bitwise shift examples =====");

    let x = rand::random::<u8>();
    let shift = Shift::arbitrary(&mut Gen::new(256)).0;

    println!("LEFT:  {x:08b} << {shift} == {:08b}", x << shift);
    println!("RIGHT: {x:08b} >> {shift} == {:08b}", x >> shift);

    // boolean
    println!("\n===== bitwise bool examples =====");

    let x = rand::random::<u8>();
    let y = rand::random::<u8>();

    println!("AND:  {x:08b} & {y:08b} == {:08b}", x & y);
    println!("XOR:  {x:08b} ^ {y:08b} == {:08b}", x ^ y);
    println!("OR:   {x:08b} | {y:08b} == {:08b}", x | y);
    println!("NOT: !{:<19} == {:08b}", format!("{x:08b}"), !x);
}
