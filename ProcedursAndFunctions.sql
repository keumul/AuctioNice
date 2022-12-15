ALTER SESSION SET NLS_LANGUAGE= 'american';

CREATE OR REPLACE PACKAGE admin_package AS
    FUNCTION encrypt_password(password IN VARCHAR2) RETURN users.password%type;
    PROCEDURE delete_item_procedure(id_p INT);
    PROCEDURE delete_items_category_procedure(itemid_p INT);
    PROCEDURE add_items_category_procedure(itemid_p INT, categoryid_p INT);
    FUNCTION  get_current_auction_function(date_p DATE) RETURN SYS_REFCURSOR;
    FUNCTION  get_item_function(item in ITEM.ID%type) RETURN SYS_REFCURSOR;
    FUNCTION  get_item_category_function(type INT) RETURN SYS_REFCURSOR;
    PROCEDURE delete_auction_procedure(id_p INT);
    PROCEDURE delete_auction_items_procedure(auctionid_p INT);
    FUNCTION  fill_auction_function(
        auctionid_p INT,
        date_p      DATE,
        category_p  INT) RETURN SYS_REFCURSOR;
    PROCEDURE add_auction(
        categoryid_p INT,
        startdate_p DATE);
    FUNCTION get_all_users_pagination(
        page_number_in NUMBER,
        page_size_in NUMBER) RETURN SYS_REFCURSOR;
END admin_package;

CREATE OR REPLACE PACKAGE seller_package AS
    PROCEDURE insert_item_procedure(
        item_cursor OUT sys_refcursor,
        title_p       VARCHAR,
	    description_p VARCHAR,
	    userid_p      INT,
	    endtime_p     DATE,
	    startprice_p  INT,
	    typeid_p      INT);
    FUNCTION  encrypt_password(password IN VARCHAR2) RETURN users.password%type;
    FUNCTION  get_item_function(item in ITEM.ID%type) RETURN SYS_REFCURSOR;
    FUNCTION  get_item_category_function(type INT) RETURN SYS_REFCURSOR;
    PROCEDURE delete_items_category_procedure(itemid_p INT);
    PROCEDURE add_items_category_procedure(itemid_p INT, categoryid_p INT);
    PROCEDURE delete_item_procedure(id_p INT);
    PROCEDURE delete_auction_items_procedure(auctionid_p INT);
    PROCEDURE add_items_auction_procedure(
        auctionid_p INT,
        itemid_p INT);

END seller_package;

CREATE OR REPLACE PACKAGE buyer_package AS
    FUNCTION  encrypt_password(password IN VARCHAR2) RETURN users.password%type;
    PROCEDURE signup_procedure(
    email_p IN VARCHAR2,
    password_p IN VARCHAR2,
    username_P IN VARCHAR2);
    FUNCTION  update_price_function(id_p INT, buyerid_p INT) RETURN SYS_REFCURSOR;
    PROCEDURE signin_procedure(
        p_login IN OUT users.email%TYPE,
        p_password IN users.password%TYPE);
    FUNCTION  get_user_notifications(username_in in users.username%type) RETURN SYS_REFCURSOR;
    PROCEDURE remove_notification(notification_id in notifications.id%type);
    PROCEDURE add_money_procedure(
        p_id    INT,
        p_value INT);
    FUNCTION  get_item_function(item in ITEM.ID%type) RETURN SYS_REFCURSOR;
    FUNCTION  get_item_category_function(type INT) RETURN SYS_REFCURSOR;
    FUNCTION  get_current_auction_function(date_p DATE) RETURN SYS_REFCURSOR;
END buyer_package;


--============================= [ADMIN] ================================--
CREATE OR REPLACE PACKAGE BODY admin_package AS
------------------------ [PASSWORD ENCRYPTION] ---------------------------
--DROP FUNCTION encrypt_password;
FUNCTION encrypt_password(password IN VARCHAR2) RETURN users.password%type IS
        hash users.password%type;
    BEGIN
        hash := utl_raw.cast_to_raw(utl_encode.base64_encode(utl_raw.cast_to_raw(password)));
        RETURN hash;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001, 'Error encrypting password');
