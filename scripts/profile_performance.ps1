#!/usr/bin/env pwsh

# SignalEngine Performance Profiler
# This script runs performance tests and generates detailed performance reports

Write-Host "🚀 SignalEngine Performance Profiler" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Set environment for maximum performance
$env:CARGO_PROFILE_RELEASE_OPT_LEVEL = "3"
$env:CARGO_PROFILE_RELEASE_LTO = "fat"
$env:RUSTFLAGS = "-C target-cpu=native -C opt-level=3"

Write-Host ""
Write-Host "⚡ Performance Configuration:" -ForegroundColor Yellow
Write-Host "   • Target CPU: Native optimizations" -ForegroundColor Gray
Write-Host "   • Optimization Level: 3 (Maximum)" -ForegroundColor Gray  
Write-Host "   • LTO: Fat (Link-time optimization)" -ForegroundColor Gray
Write-Host "   • Profile: release-optimized" -ForegroundColor Gray

# Create results directory
$resultsDir = "performance_results"
if (!(Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

Write-Host ""
Write-Host "Building SignalEngine (release-optimized)..." -ForegroundColor Green
$buildStart = Get-Date
cargo build --release --profile release-optimized
$buildEnd = Get-Date
$buildTime = ($buildEnd - $buildStart).TotalSeconds

Write-Host "   Build completed in $([math]::Round($buildTime, 2))s" -ForegroundColor Gray

Write-Host ""
Write-Host "🧪 Running Component Performance Tests..." -ForegroundColor Green

# Test 1: SmartOrderRouter Performance
Write-Host ""
Write-Host "   SmartOrderRouter" -ForegroundColor Magenta
$smartRouterStart = Get-Date
cargo test --release smartorderrouter::tests::test_ultra_fast_routing --lib -- --nocapture 2>$null
$smartRouterEnd = Get-Date
$smartRouterTime = ($smartRouterEnd - $smartRouterStart).TotalMilliseconds

# Test 2: SignalGenerator Performance  
Write-Host "   SignalGenerator" -ForegroundColor Magenta
$signalGenStart = Get-Date
cargo test --release signalgenerator::tests::test_simd_signal_generation --lib -- --nocapture 2>$null
$signalGenEnd = Get-Date
$signalGenTime = ($signalGenEnd - $signalGenStart).TotalMilliseconds

# Test 3: SignalDispatcher Performance
Write-Host "   📡 SignalDispatcher (Target: 2-4x improvement, <200μs)" -ForegroundColor Magenta
$dispatcherStart = Get-Date
cargo test --release signaldispatcher::tests::test_simd_batch_dispatch --lib -- --nocapture 2>$null
$dispatcherEnd = Get-Date
$dispatcherTime = ($dispatcherEnd - $dispatcherStart).TotalMilliseconds

# Test 4: ExecutionHandler Performance
Write-Host "   ExecutionHandler" -ForegroundColor Magenta
$execStart = Get-Date
cargo test --release executionhandler::tests::test_ultra_low_latency_execution --lib -- --nocapture 2>$null
$execEnd = Get-Date
$execTime = ($execEnd - $execStart).TotalMilliseconds

# Test 5: StrategyHandler Performance
Write-Host "   StrategyHandler" -ForegroundColor Magenta
$strategyStart = Get-Date
cargo test --release strategyhandler::tests::test_ultra_strategy_execution --lib -- --nocapture 2>$null
$strategyEnd = Get-Date
$strategyTime = ($strategyEnd - $strategyStart).TotalMilliseconds

Write-Host ""
Write-Host "🔥 Running End-to-End Performance Test..." -ForegroundColor Green
$e2eStart = Get-Date
cargo test --release integration_test_end_to_end_performance --lib -- --nocapture 2>$null
$e2eEnd = Get-Date
$e2eTime = ($e2eEnd - $e2eStart).TotalMilliseconds

Write-Host ""
Write-Host "📊 PERFORMANCE RESULTS" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

# Generate performance report
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportFile = "$resultsDir/performance_report_$timestamp.txt"

$report = @"
SignalEngine Performance Report
Generated: $(Get-Date)
Build Configuration: release-optimized

COMPONENT PERFORMANCE RESULTS:
=============================

SmartOrderRouter:
  • Test Execution Time: $([math]::Round($smartRouterTime, 2))ms
  • Architecture: Lock-free DashMap with atomic routing

SignalGenerator: 
  • Test Execution Time: $([math]::Round($signalGenTime, 2))ms  
  • Architecture: SIMD processing with zero-allocation

SignalDispatcher:
  • Test Execution Time: $([math]::Round($dispatcherTime, 2))ms
  • Architecture: SIMD batch processing

ExecutionHandler:
  • Test Execution Time: $([math]::Round($execTime, 2))ms
  • Architecture: Lock-free execution with CPU affinity

StrategyHandler:
  • Test Execution Time: $([math]::Round($strategyTime, 2))ms
  • Architecture: Pre-allocated buffers with atomic operations

END-TO-END PIPELINE:
==================
  • Total Pipeline Time: $([math]::Round($e2eTime, 2))ms

SYSTEM SPECIFICATIONS:
====================
  • CPU: $(Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name)
  • RAM: $([math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1))GB
  • OS: $($env:OS) $([Environment]::OSVersion.VersionString)
  • Rust Version: $(rustc --version)
  • Build Time: $([math]::Round($buildTime, 2))s

PERFORMANCE SUMMARY:
==================
Measured component times are listed above.

"@

$report | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host ""
Write-Host "📈 Performance Summary:" -ForegroundColor Yellow
Write-Host "   SmartOrderRouter: $([math]::Round($smartRouterTime, 2))ms" -ForegroundColor Green
Write-Host "   SignalGenerator:  $([math]::Round($signalGenTime, 2))ms" -ForegroundColor Green  
Write-Host "   SignalDispatcher: $([math]::Round($dispatcherTime, 2))ms" -ForegroundColor Green
Write-Host "   ExecutionHandler: $([math]::Round($execTime, 2))ms" -ForegroundColor Green
Write-Host "   StrategyHandler:  $([math]::Round($strategyTime, 2))ms" -ForegroundColor Green
Write-Host "   END-TO-END:       $([math]::Round($e2eTime, 2))ms" -ForegroundColor Green

Write-Host ""
Write-Host "Measured times recorded above" -ForegroundColor Green
Write-Host ""

# Memory profiling
Write-Host "🧠 Memory Usage Analysis..." -ForegroundColor Blue
$process = Get-Process -Name "cargo" -ErrorAction SilentlyContinue | Sort-Object WorkingSet64 -Descending | Select-Object -First 1
if ($process) {
    $memoryMB = [math]::Round($process.WorkingSet64 / 1MB, 1)
    Write-Host "   Peak Memory Usage: ${memoryMB}MB" -ForegroundColor Gray
    $report += "`n• Peak Memory Usage: ${memoryMB}MB"
}

Write-Host ""
Write-Host "📄 Report saved to: $reportFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "SignalEngine profile run complete" -ForegroundColor Green
Write-Host "   Profile run complete" -ForegroundColor Gray

# Optional: Open performance report
$openReport = Read-Host "Open performance report? (y/N)"
if ($openReport -eq "y" -or $openReport -eq "Y") {
    Start-Process notepad.exe $reportFile
}

Write-Host ""
Write-Host "⚡ Performance profiling complete!" -ForegroundColor Cyan
