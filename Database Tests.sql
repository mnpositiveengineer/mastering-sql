
-- test1: should insert entries into table Project
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß', 'Łękołody 56-700, ul. Ålesunda 2/2', 'warehouse', 'investor', 'delivery', 1, 'in progress', 1);
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('Byggnad 3', 'Łękołody 56-700, ul. Ålesunda 2/2', 'pitch', 'general', 'assembly', 0, 'offer sent', 2);
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('Polo-market', 'Łękołody 56-700, ul. Ålesunda 2/2', 'container', 'subcontractor', 'delivery', 1, 'rejected', 3);
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('EY\'s', 'St. Louis, Oklahoma\'s street 45, New York', 'semi detached house', 'investor', 'assembly', 1, 'approved', 4);

-- test2: should not insert entries into table Project due to constraint validation
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('<script>', 'Łękołody 56-700, ul. Ålesunda 2/2', 'warehouse', 'investor', 'delivery', 1, 'in progress', 1);
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('Byggnad 3', '#$<', 'pitch', 'general', 'assembly', 0, 'offer sent', 2);
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('Polo-market', 'Łękołody 56-700, ul. Ålesunda 2/2', '23', 'subcontractor', 'delivery', 1, 'rejected', 3);
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('EY\'s', 'St. Louis, Oklahoma\'s street 45, New York', 'semi detached house', 'other', 'assembly', 1, 'approved', 4);
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('EY\'s', 'St. Louis, Oklahoma\'s street 45, New York', 'semi detached house', 'investor', 'other', 1, 'approved', 4);
INSERT INTO Project (name, location, typeOfConstruction, investorType, projectType, containsDesign, projectStatus, prospect)
VALUES ('EY\'s', 'St. Louis, Oklahoma\'s street 45, New York', 'semi detached house', 'investor', 'assembly', 1, 'other', 4);

-- test3: should set null a value of Prospects in Project table, when Prospect is deleted

DELETE FROM Prospect WHERE id = 4;

-- test4: should insert entries into table Prospect
INSERT INTO Prospect (name, address, country, principalActivity, tax)
VALUES ('Pekabex S.A', 'Łękołody 56-700, ul. Ålesunda 2/2', 'Poland', 'Production of steel', '123456789');
INSERT INTO Prospect (name, address, country, principalActivity, tax)
VALUES ('ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß', 'Tulipanowa 15/4, Moscow 67-100', 'Russia', 'Utility', 'K');
INSERT INTO Prospect (name, address, country, principalActivity, tax)
VALUES ('St. Jame\'s', 'St. Louis, Oklahoma\'s street 45, New York', 'United States', 'Mining', 'MNHJD1234581LKAM123561LKS1');
INSERT INTO Prospect (name, address, country, principalActivity, tax)
VALUES ('Co-Co', 'ul. Czysta 11/10R, 53-101 Wroclaw', 'Poland', 'Public Administration', '4');
INSERT INTO Prospect (name)
VALUES ('Party77');

-- test5: should not insert entries into table Prospect due to constraint validation
INSERT INTO Prospect (name, address, country, principalActivity, tax)
VALUES ('<>', 'Tulipanowa 15/4, Warszawa 67-100', 'Poland', 'Production of steel', '123456789');
INSERT INTO Prospect (name, address, country, principalActivity, tax)
VALUES ('Pekabex', '-- OR <>', 'Poland', 'Production of steel', '123456789');
INSERT INTO Prospect (name, address, country, principalActivity, tax)
VALUES ('Pekabex', 'Tulipanowa 15/4, Warszawa 67-100', '456', 'Production of steel', '123456789');
INSERT INTO Prospect (name, address, country, principalActivity, tax)
VALUES ('Pekabex', 'Tulipanowa 15/4, Warszawa 67-100', 'Poland', '222', '123456789');
INSERT INTO Prospect (name, address, country, principalActivity, tax)
VALUES ('Pekabex', 'St. Louis, Oklahoma\'s street 45, New York', 'United States', 'Mining', 'MNHJD1234581LKAM123561LKS11');

-- test6: should insert entries into table PersonOfContact
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Łukasz Müller', 'lukaszmuller@gmail.com', '999111000', 'director', 1, 1);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Mr. Novak', 'johndoe1@domainsample.com', '123', 'assistant', 0, 2);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Patrick O\'reily', 'john.doe@domainsample.net', '321456', 'CEO', 0, 3);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('ąĄćĆęĘłŁńŃóÓśŚźŹżŻåÅØøæÆäÄöÖüÜß', 'john.doe43@domainsample.co.uk', '111111111', 'AVP', 1, 4);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, prospect)
VALUES ('Kasia Bryl-Nowak', 'kasia.bryl-nowak@artless-design.pl', '519872240', 5);