END encrypt_password;

------------------------ [DELETE ITEM] ------------------------------------
--DROP PROCEDURE delete_item_procedure
PROCEDURE delete_item_procedure(
    id_p INT)
IS
BEGIN
    delete_items_category_procedure(id_p);
    DELETE FROM Item
        WHERE id = id_p;
EXCEPTION
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with delete_item_procedure');
END delete_item_procedure;

------------------------ [DELETE ITEMS CATEGORY] ------------------------------------
--DROP PROCEDURE delete_items_category_procedure;
PROCEDURE delete_items_category_procedure(
    itemid_p INT)
IS
BEGIN
    DELETE FROM ItemsCategory
           WHERE itemid = itemid_p;
END delete_items_category_procedure;

------------------------ [ADD ITEMS CATEGORY] ------------------------------------
--DROP PROCEDURE add_items_category_procedure;
PROCEDURE add_items_category_procedure(
    itemid_p     INT,
    categoryid_p INT)
IS
BEGIN
    INSERT INTO ItemsCategory
        (itemid, categoryid)
        VALUES (itemid_p, categoryid_p);
END add_items_category_procedure;

------------------------ [ADD AUCTION] ------------------------------------
--DROP PROCEDURE add_auction_procedure;
PROCEDURE add_auction(
    categoryid_p INT,
    startdate_p DATE)
IS
    count_p int;
    AUCTION_EXISTS EXCEPTION;
    CANNOT_BE_IN_PAST EXCEPTION;
BEGIN
    IF(startdate_p < SYSDATE) THEN
        RAISE CANNOT_BE_IN_PAST;
    END IF;
    IF(count_p > 0) THEN
        RAISE AUCTION_EXISTS;
    END IF;
    IF count_p = 0 AND startdate_p > Sysdate
        THEN INSERT INTO AUCTION
            (categoryid, startDate)
            VALUES (categoryid_p, startdate_p);
    END IF;
EXCEPTION
    WHEN AUCTION_EXISTS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Auction already exists');
    WHEN CANNOT_BE_IN_PAST
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Auction cannot be in the past');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with add_auction');
END add_auction;

------------------------ [DELETE AUCTION] ------------------------------------
--DROP PROCEDURE delete_auction_procedure;
PROCEDURE delete_auction_procedure(
    id_p INT)
IS
BEGIN
    delete_auction_items_procedure(id_p);
    DELETE FROM Auction
        WHERE id = id_p;
EXCEPTION
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with delete_auction');
END delete_auction_procedure;
------------------------ [GET CURRENT AUCTION] ------------------------------------
--DROP FUNCTION get_current_auction_function
FUNCTION get_current_auction_function(
    date_p DATE)
RETURN sys_refcursor IS
    get_current_auction sys_refcursor;
BEGIN
    OPEN get_current_auction FOR
        SELECT *
            FROM Auction
                WHERE startdate = date_p;
RETURN get_current_auction;
EXCEPTION
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with get_current_auction_function');
END get_current_auction_function;


------------------------ [FILL AUCTION] ------------------------------------
--DROP FUNCTION fill_auction_function
FUNCTION fill_auction_function(
    auctionid_p INT,
    date_p      DATE,
    category_p  INT)
RETURN sys_refcursor IS
    CURSOR fill_auction IS SELECT Item.Id FROM Item
        LEFT OUTER JOIN itemsauction ON
                        Item.Id = itemsauction.Itemid
                   JOIN Itemscategory ON
                        Item.Id = itemscategory.Itemid
        WHERE typeid = 1            AND
              endtime >= date_p     AND
              categoryId=category_p AND
              winnerPrice=0;
    rec fill_auction%rowtype;
    counter int := 1;
BEGIN
    OPEN fill_auction;
    FETCH fill_auction INTO rec;
      WHILE(fill_auction%FOUND AND counter != 13)
        LOOP
            seller_package.add_items_auction_procedure(auctionid_p, rec.id);
            FETCH fill_auction INTO rec;
            counter:=counter+1;
        END LOOP;
      CLOSE fill_auction;
EXCEPTION
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with fill_auction');
END fill_auction_function;

