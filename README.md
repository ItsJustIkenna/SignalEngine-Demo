# SignalEngine (demo)

A Rust workspace that turns market data into trading signals and routes them to order-execution adapters. It covers the whole path inside one process: a data handler keeps per-symbol state, strategies (an Avellaneda–Stoikov market-making strategy is the worked example) generate signals, a dispatcher queues them, a smart order router picks a venue, and an execution handler sends the order through an exchange adapter with rate limiting, a circuit breaker and position tracking. It is a research and paper-trading codebase: it is meant for studying lock-free, cache-aware Rust in a latency-sensitive pipeline, not as a trading service. Configurations in this public demo are sanitized examples.

## Architecture

```
 market data ──► datahandler ──► signalgenerator ──► signaldispatcher
 (feed)             (DashMap        strategyhandler       (lock-free
                     per-symbol     (Avellaneda–Stoikov     signal queue)
                     state)          example strategy)           │
                                                                 ▼
 portfoliohandler ◄── position_tracker ◄── executionhandler ◄── smartorderrouter
 (account state)       circuit_breaker     rate_limiter          (venue choice)
                       memory_pool         exchange adapters
                       lock_free queues    (Kraken; experimental DEX modules)
```

Workspace layout (`crates/`): `core` (cache-aligned, lock-free, memory-pool and timestamp primitives), `datahandler`, `signalgenerator`, `signaldispatcher`, `strategyhandler`, `smartorderrouter`, `executionhandler`, `portfoliohandler`, `portfolio`, `orderbook`, `exchangemetricaggregator`, `protocol` and `subscriber` (in-repo stand-ins for the message-broker client), `config`, `ultra-logger`, `hostbuilder`. `program/` is the binary that wires them together.

## Build and test

Requires a recent stable Rust toolchain (edition 2021).

```bash
cargo build --workspace
cargo test --workspace
```

The workspace also defines a `release-optimized` profile (fat LTO, `panic = "abort"`). The `program` binary reads its configuration from the `CONFIG_PATH` environment variable. Its fallback, `./config/default.toml`, is not in this repo; the example configuration is `crates/config/default.toml`. A `Dockerfile`, `compose.yaml` and a Helm chart (`k8s/signal-engine-helm`) are included. Exchange keys, if you use any, come from environment variables; use sandbox or paper credentials only.

## Tests

`cargo test --workspace` runs about 130 `#[test]`/`#[tokio::test]` functions (static count) across the crates, including `tests/performance_integration_test.rs` and `crates/executionhandler/tests/`.

Known issue: `signalengine-core` has one failing test, `memory_pool::tests::test_concurrent_access`, which also fails before the recent cleanup commits. Everything else in the workspace passes.

## Scope and disclaimer

Research, backtesting and paper-trading code. It makes no claim of use with real capital, and nothing here is investment advice.
