<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get the current date
$currentDate = date('Y-m-d');

// Define the directory path with the current date
$imageDirectory = '/home/raspberry/final_project/images/' . $currentDate;

// Function to get list of files with specific extensions in a directory
function getFilesInDirectory($directory, $extensions) {
    $files = [];
    $dir = opendir($directory);

    while (($file = readdir($dir)) !== false) {
        if ($file != '.' && $file != '..') {
            $fileInfo = pathinfo($directory . '/' . $file);
            if (isset($fileInfo['extension']) && in_array(strtolower($fileInfo['extension']), $extensions)) {
                $files[] = $file;
            }
        }
    }

    closedir($dir);
    return $files;
}

// Get list of image files (jpg)
$imageFiles = getFilesInDirectory($imageDirectory, ['jpg']);

// Get list of JSON files
$jsonFiles = getFilesInDirectory($imageDirectory, ['json']);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monitoring Data</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        h2 {
            color: #555;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin-bottom: 10px;
        }
        a {
            text-decoration: none;
            color: #007bff;
        }
        a:hover {
            text-decoration: underline;
        }
        .file-list {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Monitoring Data</h1>

        <section class="file-list">
            <h2>Images</h2>
            <ul>
                <?php foreach ($imageFiles as $imageFile): ?>
                    <li><a href="show_file.php?file=<?= urlencode($imageDirectory . '/' . $imageFile) ?>"><?= $imageFile ?></a></li>
                <?php endforeach; ?>
            </ul>
        </section>

        <section class="file-list">
            <h2>JSON Files</h2>
            <ul>
                <?php foreach ($jsonFiles as $jsonFile): ?>
                    <li><a href="show_file.php?file=<?= urlencode($imageDirectory . '/' . $jsonFile) ?>"><?= $jsonFile ?></a></li>
                <?php endforeach; ?>
            </ul>
        </section>

    </div>
</body>
</html>
