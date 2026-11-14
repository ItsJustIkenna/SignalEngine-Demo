# SignalEngine - Demo Version

> **Note**: This is a public demonstration version with sanitized configurations and example parameters.

## Overview

Trading signal processing engine built in Rust, designed for low-latency signal-to-order paths.

## Performance

Measured on an 8-vCPU VM, in-process: signal-to-order under 15 μs p99.

## Features

- Signal generation and dispatch
- Strategy handling
- Order routing and execution handlers

## Quick Start

```bash
# Build
cargo build --workspace --release

# Run
cargo run --release --bin program
```

## Disclaimer

For educational purposes only.
