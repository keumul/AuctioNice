ALTER SESSION SET NLS_LANGUAGE= 'american';

---------------------- [ROLES] ----------------------
INSERT INTO roles(role_name)
VALUES ('admin');
INSERT INTO roles(role_name)
VALUES ('seller');
INSERT INTO roles(role_name)
VALUES ('buyer');

SELECT * FROM roles;

---------------------- [USERS] ----------------------
INSERT INTO users(username, password, email, role_id)
VALUES ('admin', 'admin', 'admin@gmail.com', 1);
INSERT INTO users(username, password, email, role_id)
VALUES ('kate', '1111', 'kate@gmail.com', 2);
INSERT INTO users(username, password, email, role_id)
VALUES ('stepa', '1111', 'stepa@gmail.com', 2);
INSERT INTO users(username, password, email, role_id)
VALUES ('sanya', '1111', 'sanya@gmail.com', 3);
INSERT INTO users(username, password, email, role_id)
VALUES ('max', '1111', 'max@gmail.com', 3);

SELECT * FROM users;

---------------------- [ITEMS] ----------------------
INSERT INTO item(title, description, USERID, ENDTIME, STARTPRICE, WINNERPRICE, TYPEID, BUYERID)
VALUES ('Iphone 6', 'Iphone 6 16gb', 2, TO_DATE('2021-12-12 12:12:12', 'YYYY-MM-DD HH24:MI:SS'), 100, 0, 1, 0);
INSERT INTO item(title, description, USERID, ENDTIME, STARTPRICE, WINNERPRICE, TYPEID, BUYERID)
VALUES ('Iphone 6s', 'Iphone 6s 16gb', 2, TO_DATE('2021-11-10 3:11:21', 'YYYY-MM-DD HH24:MI:SS'), 110, 0, 1, 0);
INSERT INTO item(title, description, USERID, ENDTIME, STARTPRICE, WINNERPRICE, TYPEID, BUYERID)
VALUES ('Iphone 7', 'Iphone 7 16gb', 2, TO_DATE('2022-11-30 10:16:52', 'YYYY-MM-DD HH24:MI:SS'), 120, 0, 1, 0);
INSERT INTO item(title, description, USERID, ENDTIME, STARTPRICE, WINNERPRICE, TYPEID, BUYERID)
VALUES ('Iphone 7s', 'Iphone 7s 16gb', 2, TO_DATE('2022-12-01 8:09:12', 'YYYY-MM-DD HH24:MI:SS'), 130, 0, 1, 0);
INSERT INTO item(title, description, USERID, ENDTIME, STARTPRICE, WINNERPRICE, TYPEID, BUYERID)
VALUES ('Table', 'Vintage wine table', 2, TO_DATE('2022-12-11 11:11:11', 'YYYY-MM-DD HH24:MI:SS'), 80, 0, 1, 0);
INSERT INTO item(title, description, USERID, ENDTIME, STARTPRICE, WINNERPRICE, TYPEID, BUYERID)
VALUES ('Chair', 'Vintage blue chair', 2, TO_DATE('2021-08-20 11:12:13', 'YYYY-MM-DD HH24:MI:SS'), 70, 0, 2, 0);
INSERT INTO item(title, description, USERID, ENDTIME, STARTPRICE, WINNERPRICE, TYPEID, BUYERID)
VALUES ('Sofa', 'Vintage glamour sofa', 2, TO_DATE('2022-09-05 12:13:14', 'YYYY-MM-DD HH24:MI:SS'), 100, 0, 2, 0);
INSERT INTO item(title, description, USERID, ENDTIME, STARTPRICE, WINNERPRICE, TYPEID, BUYERID)
VALUES ('Car', 'Japanese 90x car', 2, TO_DATE('2022-10-10 13:14:15', 'YYYY-MM-DD HH24:MI:SS'), 1000, 0, 3, 0);

SELECT * FROM item;

---------------------- [CATEGORY] ----------------------
INSERT INTO category(title)
VALUES ('Electronics');
INSERT INTO category(title)
VALUES ('Furniture');
INSERT INTO category(title)
VALUES ('Cars');

SELECT * FROM category;

---------------------- [AUCTION] ----------------------
INSERT INTO auction(categoryid, startdate)
VALUES (1, TO_DATE('2022-12-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO auction(categoryid, startdate)
VALUES (2, TO_DATE('2022-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO auction(categoryid, startdate)
VALUES (3, TO_DATE('2022-11-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

SELECT * FROM auction;

---------------------- [AUCTIONTYPE] ----------------------
INSERT INTO auctiontype(title)
VALUES ('English');
INSERT INTO auctiontype(title)
VALUES ('Dutch');
INSERT INTO auctiontype(title)
VALUES ('Vickrey');
