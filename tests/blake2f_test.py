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


    rounds = 12
    h = [
        0x6a09e667f2bdc948,
        0xbb67ae8584caa73b,
        0x3c6ef372fe94f82b,
        0xa54ff53a5f1d36f1,
        0x510e527fade682d1,
        0x9b05688c2b3e6c1f,
        0x1f83d9abfb41bd6b,
        0x5be0cd19137e2179,
    ]
    m = [0x0000000000636261] + [0 for _ in range(15)]
    t = 0x0000000000000003
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

    LOGGER.info(ret.result.output)
