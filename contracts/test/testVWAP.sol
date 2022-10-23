//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "UniswapV3Pack/v3-core/interfaces/IUniswapV3Factory.sol";
import "UniswapV3Pack/v3-core/interfaces/IUniswapV3Pool.sol";
import "UniswapV3Pack/v3-periphery/libraries/OracleLibrary.sol";

contract TestVWAP is Test {
    // WETH
    address public constant token0 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // USD//C
    address public constant token1 = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public pool001;
    address public pool005;
    address public pool030;
    address public pool100;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"));
        pool001 = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984).getPool(token0, token1, 100);

        emit log_named_address("0.01%", pool001);

        pool005 = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984).getPool(token0, token1, 500);

        emit log_named_address("0.05%", pool005);

        pool030 = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984).getPool(token0, token1, 3000);

        emit log_named_address("0.30%", pool030);

        pool100 = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984).getPool(token0, token1, 10000);

        emit log_named_address("1.00%", pool100);
    }

    function testWithOracleLib() public {
        uint32 twapDuration = 360;
        int24 arithmeticMeanTick;
        uint128 harmonicMeanLiquidity;
        int256 totalTickByLiquidity;
        uint256 totalLiquidity;
        int24 VWAP;

        // ETH:USDC 0.05%;
        (arithmeticMeanTick, harmonicMeanLiquidity) = OracleLibrary.consult(pool005, twapDuration);
        emit log_named_int("pool005 tick", arithmeticMeanTick);
        emit log_named_uint("pool005 liquidity", harmonicMeanLiquidity);

        assembly {
            totalTickByLiquidity := add(totalTickByLiquidity, mul(arithmeticMeanTick, harmonicMeanLiquidity))
        }
        totalLiquidity += harmonicMeanLiquidity;

        // ETH:USDC 0.3%;
        (arithmeticMeanTick, harmonicMeanLiquidity) = OracleLibrary.consult(pool030, twapDuration);
        emit log_named_int("pool030 tick", arithmeticMeanTick);
        emit log_named_uint("pool030 liquidity", harmonicMeanLiquidity);

        assembly {
            totalTickByLiquidity := add(totalTickByLiquidity, mul(arithmeticMeanTick, harmonicMeanLiquidity))
        }
        totalLiquidity += harmonicMeanLiquidity;

        // ETH:USDC 1%;
        (arithmeticMeanTick, harmonicMeanLiquidity) = OracleLibrary.consult(pool100, twapDuration);
        emit log_named_int("pool100 tick", arithmeticMeanTick);
        emit log_named_uint("pool100 liquidity", harmonicMeanLiquidity);

        // VWAP...?
        assembly {
            totalTickByLiquidity := add(totalTickByLiquidity, mul(arithmeticMeanTick, harmonicMeanLiquidity))
        }
        totalLiquidity += harmonicMeanLiquidity;

        assembly {
            VWAP := div(totalTickByLiquidity, totalLiquidity)
        }
        emit log_named_int("VWAP", VWAP);
    }

    function testSample() public {
        uint32 twapDuration = 21600;
        uint32[] memory secondsAgo = new uint32[](2);
        secondsAgo[0] = twapDuration;
        secondsAgo[1] = 0;
        int56[] memory tickCumulatives;
        uint160[] memory secondsPerLiquidityCumulativeX128s;
        int56 tick1;
        int56 tick0;
        int24 tick;

        // (tickCumulatives, secondsPerLiquidityCumulativeX128s) = IUniswapV3Pool(
        //     pool001
        // ).observe(secondsAgo);

        // tick1 = tickCumulatives[1];
        // tick0 = tickCumulatives[0];
        // tick;

        // assembly {
        //     tick := div(sub(tick1, tick0), twapDuration)
        // }

        // emit log_named_int("pool001", tick);
        // emit log_named_uint(
        //     "pool001 SLP",
        //     secondsPerLiquidityCumulativeX128s[1] -
        //         secondsPerLiquidityCumulativeX128s[0]
        // );

        (tickCumulatives, secondsPerLiquidityCumulativeX128s) = IUniswapV3Pool(pool005).observe(secondsAgo);
        tick1 = tickCumulatives[1];
        tick0 = tickCumulatives[0];
        tick;

        assembly {
            tick := div(sub(tick1, tick0), twapDuration)
        }

        // emit log_named_int("pool005 cum1", tick1);
        // emit log_named_int("pool005 cum0", tick0);
        emit log_named_int("pool005", tick);
        emit log_named_uint(
            "pool005 SPL",
            secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0]
        );
        emit log_named_uint(
            "pool005 SPL",
            (secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0]) / twapDuration
        );

        (tickCumulatives, secondsPerLiquidityCumulativeX128s) = IUniswapV3Pool(pool030).observe(secondsAgo);
        tick1 = tickCumulatives[1];
        tick0 = tickCumulatives[0];
        tick;

        assembly {
            tick := div(sub(tick1, tick0), twapDuration)
        }

        // emit log_named_int("pool030 cum1", tick1);
        // emit log_named_int("pool030 cum0", tick0);
        emit log_named_int("pool030", tick);
        emit log_named_uint(
            "pool030 SPL",
            secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0]
        );
        emit log_named_uint(
            "pool030 SPL",
            (secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0]) / twapDuration
        );

        (tickCumulatives, secondsPerLiquidityCumulativeX128s) = IUniswapV3Pool(pool100).observe(secondsAgo);
        tick1 = tickCumulatives[1];
        tick0 = tickCumulatives[0];
        tick;

        assembly {
            tick := div(sub(tick1, tick0), twapDuration)
        }

        // emit log_named_int("pool100 cum1", tick1);
        // emit log_named_int("pool100 cum0", tick0);
        emit log_named_int("pool100", tick);
        emit log_named_uint(
            "pool100 SPL",
            secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0]
        );
        emit log_named_uint(
            "pool100 SPL",
            (secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0]) / twapDuration
        );
    }

    // function estimateAmountOut(
    //     address tokenIn,
    //     uint128 amountIn,
    //     uint32 secondsAgo
    // ) external view returns (uint256 amountOut) {
    //     require(tokenIn == token0 || tokenIn == token1, "invalid token");

    //     address tokenOut = tokenIn == token0 ? token1 : token0;

    //     // (int24 tick, ) = OracleLibrary.consult(pool, secondsAgo);

    //     // Code copied from OracleLibrary.sol, consult()
    //     uint32[] memory secondsAgos = new uint32[](2);
    //     secondsAgos[0] = secondsAgo;
    //     secondsAgos[1] = 0;

    //     // int56 since tick * time = int24 * uint32
    //     // 56 = 24 + 32
    //     (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(
    //         secondsAgos
    //     );

    //     int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

    //     // int56 / uint32 = int24
    //     int24 tick = int24(tickCumulativesDelta / secondsAgo);
    //     // Always round to negative infinity
    //     /*
    //     int doesn't round down when it is negative
    //     int56 a = -3
    //     -3 / 10 = -3.3333... so round down to -4
    //     but we get
    //     a / 10 = -3
    //     so if tickCumulativeDelta < 0 and division has remainder, then round
    //     down
    //     */
    //     if (
    //         tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)
    //     ) {
    //         tick--;
    //     }

    //     amountOut = OracleLibrary.getQuoteAtTick(
    //         tick,
    //         amountIn,
    //         tokenIn,
    //         tokenOut
    //     );
    // }
}
