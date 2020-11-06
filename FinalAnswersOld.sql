-- Query 1:
------------
select OrderID, 
   to_char(sum(UnitPrice * Quantity * (1 - Discount)), 'fm999999.90') as Subtotal
from orderdetails
group by OrderID
order by OrderID;


-- Query 2:
------------
Select Distinct A.Shippeddate As Shippeddate, 
    A.Orderid, 
    b.Subtotal, 
    extract(year from A.Shippeddate) As Year
From Orders A 
inner join
(
    -- Get subtotal for each order
    select distinct OrderID, 
        to_char(sum(UnitPrice * Quantity * (1 - Discount)), 'fm999999.90') as Subtotal
    from orderdetails
    group by OrderID    
) b on a.OrderID = b.OrderID
where a.ShippedDate is not null
    and a.ShippedDate between to_date('1996-12-24', 'yyyy-mm-dd') and to_date('1997-09-30', 'yyyy-mm-dd')
order by a.ShippedDate;


-- Query 3:
------------
select e.country as Country, e.lastname as LastName, e.firstname as FirstName, o.shippeddate as ShippedDate, 
o.orderid as OrderID, to_char(sum(d.unitprice*d.quantity*(1-d.discount)), 'fm999999.90') as Sale_Amount
from employees e left outer join orders o
on e.employeeid = o.employeeid
left outer join orderdetails d
on o.orderid = d.orderid
group by e.country,
e.lastname, e.firstname, o.shippeddate, o.orderid
order by e.lastname, e.firstname, e.country, o.orderid;


-- Query 4:
-----------
select distinct b.*, a.CategoryName
from Categories a 
inner join Products b on a.CategoryID = b.CategoryID
where b.Discontinued = 0
order by b.ProductName;


-- Query 5:
-----------
select ProductID, ProductName
from products
where Discontinued = 0
order by ProductName;


-- Query 6:
-----------
select distinct y.OrderID, 
    y.ProductID, 
    x.ProductName, 
    y.UnitPrice, 
    y.Quantity, 
    y.Discount, 
    round(y.UnitPrice * y.Quantity * (1 - y.Discount), 2) as ExtendedPrice
from Products x
inner join OrderDetails y on x.ProductID = y.ProductID
order by y.OrderID;


-- Query 7:
------------
select distinct a.CategoryID, 
    a.CategoryName, 
    b.ProductName, 
    sum(c.ExtendedPrice) as ProductSales
from Categories a 
inner join Products b on a.CategoryID = b.CategoryID
inner join 
(
    select distinct y.OrderID, 
        y.ProductID, 
        x.ProductName, 
        y.UnitPrice, 
        y.Quantity, 
        y.Discount, 
        round(y.UnitPrice * y.Quantity * (1 - y.Discount), 2) as ExtendedPrice
    from Products x
    inner join OrderDetails y on x.ProductID = y.ProductID
    order by y.OrderID
) c on c.ProductID = b.ProductID
inner join Orders d on d.OrderID = c.OrderID
where d.OrderDate between to_date('1997/1/1','yyyy/mm/dd') and to_date('1997/12/31','yyyy/mm/dd')
group by a.CategoryID, a.CategoryName, b.ProductName
order by a.CategoryName, b.ProductName, ProductSales;


-----------
-- Query 1
select distinct ProductName as Ten_Most_Expensive_Products, 
         UnitPrice
from Products a
where 10 >= (select count(distinct UnitPrice)
                    from Products b
                    where b.UnitPrice >= a.UnitPrice)
order by UnitPrice desc;
 
 
-- Query 2
select * from
(
    select distinct ProductName as Ten_Most_Expensive_Products, 
           UnitPrice
    from Products
    order by UnitPrice desc
) a
fetch next 10 rows only;


-- Query 9:
------------
select distinct a.CategoryName, 
    b.ProductName, 
    b.QuantityPerUnit, 
    b.UnitsInStock, 
    b.Discontinued
from Categories a
inner join Products b on a.CategoryID = b.CategoryID
where b.Discontinued = 0
order by a.CategoryName, b.ProductName;


-- Query 10:
-------------
select City, CompanyName, ContactName, 'Customers' as Relationship 
from Customers
union
select City, CompanyName, ContactName, 'Suppliers'
from Suppliers
order by City, CompanyName;


-- Query 11:
-------------
select distinct ProductName, UnitPrice
from Products
where UnitPrice > (select avg(UnitPrice) from Products)
order by UnitPrice;


-- Query 12:
-------------
select distinct a.CategoryName, 
    b.ProductName, 
    sum(c.UnitPrice * c.Quantity * (1 - c.Discount)) as ProductSales,
    concat('Qtr ', to_char(d.ShippedDate, 'Q')) as ShippedQuarter
