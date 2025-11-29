# Benchmark

Performance benchmarking suite for `state_beacon_core`.

## Structure

-   `old_code/` - Uses the published version of `state_beacon_core` from pub.dev
-   `new_code/` - Uses the local development version from `packages/state_beacon_core`
-   `check_perf.sh` - Script to run performance tests

## Usage

Run benchmarks for the published package:

```bash
./benchmark/check_perf.sh old
```

Run benchmarks for the local development code:

```bash
./benchmark/check_perf.sh new
```

This allows you to compare performance between the published package and your local changes.
