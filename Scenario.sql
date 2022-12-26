BEGIN
  FOR i IN 1..100000 LOOP
    INSERT INTO users (email, password, username, role_id)
    VALUES ( 'user' || i || '@user.com', 'user', 'user' || i, 3);
  END LOOP;
END;

BEGIN
  FOR i IN 1..100000 LOOP
      --delete users where email like 'user%';
        DELETE FROM users WHERE email LIKE 'user%';
  END LOOP;
END;


SELECT * FROM USERS;
SELECT * FROM ROLES;
SELECT * FROM AUCTION;
SELECT * FROM AUCTIONTYPE;
SELECT * FROM CATEGORY;
SELECT * FROM ITEM;
SELECT * FROM ITEMSAUCTION;
SELECT * FROM ITEMSCATEGORY;

ALTER SESSION SET NLS_LANGUAGE= 'american';



-- admin signup
BEGIN
    admin_package.signup_procedure('adminnastya@gmail.com', 'root', 'Nastya');
END;

select * from users;
-- admin login
DECLARE
    login_ VARCHAR2(255) := 'adminnastya@gmail.com';
BEGIN
    admin_package.signin_procedure(login_, 'root');
END;

-- admin add auction
DECLARE
    auction_type_ NUMBER := 1;
    start_date_   DATE  := TO_DATE('23/12/2022', 'DD/MM/YYYY');
BEGIN
    admin_package.add_auction(auction_type_, start_date_);
END;


-- admin add category
DECLARE
    category_ VARCHAR2(255) := 'dress';
BEGIN
    admin_package.add_category_procedure(category_);
END;

--admin get users pagination

DECLARE
    users_cursor sys_refcursor;
    id_p         NUMBER;
    email_p      VARCHAR2(255);
    name_p       VARCHAR2(255);
    account_p    NUMBER;
    page_p       number := 1;
    count_p      number := 100;
BEGIN
    users_cursor := admin_package.get_all_users_pagination(page_p, count_p);
    DBMS_OUTPUT.PUT_LINE( lpad('id', 5) || lpad('email', 25) || lpad('name', 20) || lpad('account', 10));
    LOOP
        FETCH users_cursor INTO id_p, email_p, name_p, account_p;
        EXIT WHEN users_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE( lpad(id_p, 5) || lpad(email_p, 25) || lpad(name_p, 20) || lpad(account_p, 10));
    END LOOP;
END;

select admin_package.get_all_users_pagination(1, 100) from dual;


ALTER SESSION SET NLS_LANGUAGE= 'american';
-- seller sign up
BEGIN
    seller_package.signup_procedure('sellervika@gmail.com', '1111', 'Vika');
END;

SELECT *
FROM USERS;

-- seller login
DECLARE
    login_ VARCHAR2(255) := 'sellervika@gmail.com';
BEGIN
    seller_package.signin_procedure(login_, '1111');
END;

SELECT * FROM USERS;

-- seller add item
DECLARE
    title_p       VARCHAR2(255) := 'dress';
    description_p VARCHAR2(255) := 'pretty dress';
    userid_p      INT           := 201;
    endtime_p     DATE          := TO_DATE('24/12/2022', 'DD/MM/YYYY');
    startprice_p  INT           := 200;
    typeid_p      INT           := 1;
BEGIN
    seller_package.insert_item_procedure(title_p, description_p, userid_p, endtime_p, startprice_p, typeid_p);
END;

SELECT *
FROM ITEM;

-- seller add item to category
DECLARE
    id_p         number := 2;
    itemid_p     number := 71;
    categoryid_p number := 1;
BEGIN
    seller_package.add_items_category_procedure(id_p, itemid_p, categoryid_p);
END;

SELECT * FROM ITEMSCATEGORY;

--get_item_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          NUMBER;
    title_p       VARCHAR2(255);
    description_p VARCHAR2(255);
    endtime_p     DATE;
    startprice_p  NUMBER;
    winnerprice_p NUMBER;
