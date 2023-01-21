import re
from typing import List

import pytest
import pytest_asyncio
import asyncio
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.testing.starknet import Starknet
from eth._utils.blake2.compression import blake2b_compress
import logging

logging.basicConfig(level=logging.INFO)


def pack(input: List[int]):
    return sum(x * 256**i for (i, x) in enumerate(input))


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
async def starknet():
    starknet = await Starknet.empty()
    return starknet


@pytest_asyncio.fixture(scope="module")
async def blake2f(starknet: Starknet):
    return await starknet.deploy(
        source="./tests/test_blake2f.cairo",
        cairo_path=["contracts"],
        disable_hint_validation=True,
    )


@pytest.mark.asyncio
@pytest.mark.BLAKE2F
class TestBlake2f:
    async def test_should_fail_when_input_len_is_not_213(self, blake2f):
        with pytest.raises(Exception) as e:
            await blake2f.test_should_fail_when_input_is_not_213().call()
        message = re.search(r"Error message: (.*)", e.value.message)[1]
        assert (
            message
            == "Kakarot: blake2f failed with incorrect input_len: 212 instead of 213"
        )

    async def test_should_fail_when_flag_is_not_0_or_1(self, blake2f):
        with pytest.raises(Exception) as e:
            await blake2f.test_should_fail_when_flag_is_not_0_or_1().call()
        message = re.search(r"Error message: (.*)", e.value.message)[1]
        assert (
            message
            == "Kakarot: blake2f failed with incorrect flag: 2 instead of 0 or 1"
        )

    async def test_should_return_blake2f_compression_with_flag_1(self, blake2f):
        await blake2f.test_should_return_blake2f_compression_with_flag_1().call()

    async def test_should_return_blake2f_compression_with_flag_0(self, blake2f):
        await blake2f.test_should_return_blake2f_compression_with_flag_0().call()

    # fmt: off
    @pytest.mark.parametrize("rounds", [12])
    @pytest.mark.parametrize("h", [[0x48, 0xc9, 0xbd, 0xf2, 0x67, 0xe6, 0x09, 0x6a, 0x3b, 0xa7, 0xca, 0x84, 0x85, 0xae,
            0x67, 0xbb, 0x2b, 0xf8, 0x94, 0xfe, 0x72, 0xf3, 0x6e, 0x3c, 0xf1, 0x36, 0x1d, 0x5f,
            0x3a, 0xf5, 0x4f, 0xa5, 0xd1, 0x82, 0xe6, 0xad, 0x7f, 0x52, 0x0e, 0x51, 0x1f, 0x6c,
            0x3e, 0x2b, 0x8c, 0x68, 0x05, 0x9b, 0x6b, 0xbd, 0x41, 0xfb, 0xab, 0xd9, 0x83, 0x1f,
            0x79, 0x21, 0x7e, 0x13, 0x19, 0xcd, 0xe0, 0x5b]])
    @pytest.mark.parametrize("f", [0, 1])
    @pytest.mark.parametrize("t0", [3])
    @pytest.mark.parametrize("t1", [0])
    async def test_should_return_blake2f_compression(self, blake2f, rounds, h, f, t0, t1):
        # Compression parameters
        m = [97, 98, 99, 100]
        empty = [0 for _ in range(128-len(m))]
        m = [*m, *empty]
        starting_state = [pack(h[i*8:(i+1)*8]) for i in range(8)]
        logging.info(m)

        got = await blake2f.test_should_return_blake2f_compression(rounds, h, m, t0, t1, f).call()
        expected = blake2b_compress(rounds, starting_state, m, [t0, t1], bool(f))
        logging.info(got.result.output)
        logging.info(expected)
