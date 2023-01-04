%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.cairo_blake2s import blake2s_compress
from starkware.cairo.common.alloc import alloc

func blakef{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    rh: felt*, message: felt*, t0: felt, f0: felt, sigma: felt*
) -> (output: felt*) {
    return (res);
}
