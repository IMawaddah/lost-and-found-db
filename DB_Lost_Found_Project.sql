-- 1. Create the Database
CREATE DATABASE UQU_LostAndFound_DB;
USE UQU_LostAndFound_DB;

-- 2. Create Staff Table (Personnel responsible for approvals/verification)
CREATE TABLE Staff (
    Staff_ID INT PRIMARY KEY,               -- Primary Key: Unique Staff Identifier
    Staff_Name VARCHAR(100) NOT NULL,       -- Staff Name (Mandatory)
    Staff_Email VARCHAR(100) UNIQUE NOT NULL -- Staff Email (Must be unique and mandatory)
);

-- 3. Create User Table (Users responsible for reporting/registering items)
CREATE TABLE User (
    User_ID INT PRIMARY KEY,                -- Primary Key: Unique User Identifier
    Name VARCHAR(100) NOT NULL,             -- User Name (Mandatory)
    Email VARCHAR(100) UNIQUE NOT NULL      -- User Email (Must be unique and mandatory)
);

-- 4. Create User_Role Table (Junction table for User M:N Role relationship)
-- Note: This table implements the required composite Primary Key (Role, User_ID)
CREATE TABLE User_Role (
    User_ID INT NOT NULL,
    Role VARCHAR(50) NOT NULL,              -- e.g., 'Reporter', 'Registrar'
    
    -- Applying the required composite Primary Key
    PRIMARY KEY (User_ID, Role),
    
    -- Foreign Key reference to the User table
    FOREIGN KEY (User_ID) REFERENCES User(User_ID)
        ON DELETE CASCADE,

    -- CONSTRAINT: Ensure the role is restricted to specific valid types
    CONSTRAINT CHK_User_Role CHECK (Role IN ('Reporter', 'Registrar'))
);

-- 5. Create Lost_Item Table (Items reported as lost)
CREATE TABLE Lost_Item (
    Item_ID INT PRIMARY KEY,
    Item_Name VARCHAR(100) NOT NULL,
    Description VARCHAR(255),
    Location_Lost VARCHAR(100) NOT NULL,
    Date_Lost DATE NOT NULL,
    Status VARCHAR(50) NOT NULL,            -- e.g., 'Reported', 'Approved', 'Matched'
    User_ID INT NOT NULL,                   -- Foreign Key: User who reported the item
    Staff_ID INT,                           -- Foreign Key: Staff who approved the report (can be NULL initially)
    
    FOREIGN KEY (User_ID) REFERENCES User(User_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID),

    -- CONSTRAINT: Ensure the status is one of the valid workflow steps
    CONSTRAINT CHK_Lost_Status CHECK (Status IN ('Reported', 'Approved', 'Matched'))
);

-- 6. Create Found_Item Table (Items registered as found)
CREATE TABLE Found_Item (
    Found_ID INT PRIMARY KEY,
    Item_Name VARCHAR(100) NOT NULL,
    Description VARCHAR(255),
    Location_Found VARCHAR(100) NOT NULL,
    Date_Found DATE NOT NULL,
    Status VARCHAR(50) NOT NULL,            -- e.g., 'Registered', 'Verified', 'Matched'
    User_ID INT NOT NULL,                   -- Foreign Key: User who registered the item
    Staff_ID INT,                           -- Foreign Key: Staff who verified the item (can be NULL initially)

    FOREIGN KEY (User_ID) REFERENCES User(User_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID),

    -- CONSTRAINT: Ensure the status is one of the valid workflow steps
    CONSTRAINT CHK_Found_Status CHECK (Status IN ('Registered', 'Verified', 'Matched'))
);

