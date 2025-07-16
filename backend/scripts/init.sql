DROP DATABASE IF EXISTS splitwise;
CREATE DATABASE splitwise;
USE splitwise;

CREATE TABLE IF NOT EXISTS Users (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SET @default_pass_hash = '$2b$12$4XVdB/KN5xT18YB7/RVdyePZXC4c7j2IoF1dPhdmHORAYe.zqbO7W';

INSERT INTO Users (Name, Email, PasswordHash) VALUES
('Alice Smith', 'alice@example.com', @default_pass_hash),
('Bob Johnson', 'bob@example.com', @default_pass_hash),
('Charlie Rose', 'charlie@example.com', @default_pass_hash),
('David Green', 'david@example.com', @default_pass_hash),
('Eve Black', 'eve@example.com', @default_pass_hash),
('Frank Harris', 'frank@example.com', @default_pass_hash),
('Grace Lee', 'grace@example.com', @default_pass_hash),
('Henry Clark', 'henry@example.com', @default_pass_hash),
('Isabel Young', 'isabel@example.com', @default_pass_hash),
('Jack White', 'jack@example.com', @default_pass_hash),
('Karen Hall', 'karen@example.com', @default_pass_hash),
('Liam King', 'liam@example.com', @default_pass_hash),
('Mia Scott', 'mia@example.com', @default_pass_hash),
('Noah Adams', 'noah@example.com', @default_pass_hash),
('Olivia Baker', 'olivia@example.com', @default_pass_hash),
('Paul Turner', 'paul@example.com', @default_pass_hash),
('Quinn Bell', 'quinn@example.com', @default_pass_hash),
('Rachel Evans', 'rachel@example.com', @default_pass_hash),
('Samuel Reed', 'samuel@example.com', @default_pass_hash),
('Tina Collins', 'tina@example.com', @default_pass_hash);
