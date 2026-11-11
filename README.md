# Lost and Found Database 🎒

A relational database design for a university **Lost and Found** system (`UQU_LostAndFound_DB`). Users report lost items and register found items, staff members approve and verify the reports, and confirmed matches are recorded so items can be returned to their owners.

The whole database lives in one MySQL script: [`DB_Lost_Found_Project.sql`](DB_Lost_Found_Project.sql).

## Entities

| Table | Purpose |
|---|---|
| `Staff` | Staff members who approve lost reports, verify found items and confirm matches |
| `User` | People who report lost items or register found items |
| `User_Role` | Junction table giving each user one or more roles (`Reporter`, `Registrar`), with a composite primary key `(User_ID, Role)` |
| `Lost_Item` | Items reported as lost (status: `Reported`, `Approved`, `Matched`) |
| `Found_Item` | Items registered as found (status: `Registered`, `Verified`, `Matched`) |
| `Match_Record` | A lost item matched with a found item, confirmed by a staff member (status: `Confirmed` or `Pending`) |

### Relationships

- A user can report many lost items and register many found items (one-to-many).
- A user can have several roles and a role can belong to several users (many-to-many through `User_Role`).
- A staff member can approve lost items, verify found items and confirm matches (all optional until the review happens).
- Each lost item and each found item can appear in at most one match record (`UNIQUE` foreign keys in `Match_Record`).

### Integrity rules

- `CHECK` constraints restrict roles and statuses to the valid workflow values.
- `UNIQUE` and `NOT NULL` constraints on emails and required fields.
- `ON DELETE CASCADE` from `User` to `User_Role`.

## Included queries

The script also contains sample data (5 rows per table) and seven example queries:

1. Lost items reported in November
2. Names and emails of users with the `Reporter` role
3. Number of approved lost items per staff member, only for staff with more than one approval (`GROUP BY` / `HAVING`)
4. Average number of days between finding an item and confirming its match
5. Confirmed matches with the lost item, the reporter and the staff member (multi-table join)
6. Staff who verified a found item that is not part of a confirmed match (nested subquery)
7. A view, `Unmatched_Approved_Lost_Items`, listing approved lost items that are still waiting for a confirmed match

## How to run

Requires MySQL 8 or MariaDB.

```bash
mysql -u <your_user> -p < DB_Lost_Found_Project.sql
```

Or open the file in MySQL Workbench and run it. The script creates the database, the tables, the sample data, the queries and the view.

## Tech

MySQL, SQL (DDL, DML, joins, subqueries, aggregation, views).
