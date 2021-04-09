-- PostgreSQL 12.4

-- 1
-- выведи топ 10 вендоров с самым большим количеством заказов за последний месяц
select vendor_id as vendor, count(*) as number_of_orders
from orders
where order_date > ('now'::timestamp - '1 month'::interval)
group by vendor_id
order by count(*) desc
limit 10

-- 2
-- выведи все рестораны(vendor_name) и количество их заказов
select vendor_name, count(*) as number_of_orders
from orders o left join vendors v on o.vendor_id = v.vendor_id
group by vendor_id, vendor_name


-- 3
-- выведи всех клиентов, которые НЕ заказывали в КФС за последний месяц
select user_id as users
from orders o left join vendors v on o.vendor_id = v.vendor_id
group by user_id
having count(*) FILTER
(WHERE v.vendor_name = 'КФС' and o.order_date > ('now'::timestamp - '1 month'::interval)) = 0


-- 4
-- выведи топ 3 лучших вендора по заказам в каждом месяце за последние 12 месяцев
-- ! в последние 12 месяцев включаю текущий месяц и не включаю этот месяц в прошлом году
WITH cte AS (
  select
    o.vendor_id as vendor_id,
    v.vendor_name as vendor_name,
    EXTRACT(month from o.order_date) as month
    count(*) as number_of_orders_in_month
  from orders o left join vendors v on o.vendor_id = v.vendor_id
  -- отсекаем заказы, сделанные ранее чем 12 месяцев назад
  where
  (EXTRACT(year from o.order_date) = EXTRACT(year from 'now'::timestamp - '12 months'::interval)
  and
  EXTRACT(month from o.order_date) > EXTRACT(month from 'now'::timestamp - '12 months'::interval))
  or EXTRACT(year from o.order_date) > EXTRACT(year from 'now'::timestamp - '12 months'::interval)
  -- группируем по вендору и месяцу
  group by o.vendor_id, v.vendor_name, EXTRACT(month from o.order_date)
), cte2 AS (
  select
    *,
    row_number() over (partition by month order by number_of_orders_in_month desc) as orders_rank
  from cte
)
select month, vendor_name, number_of_orders_in_month
from cte2
where orders_rank <= 3
order by month, number_of_orders_in_month desc


-- 5
-- напиши запрос, который выводит следующую таблицу
select
  o.user_id,
  sum(v.take_rate) as revenue,
  sum(sum(v.take_rate)) over () as total_revenue,
  round((sum(v.take_rate) / sum(sum(v.take_rate)) over ()) * 100, 1) as share,
  round((sum(sum(v.take_rate)) over (order by o.user_id) / sum(sum(v.take_rate)) over ()) * 100, 1) as cumulative_share
from orders o left join vendors v on o.vendor_id = v.vendor_id
group by o.user_id
order by o.user_id
