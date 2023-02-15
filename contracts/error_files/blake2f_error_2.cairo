%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.registers import get_fp_and_pc, get_label_location
from starkware.cairo.common.math_cmp import is_nn, is_le

@view
func blake2f{
    bitwise_ptr: BitwiseBuiltin*, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(rounds: felt, h_len: felt, h: felt*, m_len: felt, m: felt*, t: felt, f: felt) -> (
    output_len: felt, output: felt*
) {
    alloc_locals;

    // Check the flag
    let is_positive_flag = is_nn(f);
    let is_valid_flag = is_le(f, 1);
    with_attr error_message("Kakarot: blake2f failed") {
        assert is_positive_flag + is_valid_flag = 2;
    }

    let (local output) = alloc();
    let (local t1, local t0) = unsigned_div_rem(t, 2 ** 64);
    let (sigma_address) = get_label_location(data);
    local sigma: felt* = cast(sigma_address, felt*);

    // Compute state[12].
    assert bitwise_ptr[0].x = 0x510e527fade682d1;
    assert bitwise_ptr[0].y = t0;
    let state12 = bitwise_ptr[0].x_xor_y;
    let bitwise_ptr = bitwise_ptr + BitwiseBuiltin.SIZE;

    // Compute state[13].
    assert bitwise_ptr[0].x = 0x9b05688c2b3e6c1f;
    assert bitwise_ptr[0].y = t1;
    let state13 = bitwise_ptr[0].x_xor_y;
    let bitwise_ptr = bitwise_ptr + BitwiseBuiltin.SIZE;

    // Compute state[14].
    local state14;
    if (f == 1) {
        // 0x1f83d9abfb41bd6b ^ 0xffffffffffffffff
        state14 = 0xe07c265404be4294;
    } else {
        state14 = 0x1f83d9abfb41bd6b;
    }

    let (local initial_state: felt*) = alloc();
    assert initial_state[0] = h[0];
    assert initial_state[1] = h[1];
    assert initial_state[2] = h[2];
    assert initial_state[3] = h[3];
    assert initial_state[4] = h[4];
    assert initial_state[5] = h[5];
    assert initial_state[6] = h[6];
    assert initial_state[7] = h[7];
    assert initial_state[8] = 0x6a09e667f3bcc908;
    assert initial_state[9] = 0xbb67ae8584caa73b;
    assert initial_state[10] = 0x3c6ef372fe94f82b;
    assert initial_state[11] = 0xa54ff53a5f1d36f1;
    assert initial_state[12] = state12;
    assert initial_state[13] = state13;
    assert initial_state[14] = state14;
    assert initial_state[15] = 0x5be0cd19137e2179;

    let (state) = blake_rounds(rounds, 0, initial_state, m, sigma);

    tempvar old_h = h;
    tempvar last_state = state;
    tempvar new_h = output;
    tempvar bitwise_ptr = bitwise_ptr;
    tempvar pedersen_ptr = pedersen_ptr;
    tempvar range_check_ptr = range_check_ptr;
    tempvar syscall_ptr = syscall_ptr;
    tempvar n = 8;

    loop:
    assert bitwise_ptr[0].x = old_h[0];
    assert bitwise_ptr[0].y = last_state[0];
    assert bitwise_ptr[1].x = bitwise_ptr[0].x_xor_y;
    assert bitwise_ptr[1].y = last_state[8];
    assert new_h[0] = bitwise_ptr[1].x_xor_y;
    tempvar old_h = old_h + 1;
    tempvar last_state = last_state + 1;
    tempvar new_h = new_h + 1;
    tempvar bitwise_ptr = bitwise_ptr + 2 * BitwiseBuiltin.SIZE;
    tempvar range_check_ptr = range_check_ptr;
    tempvar pedersen_ptr = pedersen_ptr;
    tempvar syscall_ptr = syscall_ptr;
    tempvar n = n - 1;
    jmp loop if n != 0;

    return (output_len=8, output=output);

    data:
    dw 0;
    dw 2;
    dw 4;
    dw 6;
    dw 1;
    dw 3;
    dw 5;
    dw 7;
    dw 8;
    dw 10;
    dw 12;
    dw 14;
    dw 9;
    dw 11;
    dw 13;
    dw 15;
    dw 14;
    dw 4;
    dw 9;
    dw 13;
    dw 10;
    dw 8;
    dw 15;
    dw 6;
    dw 1;
    dw 0;
    dw 11;
    dw 5;
    dw 12;
    dw 2;
    dw 7;
    dw 3;
    dw 11;
    dw 12;
    dw 5;
    dw 15;
    dw 8;
    dw 0;
    dw 2;
    dw 13;
    dw 10;
    dw 3;
    dw 7;
    dw 9;
    dw 14;
    dw 6;
    dw 1;
    dw 4;
    dw 7;
    dw 3;
    dw 13;
    dw 11;
    dw 9;
    dw 1;
    dw 12;
    dw 14;
    dw 2;
    dw 5;
    dw 4;
    dw 15;
    dw 6;
    dw 10;
    dw 0;
    dw 8;
    dw 9;
    dw 5;
    dw 2;
    dw 10;
    dw 0;
    dw 7;
    dw 4;
    dw 15;
    dw 14;
    dw 11;
    dw 6;
    dw 3;
    dw 1;
    dw 12;
    dw 8;
    dw 13;
    dw 2;
    dw 6;
    dw 0;
    dw 8;
    dw 12;
    dw 10;
    dw 11;
    dw 3;
    dw 4;
    dw 7;
    dw 15;
    dw 1;
    dw 13;
    dw 5;
    dw 14;
    dw 9;
    dw 12;
    dw 1;
    dw 14;
    dw 4;
    dw 5;
    dw 15;
    dw 13;
    dw 10;
    dw 0;
    dw 6;
    dw 9;
    dw 8;
    dw 7;
    dw 3;
    dw 2;
    dw 11;
    dw 13;
    dw 7;
    dw 12;
    dw 3;
    dw 11;
    dw 14;
    dw 1;
    dw 9;
    dw 5;
    dw 15;
    dw 8;
    dw 2;
    dw 0;
    dw 4;
    dw 6;
    dw 10;
    dw 6;
    dw 14;
    dw 11;
    dw 0;
    dw 15;
    dw 9;
    dw 3;
    dw 8;
    dw 12;
    dw 13;
    dw 1;
    dw 10;
    dw 2;
    dw 7;
    dw 4;
    dw 5;
    dw 10;
    dw 8;
    dw 7;
    dw 1;
    dw 2;
    dw 4;
    dw 6;
    dw 5;
    dw 15;
    dw 9;
    dw 3;
    dw 13;
    dw 11;
    dw 14;
    dw 12;
    dw 0;
}

func blake_rounds{
    bitwise_ptr: BitwiseBuiltin*, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(rounds: felt, i: felt, h: felt*, m: felt*, sigma: felt*) -> (final_h: felt*) {
    if (rounds == 0) {
        return (final_h=h);
    }
    let (_, r) = unsigned_div_rem(i, 10);
    let (h_new) = blake_round(h, m, sigma + r * 16);

    return blake_rounds(rounds - 1, i + 1, h_new, m, sigma);
}

func blake_round{
    bitwise_ptr: BitwiseBuiltin*, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(state: felt*, message: felt*, sigma: felt*) -> (new_state: felt*) {
    alloc_locals;

    let (state0, state4, state8, state12) = mix_one(
        state[0], state[4], state[8], state[12], message[sigma[0]]
    );
    let (state1, state5, state9, state13) = mix_one(
        state[1], state[5], state[9], state[13], message[sigma[1]]
    );
    let (state2, state6, state10, state14) = mix_one(
        state[2], state[6], state[10], state[14], message[sigma[2]]
    );
    let (state3, state7, state11, state15) = mix_one(
        state[3], state[7], state[11], state[15], message[sigma[3]]
    );

    let (state0, state4, state8, state12) = mix_two(
        state0, state4, state8, state12, message[sigma[4]]
    );
    let (state1, state5, state9, state13) = mix_two(
        state1, state5, state9, state13, message[sigma[5]]
    );
    let (state2, state6, state10, state14) = mix_two(
        state2, state6, state10, state14, message[sigma[6]]
    );
    let (state3, state7, state11, state15) = mix_two(
        state3, state7, state11, state15, message[sigma[7]]
    );

    let (state0, state5, state10, state15) = mix_one(
        state0, state5, state10, state15, message[sigma[8]]
    );
    let (state1, state6, state11, state12) = mix_one(
        state1, state6, state11, state12, message[sigma[9]]
    );
    let (state2, state7, state8, state13) = mix_one(
        state2, state7, state8, state13, message[sigma[10]]
    );
    let (state3, state4, state9, state14) = mix_one(
        state3, state4, state9, state14, message[sigma[11]]
    );

    let (state0, state5, state10, state15) = mix_two(
        state0, state5, state10, state15, message[sigma[12]]
    );
    let (state1, state6, state11, state12) = mix_two(
        state1, state6, state11, state12, message[sigma[13]]
    );
    let (state2, state7, state8, state13) = mix_two(
        state2, state7, state8, state13, message[sigma[14]]
    );
    let (state3, state4, state9, state14) = mix_two(
        state3, state4, state9, state14, message[sigma[15]]
    );

    let (new_state: felt*) = alloc();
    assert new_state[0] = state0;
    assert new_state[1] = state1;
    assert new_state[2] = state2;
    assert new_state[3] = state3;
    assert new_state[4] = state4;
    assert new_state[5] = state5;
    assert new_state[6] = state6;
    assert new_state[7] = state7;
    assert new_state[8] = state8;
    assert new_state[9] = state9;
    assert new_state[10] = state10;
    assert new_state[11] = state11;
    assert new_state[12] = state12;
    assert new_state[13] = state13;
    assert new_state[14] = state14;
    assert new_state[15] = state15;

    return (new_state=new_state);
}

func mix_one{
    bitwise_ptr: BitwiseBuiltin*, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(a: felt, b: felt, c: felt, d: felt, m: felt) -> (a: felt, b: felt, c: felt, d: felt) {
    alloc_locals;

    // Defining the following constant as local variables saves some instructions.
    // TODO move to namespace
    const mask64ones = (2 ** 64 - 1);

    // a = (a + b + m) % 2**64
    assert bitwise_ptr[0].x = a + b + m;
    assert bitwise_ptr[0].y = mask64ones;
    tempvar a = bitwise_ptr[0].x_and_y;
    let bitwise_ptr = bitwise_ptr + BitwiseBuiltin.SIZE;

    // d = right_rot((d ^ a), 32).
    assert bitwise_ptr[0].x = a;
    assert bitwise_ptr[0].y = d;
    tempvar a_xor_d = bitwise_ptr[0].x_xor_y;
    assert bitwise_ptr[1].x = a_xor_d;
    assert bitwise_ptr[1].y = (2 ** 64 - 2 ** 32);
    tempvar d = (
        (2 ** (64 - 32)) * a_xor_d + (1 / 2 ** 32 - 2 ** (64 - 32)) * bitwise_ptr[1].x_and_y
    );
    let bitwise_ptr = bitwise_ptr + 2 * BitwiseBuiltin.SIZE;

    // c = (c + d) % 2**64
    assert bitwise_ptr[0].x = c + d;
    assert bitwise_ptr[0].y = mask64ones;
    tempvar c = bitwise_ptr[0].x_and_y;
    let bitwise_ptr = bitwise_ptr + BitwiseBuiltin.SIZE;

    // b = right_rot((b ^ c), 24).
    assert bitwise_ptr[0].x = b;
    assert bitwise_ptr[0].y = c;
    tempvar b_xor_c = bitwise_ptr[0].x_xor_y;
    assert bitwise_ptr[1].x = b_xor_c;
    assert bitwise_ptr[1].y = (2 ** 64 - 2 ** 24);
    tempvar b = (
        (2 ** (64 - 24)) * b_xor_c + (1 / 2 ** 24 - 2 ** (64 - 24)) * bitwise_ptr[1].x_and_y
    );
    let bitwise_ptr = bitwise_ptr + 2 * BitwiseBuiltin.SIZE;

    return (a, b, c, d);
}

func mix_two{
    bitwise_ptr: BitwiseBuiltin*, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(a: felt, b: felt, c: felt, d: felt, m: felt) -> (a: felt, b: felt, c: felt, d: felt) {
    alloc_locals;

    // Defining the following constant as local variables saves some instructions.
    // TODO move to namespace
    const mask64ones = (2 ** 64 - 1);

    // a = (a + b + m) % 2**64
    assert bitwise_ptr[0].x = a + b + m;
    assert bitwise_ptr[0].y = mask64ones;
    tempvar a = bitwise_ptr[0].x_and_y;
    let bitwise_ptr = bitwise_ptr + BitwiseBuiltin.SIZE;

    // d = right_rot((d ^ a), 16).
    assert bitwise_ptr[0].x = d;
    assert bitwise_ptr[0].y = a;
    tempvar d_xor_a = bitwise_ptr[0].x_xor_y;
    assert bitwise_ptr[1].x = d_xor_a;
    assert bitwise_ptr[1].y = (2 ** 64 - 2 ** 16);
    tempvar d = (2 ** (64 - 16)) * d_xor_a + (1 / 2 ** 16 - 2 ** (64 - 16)) * bitwise_ptr[1].x_and_y;
    let bitwise_ptr = bitwise_ptr + 2 * BitwiseBuiltin.SIZE;

    // c = (c + d) % 2**64
    assert bitwise_ptr[0].x = c + d;
    assert bitwise_ptr[0].y = mask64ones;
    tempvar c = bitwise_ptr[0].x_and_y;
    let bitwise_ptr = bitwise_ptr + BitwiseBuiltin.SIZE;

    // b = right_rot((b ^ c), 63).
    assert bitwise_ptr[0].x = b;
    assert bitwise_ptr[0].y = c;
    tempvar b_xor_c = bitwise_ptr[0].x_xor_y;
    assert bitwise_ptr[1].x = b_xor_c;
    assert bitwise_ptr[1].y = (2 ** 64 - 2 ** 63);
    tempvar b = (2 ** (64 - 63)) * b_xor_c + (1 / 2 ** 63 - 2 ** (64 - 63)) * bitwise_ptr[1].x_and_y;
    let bitwise_ptr = bitwise_ptr + 2 * BitwiseBuiltin.SIZE;

    return (a, b, c, d);
}
