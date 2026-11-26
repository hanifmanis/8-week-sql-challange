/*
Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
*/

-- ANSWER

-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(mn.price) as total_belanja
from sales s 
join menu mn on s.product_id = mn.product_id 
group by s.customer_id 

/*
referensi mencari jawaban :
1. search google "sum amount sql"
2. direct to https://www.w3schools.com/sql/sql_sum.asp
*/

-- 2. How many days has each customer visited the restaurant?
select s.customer_id ,
	count(s.order_date ) as jumlah_kunjungan
from sales s
group by s.customer_id 

/*
 Referensi : https://www.youtube.com/watch?v=xYBclb-sYQ4&list=PL-CtdCApEFH_P2_2zR6pvDublvpD3fF6W 
 materi grouping dan distinct
 */

-- 3. What was the first item from the menu purchased by each customer?
-- mencari data order di customer tertentu
select s.customer_id , mn.product_name, s.order_date 
from sales s
join menu mn on mn.product_id = s.product_id 
-- where s.customer_id = 'A'
order by s.order_date 
-- limit 1;

-- mencari data order pertama di tiap customer
-- query cte dapat dari https://www.youtube.com/watch?v=ArpVAwshAFU&t=28382s
with cte_name as(
	select -- query cte
)
select .. from cte_name;

with rn as(
	select s.customer_id , mn.product_name, s.order_date 
	from sales s
	join menu mn on mn.product_id = s.product_id 
	-- where s.customer_id = 'A'
	order by s.order_date 
)
select 
-- query di atas masi gagal

-- mencoba rank(), referensi : https://www.geeksforgeeks.org/mysql/mysql-ranking-functions/
select * ,

from sales
order by rn;

-- menggabungkan cte dengan rank
with ranked as (
	select s.customer_id , s.order_date ,s.product_id ,mn.product_name ,
	rank() over (partition by customer_id order by order_date) as 'rn'
	from sales s
	join menu mn on s.product_id = mn.product_id 
	order by rn
)
select customer_id, product_name
from ranked 
where rn = 1


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select mn.product_name, count(s.product_id) as terbeli
from sales s
join menu mn on mn.product_id = s.product_id 
group by s.product_id , mn.product_name
order by terbeli desc limit 1

-- 5. Which item was the most popular for each customer?
with ranked as(
with beli as(
select s.customer_id , mn.product_name , count(s.product_id) as terbeli
from sales s
join menu mn on mn.product_id = s.product_id 
group by s.product_id , mn.product_name,s.customer_id 
order by terbeli desc
)
select customer_id, product_name,terbeli,
rank() over (partition by customer_id order by terbeli desc) as 'rn'
from beli 
)
select customer_id, product_name,terbeli
from ranked
where rn = 1

--  6. Which item was purchased first by the customer after they became a member?
select * from members;
select * from menu;
select * from sales;

-- Membuat query untuk lihat barang dibeli setelah join, lalu tambahkan rank tiap customer
select s.customer_id , mn.product_name , m.join_date, s.order_date  ,
rank() over (partition by customer_id order by order_date)
from sales s 
join menu mn on s.product_id = mn.product_id 
left join members m on s.customer_id = m.customer_id
where s.order_date >= m.join_date 
order by order_date; 

-- Setelah ada rank, membuat query hanya menampilkan rank 1
with ranked6 as (
	select s.customer_id , mn.product_name , m.join_date, s.order_date  ,
	rank() over (partition by customer_id order by order_date) as 'rank_after_member'
	from sales s 
	join menu mn on s.product_id = mn.product_id 
	left join members m on s.customer_id = m.customer_id
	where s.order_date > m.join_date 
	order by order_date
)
select customer_id, product_name
from ranked6
where rank_after_member = 1;

