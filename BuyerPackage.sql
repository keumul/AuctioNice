--DROP PACKAGE buyer_package;

CREATE OR REPLACE PACKAGE buyer_package AS
    PROCEDURE signup_procedure(
        email_p IN VARCHAR2,
        password_p IN VARCHAR2,
        username_P IN VARCHAR2);
    FUNCTION update_price_function(
    id_p number,
    buyerid_p number) RETURN SYS_REFCURSOR;
    PROCEDURE signin_procedure(
        p_login IN OUT VARCHAR2,
        p_password IN VARCHAR2);
    FUNCTION  get_user_notifications(username_in in VARCHAR2) RETURN SYS_REFCURSOR;
    PROCEDURE add_money_procedure(
        p_id INT,
        p_value INT);
    FUNCTION get_item_function(item IN NUMBER) RETURN SYS_REFCURSOR;
    FUNCTION get_item_category_function(type_ INT) RETURN SYS_REFCURSOR;
    FUNCTION get_current_auction_function(date_p DATE) RETURN SYS_REFCURSOR;
END buyer_package;

CREATE OR REPLACE PACKAGE BODY buyer_package AS
------------------------ [SIGN UP] -------------------------------------------------
--DROP PROCEDURE signup_procedure;
    PROCEDURE signup_procedure(
        email_p IN VARCHAR2,
        password_p IN VARCHAR2,
        username_p IN VARCHAR2) IS
    BEGIN
        INSERT INTO users (email, password, username, role_id)
        VALUES (email_p, ORA_HASH(password_p), username_p, 3);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Username already exists');
    END signup_procedure;

------------------------ [SIGN IN] -------------------------------------------------
--DROP PROCEDURE signin_procedure;
    PROCEDURE signin_procedure(
        p_login IN OUT VARCHAR2,
        p_password IN VARCHAR2
    )
        IS
        notification_ sys_refcursor;
        NULL_PARAMETER EXCEPTION;
        user_found NUMBER;
    BEGIN
        OPEN notification_ FOR
            SELECT * FROM NOTIFICATIONS WHERE user_id = (SELECT id FROM users WHERE email = p_login);
        IF (p_password IS NULL)
        THEN
            RAISE NULL_PARAMETER;
        END IF;

        SELECT COUNT(*)
        INTO user_found
        FROM users
        WHERE email = p_login;
        COMMIT ;
        IF (user_found != 1)
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        SELECT email
        INTO p_login
        FROM users
        WHERE email = p_login
        AND ORA_HASH(p_password) = password;
        COMMIT ;
    EXCEPTION
        WHEN NULL_PARAMETER
            THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find user!');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR(-20007, SQLERRM);
    END signin_procedure;


------------------------ [ADD MONEY] ------------------------------------
--DROP PROCEDURE add_money_procedure;
    PROCEDURE add_money_procedure(
        p_id INT,
        p_value INT)
        IS
        NULL_PARAMETER EXCEPTION;
        user_found NUMBER;
    BEGIN
        UPDATE Users
        SET account = account + p_value
        WHERE id = p_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Money added successfully!');
        IF (p_id IS NULL OR p_value IS NULL)
        THEN
            RAISE NULL_PARAMETER;
        END IF;

        IF (user_found != 1)
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

    EXCEPTION
        WHEN NULL_PARAMETER
            THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find user!');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR(-20007, SQLERRM);
    END;

-- ------------------------ [GET ITEM] ------------------------------------
--DROP FUNCTION get_item_function;
    FUNCTION get_item_function(item IN NUMBER)
        RETURN sys_refcursor AS
        item_cursor sys_refcursor;
    BEGIN
        OPEN item_cursor FOR
            SELECT id,
                   title,
                   description,
                   endtime,
                   startprice,
                   winnerprice
            FROM Item
            WHERE id = item;
        RETURN (item_cursor);
    EXCEPTION
        WHEN OTHERS THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with get_item_procedure');
    END get_item_function;

------------------------ [GET ITEM CATEGORY] ------------------------------------
--DROP FUNCTION get_item_category_function
    FUNCTION get_item_category_function(
        type_ INT)
        RETURN sys_refcursor AS
        item_category sys_refcursor;
    BEGIN
        OPEN item_category
            FOR SELECT id,
                       title,
                       description,
                       endtime,
                       startprice,
                       winnerprice,
                       category_title
                FROM ITEM_CATEGORY_VIEW
                WHERE id = type_;
        RETURN (item_category);
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with get_item_category_function');
    END get_item_category_function;

