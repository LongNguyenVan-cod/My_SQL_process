
create DATABASE Business
use Business

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
-- , tb5 as (
--     select 
--         CustomerKey,
--         R_score,
--         F_score,
--         M_score,
--         concat(R_score, F_score, M_score) as "RFM_score",
--         Segment
--     from tb3 
--     left join tb4 
--         on concat(tb3.R_score, tb3.F_score, tb3.M_score) = tb4.RFM_score
-- )
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

-- Tinh phan tram khach hang theo tung phan khuc
-- select 
--     Segment,
--     count(CustomerKey) as 'NumberOfCus',
--     -- sum(count(CustomerKey)) over() as 'Total',
--     round(cast(count(CustomerKey) as float)*100 / cast(sum(count(CustomerKey)) over() as float), 2) as 'Percent %'
-- from tb5
-- group by Segment
-- order by 3 desc 





