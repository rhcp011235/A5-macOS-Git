<?php
// Log all activation attempts to Activations.txt (append mode, never overwrite)
function logActivation($status, $model = null, $build = null) {
    $logFile = __DIR__ . '/Activations.txt';

    // Prepare log entry with all available data
    $logData = [
        'timestamp' => date('Y-m-d H:i:s T'),
        'status' => $status,
        'ip_address' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
        'model' => $model ?? 'unknown',
        'build' => $build ?? 'unknown',
        'request_method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
        'request_uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
        'http_host' => $_SERVER['HTTP_HOST'] ?? 'unknown',
        'server_name' => $_SERVER['SERVER_NAME'] ?? 'unknown',
        'server_port' => $_SERVER['SERVER_PORT'] ?? 'unknown',
    ];

    // Parse iOS version from User-Agent if available
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
    if (preg_match('/iOS\/([0-9.]+)/', $userAgent, $iosMatches)) {
        $logData['ios_version'] = $iosMatches[1];
    } else {
        $logData['ios_version'] = 'unknown';
    }

    // Parse hardware platform if available
    if (preg_match('/hwp\/([a-zA-Z0-9]+)/', $userAgent, $hwpMatches)) {
        $logData['hardware_platform'] = $hwpMatches[1];
    } else {
        $logData['hardware_platform'] = 'unknown';
    }

    // Format log entry
    $logEntry = str_repeat('=', 80) . "\n";
    $logEntry .= "ACTIVATION ATTEMPT - " . $logData['timestamp'] . "\n";
    $logEntry .= str_repeat('=', 80) . "\n";
    $logEntry .= "Status: " . $logData['status'] . "\n";
    $logEntry .= "Device Model: " . $logData['model'] . "\n";
    $logEntry .= "iOS Build: " . $logData['build'] . "\n";
    $logEntry .= "iOS Version: " . $logData['ios_version'] . "\n";
    $logEntry .= "Hardware Platform: " . $logData['hardware_platform'] . "\n";
    $logEntry .= "IP Address: " . $logData['ip_address'] . "\n";
    $logEntry .= "Request Method: " . $logData['request_method'] . "\n";
    $logEntry .= "Request URI: " . $logData['request_uri'] . "\n";
    $logEntry .= "HTTP Host: " . $logData['http_host'] . "\n";
    $logEntry .= "Server: " . $logData['server_name'] . ":" . $logData['server_port'] . "\n";
    $logEntry .= "User-Agent: " . $logData['user_agent'] . "\n";

    // Add all HTTP headers for complete logging
    $logEntry .= "\nAll HTTP Headers:\n";
    foreach ($_SERVER as $key => $value) {
        if (strpos($key, 'HTTP_') === 0) {
            $headerName = str_replace('HTTP_', '', $key);
            $headerName = str_replace('_', '-', $headerName);
            $logEntry .= "  $headerName: $value\n";
        }
    }

    $logEntry .= "\n";

    // Append to log file (never overwrite)
    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';

$model = null;
$build = null;

if (preg_match('/model\/([a-zA-Z0-9,]+)/', $userAgent, $mMatches)) {
    $model = $mMatches[1];
}

if (preg_match('/build\/([a-zA-Z0-9]+)/', $userAgent, $bMatches)) {
    $build = $bMatches[1];
}

if ($model && $build) {
    if (strpos($model, '..') !== false || strpos($build, '..') !== false) {
        logActivation('FORBIDDEN - Path traversal attempt', $model, $build);
        http_response_code(403);
        exit();
    }

    $baseDir = __DIR__ . '/plists';
    $filePath = $baseDir . '/' . $model . '/' . $build . '/patched.plist';

    if (file_exists($filePath)) {
        logActivation('SUCCESS - Plist sent', $model, $build);

        header('Content-Description: File Transfer');
        header('Content-Type: application/xml');
        header('Content-Disposition: attachment; filename="patched.plist"');
        header('Content-Length: ' . filesize($filePath));
        header('Cache-Control: must-revalidate');
        header('Pragma: public');

        readfile($filePath);
        exit();
    } else {
        logActivation('NOT FOUND - Plist missing for model/build', $model, $build);
    }
} else {
    logActivation('FORBIDDEN - Invalid or missing model/build', $model, $build);
}

http_response_code(403);
echo "Forbidden";
exit();
?>