-- ------------------------ [UPDATE PRICE] ------------------------------------
--DROP FUNCTION update_price_function
    FUNCTION update_price_function(
        id_p number,
        buyerid_p number)
        RETURN sys_refcursor IS
        count_p      number := 0;
        perc         number;
        countBefore  number;
        bid          number;
        money        number;
        oldmoney     number;
        date_p       DATE;
        winner_      number;
        startprice_  number;
        update_price sys_refcursor;
        BUYER_CANNOT_BID EXCEPTION;
        BUYER_NO_MONEY EXCEPTION;
        AUC_ENDED EXCEPTION;

    BEGIN
        SELECT WINNERPRICE INTO winner_ FROM ITEM WHERE ID = id_p;
        SELECT STARTPRICE INTO startprice_ FROM ITEM WHERE ID = id_p;
        IF (winner_ IS NULL) THEN winner_ := startprice_; END IF;
        COMMIT;
        SELECT BUYERID INTO bid FROM ITEM WHERE ID = id_p;
        SELECT account
        INTO money
        FROM Users
        WHERE id = buyerid_p;
        SELECT account
        INTO oldmoney
        FROM Users
        WHERE id = bid;
        SELECT WINNERPRICE
        INTO countBefore
        FROM Item
        WHERE id = id_p;

        SELECT WINNERPRICE
        INTO perc
        FROM Item
        WHERE id = id_p;
        count_p := perc;
        count_p := count_p + (perc * 0.1);

        IF (buyerid_p = bid)
        THEN
            RAISE BUYER_CANNOT_BID;
        ELSIF (money < count_p)
        THEN
            RAISE BUYER_NO_MONEY;
        ELSIF (date_p < TRUNC(SYSDATE))
        THEN
            RAISE AUC_ENDED;
        END IF;

        UPDATE Users
        SET account = money - count_p
        WHERE id = buyerid_p;

        INSERT INTO NOTIFICATIONS(OPERATION_DATE, MESSAGE, USER_ID)
        VALUES (SYSDATE, 'You have been outbid on item ' || id_p, bid);

        UPDATE Users
        SET account = oldmoney + countbefore
        WHERE id = bid;

        UPDATE Item
        SET buyerid     = buyerid_p,
            winnerPrice = count_p
        WHERE id = id_p;

        OPEN update_price FOR
            SELECT startprice,
                   userid,
                   buyerid,
                   winnerprice,
                   endtime
            FROM Item
            WHERE id = id_p;
        RETURN (update_price);
    EXCEPTION
        WHEN BUYER_CANNOT_BID
            THEN RAISE_APPLICATION_ERROR(-20004, 'Buyer cannot bid!');
        WHEN BUYER_NO_MONEY
            THEN RAISE_APPLICATION_ERROR(-20006, 'Buyer has no money!');
        WHEN AUC_ENDED
            THEN RAISE_APPLICATION_ERROR(-20008, 'Auction ended!');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR(-20009, SQLERRM);
    END update_price_function;
--
-- ------------------------ [GET CURRENT AUCTION] ------------------------------------
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


-- ------------------------ [NOTIFICATION] ------------------------------------
--DROP PROCEDURE get_user_notifications;
FUNCTION get_user_notifications(
        username_in in varchar2)
RETURN sys_refcursor IS
        user_id_              INT;
        notifications_cursor sys_refcursor;
    BEGIN
        SELECT id INTO user_id_
                  FROM users
                  WHERE username = username_in;
        OPEN notifications_cursor FOR SELECT id, operation_date, message, user_id, is_read
                                       FROM notifications
                                       WHERE user_id = user_id_ AND is_read = 0;

        UPDATE notifications SET is_read = 1 WHERE user_id = user_id_;
        COMMIT ;
        RETURN notifications_cursor;
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with get_user_notifications');
END get_user_notifications;

END buyer_package;




----------------------------------- [TEST] -----------------------------------
-- buyer sign up
BEGIN
    buyer_package.signup_procedure('buyer2@gmail.com', '1111', 'buyer2');
END;


-- buyer login
DECLARE
    login_ varchar2(255) := 'buyer1@gmail.com';
BEGIN
    buyer_package.signin_procedure(login_, '1111');
END;

-- buyer add money
DECLARE
    money_p INT := 1000;
    p_id    INT := 101;
BEGIN
    buyer_package.add_money_procedure(p_id, money_p);
END;

-- buyer update price function
DECLARE
    startprice_      number;
    userid_          number;
    buyerid_         number;
    realwinnerprice_ number;
    endtime_         DATE;
    cursor_          sys_refcursor;
BEGIN
    cursor_ := buyer_package.update_price_function(23, 121);
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
