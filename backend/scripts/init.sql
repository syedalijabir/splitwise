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


CREATE TABLE IF NOT EXISTS ExpenseGroups (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    CreatedBy INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CreatedBy) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO ExpenseGroups (Name, CreatedBy) VALUES
('Roommates NYC', 1),
('College Reunion Trip', 2),
('Family Vacation', 3),
('Office Pizza Party', 4);


CREATE TABLE IF NOT EXISTS GroupMembers (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    GroupID INT NOT NULL,
    UserID INT NOT NULL,
    AddedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (GroupID) REFERENCES ExpenseGroups(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (GroupID, UserID)
);

-- Roommates NYC (GroupID = 1)
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(1, 1), (1, 5), (1, 9), (1, 13);

-- College Reunion Trip (GroupID = 2)
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(2, 2), (2, 6), (2, 10), (2, 14);

-- Family Vacation (GroupID = 3)
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(3, 3), (3, 7), (3, 11), (3, 15);

-- Office Pizza Party (GroupID = 4)
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(4, 4), (4, 8), (4, 12), (4, 16);


CREATE TABLE IF NOT EXISTS Friends (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    FriendID INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (FriendID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (UserID, FriendID)
);

-- Alice (1) is friends with Bob (2), Charlie (3), and David (4)
INSERT INTO Friends (UserID, FriendID) VALUES
(1, 2), (2, 1),
(1, 3), (3, 1),
(1, 4), (4, 1);

-- Bob (2) is friends with Eve (5)
INSERT INTO Friends (UserID, FriendID) VALUES
(2, 5), (5, 2);

-- Charlie (3) is friends with Frank (6), Grace (7)
INSERT INTO Friends (UserID, FriendID) VALUES
(3, 6), (6, 3),
(3, 7), (7, 3);

-- David (4) is friends with Henry (8), Isabel (9)
INSERT INTO Friends (UserID, FriendID) VALUES
(4, 8), (8, 4),
(4, 9), (9, 4);

-- Paul (16) and Quinn (17) are also close friends
INSERT INTO Friends (UserID, FriendID) VALUES
(16, 17), (17, 16);


CREATE TABLE IF NOT EXISTS Expenses (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    GroupID INT NOT NULL,
    PaidBy INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Amount DECIMAL(10,2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (GroupID) REFERENCES ExpenseGroups(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PaidBy) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Roommates NYC (GroupID = 1), members: Alice(1), Eve(5), Isabel(9), Mia(13)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount)
VALUES
(1, 1, 'Groceries', 'Weekly groceries from Trader Joes', 120.00),
(1, 5, 'Utilities', 'Electricity and water bill', 80.00),
(1, 9, 'Internet', 'Monthly WiFi charges', 60.00);

-- College Reunion Trip (GroupID = 2), members: Bob(2), Frank(6), Jack(10), Noah(14)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount)
VALUES
(2, 2, 'Hotel Booking', '3 nights stay', 400.00),
(2, 6, 'Dinner', 'Group dinner at restaurant', 160.00),
(2, 10, 'Gas', 'Road trip fuel costs', 80.00);

-- Family Vacation (GroupID = 3), members: Charlie(3), Grace(7), Karen(11), Olivia(15)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount)
VALUES
(3, 3, 'Airbnb', 'Entire home rental', 500.00),
(3, 7, 'Theme Park Tickets', 'Entry for 4 adults', 280.00);

-- Office Pizza Party (GroupID = 4), members: David(4), Henry(8), Liam(12), Paul(16)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount)
VALUES
(4, 4, 'Pizza & Sodas', 'Ordered from Dominos', 100.00),
(4, 8, 'Decorations', 'Balloons, streamers, cups', 40.00);


CREATE TABLE IF NOT EXISTS Settlements (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    GroupID INT NOT NULL,
    FromUserID INT NOT NULL,
    ToUserID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (GroupID) REFERENCES ExpenseGroups(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (FromUserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ToUserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Settlements for Roommates NYC (GroupID = 1)
-- Eve (5) paid Alice (1) back $30
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount)
VALUES (1, 5, 1, 30.00);

-- Isabel (9) paid Alice (1) $30
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount)
VALUES (1, 9, 1, 30.00);

-- Settlements for College Reunion Trip (GroupID = 2)
-- Frank (6) paid Bob (2) $100
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount)
VALUES (2, 6, 2, 100.00);

-- Jack (10) paid Bob (2) $100
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount)
VALUES (2, 10, 2, 100.00);

-- Settlements for Office Pizza Party (GroupID = 4)
-- Liam (12) paid David (4) $20
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount)
VALUES (4, 12, 4, 20.00);

-- Paul (16) paid Henry (8) $10
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount)
VALUES (4, 16, 8, 10.00);

