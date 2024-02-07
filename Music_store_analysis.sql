--Questions Set 1 - EASY 

--1. Who is the senior most employee based on job title?

select top 1 CONCAT(last_name,'_',first_name) as Emp_name,title as Job_title
from employee
order by levels desc

--2. Which countries have the most Invoices?

select billing_country,count(*) as City_count
from invoice
group by billing_country
order by 2 desc

--3. What are top 3 values of total invoice?

select top 3 total 
from invoice
order by 1 desc

/*4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals*/

select top 1 billing_city,sum(total) as Invoice_total
from invoice
group by billing_city
order by 2 desc

/* 5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. 
Write a query that returns the person who has spent the most money */

select top 1 c.last_name,c.first_name,sum(total) as Total_spents
from customer c
join invoice i
on c.customer_id = i.customer_id
group by c.last_name,c.first_name
order by 3 desc 

--Questions Set 2 - Moderate

/*1. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A */

select Distinct c.email,c.last_name,c.first_name,g.name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name like 'ROCK'
order by c.email


/*2. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands */

select top 10 a.artist_id,a.name,count(a.artist_id) as Num_of_songs
from artist a
join album al on a.artist_id = al.artist_id
join track t on t.album_id = al.album_id
join genre g on g.genre_id = t.genre_id
where g.name like 'ROCK'
group by a.artist_id,a.name
order by 3 desc

/* 3. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first */
select name,milliseconds
from track 
where milliseconds > (select avg(milliseconds) from track)
order by 2 desc

--Question Set 3 – Advance

/* 1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent
/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines.
Now use this artist to find which customer spent the most on this artist. 
For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables.
Note, this one is tricky because the Total spent in the Invoice table might not be on a single product,
so you need to use the InvoiceLine table to find out how many of each product was purchased,
and then multiply this by the price for each artist. */*/

with best_selling_artist as
(
	select top 1 a.artist_id,a.name,sum(il.unit_price * il.Quantity) as total_sales
	from invoice_line il
	join track t on il.track_id = t.track_id
	join album al on al.album_id = t.album_id
	join artist a on a.artist_id = al.artist_id
	group by a.artist_id,a.name
	order by 3 desc
)
select c.customer_id,c.last_name,c.first_name,bsa.name artist_name,Round(sum(il.unit_price * il.Quantity),2) as Total_spent
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join artist a on a.artist_id = al.artist_id
join best_selling_artist bsa on bsa.artist_id= a.artist_id
group by c.customer_id,c.last_name,c.first_name,bsa.name
order by 5 desc



/* 2. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres */

with popular_genre as
(
	select c.country,g.genre_id,g.name,count(il.quantity) as purchases,
	Row_Number() over (Partition by c.country order by count(il.quantity) desc ) as Row_no
	from invoice_line il
	join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track t on t.track_id = il.track_id
	join genre g on g.genre_id  = t.genre_id
	group by c.country,g.name,g.genre_id
	order by 4 desc
)
select * from popular_genre
where Row_no <= 1


/* 3. Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount Complete */

with customer_with_country as
(
	select  c.customer_id,c.first_name,c.last_name,i.billing_city,Round(sum(i.total),2) as total_spents,
	ROW_NUMBER() over (partition by i.billing_city order by sum(i.total) desc ) as Rw_no
	from customer c
	join invoice i on c.customer_id = i.invoice_id
	group by c.customer_id,c.first_name,c.last_name,i.billing_city
	order by 5 desc
)
select * from customer_with_country
where Rw_no <=1

