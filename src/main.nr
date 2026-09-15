global N: u32 = 5;
global MAX_U64: u64 = 18446744073709551615;

fn main(
    u: [u64; N],
    e_extract: u64,
    r_risk: u64,
    l1: u64,
    u_floor: u64,
    budget: u64,
    k_e: u64,
    k_r: u64,
    lam: u64,
) {
    let mut u_min = u[0];
    for i in 0..N {
        assert(u[i] >= u_floor, "UCARE: Dignity floor violated");
        if u[i] < u_min {
            u_min = u[i];
        }
    }

    let overage = if e_extract > budget { e_extract - budget } else { 0 };

    let mut d_e: u64 = 0;
    if (k_e != 0) & (overage != 0) {
        assert(overage <= (MAX_U64 / k_e), "UCARE: k_e * overage overflow");
        d_e = k_e * overage;
    }

    let mut d_r: u64 = 0;
    if (k_r != 0) & (r_risk != 0) {
        assert(r_risk <= (MAX_U64 / k_r), "UCARE: k_r * r_risk overflow");
        d_r = k_r * r_risk;
    }

    let mut d_m: u64 = 0;
    if (lam != 0) & (l1 != 0) {
        assert(l1 <= (MAX_U64 / lam), "UCARE: lam * l1 overflow");
        d_m = lam * l1;
    }

    assert(d_e <= MAX_U64 - d_r, "UCARE: d_e + d_r overflow");
    let delta_partial = d_e + d_r;
    assert(delta_partial <= MAX_U64 - d_m, "UCARE: delta_partial + d_m overflow");
    let delta = delta_partial + d_m;

    assert(u_min >= delta, "UCARE: Invariant gate failed (u_min < delta)");
}

#[test]
fn test_valid_ucare_state() {
    let u: [u64; 5] = [6000000, 6500000, 7000000, 6000000, 8000000];
    main(u, 1050000, 5, 3, 5000000, 1000000, 2, 10000, 50000);
}

#[test(should_fail_with = "UCARE: Dignity floor violated")]
fn test_fails_dignity_floor() {
    let u: [u64; 5] = [6000000, 4999999, 7000000, 6000000, 8000000];
    main(u, 1000000, 0, 0, 5000000, 1000000, 0, 0, 0);
}

#[test(should_fail_with = "UCARE: Invariant gate failed (u_min < delta)")]
fn test_fails_ucare_gate() {
    let u: [u64; 5] = [6000000, 6500000, 7000000, 6000000, 8000000];
    main(u, 1000000, 700, 0, 5000000, 1000000, 0, 10000, 0);
}

#[test(should_fail_with = "UCARE: k_r * r_risk overflow")]
fn test_fails_multiplication_overflow() {
    let u: [u64; 5] = [6000000, 6500000, 7000000, 6000000, 8000000];
    main(u, 1000000, 18446744073709551615, 0, 5000000, 1000000, 0, 2, 0);
}
