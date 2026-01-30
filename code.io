1)
Select posts of particular ACTIVE user

(First Name + Last Name, Role, Post Title, Reference, Likes count, Post creation date)

✅ Ensure data exists (ACTIVE user with posts)
-- Ensure user 3 (Neha Mehta) is active
UPDATE Users SET active = 1 WHERE user_id = 3;

-- Ensure at least one post exists for active user
INSERT INTO Group_Posts
(post_id, posted_by, title, content, group_id, sub_group_id, reference_link, like_count, created_date)
VALUES
(11,3,'Advanced React','React deep concepts',2,3,'react.dev',22,NOW());

✅ QUERY
SELECT 
 CONCAT(u.first_name,' ',u.last_name) AS UserName,
 r.name AS Role,
 p.title AS PostTitle,
 p.reference_link,
 p.like_count,
 p.created_date
FROM Users u
JOIN Roles r ON u.role_id = r.role_id
JOIN Group_Posts p ON u.user_id = p.posted_by
WHERE u.active = 1;

📤 RESULT
-- UserName      | Role       | PostTitle        | Reference   | Likes | CreatedDate
-- Neha Mehta    | Developer  | React Hooks      | react.dev  | 15    | 2026-01-29
-- Neha Mehta    | Developer  | Advanced React   | react.dev  | 22    | 2026-01-30
-- Amit Shah     | Admin      | Movie Review     | imdb.com   | 25    | 2026-01-29
-- ...



2)

Select posts of employee who joined company first
✅ Ensure correct first joined employee has a post
-- Check first joined employee (earliest joining date = user_id 10)

-- Ensure post exists
INSERT INTO Group_Posts
(post_id, posted_by, title, content, group_id, sub_group_id, reference_link, like_count, created_date)
VALUES
(12,10,'Company Policy','HR guidelines',10,10,'company.com',30,NOW());

✅ QUERY
SELECT 
 u.first_name,
 u.last_name,
 p.title,
 p.like_count,
 p.created_date
FROM Users u
JOIN Group_Posts p ON u.user_id = p.posted_by
WHERE u.joining_date = (
   SELECT MIN(joining_date) FROM Users
);

📤 RESULT
-- FirstName | LastName | Title           | Likes | CreatedDate
-- Nikita   | Rao      | HR Policy       | 9     | 2026-01-29
-- Nikita   | Rao      | Company Policy  | 30    | 2026-01-30


3)1. Update joining date of an employee
UPDATE Users
SET joining_date = '2020-01-01'
WHERE user_id = 8;

4)
🔹 2. Delete groups created by role = ‘HR’
✅ Ensure HR has created a group
-- HR role_id = 2, created_by = user_id 2
INSERT INTO Groups
(group_id, name, description, active, created_date, created_by)
VALUES
(11,'HR Internal','HR Only Group',1,NOW(),2);

5)

✅ DELETE QUERY
DELETE FROM Groups
WHERE created_by IN (
   SELECT user_id
   FROM Users
   WHERE role_id = (
       SELECT role_id FROM Roles WHERE name='HR'
   )
);

5)
🔹 3. Update description and active status of particular group
UPDATE Groups
SET description = 'Updated Technology Discussions',
    active = 0
WHERE group_id = 2;




6)

🔹 3. Users who have posted in MORE THAN ONE GROUP
✅ Ensure data exists (insert extra post for same user in different group)
-- Extra post so user_id = 3 posts in multiple groups
INSERT INTO Group_Posts
VALUES (11,3,'Extra Tech Post','Another post',5,7,NULL,NULL,'extra.com',6,NOW());

QUERY
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS UserName,
       COUNT(DISTINCT p.group_id) AS GroupCount
FROM Users u
JOIN Group_Posts p ON u.user_id = p.posted_by
GROUP BY u.user_id
HAVING COUNT(DISTINCT p.group_id) > 1;


7)
🔹 4. Users who joined the company in LAST 6 MONTHS
QUERY
SELECT user_id, first_name, joining_date
FROM Users
WHERE joining_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);


