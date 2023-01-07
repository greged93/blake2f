%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_blake2s.packed_blake2s import blake_round
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.registers import get_fp_and_pc, get_label_location
from starkware.cairo.common.math_cmp import is_nn, is_le

@view
func blake2f{
    bitwise_ptr: BitwiseBuiltin*, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(rounds: felt, h_len: felt, h: felt*, m_len: felt, m: felt*, t: felt, f: felt) -> (output_len: felt, output:felt*) {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();

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

    local initial_state = h[0];
    local initial_state_ = h[1];
    local initial_state_= h[2];
    local initial_state_ = h[3];
    local initial_state_ = h[4];
    local initial_state_ = h[5];
    local initial_state_ = h[6];
    local initial_state_ = h[7];
    local initial_state_ = 0x6a09e667f3bcc908;
    local initial_state_ = 0xbb67ae8584caa73b;
    local initial_state_ = 0x3c6ef372fe94f82b;
    local initial_state_ = 0xa54ff53a5f1d36f1;
    local initial_state_ = state12;
    local initial_state_ = state13;
    local initial_state_ = state14;
    local initial_state_ = 0x5be0cd19137e2179;

    let state = &initial_state;

    let (state) = blake_rounds(rounds, 0, state, m, sigma);

    tempvar old_h = h;
    tempvar last_state = state;
    tempvar new_h = output;
    tempvar bitwise_ptr = bitwise_ptr;
    tempvar range_check_ptr = range_check_ptr;
    tempvar pedersen_ptr = pedersen_ptr;
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
    dw 1;
    dw 2;
    dw 3;
    dw 4;
    dw 5;
    dw 6;
    dw 7;
    dw 8;
    dw 9;
    dw 10;
    dw 11;
    dw 12;
    dw 13;
    dw 14;
    dw 15;
    dw 14;
    dw 10;
    dw 4;
    dw 8;
    dw 9;
    dw 15;
    dw 13;
    dw 6;
    dw 1;
    dw 12;
    dw 0;
    dw 2;
    dw 11;
    dw 7;
    dw 5;
    dw 3;
    dw 11;
    dw 8;
    dw 12;
    dw 0;
    dw 5;
    dw 2;
    dw 15;
    dw 13;
    dw 10;
    dw 14;
    dw 3;
    dw 6;
    dw 7;
    dw 1;
    dw 9;
    dw 4;
    dw 7;
    dw 9;
    dw 3;
    dw 1;
    dw 13;
    dw 12;
    dw 11;
    dw 14;
    dw 2;
    dw 6;
    dw 5;
    dw 10;
    dw 4;
    dw 0;
    dw 15;
    dw 8;
    dw 9;
    dw 0;
    dw 5;
    dw 7;
    dw 2;
    dw 4;
    dw 10;
    dw 15;
    dw 14;
    dw 1;
    dw 11;
    dw 12;
    dw 6;
    dw 8;
    dw 3;
    dw 13;
    dw 2;
    dw 12;
    dw 6;
    dw 10;
    dw 0;
    dw 11;
    dw 8;
    dw 3;
    dw 4;
    dw 13;
    dw 7;
    dw 5;
    dw 15;
    dw 14;
    dw 1;
    dw 9;
    dw 12;
    dw 5;
    dw 1;
    dw 15;
    dw 14;
    dw 13;
    dw 4;
    dw 10;
    dw 0;
    dw 7;
    dw 6;
    dw 3;
    dw 9;
    dw 2;
    dw 8;
    dw 11;
    dw 13;
    dw 11;
    dw 7;
    dw 14;
    dw 12;
    dw 1;
    dw 3;
    dw 9;
    dw 5;
    dw 0;
    dw 15;
    dw 4;
    dw 8;
    dw 6;
    dw 2;
    dw 10;
    dw 6;
    dw 15;
    dw 14;
    dw 9;
    dw 11;
    dw 3;
    dw 0;
    dw 8;
    dw 12;
    dw 2;
    dw 13;
    dw 7;
    dw 1;
    dw 4;
    dw 10;
    dw 5;
    dw 10;
    dw 2;
    dw 8;
    dw 4;
    dw 7;
    dw 6;
    dw 1;
    dw 5;
    dw 15;
    dw 11;
    dw 9;
    dw 14;
    dw 3;
    dw 12;
    dw 13;
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
