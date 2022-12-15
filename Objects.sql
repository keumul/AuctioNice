------------------------------------- [trigger] -------------------------------------
CREATE OR REPLACE TRIGGER notify_rate_increase
    FOR UPDATE OF winnerprice
    ON Item
    COMPOUND TRIGGER
    message varchar2(1000);
BEFORE EACH ROW IS
BEGIN
    IF :OLD.winnerprice < :NEW.winnerprice THEN
        message := 'The price of item ' || :NEW.id || ' has increased to ' || :NEW.winnerprice;
        DBMS_ALERT.SIGNAL('rate_increase', message);
    END IF;
END BEFORE EACH ROW;
    AFTER STATEMENT IS
BEGIN
        IF message IS NOT NULL THEN
            INSERT INTO NOTIFICATIONS(message) VALUES (message);
        END IF;
END AFTER STATEMENT;
END notify_rate_increase;

------------------------------------- [view] -------------------------------------
CREATE OR REPLACE VIEW item_category_view
AS
SELECT item.id, item.title,
                  item.description, item.endtime,
                  item.startprice,  item.winnerprice,
                  category.title category_title
FROM Item
    JOIN ItemsCategory items_category
        ON Item.id = items_category.itemid
    JOIN Category
        ON items_category.categoryid = category.id;

select * from item_category_view;