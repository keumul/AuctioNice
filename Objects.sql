------------------------------------- [trigger] -------------------------------------
CREATE OR REPLACE TRIGGER notify_rate_increase
    FOR UPDATE OF winnerprice
    ON Item
    COMPOUND TRIGGER
    message_ varchar2(1000);
BEFORE EACH ROW IS
BEGIN
    IF :OLD.winnerprice < :NEW.winnerprice THEN
        message_ := 'The price of item ' || :NEW.id || ' has increased to ' || :NEW.winnerprice;
        INSERT INTO Notifications(operation_date, message, user_id, is_read) VALUES (SYSDATE, message_, :NEW.BUYERID, 0);
    END IF;
END BEFORE EACH ROW;
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

DROP VIEW item_category_view;

------------------------------------- [indexes] -------------------------------------
create index title_and_description_item on Item(Title, Description);
create index items_category_ItemId on ItemsCategory(itemid);
create index items_category_categoryId on ItemsCategory(categoryId);


SELECT *