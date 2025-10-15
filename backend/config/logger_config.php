<?php
/**
 * Logger Configuration
 */

require_once __DIR__ . '/../helpers/logger.php';

// Enable logging
Logger::setEnabled(true);

// Set log file
Logger::setLogFile(__DIR__ . '/../logs/tsaci.log');

