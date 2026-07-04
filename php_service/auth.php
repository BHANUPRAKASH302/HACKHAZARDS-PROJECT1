<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$inputData = file_get_contents("php://input");
$data = json_decode($inputData, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    echo json_encode(["success" => false, "error" => "Invalid JSON"]);
    exit();
}

$action = $data['action'] ?? '';
$usersFile = __DIR__ . '/users.json';

function getUsers() {
    global $usersFile;
    if (!file_exists($usersFile)) return [];
    $content = file_get_contents($usersFile);
    return json_decode($content, true) ?: [];
}

function saveUsers($users) {
    global $usersFile;
    file_put_contents($usersFile, json_encode($users, JSON_PRETTY_PRINT));
}

switch ($action) {
    case 'register':
        $email = strtolower(trim($data['email'] ?? ''));
        $password = $data['password'] ?? '';
        $name = trim($data['name'] ?? 'User');

        if (!$email || !$password) {
            echo json_encode(["success" => false, "error" => "Email and password required"]);
            exit();
        }

        $users = getUsers();
        if (isset($users[$email])) {
            echo json_encode(["success" => false, "error" => "User already exists"]);
            exit();
        }

        // Hashing the password
        $hash = password_hash($password, PASSWORD_BCRYPT);
        
        $users[$email] = [
            "name" => $name,
            "email" => $email,
            "hash" => $hash
        ];
        
        saveUsers($users);
        
        echo json_encode([
            "success" => true,
            "user" => ["name" => $name, "email" => $email]
        ]);
        break;

    case 'login':
        $email = strtolower(trim($data['email'] ?? ''));
        $password = $data['password'] ?? '';

        if (!$email || !$password) {
            echo json_encode(["success" => false, "error" => "Email and password required"]);
            exit();
        }

        $users = getUsers();
        if (!isset($users[$email])) {
            echo json_encode(["success" => false, "error" => "User not found"]);
            exit();
        }

        $user = $users[$email];
        if (password_verify($password, $user['hash'])) {
            echo json_encode([
                "success" => true,
                "user" => ["name" => $user['name'], "email" => $user['email']]
            ]);
        } else {
            echo json_encode(["success" => false, "error" => "Invalid credentials"]);
        }
        break;

    default:
        echo json_encode(["success" => false, "error" => "Unknown action"]);
        break;
}
