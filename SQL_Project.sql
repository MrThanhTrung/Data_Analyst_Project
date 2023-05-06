
--Business situation

select  sum (payment_amount) as Total_Revenue
, sum (order_details.quantity) as Total_Quantity
, sum (cost_of_product*order_details.quantity) as Cost
, sum (cost_after_discount*order_details.quantity) as Total_Cost_after_Discount
from Order_Details
left join Sales
on order_Details.order_id=Sales.order_id
left join Product
on Product.product_id=Sales.product_id
where category is not null
order by Total_Revenue DESC


--Business situation in the year

select order_created_month
, sum (order_details.quantity) as Total_Quantity
, sum (payment_amount) as Total_Revenue
, sum (cost_after_discount*order_details.quantity) as total_Cost
from Order_Details
left join Sales
on order_Details.order_id=Sales.order_id
left join Product
on Product.product_id=Sales.product_id
where order_created_year = '2022'
group by order_created_month
order by Total_Revenue DESC


--Top category with the highest 

select top 10 category 
, round(sum (payment_amount),2) as Total_Revenue
, sum (order_details.quantity) as Total_Quantity
, sum (cost_of_product*order_details.quantity) as Cost
, sum (cost_after_discount*order_details.quantity) as Total_Cost_after_Discount
from Order_Details
left join Sales
on order_Details.order_id=Sales.order_id
left join Product
on Product.product_id=Sales.product_id
where category is not null
group by category
order by Total_Revenue DESC


--Effects of product discounts and rating on sales

select category
, round(sum (payment_amount),2) as Total_Revenue
, sum (Product.quantity) as Total_Quantity
, Round(avg (average_review_rating),2) as Avg_Rate
, case
	when avg(discount_offered) <= 20 then 'Low'
	when avg(discount_offered) <= 40 then 'Avg'
	else 'Hight'
end as Discount_Level
from Product
left join Sales
on Product.product_id=Sales.product_id
left join Order_Details
on order_Details.order_id=Sales.order_id
where category is not null
Group by category
order by Total_revenue DESC


--Analyze the distribution of each metric

with sumary_table as (
	select Order_Details.order_id
	, sum (payment_amount) as Total_Rev
	, sum (cost_of_product) as Cost
	, sum (discount_offered) as Total_Dis
	, sum (cost_after_discount) as Total_Cos
	, sum (payment_fee) as Total_payfee
	, sum (delivery_fee) as Total_delifee
	from Order_Details
	left join Sales
	on order_Details.order_id=Sales.order_id
	left join Product
	on Product.product_id=Sales.product_id
	group by Order_Details.order_id
)
	select 'the_number_of_Revenue' as Metric
	, min (Total_Rev) as Min_value
	, max (Total_Rev) as Max_value
	, round(avg (Total_Rev),2) as Avg_value
	, round(Stdev (Total_Rev),2) as Std_value
	from sumary_table
union
	select 'the_number_of_Cost' as Metric
	, min (Cost) as Min_value
	, max (Cost) as Max_value
	, round(avg (Cost),2) as Avg_value
	, round(Stdev (Cost),2) as Std_value
	from sumary_table
union
	select 'the_number_of_Discount' as Metric
	, min (Total_Dis) as Min_value
	, max (Total_Dis) as Max_value
	, round(avg (Total_Dis),2) as Avg_value
	, round(Stdev (Total_Dis),2) as Std_value
	from sumary_table
union
	select 'the_number_of_Total_Cost' as Metric
	, min (Total_Cos) as Min_value
	, max (Total_Cos) as Max_value
	, round(avg (Total_Cos),2) as Avg_value
	, round(Stdev (Total_Cos),2) as Std_value
	from sumary_table
union
	select 'the_number_of_Paymentfee' as Metric
	, min (Total_payfee) as Min_value
	, max (Total_payfee) as Max_value
	, round(avg (Total_payfee),2) as Avg_value
	, round(Stdev (Total_payfee),2) as Std_value
	from sumary_table
union
	select 'the_number_of_Deliveryfee' as Metric
	, min (Total_delifee) as Min_value
	, max (Total_delifee) as Max_value
	, round(avg (Total_delifee),2) as Avg_value
	, round(Stdev (Total_delifee),2) as Std_value
	from sumary_table


-- Revenue on 2 e-commerce floors

select online_retail_seller 
, sum (quantity) as Total_quantity
, sum (payment_amount) as Revenue
from order_details
group by online_retail_seller


-- Compare the revenue situation on 2 e-commerce platforms

with Total_amazon as (
	select category
		, sum (order_details.quantity) as Amazon_Quantity
		, sum (payment_amount) as Amazon_Revenue
		,count (order_details.online_retail_seller) as Number_Product_seller_on_Ama
		from order_details
		left join Sales
		on order_Details.order_id=Sales.order_id
		left join Product
		on Product.product_id=Sales.product_id
	where order_details.online_retail_seller = 'Amazon'
	group by category
)
, Total_betsy as(
	select category
		, sum (order_details.quantity) as Betsy_Quantity
		, sum (payment_amount) as Betsy_Revenue
		,count (order_details.online_retail_seller) as Number_Product_seller_on_Bet
		from order_details
		left join Sales
		on order_Details.order_id=Sales.order_id
		left join Product
		on Product.product_id=Sales.product_id
	where order_details.online_retail_seller = 'Betsy'
	group by category
) 
select top 10 percent Total_Amazon.category
	, Amazon_Revenue + Betsy_Revenue as Total_Revenue
	, Number_Product_seller_on_Ama
	, Amazon_Quantity
	, Amazon_Revenue
	, Number_Product_seller_on_Bet
	, Betsy_Quantity
	, Betsy_Revenue
	from total_Amazon
	left join Total_Betsy
	on Total_Amazon.category=Total_Betsy.category
where Total_Amazon.category is not null
order by Total_Revenue DESC


--Customers who made a transaction in 2021 come back in 2022

Select customer_id
, quantity
, payment_amount
, order_created_year
from order_details
where customer_id in (select customer_id from Order_Details
					where order_created_year = '2022')
and order_created_year = '2021'
union
Select customer_id
, quantity
, payment_amount
, order_created_year
from order_details
where customer_id in (select customer_id from Order_Details
					where order_created_year = '2021')
and order_created_year = '2022'
order by order_created_year ASC, payment_amount DESC


-- Percent of sales of non-branded products

with Brand as (
	select category
		, sum (Order_Details.quantity) as Total_Quantity
		, sum (payment_amount) as Total_Revenue
		from Order_Details
		left join Sales
		on order_Details.order_id=Sales.order_id
		left join Product
		on Product.product_id=Sales.product_id
	group by category
	)
, No_brand as (
	select category
		, sum (order_details.quantity) as Nobrand_Quantity
		, sum (payment_amount) as Nobrand_Revenue
		from Order_Details
		left join Sales
		on order_Details.order_id=Sales.order_id
		left join Product
		on Product.product_id=Sales.product_id
	where product.product_id not in (select distinct product_id
								from Product 
								where brand is null)
	group by category
)
select TOP 10 percent brand.category
	, sum (Nobrand_Quantity) as Nobr_Quan
	, sum (Total_Quantity) as Total_Quan
	, sum (nobrand_Revenue) as Nobr_Rev
	, round(sum (Total_Revenue),2) as Total_Rev
	, concat(round((sum (nobrand_Revenue)/sum (Total_Revenue))*100,1),'%') as Nobrand_Revenue_Rate
	from Brand
	le
	ft join No_brand
	on brand.category=no_brand.category
where brand.category is not null
group by brand.category
order by Nobr_quan DESC