-- test7: should not insert entries into table PersonOfContact due to constraint validation
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('123', 'lukaszmuller@gmail.com', '123456789', 'director', 1, 1);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Łukasz Müller', 'abc', '123456789', 'director', 1, 1);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Łukasz Müller', '123', '123456789', 'director', 1, 1);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Łukasz Müller', '@domainsample.com', '123456789', 'director', 1, 1);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Łukasz Müller', 'johndoedomainsample.com', '123456789', 'director', 1, 1);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Łukasz Müller', 'john.doe43@domainsample', '123456789', 'director', 1, 1);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Łukasz Müller', 'lukaszmuller@gmail.com', 'abc', 'director', 1, 1);
INSERT INTO PersonOfContact(firstName, email, phoneNumber, position, decisionMaker, prospect)
VALUES ('Łukasz Müller', 'lukaszmuller@gmail.com', '1122', '999', 1, 1);

-- test8: should set null as a value of prospects in PersonOfContact

DELETE FROM Prospect WHERE name = "Party77";

-- test9: should insert entries into table SalesPerson
INSERT INTO SalesPerson (email, name)
VALUES ('jimmy.brown@company.com', 'Jimmy Brown');
INSERT INTO SalesPerson (email, name)
VALUES ('kate-wrist2@company.com', 'Kate Wrist');
INSERT INTO SalesPerson (email, name)
VALUES ('megan_cox@company-company.org', 'Megan Cox');
INSERT INTO SalesPerson (email, name)
VALUES ('jakemontana@qwerty.net', 'Jake Montana');

-- test10: should not insert entries into table SalesPerson due to constraint validation
INSERT INTO SalesPerson (email, name)
VALUES ('jimmy.browncompany.com', 'Jimmy Brown');
INSERT INTO SalesPerson (email, name)
VALUES ('kate-wrist@company', 'Kate Wrist');
INSERT INTO SalesPerson (email, name)
VALUES ('@company-company.org', 'Megan Cox');
INSERT INTO SalesPerson (email, name)
VALUES ('jakemontana@.net', 'Jake Montana');

-- test11: should insert entries into table ProjectSalesPerson
INSERT INTO ProjectSalesPerson (sales_person_id, project_id)
VALUES (1, 1), (1,2), (1,3), (2,3), (3,4);

-- test12: should not insert entires into table ProjectSalesPerson due to violation of Primary Key
INSERT INTO ProjectSalesPerson (sales_person_id, project_id)
VALUES (1, 1);
INSERT INTO ProjectSalesPerson (sales_person_id, project_id)
VALUES (3, 4);

-- test13: should assign new project to Sales Person with id = 1

INSERT INTO Project (name, location, prospect)
VALUES ('Test Project', 'Test', 3);

-- test14: should create new sales person and assign newly created project

DELETE FROM SalesPerson;

INSERT INTO Project (name, location, prospect)
VALUES ('Test Project3', 'Test1', 2);

-- test15: should not delete Sales Person of id = 1, leaving project without SalesPerson.

DELETE FROM salesperson WHERE id = 1;

-- test16: should not delete from ProjectSalesPerson, leaving project without SalesPerson.

DELETE FROM projectsalesperson WHERE sales_person_id = 1;
DELETE FROM projectsalesperson WHERE project_id = LAST_INSERT_ID();

-- test17: should delete SalesPerson of id = 1, leaving project with other SalesPerson

INSERT INTO SalesPerson (email, name)
VALUES ('newsalesperson@prefab.com', 'newsalesperson');

INSERT ProjectSalesPerson (sales_person_id, project_id)
VALUES (LAST_INSERT_ID(), 12);

DELETE FROM salesperson WHERE id = 1;

-- test18: should not delete Sales Person of id = LAST_INSERT_ID(), leaving project without SalesPerson.

DELETE FROM salesperson WHERE id = LAST_INSERT_ID();

-- test19: should delete ProjectSalesPerson, leaving project with other SalesPerson

INSERT INTO SalesPerson (email, name)
VALUES ('newsalesperson2@prefab.com', 'newsalespersonthird');

INSERT INTO SalesPerson (email, name)
VALUES ('newsalesperson3@prefab.com', 'newsalespersonsecond');

INSERT ProjectSalesPerson (sales_person_id, project_id)
VALUES (3, 12), (4,12);

DELETE FROM projectsalesperson WHERE sales_person_id = 2;

