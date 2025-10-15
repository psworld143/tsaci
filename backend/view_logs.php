#!/usr/bin/env php
<?php
/**
 * Log Viewer - View TSACI API logs
 * Run: php view_logs.php [lines]
 */

$logFile = __DIR__ . '/logs/tsaci.log';
$lines = isset($argv[1]) ? intval($argv[1]) : 50;

if (!file_exists($logFile)) {
    echo "No log file found at: $logFile\n";
    exit(1);
}

echo "================================================================================\n";
echo "TSACI API LOGS (Last $lines lines)\n";
echo "================================================================================\n\n";

// Read last N lines
$file = new SplFileObject($logFile);
$file->seek(PHP_INT_MAX);
$lastLine = $file->key();
$startLine = max(0, $lastLine - $lines);

$file->seek($startLine);
while (!$file->eof()) {
    echo $file->current();
    $file->next();
}

echo "\n================================================================================\n";
echo "Log file location: $logFile\n";
echo "Total lines: " . ($lastLine + 1) . "\n";
echo "================================================================================\n";

