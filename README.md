# VWAP on Chain

> **It's not mathematically considered, it's technically!**

After Ethereum the merge, the possibility of manipulation of TWAP was raised.
Many DeFi protocols rely on chainlink's VWAP provided by off-chain. This is agreed off-chain to provide VWAP, but it is unfortunate that there is no fallback.

The repository implements VWAP by tying TWAPs provided by on-chain.