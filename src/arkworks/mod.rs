use ark_bls12_381::Fq2 as F;
use ark_ff::{AdditiveGroup, Field};
use ark_std::{One, UniformRand};

pub fn ops_examples() {
    let mut rng = ark_std::rand::thread_rng();

    // sample uniformly random field elements
    let a = F::rand(&mut rng);
    let b = F::rand(&mut rng);

    // add
    let c = a + b;

    // subtract
    let d = a - b;

    // double
    assert_eq!(c + d, a.double());
    assert_eq!(a + a, a.double());

    // multiply
    let e = c * d;

    // square
    assert_eq!(a * a, a.square());
    assert_eq!(e, a.square() - b.square());

    // inverses
    assert_eq!(a - a, F::ZERO);
    assert_eq!(a.inverse().unwrap() * a, F::one());
}
