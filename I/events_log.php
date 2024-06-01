<?php
// Define the path to the log file
$logFile = '/home/raspberry/final_project/log/log_events.txt';

// Read the file content
$logContent = file_get_contents($logFile);

// Split the content by new lines
$logLines = explode("\n", trim($logContent));

// Initialize an array to store log entries
$logEntries = [];

// Process each line
foreach ($logLines as $line) {
    // Skip empty lines
    if (trim($line) === '') continue;

    // Split the line into components
    list($date, $epoch, $message) = explode(',', $line);

    // Trim whitespace from components
    $date = trim($date);
    $epoch = trim($epoch);
    $message = trim($message);

    // Add the log entry to the array
    $logEntries[] = [
        'date' => $date,
        'epoch' => $epoch,
        'message' => $message
    ];
}

// Sort log entries by epoch
usort($logEntries, function($a, $b) {
    return $a['epoch'] <=> $b['epoch'];
});

// Function to generate a light color based on a string
function generateLightColor($string) {
    $hash = substr(md5($string), 0, 6);
    $r = hexdec(substr($hash, 0, 2)) % 128 + 128; // Ensure light color range
    $g = hexdec(substr($hash, 2, 2)) % 128 + 128;
    $b = hexdec(substr($hash, 4, 2)) % 128 + 128;
    return sprintf('#%02X%02X%02X', $r, $g, $b);
}

// Function to determine if a color is light or dark
function isLightColor($color) {
    $r = hexdec(substr($color, 1, 2));
    $g = hexdec(substr($color, 3, 2));
    $b = hexdec(substr($color, 5, 2));
    // Calculate luminance
    $luminance = 0.299 * $r + 0.587 * $g + 0.114 * $b;
    return $luminance > 186; // Threshold for deciding light/dark text
}

// HTML output
echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log Events</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 8px;
            text-align: left;
        }
    </style>
</head>
<body>
    <h1>Log Events</h1>
    <table>
        <tr>
            <th>Date</th>
            <th>Epoch</th>
            <th>Message</th>
        </tr>';

// Output each log entry, keeping the same color for the same message
foreach ($logEntries as $entry) {
    $color = generateLightColor($entry['message']);
    $textColor = isLightColor($color) ? 'black' : 'white';
    echo '<tr style="background-color:' . htmlspecialchars($color) . '; color:' . htmlspecialchars($textColor) . ';">
            <td>' . htmlspecialchars($entry['date']) . '</td>
            <td>' . htmlspecialchars($entry['epoch']) . '</td>
            <td>' . htmlspecialchars($entry['message']) . '</td>
          </tr>';
}

echo '    </table>
</body>
</html>';
?>
