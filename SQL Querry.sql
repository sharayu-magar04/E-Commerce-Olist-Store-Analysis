SET SQL_SAFE_UPDATES = 0;

##KPI_01
## Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

	## adding column *Weektime* to enter the weekday to weekend value 
alter table orders add column weektime varchar(20);
	## updating the *Weektime* column with the value
update orders
	set weektime = 
					case
					when dayofweek(order_purchase_timestamp) in(1,7) then "weekend"
					else "weekday"
					end;

	##result table with sum of payment as total % 
select 
	a.weektime, 
    concat(
		round(
			(sum(b.payment_value) / (select sum(payment_value) from payments))
            * 100,2)
		, '%') as Payment_percent 
from orders as a 
left join payments as b 
	on a.order_id = b.order_id 
group by a.weektime;

##KPI_02
## Number of Orders with review score 5 and payment type as credit card.

	##creating view to store the first join (creating first fileter value review_score = 5)
create view or_rev as select a.*, b.review_score  from orders as a left join reviews as b on a.order_id = b.order_id where b.review_score = 5;
	## displaying the result by combining the view and payment table (second filter payment value = credit card)
select count(a.order_id)  from or_rev as a left join payments as b on a.order_id = b.order_id where b.payment_type = 'credit_card';

##KPI_03
## Average number of days taken for order_delivered_customer_date for pet_shop
select 
	c.product_category_name,
	round( avg (TIMESTAMPDIFF(second, order_purchase_timestamp, order_delivered_customer_date)/(24*60*60)),2) as Average_delivery_days_for_oet_shop
from 
	orders as a 
left join 
	items as b on a.order_id = b.order_id
left join 
	products as c on b.product_id = c.product_id
where
	c.product_category_name = 'pet_shop'
group by c.product_category_name;
    
##KPI_04
## Average price and payment values from customers of sao paulo city
select 
	round(avg(price),2) as avg_price_sao_paulo_city,
	round(avg(payment_value),2) as avg_payment_value_sao_paulo_city
from 
	orders as a 
left join 
	payments as b on a.order_id = b.order_id
left join 
	items as c on a.order_id = c.order_id
left join
	customers as d on d.customer_id = a.customer_id
where
	d.customer_city = 'sao paulo';
    

## KPI_05
## Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
SELECT 
	review_score,
	avg(TIMESTAMPDIFF(second, order_purchase_timestamp, order_delivered_customer_date)/(24*60*60)) as days 
from 
	orders as a 
left join 
	reviews as b 
on 
	a.order_id = b.order_id 
where 
	review_score is not null
group by 
	review_score
;

