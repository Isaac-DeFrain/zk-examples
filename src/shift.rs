use quickcheck::{Arbitrary, Gen};

#[derive(Debug, Clone)]
pub struct Shift(pub u8);

impl Arbitrary for Shift {
    fn arbitrary(g: &mut Gen) -> Self {
        Self(u8::arbitrary(g) % 7)
    }
}
