# Introduction

Blake2 compression function implementation in Cairo.
Inspired by the blake2s implementation from [Starkware](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_blake2s/packed_blake2s.cairo#L158)
and the blake2b implementation from [go-ethereum](https://github.com/ethereum/go-ethereum/blob/master/crypto/blake2b/blake2b_generic.go#L47). Details about the compression functions for blake2s and blake2b can be found [here](https://www.rfc-editor.org/rfc/rfc7693).

# Test

Test cases have been picked from [eip-152](https://eips.ethereum.org/EIPS/eip-152).