-- 7. Which item was purchased just before the customer became a member?
with ranked7 as (
	select s.customer_id , mn.product_name , m.join_date, s.order_date  ,
	rank() over (partition by customer_id order by order_date) as 'rank_before_member'
	from sales s 
	join menu mn on s.product_id = mn.product_id 
	left join members m on s.customer_id = m.customer_id
	where s.order_date <= m.join_date 
	order by order_date
)
select customer_id, product_name
from ranked7
where rank_before_member = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
select 
	s.customer_id, 
	sum(mn.price ) as total_spent, COALESCE(m.join_date, 'belum member') as join_date  
from sales s 
join menu mn on s.product_id = mn.product_id 
left join members m on s.customer_id = m.customer_id 
where s.order_date <= m.join_date or m.join_date is null
group by s.customer_id,m.join_date ;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- mencoba buat new column with conditions referensi : https://datacarpentry.github.io/sql-socialsci/instructor/05-creating-new-columns.html#using-sql-syntax-to-conditionally-create-new-values
select 
	s.customer_id ,
	mn.product_name ,
	mn.price,
	case 
		when mn.product_name = "sushi" then 20
		else 10
	end as points	
from sales s 
join menu mn on s.product_id  = mn.product_id
left join members m on s.customer_id = m.customer_id 

-- menghitung total points tiap member
with point9 as(
	select 
		s.customer_id ,
		mn.product_name ,
		mn.price,
		case 
			when mn.product_name = "sushi" then 20
			else 10
		end as points
	from sales s 
	join menu mn on s.product_id  = mn.product_id
	left join members m on s.customer_id = m.customer_id 
)
select customer_id, sum(points) as total_point
from point9 
group by customer_id

-- ternyata harus menggunakan CTE karena: column points baru dibuat, jadi ga match dengan aggreation

-- 10. In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- membuat points tiap order, tiap customer
select 
	s.customer_id ,
	mn.product_name ,
	mn.price,
	10 as points,
	m.join_date,
	s.order_date 
from sales s 
join menu mn on s.product_id  = mn.product_id
LEFT join members m on s.customer_id = m.customer_id 
order by order_date 

-- membuat point pengali x2 ketika join_date + 7 hari
with points10 as (
	SELECT 
		s.customer_id ,
		mn.product_name ,
		mn.price,
		10 as points,
		m.join_date,
		s.order_date 
	from sales s 
	join menu mn on s.product_id  = mn.product_id
	LEFT join members m on s.customer_id = m.customer_id 
	order by order_date 
)
select 
	customer_id,
	order_date,
	join_date,
	case 
		when order_date >= join_date and order_date < join_date + 7 then points * 2
		else points
	end as points
from points10 
order by order_date 
	
-- join date <= order date
-- order date < join_date + 7
	
-- membuat cte kedua
with points10 as (
	SELECT 
		s.customer_id ,
		mn.product_name ,
		mn.price,
		10 as points,
		m.join_date,
		s.order_date 
	from sales s 
	join menu mn on s.product_id  = mn.product_id
	LEFT join members m on s.customer_id = m.customer_id 
	order by order_date 
),
point_pengali as(
select 
	customer_id,
	order_date,
	join_date,
	case 
		when order_date >= join_date and order_date < join_date + 7 then points * 2
		else points
	end as points
from points10 
order by order_date 
)
select customer_id, sum(points) as total_point
from point_pengali 
group by customer_id 


/*
 Review gemini
 Berdasarkan hasil review di atas, nomor-nomor yang output atau logikanya masih salah (perlu perbaikan) adalah:

Nomor 2 (Karena menghitung total baris transaksi, bukan tanggal unik kunjungan/hari).

Nomor 3 (Karena sorting window function kurang tepat dan ada potensi salah menampilkan jika tidak memakai DISTINCT atau DENSE_RANK dengan benar pada kasus data ganda di tanggal yang sama).

Nomor 7 (Karena kondisi tanggalnya masih menggunakan <= yang seharusnya <, serta arah sorting RANK()-nya harus dari yang paling mendekati tanggal join secara descending).

Nomor 8 (Karena kolom total item yang dibeli belum dihitung, syarat tanggalnya harus < (bukan <=), dan menggunakan INNER JOIN karena spesifik untuk member).

Nomor 9 (Karena perhitungan poinnya menggunakan angka statis 20 dan 10, bukan dikalikan dengan harga menu mn.price).

Nomor 10 (Karena ada syntax error pada penulisan pengali poin, belum ada filter batas akhir Januari, dan aturan poin minggu pertama serta sushi harus digabungkan dengan benar).
 */

