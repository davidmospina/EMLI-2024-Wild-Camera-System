<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get the filename from the query parameter
$file = urldecode($_GET['file']);

// Check if the file exists
if (file_exists($file)) {
    // Set appropriate headers based on the file type
    $file_extension = strtolower(pathinfo($file, PATHINFO_EXTENSION));
    if ($file_extension === 'jpg') {
        header('Content-Type: image/jpeg');
    } elseif ($file_extension === 'json') {
        header('Content-Type: application/json');
    }

    // Output the content of the file
    readfile($file);
} else {
    // File not found, return a 404 error
    http_response_code(404);
    echo "File not found";
}
?>
