DROP DATABASE IF EXISTS splitwise;
CREATE DATABASE splitwise;
USE splitwise;

CREATE TABLE IF NOT EXISTS Users (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SET @default_pass_hash = '$2b$12$4XVdB/KN5xT18YB7/RVdyePZXC4c7j2IoF1dPhdmHORAYe.zqbO7W';

INSERT INTO Users (FirstName, LastName, Email, PasswordHash) VALUES
('Alice', 'Smith', 'alice@example.com', @default_pass_hash),
('Bob', 'Johnson', 'bob@example.com', @default_pass_hash),
('Charlie', 'Rose', 'charlie@example.com', @default_pass_hash),
('David', 'Green', 'david@example.com', @default_pass_hash),
('Eve', 'Black', 'eve@example.com', @default_pass_hash),
('Frank', 'Harris', 'frank@example.com', @default_pass_hash),
('Grace', 'Lee', 'grace@example.com', @default_pass_hash),
('Henry', 'Clark', 'henry@example.com', @default_pass_hash),
('Isabel', 'Young', 'isabel@example.com', @default_pass_hash),
('Jack', 'White', 'jack@example.com', @default_pass_hash),
('Karen', 'Hall', 'karen@example.com', @default_pass_hash),
('Liam', 'King', 'liam@example.com', @default_pass_hash),
('Mia', 'Scott', 'mia@example.com', @default_pass_hash),
('Noah', 'Adams', 'noah@example.com', @default_pass_hash),
('Olivia', 'Baker', 'olivia@example.com', @default_pass_hash),
('Paul', 'Turner', 'paul@example.com', @default_pass_hash),
('Quinn', 'Bell', 'quinn@example.com', @default_pass_hash),
('Rachel', 'Evans', 'rachel@example.com', @default_pass_hash),
('Samuel', 'Reed', 'samuel@example.com', @default_pass_hash),
('Tina', 'Collins', 'tina@example.com', @default_pass_hash),
('Victor', 'Brooks', 'victor@example.com', @default_pass_hash),
('Wendy', 'Price', 'wendy@example.com', @default_pass_hash),
('Xavier', 'Long', 'xavier@example.com', @default_pass_hash),
('Yvonne', 'Ward', 'yvonne@example.com', @default_pass_hash),
('Zachary', 'Foster', 'zachary@example.com', @default_pass_hash),
('Amanda', 'Gray', 'amanda@example.com', @default_pass_hash),
('Benjamin', 'Hayes', 'benjamin@example.com', @default_pass_hash),
('Cynthia', 'Wood', 'cynthia@example.com', @default_pass_hash),
('Daniel', 'Simmons', 'daniel@example.com', @default_pass_hash),
('Emily', 'Bryant', 'emily@example.com', @default_pass_hash),
('Frederick', 'Russell', 'frederick@example.com', @default_pass_hash),
('Gloria', 'Patterson', 'gloria@example.com', @default_pass_hash),
('Harold', 'Hughes', 'harold@example.com', @default_pass_hash),
('Irene', 'Sanders', 'irene@example.com', @default_pass_hash),
('Jason', 'Bennett', 'jason@example.com', @default_pass_hash),
('Katherine', 'Rivera', 'katherine@example.com', @default_pass_hash),
('Lawrence', 'Coleman', 'lawrence@example.com', @default_pass_hash),
('Melissa', 'Stewart', 'melissa@example.com', @default_pass_hash),
('Nathan', 'Morris', 'nathan@example.com', @default_pass_hash),
('Ophelia', 'Murphy', 'ophelia@example.com', @default_pass_hash);

CREATE TABLE IF NOT EXISTS Categories (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO Categories (Name) VALUES 
('Food'),
('Travel'),
('Rent'),
('Utilities'),
('Entertainment'),
('Groceries'),
('Health'),
('Education'),
('Miscellaneous');


CREATE TABLE IF NOT EXISTS ExpenseGroups (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    CreatedBy INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CreatedBy) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX created_by ON ExpenseGroups(CreatedBy);

CREATE TABLE IF NOT EXISTS GroupMembers (
    GroupID INT NOT NULL,
    UserID INT NOT NULL,
    AddedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (GroupID, UserID),
    FOREIGN KEY (GroupID) REFERENCES ExpenseGroups(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO ExpenseGroups (Name, CreatedBy, CreatedAt) VALUES
('Roommates NYC', 1, '2024-01-01 10:00:00'),
('College Reunion Trip', 2, '2024-02-01 11:00:00'),
('Family Vacation', 3, '2024-08-12 02:37:00'),
('Office Pizza Party', 4, '2024-11-11 11:45:00');


INSERT INTO ExpenseGroups (Name, CreatedBy, CreatedAt) VALUES
('Summer Music Festival', 5, '2024-05-15 09:30:00'),
('Book Club', 10, '2024-03-10 18:00:00'),
('Weekend Hiking Crew', 15, '2024-04-20 07:15:00'),
('Fantasy Football League', 7, '2024-09-01 19:00:00'),
('Wedding Planning Committee', 12, '2024-06-15 12:30:00'),
('Startup Investment Group', 19, '2024-07-20 15:45:00'),
('Gourmet Cooking Club', 25, '2024-03-05 17:00:00'),
('Tech Conference 2024', 30, '2024-10-10 08:00:00'),
('Beach House Weekend', 35, '2024-05-25 09:00:00'),
('Photography Enthusiasts', 8, '2024-04-18 16:20:00'),
('Volunteer Cleanup Crew', 16, '2024-02-14 07:00:00'),
('Language Exchange', 23, '2024-01-30 20:00:00'),
('Ski Trip 2025', 37, '2024-12-01 10:30:00');

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

-- Additional
-- Alice Smith (1) is already in Roommates NYC (1), her friends include Bob (2), Charlie (3), and David (4)
-- All three are in different groups, so we can add Alice to those groups
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(2, 1),  -- Alice joins Bob's group
(3, 1),  -- Alice joins Charlie's group
(4, 1);  -- Alice joins David's group

-- Bob Johnson (2) is already in College Reunion Trip (2), is friends with Alice (1) and Eve (5)
-- Alice is in Group 1, so Bob can join it
-- Eve is not in any group Bob isn't already in, skip for now
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(1, 2);

-- Charlie Rose (3) is in Family Vacation (3), friends with Alice (1), Frank (6), Grace (7)
-- Alice is in 1 and 2, Frank and Grace aren't yet shared in groups
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(1, 3),  -- With Alice
(2, 3);  -- With Alice again

-- David Green (4) is in Office Pizza Party (4), friends with Alice (1), Henry (8), Isabel (9)
-- Alice is in 1–4, so David can join 1–3
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(1, 4), (2, 4), (3, 4);

-- Grace Lee (7) is friends with Charlie (3), in 2 and 3
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(2, 7);

-- Henry Clark (8) is friends with David (4), David is in 1–4 now
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(1, 8), (2, 8);

-- Isabel Young (9) is friends with David (4)
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(2, 9), (3, 9);

-- Quinn Bell (17) is friends with Paul (16), Paul is in Office Pizza Party (4)
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(4, 17);

-- Now add members to each group (using the correct GroupIDs)
-- GroupID 5: Summer Music Festival
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(5, 5), (5, 1), (5, 9), (5, 13), (5, 17), (5, 21), (5, 25), (5, 29);

-- GroupID 6: Book Club
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(6, 10), (6, 2), (6, 6), (6, 14), (6, 18), (6, 22), (6, 26), (6, 30);

-- GroupID 7: Weekend Hiking Crew
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(7, 15), (7, 3), (7, 7), (7, 11), (7, 19), (7, 23), (7, 27), (7, 31);

-- GroupID 8: Fantasy Football League
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(8, 7), (8, 2), (8, 10), (8, 15), (8, 22), (8, 27);

-- GroupID 9: Wedding Planning Committee
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(9, 12), (9, 3), (9, 9), (9, 17), (9, 24);

-- GroupID 10: Startup Investment Group
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(10, 19), (10, 4), (10, 11), (10, 21), (10, 29), (10, 36);

-- GroupID 11: Gourmet Cooking Club
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(11, 25), (11, 5), (11, 13), (11, 20), (11, 32);

-- GroupID 12: Tech Conference 2024
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(12, 30), (12, 6), (12, 14), (12, 23), (12, 31), (12, 38);

-- GroupID 13: Beach House Weekend
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(13, 35), (13, 1), (13, 8), (13, 18), (13, 26);

-- GroupID 14: Photography Enthusiasts
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(14, 8), (14, 16), (14, 24), (14, 33), (14, 40);

-- GroupID 15: Volunteer Cleanup Crew
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(15, 16), (15, 7), (15, 19), (15, 28);

-- GroupID 16: Language Exchange
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(16, 23), (16, 11), (16, 17), (16, 29), (16, 34), (16, 37);

-- GroupID 17: Ski Trip 2025
INSERT INTO GroupMembers (GroupID, UserID) VALUES
(17, 37), (17, 9), (17, 20), (17, 27), (17, 35), (17, 39);

CREATE TABLE IF NOT EXISTS Friends (
    UserID INT NOT NULL,
    FriendID INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (UserID, FriendID),
    FOREIGN KEY (UserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (FriendID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE
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

-- Now add the friend relationships (same as before)
-- Football friends
INSERT INTO Friends (UserID, FriendID) VALUES
(7, 27), (27, 7), (10, 22), (22, 10);

-- Wedding planning friends
INSERT INTO Friends (UserID, FriendID) VALUES
(12, 17), (17, 12), (3, 24), (24, 3);

-- Startup connections
INSERT INTO Friends (UserID, FriendID) VALUES
(19, 29), (29, 19), (4, 36), (36, 4);

-- Cooking buddies
INSERT INTO Friends (UserID, FriendID) VALUES
(25, 32), (32, 25), (13, 20), (20, 13);

-- Tech conference colleagues
INSERT INTO Friends (UserID, FriendID) VALUES
(30, 38), (38, 30), (14, 31), (31, 14);

-- Beach house friends
INSERT INTO Friends (UserID, FriendID) VALUES
(35, 26), (26, 35), (1, 18), (18, 1);

-- Photography connections
INSERT INTO Friends (UserID, FriendID) VALUES
(16, 40), (40, 16), (8, 33), (33, 8);

-- Volunteer friends
INSERT INTO Friends (UserID, FriendID) VALUES
(16, 28), (28, 16), (7, 19), (19, 7);

-- Language partners
INSERT INTO Friends (UserID, FriendID) VALUES
(23, 34), (34, 23), (17, 37), (37, 17);

-- Ski trip buddies
INSERT INTO Friends (UserID, FriendID) VALUES
(37, 39), (39, 37), (9, 35), (35, 9);


CREATE TABLE IF NOT EXISTS Expenses (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    GroupID INT NOT NULL,
    PaidBy INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    CategoryID INT NOT NULL DEFAULT 9, -- default misc.
    Amount DECIMAL(10,2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (GroupID) REFERENCES ExpenseGroups(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PaidBy) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX group_id ON Expenses (GroupID);
CREATE INDEX paid_by ON Expenses (PaidBy);
CREATE INDEX category_id ON Expenses (CategoryID);

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

-- Expenses for Summer Music Festival (GroupID = 5)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(5, 5, 'Weekend Passes', 'General admission tickets for all', 600.00, '2024-05-20 09:15:00'),
(5, 21, 'Airbnb Rental', 'Shared house near festival', 800.00, '2024-05-22 14:30:00'),
(5, 1, 'Group Dinner', 'Pre-festival meal at local bistro', 180.00, '2024-05-23 19:00:00');

-- Expenses for Book Club (GroupID = 6)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(6, 10, 'Book Purchases', 'Monthly selections for all members', 150.00, '2024-03-12 11:20:00'),
(6, 22, 'Coffee & Snacks', 'Meeting refreshments', 45.00, '2024-03-15 18:45:00'),
(6, 14, 'Author Event Tickets', 'Local book signing event', 75.00, '2024-03-20 10:00:00');

-- Expenses for Weekend Hiking Crew (GroupID = 7)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(7, 15, 'Cabin Rental', 'Mountain lodge for weekend', 350.00, '2024-04-25 08:00:00'),
(7, 23, 'Trail Permits', 'Park access fees', 60.00, '2024-04-26 07:30:00'),
(7, 31, 'Group Supplies', 'First aid kits and maps', 85.00, '2024-04-27 09:15:00');

-- Expenses for Fantasy Football League (GroupID = 8)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(8, 7, 'League Fees', 'Entry fees for all players', 250.00, '2024-09-05 20:15:00'),
(8, 27, 'Draft Party', 'Food and drinks for draft night', 120.00, '2024-09-10 19:30:00'),
(8, 10, 'Trophy & Prizes', 'Championship rewards', 150.00, '2024-09-15 16:45:00');

-- Expenses for Wedding Planning Committee (GroupID = 9)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(9, 12, 'Bridal Shower Venue', 'Deposit for event space', 500.00, '2024-06-18 12:00:00'),
(9, 24, 'Decor Samples', 'Test centerpieces and linens', 175.00, '2024-06-20 15:30:00'),
(9, 3, 'Catering Tasting', 'Food sampling for selection', 200.00, '2024-06-25 13:45:00');

-- Expenses for Startup Investment Group (GroupID = 10)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(10, 19, 'Conference Tickets', 'Tech startup summit passes', 900.00, '2024-07-25 09:00:00'),
(10, 29, 'Meeting Space', 'Monthly coworking rental', 300.00, '2024-08-01 14:15:00'),
(10, 4, 'Legal Consultation', 'Startup incorporation advice', 450.00, '2024-08-05 11:30:00');

-- Expenses for Gourmet Cooking Club (GroupID = 11)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(11, 25, 'Ingredients', 'Specialty items for French menu', 180.00, '2024-03-10 16:20:00'),
(11, 32, 'Wine Pairings', 'Selection for 5-course meal', 150.00, '2024-03-12 18:45:00'),
(11, 5, 'Cooking Tools', 'Shared equipment purchase', 90.00, '2024-03-15 15:30:00');

-- Expenses for Tech Conference 2024 (GroupID = 12)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(12, 30, 'Conference Passes', 'Early bird registration', 1200.00, '2024-10-01 08:00:00'),
(12, 23, 'Hotel Rooms', 'Shared accommodations', 750.00, '2024-10-05 14:20:00'),
(12, 38, 'Transportation', 'Airport transfers and taxis', 180.00, '2024-10-10 09:45:00');

-- Expenses for Beach House Weekend (GroupID = 13)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(13, 35, 'Beach Rental', 'Oceanfront house deposit', 1200.00, '2024-05-28 10:00:00'),
(13, 1, 'Groceries', 'Weekend food supplies', 250.00, '2024-06-01 12:30:00'),
(13, 26, 'Boat Rental', 'Half-day fishing excursion', 300.00, '2024-06-02 08:15:00');

-- Expenses for Photography Enthusiasts (GroupID = 14)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(14, 8, 'Workshop Fees', 'Professional lighting class', 200.00, '2024-04-20 09:00:00'),
(14, 40, 'Model Fees', 'Compensation for portrait session', 150.00, '2024-04-25 18:30:00'),
(14, 16, 'Printing Costs', 'Exhibition quality prints', 120.00, '2024-04-28 14:15:00');

-- Expenses for Volunteer Cleanup Crew (GroupID = 15)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(15, 16, 'Supplies', 'Gloves, bags, and tools', 80.00, '2024-02-16 07:30:00'),
(15, 28, 'T-Shirts', 'Team volunteer shirts', 120.00, '2024-02-18 10:45:00'),
(15, 7, 'Lunch', 'Post-cleanup meal for team', 60.00, '2024-02-20 12:00:00');

-- Expenses for Language Exchange (GroupID = 16)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(16, 23, 'Textbooks', 'Learning materials', 90.00, '2024-02-05 19:00:00'),
(16, 34, 'Meeting Space', 'Coffee shop minimums', 75.00, '2024-02-12 17:30:00'),
(16, 11, 'Cultural Event', 'International film screening', 50.00, '2024-02-20 18:45:00');

-- Expenses for Ski Trip 2025 (GroupID = 17)
INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount, CreatedAt) VALUES
(17, 37, 'Lift Tickets', 'Weekend passes for group', 600.00, '2024-12-05 08:00:00'),
(17, 20, 'Equipment Rental', 'Skis and snowboards', 350.00, '2024-12-06 09:30:00'),
(17, 35, 'Lodge Dinner', 'Group apres-ski meal', 220.00, '2024-12-06 19:00:00');

CREATE TABLE IF NOT EXISTS PaymentMethods (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Type VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO PaymentMethods (Type) VALUES
('Cash'),
('Credit Card'),
('Debit Card'),
('PayPal'),
('Bank Transfer'),
('Venmo'),
('Zelle');


CREATE TABLE IF NOT EXISTS Settlements (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    GroupID INT NOT NULL,
    FromUserID INT NOT NULL,
    ToUserID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PMID INT NOT NULL DEFAULT 7,
    FOREIGN KEY (GroupID) REFERENCES ExpenseGroups(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (FromUserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ToUserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PMID) REFERENCES PaymentMethods(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX group_id ON Settlements (GroupID);
CREATE INDEX from_user ON Settlements (FromUserID);
CREATE INDEX to_user ON Settlements (ToUserID);
CREATE INDEX payment_method ON Settlements (PMID);

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

-- Settlements for Summer Music Festival (GroupID = 5)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(5, 1, 5, 150.00, '2024-05-25 10:30:00'),
(5, 9, 21, 200.00, '2024-05-26 11:45:00'),
(5, 13, 1, 45.00, '2024-05-27 09:15:00');

-- Settlements for Book Club (GroupID = 6)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(6, 2, 10, 37.50, '2024-03-16 12:00:00'),
(6, 6, 22, 15.00, '2024-03-17 13:30:00'),
(6, 18, 14, 18.75, '2024-03-18 14:45:00');

-- Settlements for Weekend Hiking Crew (GroupID = 7)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(7, 3, 15, 87.50, '2024-04-28 08:00:00'),
(7, 7, 23, 15.00, '2024-04-29 09:30:00'),
(7, 19, 31, 21.25, '2024-04-30 10:45:00');

-- Settlements for Fantasy Football League (GroupID = 8)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(8, 2, 7, 62.50, '2024-09-12 21:00:00'),
(8, 15, 27, 30.00, '2024-09-13 22:15:00'),
(8, 22, 10, 37.50, '2024-09-14 20:30:00');

-- Settlements for Wedding Planning Committee (GroupID = 9)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(9, 17, 12, 125.00, '2024-06-22 14:00:00'),
(9, 3, 24, 43.75, '2024-06-23 15:30:00'),
(9, 9, 3, 50.00, '2024-06-26 16:45:00');

-- Settlements for Startup Investment Group (GroupID = 10)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(10, 11, 19, 225.00, '2024-07-28 10:00:00'),
(10, 21, 29, 75.00, '2024-08-03 11:30:00'),
(10, 36, 4, 112.50, '2024-08-08 12:45:00');

-- Settlements for Gourmet Cooking Club (GroupID = 11)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(11, 13, 25, 45.00, '2024-03-16 17:00:00'),
(11, 20, 32, 37.50, '2024-03-17 18:30:00'),
(11, 5, 25, 22.50, '2024-03-18 19:45:00');

-- Settlements for Tech Conference 2024 (GroupID = 12)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(12, 6, 30, 300.00, '2024-10-03 09:00:00'),
(12, 14, 23, 187.50, '2024-10-08 10:30:00'),
(12, 31, 38, 45.00, '2024-10-12 11:45:00');

-- Settlements for Beach House Weekend (GroupID = 13)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(13, 8, 35, 300.00, '2024-06-03 11:00:00'),
(13, 18, 1, 62.50, '2024-06-04 12:30:00'),
(13, 26, 35, 75.00, '2024-06-05 13:45:00');

-- Settlements for Photography Enthusiasts (GroupID = 14)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(14, 24, 8, 50.00, '2024-04-22 10:00:00'),
(14, 33, 40, 37.50, '2024-04-27 11:30:00'),
(14, 16, 8, 30.00, '2024-04-30 12:45:00');

-- Settlements for Volunteer Cleanup Crew (GroupID = 15)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(15, 19, 16, 20.00, '2024-02-17 08:30:00'),
(15, 28, 16, 30.00, '2024-02-19 09:45:00'),
(15, 7, 28, 15.00, '2024-02-21 11:00:00');

-- Settlements for Language Exchange (GroupID = 16)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(16, 17, 23, 22.50, '2024-02-08 20:00:00'),
(16, 29, 34, 18.75, '2024-02-14 18:30:00'),
(16, 37, 11, 12.50, '2024-02-22 19:45:00');

-- Settlements for Ski Trip 2025 (GroupID = 17)
INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount, CreatedAt) VALUES
(17, 9, 37, 150.00, '2024-12-08 09:00:00'),
(17, 27, 20, 87.50, '2024-12-09 10:30:00'),
(17, 39, 35, 55.00, '2024-12-10 11:45:00');


CREATE TABLE Notifications (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    Type ENUM('invite', 'expense_update', 'settlement') NOT NULL,
    GroupID INT NOT NULL,
    Message TEXT NOT NULL,
    IsRead BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (GroupID) REFERENCES ExpenseGroups(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX userid ON Notifications (UserID);
CREATE INDEX userid_isread ON Notifications (UserID, IsRead);

CREATE TABLE ActivityFeed (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    GroupID INT NOT NULL,
    UserID INT NOT NULL,
    ActionType ENUM('created_expense', 'updated_expense', 'settled_debt', 'joined_group') NOT NULL,
    Description TEXT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (GroupID) REFERENCES ExpenseGroups(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX userid ON ActivityFeed (UserID);
CREATE INDEX groupid_createdat ON ActivityFeed (GroupID, CreatedAt DESC);