BEGIN
    item_cursor := seller_package.get_item_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20));
    END LOOP;
END;


--get_item_category_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          NUMBER;
    title_p       VARCHAR2(255);
    description_p VARCHAR2(255);
    endtime_p     DATE;
    startprice_p  NUMBER;
    winnerprice_p NUMBER;
    title_c       VARCHAR2(255);
BEGIN
    item_cursor := seller_package.get_item_category_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items category list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20) || lpad('category', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p, title_c;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20) || lpad(title_c, 20));
    END LOOP;
END;

--get_item_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          NUMBER;
    title_p       VARCHAR2(255);
    description_p VARCHAR2(255);
    endtime_p     DATE;
    startprice_p  NUMBER;
    winnerprice_p NUMBER;
BEGIN
    item_cursor := seller_package.get_item_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20));
    END LOOP;
END;


--get_item_category_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          NUMBER;
    title_p       VARCHAR2(255);
    description_p VARCHAR2(255);
    endtime_p     DATE;
    startprice_p  NUMBER;
    winnerprice_p NUMBER;
    title_c       VARCHAR2(255);
BEGIN
    item_cursor := seller_package.get_item_category_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items category list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20) || lpad('category', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p, title_c;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20) || lpad(title_c, 20));
    END LOOP;
END;



SELECT *
FROM ITEMSCATEGORY;


-- admin delete item
DECLARE
    id_p number := 71;
BEGIN
    admin_package.delete_item_procedure(id_p);
END;

SELECT * FROM ITEM;

-- admin delete items category
DECLARE
    id_p number := 23;
BEGIN
    admin_package.delete_items_category(id_p);
END;

SELECT *
FROM ITEMSCATEGORY;

-- admin delete auction
DECLARE
    id_p number := 1;
BEGIN
    admin_package.delete_auction_procedure(id_p);
END;

SELECT *
FROM AUCTION;

-- admin delete items auction
DECLARE
    id_p number := 1;
BEGIN
    admin_package.delete_auction_items(id_p);
END;

--get_item_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          NUMBER;
    title_p        VARCHAR2(255);
    description_p VARCHAR2(255);
    endtime_p     DATE;
    startprice_p  NUMBER;
    winnerprice_p NUMBER;

BEGIN
    item_cursor := admin_package.get_item_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20));
    END LOOP;
END;


--get_item_category_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          NUMBER;
    title_p       VARCHAR2(255);
    description_p VARCHAR2(255);
    endtime_p     DATE;
    startprice_p  NUMBER;
    winnerprice_p NUMBER;
    title_c       VARCHAR2(255);
BEGIN
    item_cursor := admin_package.get_item_category_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items category list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20) || lpad('category', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p, title_c;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20) || lpad(title_c, 20));
    END LOOP;
END;
SELECT *
FROM CATEGORY;
SELECT *
FROM ITEM_CATEGORY_VIEW;
SELECT *
FROM ITEMSCATEGORY;

--get_current_auction_function
DECLARE
    auction_cursor sys_refcursor;
    id_p           NUMBER;
    startdate_p    DATE;
    categoryid_p   NUMBER;
