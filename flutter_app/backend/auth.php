<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['action'])) {
    echo json_encode(['success' => false, 'message' => 'No action specified']);
    exit;
}

$action = $data['action'];
$usersFile = 'users.json';

// Initialize mock DB
if (!file_exists($usersFile)) {
    file_put_contents($usersFile, json_encode([]));
}

$users = json_decode(file_get_contents($usersFile), true);

if ($action === 'register') {
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';
    $name = $data['name'] ?? 'User';

    if (empty($email) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'Email and password required']);
        exit;
    }

    if (isset($users[$email])) {
        echo json_encode(['success' => false, 'message' => 'User already exists']);
        exit;
    }

    // Hashing password
    $users[$email] = [
        'name' => $name,
        'password' => password_hash($password, PASSWORD_DEFAULT),
    ];

    file_put_contents($usersFile, json_encode($users));
    echo json_encode(['success' => true, 'message' => 'Registration successful', 'user' => ['name' => $name, 'email' => $email]]);
} elseif ($action === 'login') {
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';

    if (empty($email) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'Email and password required']);
        exit;
    }

    if (!isset($users[$email])) {
        echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
        exit;
    }

    if (password_verify($password, $users[$email]['password'])) {
        echo json_encode(['success' => true, 'message' => 'Login successful', 'user' => ['name' => $users[$email]['name'], 'email' => $email]]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid action']);
}
?>
