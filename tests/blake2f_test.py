import pytest
import json
from starkware.starknet.testing.starknet import Starknet
import asyncio
import logging

LOGGER = logging.getLogger(__name__)

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

    # Load testset
    # Test set based on test cases from https://eips.ethereum.org/EIPS/eip-152
    with open("./tests/test_set.json") as f:
        sets = json.load(f)

    # Deploy contract
    contract = await starknet.deploy(
        source="contracts/blake2f.cairo",
    )
    LOGGER.info(f"> Deployed blake2f.cairo.")

    for s in sets:
        rounds = s["rounds"]
        hIn = [int(x, 16) for x in s["hIn"]]
        m = [int(x, 16) for x in s["m"]]
        t = s["t"][0] + s["t"][1] * 2**64
        f = s["f"]

        ret = await contract.blake2f(rounds, hIn, m, t, f).call()
        LOGGER.info(
            f"> Simulation of blake2f took execution_resources = {ret.call_info.execution_resources}"
        )

        hOut = [int.from_bytes(int(s["hOut"][i*16:(i+1)*16], 16).to_bytes(8, 'little'), 'big') for i in range(8)]
        assert hOut == ret.result.output