------------------------ [GET ITEM] ------------------------------------
--DROP FUNCTION get_item_procedure
FUNCTION get_item_function(item in ITEM.ID%type)
RETURN sys_refcursor IS
    item_cursor sys_refcursor;
BEGIN
    OPEN item_cursor FOR
    SELECT id,
           title,
           description,
           endtime,
           startprice,
           winnerprice
    FROM Item WHERE
    (title LIKE '%' || item || '%' OR
     description LIKE '%' || item || '%')
                   AND typeid = 2;
RETURN(item_cursor);
EXCEPTION
    WHEN OTHERS THEN RAISE_APPLICATION_ERROR
        (-20010, 'Something went wrong with get_item_procedure');
END get_item_function;

------------------------ [GET ITEM CATEGORY] ------------------------------------
--DROP FUNCTION get_item_category_function
FUNCTION get_item_category_function(
    type INT)
    RETURN sys_refcursor IS
    item_category sys_refcursor;
BEGIN
     OPEN item_category
        FOR SELECT id, title,
                  description, endtime,
                  startprice,  winnerprice,
                  title category_title
        FROM ITEM_CATEGORY_VIEW
        WHERE id = type;
RETURN (item_category);
EXCEPTION
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with get_item_category_function');
END get_item_category_function;

------------------------ [DELETE AUCTION ITEMS] ------------------------------------
--DROP PROCEDURE delete_auction_items_procedure;
PROCEDURE delete_auction_items_procedure(
    auctionid_p INT)
IS
BEGIN
    DELETE FROM ItemsAuction
        WHERE auctionid = auctionid_p;
END delete_auction_items_procedure;

------------------------ [GET USERS PAGINATION] ------------------------------------
FUNCTION get_all_users_pagination(
        page_number_in NUMBER,
        page_size_in NUMBER)
    RETURN sys_refcursor IS
        users_cursor sys_refcursor;
BEGIN
     OPEN users_cursor FOR
        SELECT * FROM
            (SELECT ROWNUM AS row_num, users.*
                FROM users
                    WHERE ROWNUM <= page_number_in * page_size_in)
            WHERE row_num > (page_number_in - 1) * page_size_in;
     RETURN users_cursor;
    EXCEPTION
        WHEN OTHERS THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with get_all_users_pagination');
END get_all_users_pagination;

END;

--============================= [SELLER] ================================--
CREATE OR REPLACE PACKAGE BODY seller_package AS
------------------------ [PASSWORD ENCRYPTION] -------------------------------------
--DROP FUNCTION encrypt_password;
FUNCTION encrypt_password(password IN VARCHAR2) RETURN users.password%type IS
        hash users.password%type;
    BEGIN
        hash := utl_raw.cast_to_raw(utl_encode.base64_encode(utl_raw.cast_to_raw(password)));
        RETURN hash;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001, 'Error encrypting password');
END encrypt_password;
------------------------ [DELETE ITEMS CATEGORY] ------------------------------------
--DROP PROCEDURE delete_items_category_procedure;
PROCEDURE delete_items_category_procedure(
    itemid_p INT)
IS
BEGIN
    DELETE FROM ItemsCategory
           WHERE itemid = itemid_p;
END delete_items_category_procedure;

------------------------ [ADD ITEMS CATEGORY] ------------------------------------
--DROP PROCEDURE add_items_category_procedure;
PROCEDURE add_items_category_procedure(
    itemid_p     INT,
    categoryid_p INT)
IS
BEGIN
    INSERT INTO ItemsCategory
        (itemid, categoryid)
        VALUES (itemid_p, categoryid_p);
END add_items_category_procedure;
------------------------ [ADD ITEM] ------------------------------------
--DROP PROCEDURE insert_item_procedure;
PROCEDURE insert_item_procedure(
    item_cursor OUT sys_refcursor,
    title_p       VARCHAR,
	description_p VARCHAR,
	userid_p      INT,
	endtime_p     DATE,
	startprice_p  INT,
	typeid_p      INT)
IS
    count_p INT;
    NOT_FOUND_TYPE EXCEPTION;
    INVALID_PRICE EXCEPTION;
