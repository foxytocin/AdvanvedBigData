explain plan for
select distinct ProductName as Ten_Most_Expensive_Products, 
         UnitPrice
from Products a
where 10 >= (select count(distinct UnitPrice)
                    from Products b
                    where b.UnitPrice >= a.UnitPrice)
order by UnitPrice desc;

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-----------------------------------------------

explain plan for
select ProductName as Ten_Most_Expensive_Products, UnitPrice 
from Products 
where UnitPrice >= (select min(UnitPrice)
                    from (select ProductName, 
                          UnitPrice
                          from Products
                          order by UnitPrice desc)
                    where rownum <= 10)
order by UnitPrice desc;

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-----------------------------------------------

explain plan for
select * from orders

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-----------------------------------------------

create index orders_shippeddate on orders (shippeddate)

explain plan for
select * from orders
where ShippedDate between to_date('1997-01-30', 'yyyy-mm-dd') and to_date('1997-01-31', 'yyyy-mm-dd')

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-----------------------------------------------

explain plan for
select /*+ FULL(orders) */ * from orders
where ShippedDate between to_date('1997-01-30', 'yyyy-mm-dd') and to_date('1997-01-31', 'yyyy-mm-dd')

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-----------------------------------------------

explain plan for
select c.*
from customers c inner join orders o
    on c.customerid = o.customerid
where o.ShippedDate between to_date('1997-01-31', 'yyyy-mm-dd') and to_date('1997-01-31', 'yyyy-mm-dd')
;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-----------------------------------------------

explain plan for
select /*+ordered */ c.*
from customers c inner join orders o
    on c.customerid = o.customerid
where o.ShippedDate between to_date('1997-01-31', 'yyyy-mm-dd') and to_date('1997-01-31', 'yyyy-mm-dd')
;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());
