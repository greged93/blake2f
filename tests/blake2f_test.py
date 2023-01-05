import pytest
import os
from starkware.starknet.testing.starknet import Starknet
import asyncio
import logging

LOGGER = logging.getLogger(__name__)


def adjust_from_felt(felt):
    if felt > PRIME_HALF:
        return felt - PRIME
    else:
        return felt


### Reference: https://github.com/perama-v/GoL2/blob/main/tests/test_GoL2_infinite.py
@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
async def starknet():
    starknet = await Starknet.empty()
    return starknet


@pytest.mark.asyncio
async def test(starknet):

    # Deploy contract
    contract = await starknet.deploy(
        source="contracts/blake2f.cairo",
    )
    LOGGER.info(f"> Deployed blake2f.cairo.")

    IV = [
        0x6A09E667,
        0xBB67AE85,
        0x3C6EF372,
        0xA54FF53A,
        0x510E527F,
        0x9B05688C,
        0x1F83D9AB,
        0x5BE0CD19,
    ]

    rounds = 12
    h = [
        0x48C9BDF2,
        0x67E6096A,
        0x3BA7CA84,
        0x85AE67BB,
        0x2BF894FE,
        0x72F36E3C,
        0xF1361D5F,
        0x3AF54FA5,
        0xD182E6AD,
        0x7F520E51,
        0x1F6C3E2B,
        0x8C68059B,
        0x6BBD41FB,
        0xABD9831F,
        0x79217E13,
        0x19CDE05B,
    ]
    m = [0x0000000000636261] + [0 for _ in range(15)]
    t = 0x0300000000000000
    f = 1

    LOGGER.info(rounds)
    LOGGER.info(h)
    LOGGER.info(m)
    LOGGER.info(t)
    LOGGER.info(f)
    ret = await contract.blake2f(rounds, h, m, t, f).call()

    LOGGER.info(
        f"> Simulation of blake2f took execution_resources = {ret.call_info.execution_resources}"
    )