BEGIN
    auction_cursor := admin_package.get_current_auction_function(TO_DATE('31/12/2022', 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('[Information about current auction]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('category id', 20) || lpad('start date', 20) );
    LOOP
        FETCH auction_cursor
        INTO id_p, categoryid_p, startdate_p ;
        EXIT WHEN auction_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(categoryid_p, 20) || lpad(startdate_p, 20) );
    END LOOP;
END;




-- seller delete category
DECLARE
    id_p number := 22;
BEGIN
    seller_package.delete_items_category(id_p);
END;

SELECT *
FROM ITEMSCATEGORY;

-- seller delete item
DECLARE
    id_p number := 22;
BEGIN
    seller_package.delete_item_procedure(id_p);
END;

SELECT *
FROM ITEM;

--seller delete auction items
DECLARE
    id_p number := 2;
BEGIN
    seller_package.delete_auction_items(id_p);
END;

SELECT *
FROM ITEMSAUCTION;

-- seller add item to auction
DECLARE
    count_p     INT := 3;
    itemid_p    INT := 23;
    auctionid_p INT := 2;
BEGIN
    seller_package.add_items_auction_procedure(auctionid_p, itemid_p, count_p);
END;

SELECT *
FROM ITEM;
SELECT *
FROM AUCTION;
SELECT *
FROM ITEMSAUCTION;


--seller actualize item
SELECT *
FROM ITEM;
DECLARE
    id_p INT := 23;
BEGIN
    seller_package.actualize_item_procedure(id_p);
END;




-- buyer sign up
BEGIN
    buyer_package.signup_procedure('buyerolya@gmail.com', '1111', 'olya');
END;


-- buyer login
DECLARE
    login_ varchar2(255) := 'buyerolya@gmail.com';
BEGIN
    buyer_package.signin_procedure(login_, '1111');
END;

select * from USERS;
-- buyer add money
DECLARE
    money_p INT := 2000;
    p_id    INT := 222;
BEGIN
    buyer_package.add_money_procedure(p_id, money_p);
END;

SELECT * FROM USERS;
SELECT * FROM ITEM;
-- buyer update price function
DECLARE
    startprice_      number;
    userid_          number;
    buyerid_         number;
    realwinnerprice_ number;
    endtime_         DATE;
    cursor_          sys_refcursor;
BEGIN
    cursor_ := buyer_package.update_price_function(72, 121);
    LOOP
        FETCH cursor_ INTO startprice_, userid_, buyerid_, realwinnerprice_, endtime_;
        EXIT WHEN cursor_%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('startprice: ' || startprice_ || ' | userid: ' || userid_ || ' | buyerid: ' || buyerid_ ||
                             ' | realwinnerprice: ' || realwinnerprice_ || ' | endtime: ' || endtime_);
    END LOOP;
END;
SELECT * FROM NOTIFICATIONS;
SELECT * FROM USERS;

-- buyer notification

declare
    notifications_cursor sys_refcursor;
    notification_id      int;
    operation_date       date;
    message              varchar2(255);
    user_id              int;
    is_read              int;
begin
    notifications_cursor := buyer_package.get_user_notifications('buyer1');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 10) || lpad('operation_date', 20) || lpad('message', 50) || lpad('user_id', 10) || lpad('is_read', 10));
    loop
        fetch notifications_cursor into notification_id, operation_date, message, user_id, is_read;
        exit when notifications_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(notification_id, 10) || lpad(operation_date, 20) || lpad(message, 50) || lpad(user_id, 10) || lpad(is_read, 10));
    end loop;
end;

SELECT * FROM NOTIFICATIONS;
SELECT * FROM USERS;


--get_item_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          number;
    title_p       varchar2(255);
    description_p varchar2(255);
    endtime_p     date;
    startprice_p  number;
    winnerprice_p number;
BEGIN
    item_cursor := buyer_package.get_item_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20));
    END LOOP;
END;


--get_item_category_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          number;
    title_p       varchar2(255);
    description_p varchar2(255);
    endtime_p     date;
    startprice_p  number;
    winnerprice_p number;
    title_c       varchar2(255);
BEGIN
    item_cursor := buyer_package.get_item_category_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items category list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20) || lpad('category', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p, title_c;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20) || lpad(title_c, 20));
    END LOOP;
END;

--get_current_auction_function
DECLARE
    auction_cursor sys_refcursor;
    id_p           number;
    startdate_p    date;
    categoryid_p   number;
BEGIN
    auction_cursor := buyer_package.get_current_auction_function(TO_DATE('31/12/2022', 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('[Information about current auction]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('category id', 20) || lpad('start date', 20) );
    LOOP
        FETCH auction_cursor
        INTO id_p, categoryid_p, startdate_p ;
        EXIT WHEN auction_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(categoryid_p, 20) || lpad(startdate_p, 20) );
    END LOOP;
END;

