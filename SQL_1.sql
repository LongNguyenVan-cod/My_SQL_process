
-- Tao database va goi database su dung
create DATABASE MX_practices
use MX_practices


-- Lay ra cac thong tin theo mot so dieu kien ap dung
select
    so.TerritoryKey,
    sum(so.SalesAmount) as "Total_Amount",
    sum(case when year(so.OrderDate)= 2015 then so.SalesAmount else 0 end) as "Sales_Amount_2015",
    count(distinct so.CustomerKey) as Customercount,
    count(distinct case when year(so.OrderDate) = 2015 then so.CustomerKey else null end) as "Customer_2015_count",
    count(distinct so.OrderNumber) as "OrderNumber_count",
    count(distinct case when year(so.OrderDate) = 2015 then so.OrderNumber else null end) as "OrderNumber_2015_count"
from [dbo].[SaleOrders] as so
group by so.TerritoryKey
order by 1

-------------
select 
    count(distinct so.CustomerKey) 
from [dbo].[SaleOrders] as so
where so.TerritoryKey = 1 and year(so.OrderDate) =  2015
--------------


--Phân loại khách hàng theo RFM
--R là bao lâu rồi chưa mua hàng
--F là số đơn
--M là doanh thu từ khách hàng đấy

with tb1 as (
    select 
        so.CustomerKey,
        datediff(day, max(so.OrderDate), '2017-07-01') as R,
        count(distinct so.OrderNumber) as F,
        sum(so.SalesAmount) as M
    from [dbo].[SaleOrders] as so
    group by so.CustomerKey
    ),
    tb2 as (
    select *,
        PERCENT_RANK() over (order by R) as "R_percent",
        PERCENT_RANK() over (order by F) as "F_percent",
        PERCENT_RANK() over (order by M) as "M_percent"
    from tb1
    ),
    tb3 as (
    select *,
        case 
            when R_percent < 0.2 then '5'
            when R_percent < 0.4 then '4'
            when R_percent < 0.6 then '3'
            when R_percent < 0.8 then '2'
            when R_percent <= 1 then '1'
        end as R_score,
        case 
            when F_percent < 0.2 then '1'
            when F_percent < 0.4 then '2'
            when F_percent < 0.6 then '3'
            when F_percent < 0.8 then '4'
            when F_percent <= 1 then '5'
        end as F_score,
        case 
            when M_percent < 0.2 then '1'
            when M_percent < 0.4 then '2'
            when M_percent < 0.6 then '3'
            when M_percent < 0.8 then '4'
            when M_percent <= 1 then '5'
        end as M_score
    from tb2
    ),
    tb4 as (
    select 
        Segment,
        trim([value]) as "RFM_score"
    from [dbo].[RankRFM]
    cross apply string_split(Scores, ',')
    )

select 
    CustomerKey,
    R_score,
    F_score,
    M_score,
    concat(R_score, F_score, M_score) as "RFM_score",
    Segment
from tb3 
left join tb4 
    on concat(tb3.R_score, tb3.F_score, tb3.M_score) = tb4.RFM_score
-- order by R 




-- Xem thong tin bang
select top(20)*
from [dbo].[SaleOrders] as so

select 
    max(so.OrderDate),
    min(so.OrderDate)
from [dbo].[SaleOrders] as so 

select * from [dbo].[RankRFM]

