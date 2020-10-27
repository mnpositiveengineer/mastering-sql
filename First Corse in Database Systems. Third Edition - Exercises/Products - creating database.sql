CREATE DATABASE Products;
USE Products;
CREATE TABLE Products (
	producer CHAR(1),
    model INT,
    type CHAR(10)
);
INSERT INTO Products (producer, model, type)
VALUES
('A', 1001, 'pc'),
('A', 1002, 'pc'),
('A', 1003, 'pc'),
('A', 2004, 'notebook'),
('A', 2005, 'notebook'),
('A', 2006, 'notebook'),
('B', 1004, 'pc'),
('B', 1005, 'pc'),
('B', 1006, 'pc'),
('B', 2007, 'notebook'),
('C', 1007, 'pc'),
('D', 1008, 'pc'),
('D', 1009, 'pc'),
('D', 1010, 'pc'),
('D', 3004, 'printer'),
('D', 3005, 'printer'),
('E', 1011, 'pc'),
('E', 1012, 'pc'),
('E', 1013, 'pc'),
('E', 2001, 'notebook'),
('E', 2002, 'notebook'),
('E', 2003, 'notebook'),
('E', 3001, 'printer'),
('E', 3002, 'printer'),
('E', 3003, 'printer'),
('K', 2008, 'notebook'),
('K', 2009, 'notebook'),
('G', 2010, 'notebook'),
('H', 3006, 'printer'),
('H', 3007, 'printer');
CREATE TABLE PC (
	model INT,
    speed DECIMAL(3,2),
    ram int,
    hardDrive int,
    price int
);
INSERT INTO PC(model, speed, ram, hardDrive, price)
VALUES
(1001, 2.66, 1024, 250, 2114),
(1002, 2.10, 512, 250, 995),
(1003, 1.42, 512, 80, 478),
(1004, 2.80, 1024, 250, 649),
(1005, 3.20, 512, 250, 630),
(1006, 3.20, 1024, 320, 1049),
(1007, 2.20, 1024, 200, 510),
(1008, 2.20, 2048, 250, 770),
(1009, 2.00, 1024, 250, 650),
(1010, 2.80, 2048, 300, 770),
(1011, 1.86, 2048, 160, 959),
(1012, 2.80, 1024, 160, 649),
(1013, 3.06, 512, 80, 529);
CREATE TABLE notebook (
	model INT,
    speed DECIMAL(3,2),
    ram int,
    hardDrive int,
    screen DECIMAL(3,1),
    price int
);
INSERT INTO notebook(model, speed, ram, hardDrive, screen, price)
VALUES
(2001, 2.00, 2048, 240, 20.1, 3673),
(2002, 1.73, 1024, 80, 17.0, 949),
(2003, 1.80, 512, 60, 15.4, 549),
(2004, 2.00, 512, 60, 13.3, 1150),
(2005, 2.16, 1024, 120, 17.0, 2500),
(2006, 2.00, 2048, 80, 15.4, 1700),
(2007, 1.83, 1024, 120, 13.3, 1429),
(2008, 1.60, 1024, 100, 15.4, 900),
(2009, 1.60, 512, 80, 14.1, 680),
(2010, 2.00, 2048, 160, 15.4, 2300);
CREATE TABLE printer (
	model int,
    color boolean,
    type char(15),
    price int
);
INSERT INTO printer(model, color, type, price)
VALUES
(3001, true, 'inkjet', 99),
(3002, false, 'laser', 239),
(3003, true, 'laser', 899),
(3004, true, 'inkjet', 120),
(3005, false, 'laser', 120),
(3006, true, 'inkjet', 100),
(3007, true, 'laser', 200);