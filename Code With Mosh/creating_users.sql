-- CREATING USERS AND GRANTING PRIVILEGES

-- 1. prefab project

DROP USER IF EXISTS prefab_app;

CREATE USER prefab_app IDENTIFIED BY 'prefabapp';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE
ON prefab_sales.*
TO prefab_app;

DROP USER IF EXISTS prefab_admin;

CREATE USER prefab_admin IDENTIFIED BY 'prefabadmin';

GRANT ALL
ON prefab_sales.*
TO prefab_admin;

-- 2. flight_system

DROP USER IF EXISTS flight_app;

CREATE USER flight_app IDENTIFIED BY 'flightapp';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE
ON flight_system.*
TO flight_app;

DROP USER IF EXISTS flight_admin;

CREATE USER flight_admin IDENTIFIED BY 'flightadmin';

GRANT ALL
ON flight_system.*
TO flight_admin;

SELECT * FROM mysql.user;

-- 3. video_rental_store

DROP USER IF EXISTS video_app;

CREATE USER video_app IDENTIFIED BY 'videoapp';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE
ON video_rental_store.*
TO video_app;

DROP USER IF EXISTS video_admin;

CREATE USER video_admin IDENTIFIED BY 'videoadmin';

GRANT ALL
ON video_rental_store.*
TO video_admin;

SELECT * FROM mysql.user;