BEGIN
  OPEN item_cursor FOR
      SELECT count(1) INTO count_p
                        FROM auctiontype
                            WHERE id = typeid_p;
    IF (count_p = 0) THEN
        RAISE NOT_FOUND_TYPE;
    ELSIF (startprice_p < 0) THEN
        RAISE INVALID_PRICE;
    ELSE
    INSERT INTO Item
      (
        title,
      	description,
      	userid,
      	endTime,
      	startprice,
      	typeId
      )
    VALUES
      (
        title_p,
        description_p,
      	userid_p,
      	endtime_p,
      	startprice_p,
      	typeid_p
      );
    END IF;
EXCEPTION
    WHEN NOT_FOUND_TYPE
        THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find type!');
    WHEN INVALID_PRICE
        THEN RAISE_APPLICATION_ERROR(-20003, 'Invalid price!');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR(-20007, sqlerrm);
END;

------------------------ [GET ITEM] ------------------------------------
--DROP FUNCTION get_item_procedure
FUNCTION get_item_function(item in ITEM.ID%type)
RETURN sys_refcursor IS
    item_cursor sys_refcursor;
BEGIN
    OPEN item_cursor FOR
    SELECT id,
           title,
           description,
           endtime,
           startprice,
           winnerprice
    FROM Item WHERE
    (title LIKE '%' || item || '%' OR
     description LIKE '%' || item || '%')
                   AND typeid = 2;
RETURN(item_cursor);
EXCEPTION
    WHEN OTHERS THEN RAISE_APPLICATION_ERROR
        (-20010, 'Something went wrong with get_item_procedure');
END get_item_function;

------------------------ [GET ITEM CATEGORY] ------------------------------------
--DROP FUNCTION get_item_category_function
FUNCTION get_item_category_function(
    type INT)
    RETURN sys_refcursor IS
    item_category sys_refcursor;
BEGIN
     OPEN item_category
        FOR SELECT id, title,
                  description, endtime,
                  startprice,  winnerprice,
                  title category_title
        FROM ITEM_CATEGORY_VIEW
        WHERE id = type;
RETURN (item_category);
EXCEPTION
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with get_item_category_function');
END get_item_category_function;

------------------------ [DELETE ITEM] ------------------------------------
--DROP PROCEDURE delete_item_procedure
PROCEDURE delete_item_procedure(
    id_p INT)
IS
BEGIN
    seller_package.delete_items_category_procedure(id_p);
    DELETE FROM Item
        WHERE id = id_p;
EXCEPTION
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with delete_item_procedure');
END delete_item_procedure;

------------------------ [DELETE AUCTION ITEMS] ------------------------------------
--DROP PROCEDURE delete_auction_items_procedure;
PROCEDURE delete_auction_items_procedure(
    auctionid_p INT)
IS
BEGIN
    DELETE FROM ItemsAuction
        WHERE auctionid = auctionid_p;
END delete_auction_items_procedure;

------------------------ [ADD ITEMS AUCTION] ------------------------------------
--DROP PROCEDURE add_items_auction_procedure;
PROCEDURE add_items_auction_procedure(
    auctionid_p INT,
    itemid_p INT)
IS
    count_p int;
    ITEM_EXISTS EXCEPTION;
BEGIN
IF count_p=0 THEN
    INSERT INTO ItemsAuction
        (auctionid, itemid)
        VALUES (auctionid_p, itemid_p);
ELSIF count_p>0 THEN
    RAISE ITEM_EXISTS;
END IF;
EXCEPTION
    WHEN ITEM_EXISTS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Item already exists in auction!');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with add_items_auction_procedure');
END add_items_auction_procedure;

END;


--============================= [BUYER] ================================--
CREATE OR REPLACE PACKAGE BODY buyer_package AS

------------------------ [PASSWORD ENCRYPTION] -------------------------------------
--DROP FUNCTION encrypt_password;
FUNCTION encrypt_password(password IN VARCHAR2) RETURN users.password%type IS
        hash users.password%type;
    BEGIN
        hash := utl_raw.cast_to_raw(utl_encode.base64_encode(utl_raw.cast_to_raw(password)));
        RETURN hash;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001, 'Error encrypting password');