8)
🔹 5. Users whose email domain is SAME (@company.com)
QUERY
SELECT user_id, first_name, email_id
FROM Users
WHERE email_id LIKE '%@company.com';

9)
🔹 6. Groups that DO NOT have any sub-groups
✅ Ensure data exists (insert group without sub-group)
INSERT INTO Groups
VALUES (11,'CSR','Social Work',1,NOW(),1);

QUERY
SELECT g.group_id, g.name
FROM Groups g
LEFT JOIN Sub_Groups sg ON g.group_id = sg.group_id
WHERE sg.group_id IS NULL;

10)

🔹 7. Sub-groups where NO POSTS are created
✅ Ensure data exists (insert sub-group without posts)
INSERT INTO Sub_Groups
VALUES (11,'Cloud','Cloud Tech',2,1,NOW(),3);

QUERY
SELECT sg.sub_group_id, sg.name
FROM Sub_Groups sg
LEFT JOIN Group_Posts p ON sg.sub_group_id = p.sub_group_id
WHERE p.sub_group_id IS NULL;

11)
🔹 8. Groups that are INACTIVE but STILL HAVE POSTS
✅ Ensure data exists (inactive group with post)
-- Insert post in inactive group_id = 7 (Finance)
INSERT INTO Group_Posts
VALUES (12,5,'Finance Post','Finance content',7,NULL,NULL,NULL,'finance.com',11,NOW());

QUERY
SELECT DISTINCT g.group_id, g.name
FROM Groups g
JOIN Group_Posts p ON g.group_id = p.group_id
WHERE g.active = 0;

12)
🔹 9. Display GROUP-WISE total posts count
QUERY
SELECT g.group_id, g.name AS GroupName, COUNT(p.post_id) AS TotalPosts
FROM Groups g
LEFT JOIN Group_Posts p ON g.group_id = p.group_id
GROUP BY g.group_id, g.name;

13)
🔹 10. Sub-groups created by SAME USER who created the group
QUERY
SELECT g.name AS GroupName,
       sg.name AS SubGroupName,
       u.first_name AS CreatedBy
FROM Groups g
JOIN Sub_Groups sg ON g.group_id = sg.group_id
JOIN Users u ON g.created_by = sg.created_by;

13)
🔹 11. Posts where CONTENT LENGTH > 200 characters
✅ Ensure data exists
UPDATE Group_Posts
SET content = RPAD(content, 250, 'X')
WHERE post_id = 1;

QUERY
SELECT post_id, title, LENGTH(content) AS ContentLength
FROM Group_Posts
WHERE LENGTH(content) > 200;

14)
🔹 12. Posts created in LAST 3 DAYS – GROUP-WISE
QUERY
SELECT g.name AS GroupName,
       p.title,
       p.created_date
FROM Group_Posts p
JOIN Groups g ON p.group_id = g.group_id
WHERE p.created_date >= DATE_SUB(NOW(), INTERVAL 3 DAY)
ORDER BY g.name, p.created_date DESC;

15)
🔹 14. TOP TRENDING GROUP
(Highest posts + highest total likes in LAST 7 DAYS)
QUERY
SELECT g.group_id,
       g.name AS GroupName,
       COUNT(p.post_id) AS TotalPosts,
       SUM(p.like_count) AS TotalLikes
FROM Groups g
JOIN Group_Posts p ON g.group_id = p.group_id
WHERE p.created_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY g.group_id, g.name
ORDER BY TotalPosts DESC, TotalLikes DESC
LIMIT 1;

16)

🔹 15. Users who have posted in ALL ACTIVE GROUPS
LOGIC (important for viva)

User’s distinct posted groups = total active groups

QUERY
SELECT u.user_id,
       CONCAT(u.first_name,' ',u.last_name) AS UserName
FROM Users u
JOIN Group_Posts p ON u.user_id = p.posted_by
JOIN Groups g ON p.group_id = g.group_id AND g.active = 1
GROUP BY u.user_id
HAVING COUNT(DISTINCT g.group_id) = (
    SELECT COUNT(*) FROM Groups WHERE active = 1


17)
