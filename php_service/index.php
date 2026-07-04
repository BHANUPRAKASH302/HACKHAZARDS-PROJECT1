<?php
// Set CORS headers for local/cross-origin requests
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle OPTIONS preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Ensure the request is a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Only POST requests are allowed"]);
    exit();
}

// Retrieve raw request body data
$inputData = file_get_contents("php://input");
$data = json_decode($inputData, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    echo json_encode(["error" => "Invalid JSON payload"]);
    exit();
}

$action = isset($data['action']) ? $data['action'] : '';

if (empty($action)) {
    http_response_code(400);
    echo json_encode(["error" => "Field 'action' is required (hash or verify)"]);
    exit();
}

// ----------------------------------------------------
// Core Hashing Operations
// ----------------------------------------------------
switch ($action) {
    case 'hash':
        $password = isset($data['password']) ? $data['password'] : '';
        if (empty($password)) {
            http_response_code(400);
            echo json_encode(["error" => "Field 'password' is required for hashing"]);
            exit();
        }

        // Hash using standard bcrypt (default algorithm in PHP 8)
        $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 10]);

        if ($hash === false) {
            http_response_code(500);
            echo json_encode(["error" => "Password hashing failed"]);
            exit();
        }

        echo json_encode([
            "success" => true,
            "hash" => $hash,
            "algorithm" => "bcrypt"
        ]);
        break;

    case 'verify':
        $password = isset($data['password']) ? $data['password'] : '';
        $hash = isset($data['hash']) ? $data['hash'] : '';

        if (empty($password) || empty($hash)) {
            http_response_code(400);
            echo json_encode(["error" => "Fields 'password' and 'hash' are required for verification"]);
            exit();
        }

        $verified = password_verify($password, $hash);

        echo json_encode([
            "success" => true,
            "verified" => $verified
        ]);
        break;

    default:
        http_response_code(400);
        echo json_encode(["error" => "Unknown action: '$action'. Supported: 'hash', 'verify'"]);
        break;
}