END encrypt_password;

------------------------ [SIGN UP] -------------------------------------------------
--DROP PROCEDURE signup_procedure;
PROCEDURE signup_procedure(
    email_p IN VARCHAR2,
    password_p IN VARCHAR2,
    username_P IN VARCHAR2) IS
    password_hash users.password%type;
    BEGIN
        password_hash := encrypt_password(password_p);
        INSERT INTO users (email, password, username, role_id)
        VALUES (email_p, password_hash, username_p, 3);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Username already exists');
END signup_procedure;

------------------------ [SIGN IN] -------------------------------------------------
--DROP PROCEDURE signin_procedure;
PROCEDURE signin_procedure
    (
    p_login IN OUT users.email%TYPE,
    p_password IN users.password%TYPE
    )
IS
    NULL_PARAMETER EXCEPTION;
    user_found NUMBER;
BEGIN

    IF(p_password IS NULL)
        THEN RAISE NULL_PARAMETER;
    END IF;

    SELECT COUNT(*)
        INTO user_found
            FROM users
                WHERE email = p_login;

    IF(user_found != 1)
        THEN RAISE NO_DATA_FOUND;
    END IF;

    SELECT email
        INTO p_login
            FROM users
                WHERE email= p_login
        AND encrypt_password(UPPER(p_password)) = password;

EXCEPTION
    WHEN NULL_PARAMETER
        THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
    WHEN NO_DATA_FOUND
        THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find user!');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR(-20007, sqlerrm);
END signin_procedure;


------------------------ [ADD MONEY] ------------------------------------
--DROP PROCEDURE add_money_procedure;
PROCEDURE add_money_procedure(
    p_id    INT,
    p_value INT)
IS
    NULL_PARAMETER EXCEPTION;
    user_found NUMBER;
BEGIN
    UPDATE Users
        SET account = account + p_value
            WHERE id = p_id;

    IF(p_id IS NULL OR p_value IS NULL)
        THEN RAISE NULL_PARAMETER;
    END IF;

    IF(user_found != 1)
        THEN RAISE NO_DATA_FOUND;
    END IF;

EXCEPTION
    WHEN NULL_PARAMETER
        THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
    WHEN NO_DATA_FOUND
        THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find user!');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR(-20007, sqlerrm);
END;
------------------------ [GET ITEM] ------------------------------------
--DROP FUNCTION get_item_function;
FUNCTION get_item_function(item in ITEM.ID%type)
RETURN sys_refcursor IS
    item_cursor sys_refcursor;
BEGIN
    OPEN item_cursor FOR
    SELECT id,
           title,
           description,
           endtime,
           startprice,
           winnerprice
    FROM Item WHERE
    (title LIKE '%' || item || '%' OR
     description LIKE '%' || item || '%')
                   AND typeid = 2;
RETURN(item_cursor);
EXCEPTION
    WHEN OTHERS THEN RAISE_APPLICATION_ERROR
        (-20010, 'Something went wrong with get_item_procedure');
END get_item_function;

------------------------ [GET ITEM CATEGORY] ------------------------------------
--DROP FUNCTION get_item_category_function
FUNCTION get_item_category_function(
    type INT)
    RETURN sys_refcursor IS
    item_category sys_refcursor;
BEGIN
     OPEN item_category
        FOR SELECT id, title,
                  description, endtime,
                  startprice,  winnerprice,
                  title category_title
        FROM ITEM_CATEGORY_VIEW
        WHERE id = type;
RETURN (item_category);
EXCEPTION
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with get_item_category_function');
END get_item_category_function;

------------------------ [UPDATE PRICE] ------------------------------------
--DROP FUNCTION update_price_function
FUNCTION update_price_function(
    id_p      INT,
	buyerid_p INT)
RETURN sys_refcursor IS
    count_p           INT;
    perc              INT;
    countBefore       INT;
    bid               INT;
    sid               INT;
    money             INT;
    date_p            DATE;
    update_price      sys_refcursor;
    COUNT_TOO_HIGH    EXCEPTION;
    BUYER_CANNOT_BID  EXCEPTION;
    SELLER_CANNOT_BID EXCEPTION;
    BUYER_NO_MONEY    EXCEPTION;
    SELLER_NO_MONEY   EXCEPTION;
    AUC_ENDED         EXCEPTION;