-- 7. Create Match_Record Table (Record of successful item matches)
CREATE TABLE Match_Record (
    Match_ID INT PRIMARY KEY,
    Match_Date DATE NOT NULL,
    Match_Status VARCHAR(50) NOT NULL,      -- e.g., 'Confirmed', 'Pending'
    Found_ID INT NOT NULL UNIQUE,           -- Foreign Key: Linked Found Item (UNIQUE as a found item is part of only one definitive match record)
    Item_ID INT NOT NULL UNIQUE,            -- Foreign Key: Linked Lost Item (UNIQUE as a lost item is part of only one definitive match record)
    Staff_ID INT NOT NULL,                  -- Foreign Key: Staff who confirmed the match

    FOREIGN KEY (Found_ID) REFERENCES Found_Item(Found_ID),
    FOREIGN KEY (Item_ID) REFERENCES Lost_Item(Item_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
);

-- Insert 5 records into Staff
INSERT INTO Staff (Staff_ID, Staff_Name, Staff_Email) VALUES
(101, 'Alex Morgan', 'alex.morgan@example.edu'),
(102, 'Sam Carter', 'sam.carter@example.edu'),
(103, 'Drew Hayes', 'drew.hayes@example.edu'),
(104, 'Robin Quinn', 'robin.quinn@example.edu'),
(105, 'Jamie Foster', 'jamie.foster@example.edu');

-- Insert 5 records into User
INSERT INTO User (User_ID, Name, Email) VALUES
(201, 'Taylor Brooks', 'taylor.brooks@student.example.edu'),
(202, 'Jordan Lee', 'jordan.lee@student.example.edu'),
(203, 'Casey Rivera', 'casey.rivera@student.example.edu'),
(204, 'Riley Chen', 'riley.chen@example.edu'),
(205, 'Morgan Patel', 'morgan.patel@student.example.edu');

-- Insert 5 records into User_Role
INSERT INTO User_Role (User_ID, Role) VALUES
(201, 'Reporter'),
(201, 'Registrar'), -- Taylor has two roles
(202, 'Reporter'),
(203, 'Registrar'),
(204, 'Reporter');

-- Insert 5 records into Lost_Item (Note: Item 303 is not approved yet)
INSERT INTO Lost_Item (Item_ID, Item_Name, Description, Location_Lost, Date_Lost, Status, User_ID, Staff_ID) VALUES
(301, 'Blue Bag', 'Small backpack with university logo', 'Library 1st floor', '2025-11-01', 'Approved', 201, 101),
(302, 'ID Card', 'Student ID for Jordan Lee', 'Cafeteria', '2025-11-05', 'Approved', 202, 102),
(303, 'Black Umbrella', 'Large black folding umbrella', 'Gate 1 main entrance', '2025-11-08', 'Reported', 201, NULL), 
(304, 'Glasses', 'Rayban prescription glasses', 'Lecture Hall 5', '2025-10-25', 'Approved', 204, 103),
(305, 'Flash Drive', '8GB USB drive, blue', 'Computer Lab C', '2025-11-10', 'Approved', 205, 101);

-- Insert 5 records into Found_Item (Note: Item 404 is not verified yet)
INSERT INTO Found_Item (Found_ID, Item_Name, Description, Location_Found, Date_Found, Status, User_ID, Staff_ID) VALUES
(401, 'Blue Backpack', 'Small backpack, empty', 'Library entrance desk', '2025-11-02', 'Verified', 203, 101), -- Matches 301
(402, 'Student Card', 'University ID for Jordan Lee', 'Security Office', '2025-11-05', 'Verified', 203, 102), -- Matches 302
(403, 'Wallet', 'Brown leather wallet with cash', 'Parking Lot B', '2025-11-06', 'Verified', 205, 103),
(404, 'Keys', 'Set of 3 keys on a red keychain', 'Admin Building', '2025-11-09', 'Registered', 201, NULL), 
(405, 'Prescription Glasses', 'Black frame glasses', 'Lecture Hall 5', '2025-10-27', 'Verified', 202, 104); -- Matches 304

-- Insert 5 records into Match_Record (Linking the found and lost items)
INSERT INTO Match_Record (Match_ID, Match_Date, Match_Status, Found_ID, Item_ID, Staff_ID) VALUES
(501, '2025-11-03', 'Confirmed', 401, 301, 101), -- Match: Blue Bag (301) & Blue Backpack (401)
(502, '2025-11-06', 'Confirmed', 402, 302, 102), -- Match: ID Card (302) & Student Card (402)
(503, '2025-10-28', 'Confirmed', 405, 304, 103), -- Match: Glasses (304) & Prescription Glasses (405)
(504, '2025-11-11', 'Pending', 403, 305, 104), -- Test Match: Wallet (403) & Flash Drive (305) - Pending
(505, '2025-11-12', 'Pending', 404, 303, 105); -- Test Match: Keys (404) & Umbrella (303) - Pending

-- Query 1: Retrieve all Lost Items reported in November (Month 11)
SELECT Item_Name, Location_Lost, Date_Lost 
FROM Lost_Item 
WHERE MONTH(Date_Lost) = 11;

-- Query 2: Retrieve the names and emails of Users who have the 'Reporter' role
SELECT Name, Email
FROM User
WHERE User_ID IN (SELECT User_ID FROM User_Role WHERE Role = 'Reporter');

-- Query 3: Count the number of Lost Items approved by each Staff member, showing only those with more than one approval
SELECT S.Staff_Name, COUNT(L.Item_ID) AS Approved_Reports_Count
FROM Staff S
JOIN Lost_Item L ON S.Staff_ID = L.Staff_ID
WHERE L.Status = 'Approved'
GROUP BY S.Staff_Name
HAVING COUNT(L.Item_ID) > 1;

-- Query 4: Calculate the average number of days it took for a confirmed match after the item was found
SELECT AVG(DATEDIFF(M.Match_Date, F.Date_Found)) AS Average_Days_To_Match
FROM Match_Record M
JOIN Found_Item F ON M.Found_ID = F.Found_ID
WHERE M.Match_Status = 'Confirmed';

-- Query 5: Show confirmed matches, including the name of the lost item, the name of the user who reported it, and the staff member who confirmed the match.
SELECT 
    M.Match_ID,
    LI.Item_Name AS Lost_Item_Name,
    U.Name AS Reported_By_User,
    S.Staff_Name AS Match_Confirmed_By_Staff,
    M.Match_Date
FROM Match_Record M
JOIN Lost_Item LI ON M.Item_ID = LI.Item_ID  -- Join with Lost Item
JOIN User U ON LI.User_ID = U.User_ID        -- Join with User who reported it
JOIN Staff S ON M.Staff_ID = S.Staff_ID      -- Join with Staff who confirmed it
WHERE M.Match_Status = 'Confirmed';

-- Query 6: Find the names of Staff members who have verified a Found Item that is NOT part of a Confirmed Match Record.
SELECT Staff_Name
FROM Staff
WHERE Staff_ID IN (
    SELECT Staff_ID
    FROM Found_Item
    WHERE Status = 'Verified' 
      AND Found_ID NOT IN (SELECT Found_ID FROM Match_Record WHERE Match_Status = 'Confirmed')
);

-- Query 7: Create a VIEW that lists all Lost Items that are 'Approved' but not yet part of any Confirmed Match Record. This is a simple report of pending returns.
CREATE VIEW Unmatched_Approved_Lost_Items AS
SELECT 
    Item_ID,
    Item_Name,
    Description,
    Location_Lost,
    Date_Lost
FROM Lost_Item 
WHERE Status = 'Approved'
AND Item_ID NOT IN (SELECT Item_ID FROM Match_Record WHERE Match_Status = 'Confirmed');

-- Select data from the generated VIEW (Run this to see the report)
SELECT * FROM Unmatched_Approved_Lost_Items;