-- Perbaikan
-- 2. How many days has each customer visited the restaurant?
-- (Karena menghitung total baris transaksi, bukan tanggal unik kunjungan/hari).
select s.customer_id ,
	count(distinct s.order_date ) as jumlah_kunjungan -- pakai distinct s.order_date agar buat menghitung hari
from sales s
group by s.customer_id;

-- 3. What was the first item from the menu purchased by each customer?
-- (Karena sorting window function kurang tepat dan ada potensi salah menampilkan jika tidak memakai 
-- DISTINCT atau DENSE_RANK dengan benar pada kasus data ganda di tanggal yang sama).
with ranked as (
	select s.customer_id , s.order_date ,s.product_id ,mn.product_name ,
	rank() over (partition by s.customer_id order by s.order_date) as 'rn'
	from sales s
	join menu mn on s.product_id = mn.product_id 
	-- order by rn bagian sini bisa dihilangkan karena order by dalam CTE yang baru dibuat jadi redundant
)
select customer_id, product_name
from ranked 
where rn = 1;

-- 7. Which item was purchased just before the customer became a member?
-- (Karena kondisi tanggalnya masih menggunakan <= yang seharusnya <, serta arah sorting RANK()-nya harus dari yang paling mendekati tanggal join secara descending).
with ranked7 as (
	select s.customer_id , mn.product_name , m.join_date, s.order_date  
	,rank() over (partition by customer_id order by order_date desc) as 'rank_before_member'
	from sales s 
	join menu mn on s.product_id = mn.product_id 
	-- left 
	join members m on s.customer_id = m.customer_id
	where s.order_date < m.join_date 
	-- and 
	-- where 
	-- m.customer_id = 'B'
	order by order_date
)
select customer_id, product_name
from ranked7
where rank_before_member = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
-- (Karena kolom total item yang dibeli belum dihitung, syarat tanggalnya harus < (bukan <=), dan menggunakan INNER JOIN karena spesifik untuk member).
select 
	s.customer_id, 
	sum(mn.price ) as total_spent, COALESCE(m.join_date, 'belum member') as join_date  
from sales s 
join menu mn on s.product_id = mn.product_id 
left join members m on s.customer_id = m.customer_id 
where s.order_date < m.join_date or m.join_date is null
group by s.customer_id,m.join_date ;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- (Karena perhitungan poinnya menggunakan angka statis 20 dan 10, bukan dikalikan dengan harga menu mn.price).
with point9 as(
	select 
		s.customer_id ,
		mn.product_name ,
		mn.price,
		case 
			when mn.product_name = 'sushi' then 20 * mn.price
			else mn.price * 10
		end as points
	from sales s 
	join menu mn on s.product_id  = mn.product_id
	left join members m on s.customer_id = m.customer_id 
)
select customer_id, sum(points) as total_point
from point9 
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- (Karena ada syntax error pada penulisan pengali poin, belum ada filter batas akhir Januari, dan aturan poin minggu pertama serta sushi harus digabungkan dengan benar).

with points10 as (
	SELECT 
		s.customer_id ,
		mn.product_name ,
		mn.price,
		10 as points,
		m.join_date,
		s.order_date 
	from sales s 
	join menu mn on s.product_id  = mn.product_id
	LEFT join members m on s.customer_id = m.customer_id 
	order by order_date 
),
point_pengali as(
select 
	customer_id,
	order_date,
	join_date,
	case 
		when order_date >= join_date and order_date < join_date + 7 then points * 2
		else points
	end as points
from points10 
order by order_date 
)
select customer_id, sum(points) as total_point
from point_pengali 
group by customer_id 