BEGIN
    OPEN update_price FOR
    SELECT winnerprice,
           startprice,
           userid,
           buyerid,
           (winnerprice - startprice),
           endtime
    INTO count_p, perc, sid, bid, countbefore, date_p
        FROM Item
            WHERE id = id_p;

    SELECT account
        INTO money
            FROM Users
                WHERE id = buyerid_p;

    IF count_p = 0
        THEN count_p := perc;
    ELSE count_p := count_p+(perc*0.1);
    END IF;

    IF(count_p >= (perc*0.1)*25)
        THEN RAISE COUNT_TOO_HIGH;
    ELSIF(buyerid_p = sid)
        THEN RAISE BUYER_CANNOT_BID;
    ELSIF(buyerid_p = bid)
        THEN RAISE SELLER_CANNOT_BID;
    ELSIF(money < count_p)
        THEN RAISE BUYER_NO_MONEY;
    ELSIF(money < perc)
        THEN RAISE SELLER_NO_MONEY;
    ELSIF(date_p < TRUNC(sysdate))
        THEN RAISE AUC_ENDED;
    END IF;

  UPDATE Users
    SET account = money - count_p
        WHERE id = buyerid_p;
  UPDATE Users
    SET account = money + countbefore
        WHERE id = bid;
  UPDATE Item
    SET buyerid = buyerid_p,
        winnerPrice = count_p
        WHERE id=id_p;
RETURN (update_price);
EXCEPTION
    WHEN COUNT_TOO_HIGH
        THEN RAISE_APPLICATION_ERROR(-20003, 'Count too high!');
    WHEN BUYER_CANNOT_BID
        THEN RAISE_APPLICATION_ERROR(-20004, 'Buyer cannot bid!');
    WHEN SELLER_CANNOT_BID
        THEN RAISE_APPLICATION_ERROR(-20005, 'Seller cannot bid!');
    WHEN BUYER_NO_MONEY
        THEN RAISE_APPLICATION_ERROR(-20006, 'Buyer has no money!');
    WHEN SELLER_NO_MONEY
        THEN RAISE_APPLICATION_ERROR(-20007, 'Seller has no money!');
    WHEN AUC_ENDED
        THEN RAISE_APPLICATION_ERROR(-20008, 'Auction ended!');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR(-20009, sqlerrm);
END update_price_function;

------------------------ [GET CURRENT AUCTION] ------------------------------------
--DROP FUNCTION get_current_auction_function
FUNCTION get_current_auction_function(
    date_p DATE)
RETURN sys_refcursor IS
    get_current_auction sys_refcursor;
BEGIN
    OPEN get_current_auction FOR
        SELECT *
            FROM Auction
                WHERE startdate = date_p;
RETURN get_current_auction;
EXCEPTION
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with get_current_auction_function');
END get_current_auction_function;

------------------------ [NOTIFICATION] ------------------------------------
--DROP PROCEDURE get_user_notifications;
FUNCTION get_user_notifications(
        username_in in users.username%type)
RETURN sys_refcursor IS
        user_id              users.id%type;
        notifications_cursor sys_refcursor;
    BEGIN
        SELECT id INTO user_id
                  FROM users
                  WHERE username = username_in;
        OPEN notifications_cursor FOR SELECT id, operation_date, message
                                      FROM notifications
                                      WHERE user_id = user_id;
        RETURN notifications_cursor;
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR(sqlcode, sqlerrm);
END get_user_notifications;

------------------------ [REMOVE NOTIFICATION] ------------------------------------
--DROP PROCEDURE remove_notification_procedure;
PROCEDURE remove_notification(
        notification_id in notifications.id%type)
IS
    BEGIN
        DELETE FROM notifications
        WHERE id = notification_id;
    EXCEPTION
        WHEN OTHERS
            THEN
                ROLLBACK;
                RAISE_APPLICATION_ERROR(sqlcode, sqlerrm);
END remove_notification;

END;