from Categories a
inner join Products b on a.CategoryID = b.CategoryID
inner join OrderDetails c on b.ProductID = c.ProductID
inner join Orders d on d.OrderID = c.OrderID
where d.ShippedDate between to_date('1997-01-01','yyyy-mm-dd') and to_date('1997-12-31','yyyy-mm-dd')
group by a.CategoryName, 
    b.ProductName, 
    concat('Qtr ', to_char(d.ShippedDate,'Q'))
order by a.CategoryName, 
    b.ProductName, 
    ShippedQuarter;


-- Query 13:
-------------
select CategoryName, sum(ProductSales) as CategorySales
from
(
    select distinct a.CategoryName, 
        b.ProductName, 
        sum(c.UnitPrice * c.Quantity * (1 - c.Discount)) as ProductSales,
        concat('Qtr ', to_char(d.ShippedDate, 'Q')) as ShippedQuarter
    from Categories a
    inner join Products b on a.CategoryID = b.CategoryID
    inner join OrderDetails c on b.ProductID = c.ProductID
    inner join Orders d on d.OrderID = c.OrderID 
    where d.ShippedDate between to_date('1997-01-01', 'yyyy-mm-dd') and to_date('1997-12-31', 'yyyy-mm-dd')
    group by a.CategoryName, 
        b.ProductName, 
        concat('Qtr ', to_char(d.ShippedDate, 'Q'))
    order by 
    a.CategoryName, 
        b.ProductName
) x
group by ShippedQuarter, CategoryName
order by ShippedQuarter, CategoryName;


-- Query 14:
-------------
select a.ProductName, 
    d.CompanyName, 
    to_char(OrderDate, 'YYYY') as OrderYear,
    sum(case to_char(c.OrderDate, 'Q') when '1' 
        then b.UnitPrice*b.Quantity*(1-b.Discount) else 0 end) "Qtr 1",
    sum(case to_char(c.OrderDate, 'Q') when '2' 
        then b.UnitPrice*b.Quantity*(1-b.Discount) else 0 end) "Qtr 2",
    sum(case to_char(c.OrderDate, 'Q') when '3' 
        then b.UnitPrice*b.Quantity*(1-b.Discount) else 0 end) "Qtr 3",
    sum(case to_char(c.OrderDate, 'Q') when '4' 
        then b.UnitPrice*b.Quantity*(1-b.Discount) else 0 end) "Qtr 4" 
from Products a 
inner join OrderDetails b on a.ProductID = b.ProductID
inner join Orders c on c.OrderID = b.OrderID
inner join Customers d on d.CustomerID = c.CustomerID 
where c.OrderDate between to_date('1997-01-01', 'YYYY-mm-dd') and to_date('1997-12-31', 'yyyy-mm-dd')
group by a.ProductName, 
    d.CompanyName, 
    to_char(OrderDate, 'YYYY')
order by a.ProductName, d.CompanyName;


-- Query 15:
-------------
select distinct b.ShipName, 
    b.ShipAddress, 
    b.ShipCity, 
    b.ShipRegion, 
    b.ShipPostalCode, 
    b.ShipCountry, 
    b.CustomerID, 
    c.CompanyName, 
    c.Address, 
    c.City, 
    c.Region, 
    c.PostalCode, 
    c.Country, 
    concat(concat(d.FirstName,  ' '), d.LastName) as Salesperson, 
    b.OrderID, 
    b.OrderDate, 
    b.RequiredDate, 
    b.ShippedDate, 
    a.CompanyName, 
    e.ProductID, 
    f.ProductName, 
    e.UnitPrice, 
    e.Quantity, 
    e.Discount,
    e.UnitPrice * e.Quantity * (1 - e.Discount) as ExtendedPrice,
    b.Freight
from Shippers a 
inner join Orders b on a.ShipperID = b.ShipVia 
inner join Customers c on c.CustomerID = b.CustomerID
inner join Employees d on d.EmployeeID = b.EmployeeID
inner join OrderDetails e on b.OrderID = e.OrderID
inner join Products f on f.ProductID = e.ProductID
order by b.ShipName;


-- Query 16:
-------------
select c.CategoryName as "Product Category", 
       case when s.Country in 
                 ('UK','Spain','Sweden','Germany','Norway',
                  'Denmark','Netherlands','Finland','Italy','France')
            then 'Europe'
            when s.Country in ('USA','Canada','Brazil') 
            then 'America'
            else 'Asia-Pacific'
        end as "Supplier Continent", 
        sum(p.UnitsInStock) as UnitsInStock
from Suppliers s 
inner join Products p on p.SupplierID=s.SupplierID
inner join Categories c on c.CategoryID=p.CategoryID 
group by c.CategoryName, 
         case when s.Country in 
                 ('UK','Spain','Sweden','Germany','Norway',
                  'Denmark','Netherlands','Finland','Italy','France')
              then 'Europe'
              when s.Country in ('USA','Canada','Brazil') 
              then 'America'
              else 'Asia-Pacific'
         end;
