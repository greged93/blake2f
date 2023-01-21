// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_check,
    uint256_add,
    uint256_eq,
    assert_uint256_eq,
)
from starkware.cairo.common.math import split_felt

// Internal dependencies
from utils.utils import Helpers

namespace TestHelpers {
    // @notice Fill a bytecode array with "bytecode_count" entries of "value".
    // ex: array_fill(bytecode, 2, 0xFF)
    // bytecode will be equal to [0xFF, 0xFF]
    func array_fill(bytecode: felt*, bytecode_count: felt, value: felt) {
        assert bytecode[bytecode_count - 1] = value;

        if (bytecode_count - 1 == 0) {
            return ();
        }

        array_fill(bytecode, bytecode_count - 1, value);

        return ();
    }

    func assert_array_equal(array_0_len: felt, array_0: felt*, array_1_len: felt, array_1: felt*) {
        assert array_0_len = array_1_len;
        if (array_0_len == 0) {
            return ();
        }
        assert [array_0] = [array_1];
        return assert_array_equal(array_0_len - 1, array_0 + 1, array_1_len - 1, array_1 + 1);
    }

    func print_array(arr_len: felt, arr: felt*) {
        %{
            print(f"{ids.arr_len=}")
            for i in range(ids.arr_len):
                print(f"arr[{i}]={memory[ids.arr + i]}")
        %}
        return ();
    }
}
