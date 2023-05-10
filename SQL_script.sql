CREATE DATABASE books;

CREATE TABLE IF NOT EXISTS writers (
	id_writer SERIAL PRIMARY KEY,
	name_writer VARCHAR(100),
	birth_date DATE CHECK(birth_date < CURRENT_DATE),
	biography TEXT
);


CREATE TABLE IF NOT EXISTS publishers (
	id_publisher SERIAL PRIMARY KEY,
	name_publisher VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE IF NOT EXISTS genres (
	id_genre SERIAL PRIMARY KEY,
	name_genre VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE IF NOT EXISTS books (
	id_book SERIAL PRIMARY KEY,
	name_book VARCHAR(100) NOT NULL,
	writing_date INTEGER CHECK(writing_date <= EXTRACT(YEAR FROM CURRENT_DATE)),
	age_restriction INTEGER NOT NULL DEFAULT 0,
	description TEXT
);


CREATE TABLE IF NOT EXISTS books_writers (
	id_book_writer SERIAL PRIMARY KEY,
	id_book INTEGER NOT NULL,
	id_writer INTEGER NOT NULL,
	FOREIGN KEY (id_book) REFERENCES books (id_book) ON DELETE CASCADE,
	FOREIGN KEY (id_writer) REFERENCES writers (id_writer) ON DELETE CASCADE,
	CONSTRAINT unique_book_writer UNIQUE (id_book, id_writer)
);


CREATE TABLE IF NOT EXISTS books_genres (
	id_book_genre SERIAL PRIMARY KEY,
	id_book INTEGER NOT NULL,
	id_genre INTEGER NOT NULL,
	FOREIGN KEY (id_book) REFERENCES books (id_book) ON DELETE CASCADE,
	FOREIGN KEY (id_genre) REFERENCES genres (id_genre) ON DELETE CASCADE,
	CONSTRAINT unique_book_genre UNIQUE (id_book, id_genre)
);


CREATE TABLE IF NOT EXISTS series (
	id_series SERIAL PRIMARY KEY,
	name_series VARCHAR(100) NOT NULL,
	description TEXT
)


CREATE TABLE IF NOT EXISTS bindings (
	id_binding SERIAL PRIMARY KEY,
	name_binding VARCHAR(100) NOT NULL
);


CREATE TABLE IF NOT EXISTS languages (
	id_language SERIAL PRIMARY KEY,
	name_language VARCHAR(30) UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS languages_series_bindings (
	id_language_series_binding SERIAL PRIMARY KEY,
	id_language INTEGER NOT NULL,
	id_series INTEGER,
	id_binding INTEGER NOT NULL,
	FOREIGN KEY (id_language) REFERENCES languages (id_language) ON DELETE CASCADE,
	FOREIGN KEY (id_series) REFERENCES series (id_series) ON DELETE CASCADE,
	FOREIGN KEY (id_binding) REFERENCES bindings (id_binding) ON DELETE CASCADE,
	CONSTRAINT unique_language_series_binding UNIQUE (id_language, id_series, id_binding)
);


CREATE TABLE IF NOT EXISTS publisher_series (
	id_publisher_series SERIAL PRIMARY KEY,
	id_publisher INTEGER NOT NULL,
	id_series INTEGER,
	FOREIGN KEY (id_publisher) REFERENCES publishers (id_publisher) ON DELETE CASCADE,
	FOREIGN KEY (id_series) REFERENCES series (id_series) ON DELETE CASCADE,
	CONSTRAINT unique_publisher_series UNIQUE (id_publisher, id_series)
);


CREATE TABLE IF NOT EXISTS books_series (
	id_book_full_info SERIAL PRIMARY KEY,
	id_book INTEGER NOT NULL,
	id_series_full_info INTEGER NOT NULL,
	isbn BIGINT UNIQUE NOT NULL CHECK(LENGTH(isbn::VARCHAR)=13),
	pages_amount INTEGER CHECK(pages_amount > 0.0),
	book_weight REAL CHECK(book_weight > 0.0),
	published_date INTEGER NOT NULL CHECK(published_date <= EXTRACT(YEAR FROM CURRENT_DATE)), 
	FOREIGN KEY (id_book) REFERENCES books (id_book) ON DELETE CASCADE,
	FOREIGN KEY (id_series_full_info) REFERENCES languages_series_bindings (id_language_series_binding) ON DELETE CASCADE,
	CONSTRAINT unique_book_series UNIQUE (id_book, id_series_full_info)
)


CREATE TABLE IF NOT EXISTS shops (
	id_shop SERIAL PRIMARY KEY,
	address TEXT NULL,
	is_online BOOLEAN DEFAULT true	
);


CREATE TABLE IF NOT EXISTS shops_books (
	id_book_shop SERIAL PRIMARY KEY,
	id_book_series INTEGER NOT NULL,
	id_shop INTEGER NOT NULL,
	default_price REAL NOT NULL CHECK(default_price >= 0),
	sale real DEFAULT 0.0 CHECK(sale >= 0),
	amount INTEGER CHECK(amount >= 0),
	valid_from_dttm TIMESTAMP DEFAULT NOW(),
	valid_to_dttm TIMESTAMP CHECK(valid_to_dttm >= valid_from_dttm) DEFAULT ('9999-1-1'::TIMESTAMP),
	FOREIGN KEY (id_book_series) REFERENCES books_series (id_book_full_info) ON DELETE CASCADE,
	FOREIGN KEY (id_shop) REFERENCES shops (id_shop) ON DELETE CASCADE,
	CONSTRAINT unique_shop_book UNIQUE (id_book_shop, id_book_series)
);


CREATE TABLE IF NOT EXISTS customers (
	id_customer SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	middle_name VARCHAR(50),
	last_name VARCHAR(50),
	date_birth DATE CHECK(date_birth < CURRENT_DATE),
	phone_number INTEGER,
	email VARCHAR(30),
	have_account BOOLEAN DEFAULT False
);


DROP TABLE IF EXISTS delivery_types
CREATE TABLE IF NOT EXISTS delivery_types (
	id_delivery_type SERIAL PRIMARY KEY,
	name_delivery_type VARCHAR(30) NOT NULL UNIQUE
);


CREATE TABLE IF NOT EXISTS purchases (
	id_purchase SERIAL PRIMARY KEY,
	id_customer INTEGER NOT NULL,
	id_delivery_type INTEGER NOT NULL,
	purchase_dttm TIMESTAMP NOT NULL CHECK(purchase_dttm <= NOW()) DEFAULT(NOW()),
	coupon REAL DEFAULT 0,
	FOREIGN KEY (id_customer) REFERENCES customers (id_customer),
	FOREIGN KEY (id_delivery_type) REFERENCES delivery_types (id_delivery_type)
);


CREATE TABLE IF NOT EXISTS purchases_detailed (
	id_purchase_detailed SERIAL PRIMARY KEY,
	id_purchase INTEGER NOT NULL,
	id_book_shop INTEGER NOT NULL,
	amount INTEGER NOT NULL DEFAULT 1,
	FOREIGN KEY (id_purchase) REFERENCES purchases (id_purchase),
	FOREIGN KEY (id_book_shop) REFERENCES shops_books (id_book_shop),
	CONSTRAINT unique_purchase_book UNIQUE (id_purchase, id_book_shop)
);


CREATE TABLE IF NOT EXISTS customers_votes (
	id_vote SERIAL PRIMARY KEY,
	id_customer INTEGER NOT NULL,
	id_book_series INTEGER NOT NULL, 
	vote INTEGER NOT NULL CHECK (vote BETWEEN 1 AND 10),
	FOREIGN KEY (id_customer) REFERENCES customers (id_customer),
	FOREIGN KEY (id_book_series) REFERENCES books_series (id_book_full_info),
	CONSTRAINT unique_customer_book UNIQUE (id_customer, id_book_series) 
);


-- Заполнение данными --
-- 1.  Жанры --
SELECT * FROM genres;
INSERT INTO genres (name_genre) VALUES
	('Стихи'),
	('Роман'),
	('Фантастика'),
	('Ужасы'),
	('Детектив'),
	('Сказка'),
	('Приключение'),
	('Обазование'),
	('Комедия'),
	('Трагедия'),
	('Драма'),
	('Научное'),
	('Историческое');


-- 2.  Писатели
SELECT * FROM writers;
INSERT INTO  writers (name_writer, birth_date, biography) VALUES
	('Булгаков М.А.', '1900-01-02'::date, 'Русский писатель советского периода, врач, драматург, театральный режиссёр и актёр. Автор романов, повестей, рассказов, пьес, киносценариев и фельетонов, написанных в 1920-е годы.'),
	('Пушкин А.С.', '1800-01-01'::date, 'Русский поэт, драматург и прозаик, заложивший основы русского реалистического направления, литературный критик и теоретик литературы, историк, публицист, журналист.'),
	('Кинг С.', '1943-10-10'::date, 'Американский писатель, работающий в разнообразных жанрах, включая ужасы, триллер, фантастику, фэнтези, мистику, драму, детектив, получил прозвище «Король ужасов». Продано более 350 миллионов экземпляров его книг, по которым было снято множество художественных фильмов и сериалов, телевизионных постановок, а также нарисованы различные комиксы.'),
	('Маркес Г.Г.', '1927-3-6'::date, 'Колумбийский писатель-прозаик, журналист, издатель и политический деятель. Лауреат Нейштадтской литературной премии и Нобелевской премии по литературе. ');
	
-- 3.  Издательства
SELECT * FROM publishers;
INSERT INTO publishers (name_publisher) VALUES
	('Литрес'),
	('Просвещение'),
	('Питер'),
	('АСТ');

-- 4. Языки
SELECT * FROM languages;
INSERT INTO languages (name_language) VALUES
	('Русский'),
	('Английский'),
	('Испанский');
	
-- 5. Серии
SELECT * FROM series;
INSERT INTO series (name_series, description) VALUES
	('Эксклюзивная классика', 'В серии «Эксклюзивная классика», выпускаемой в иллюстрированных обложках формата покет, изданы сотни произведений, вошедших в золотой фонд мировой литературы. В их числе — авторы, чьи книги читают на протяжении веков. А именно — Гомер и Данте Алигьери, Джованни Боккаччо и Оноре де Бальзак, Уильям Шекспир и Виктор Гюго, Александр Дюма и Иоганн Вольфганг Гете и другие.'),
	('Король на все времена', 'В серии «Король на все времена» публикуются книги признанного американского мастера триллера Стивена Кинга. Он пишет в самых разных жанрах: хоррор и фантастика, реализм и фэнтези, драма и мистика. Общий тираж его произведений исчисляется сотнями миллионов. Его работы неоднократно становились бестселлерами в США.'),
	('Преступление и наказание', NULL),
	('Лучшая мировая классика', 'В серии «Лучшая мировая классика» публикуются книги, которые стали определяющими в истории отечественной и зарубежной литературы. Издания выпускаются в единообразно оформленных твердых обложках: зеленых для отечественных писателей, синих — для иностранных.'),
	('Разрыв шаблона. Детектив с шокирующим финалом', 'В этой серии подобраны особенные детективы, финал которых не просто невозможно предугадать, но и шокирует читателя невероятным сюжетным поворотом.'),
	('100 главных книг', 'Их имена знает каждый человек со школьной скамьи, их творчество стало настоящим откровением для современников и драгоценным посланием потомкам. 100 великих писателей, 100 великих произведений, 100 главных книг. В серии собраны произведения, которые заняли почетное место в списке шедевров мировой литературы и которые должен прочитать каждым мыслящий человек.');
	
-- 5. Переплеты
SELECT * FROM bindings;
INSERT INTO bindings (name_binding) VALUES
	('Твердый'),
	('Мягкий');

-- 6. Магазины
SELECT * FROM shops;
INSERT INTO shops (address, is_online) VALUES
	('www.books.ru', true),
	('ул. Ленина, д.23', false),
	('ул. Москвоская, д.65А', false);


-- 7. Книги
SELECT * FROM books;
INSERT INTO books (name_book, writing_date, age_restriction, description) VALUES
	('Мастер и Маргарита', 1928, 16, 'Роман Михаила Афанасьевича Булгакова, работа над которым началась в декабре 1928 года и продолжалась вплоть до смерти писателя в марте 1940 года. Роман относится к незавершённым произведениям; редактирование и сведение воедино черновых записей осуществляла после смерти мужа вдова писателя - Елена Сергеевна. Первая версия романа, имевшая названия «Копыто инженера», «Чёрный маг» и другие, была уничтожена Булгаковым в 1930 году. В последующих редакциях среди героев произведения появились автор романа о Понтии Пилате и его возлюбленная. Окончательное название - «Мастер и Маргарита» - оформилось в 1937 году. '),
	('Оно', 1986, 18, 'Роман американского писателя Стивена Кинга, написанный в жанре ужасов, впервые опубликованный в 1986 году издательством Viking Press. В произведении затрагиваются важные для Кинга темы: власть памяти, сила объединённой группы, влияние травм детства на взрослую жизнь. Согласно основной сюжетной линии, семеро друзей из вымышленного города Дерри в штате Мэн сражаются с чудовищем, убивающим детей и способным принимать любую физическую форму, основанные на глубочайших страхах своих жертв. Повествование ведётся параллельно в разных временных интервалах, один из которых соответствует детству главных героев, а другой - их взрослой жизни.'),
	('Капитанская дочка', 1836, 12, 'Исторический роман Александра Пушкина, действие которого происходит во время восстания Емельяна Пугачёва. Впервые опубликован без указания имени автора в 4-й книжке журнала «Современник», поступившей в продажу в последней декаде 1836 года.'),
	('Сказка о царе Салтане', 1831, 0, 'Сказка в стихах Александра Пушкина, написанная в 1831 году и впервые изданная в следующем году в собрании стихотворений. Сказка посвящена истории женитьбы царя Салтана и рождению его сына, князя Гвидона, который из-за козней тёток попадает на необитаемый остров, встречает там волшебницу - царевну Лебедь, с её помощью становится могущественным владыкой и воссоединяется с отцом. '),
	('Сто лет одиночества', 1967, 16, 'Роман колумбийского писателя Габриэля Гарсиа Маркеса, одно из наиболее характерных и популярных произведений в направлении магического реализма. Первое издание романа было опубликовано в Буэнос-Айресе в июне 1967 года тиражом 8000 экземпляров. Роман был удостоен премии Ромуло Гальегоса. На сегодняшний день продано более 30 миллионов экземпляров, роман переведён на 35 языков мира.');

-- 8. Книга-писатель
SELECT * FROM books_writers;
INSERT INTO books_writers (id_book, id_writer) VALUES
	(1, 1),
	(2, 3),
	(3, 2),
	(4, 2),
	(5, 4);

-- 9. Книга-жанр
SELECT * FROM books_genres;
INSERT INTO books_genres (id_book, id_genre) VALUES
	(1, 1),
	(1, 12),
	(1, 10),
	(2, 3),
	(2, 2),
	(2, 6),
	(3, 1),
	(3, 12),
	(4, 5),
	(4, 13),
	(5, 1);
	
-- 10. Серия-переплет-язык
SELECT * FROM languages_series_bindings;
INSERT INTO  languages_series_bindings (id_language, id_series, id_binding) VALUES
	(1, 1, 1),
	(1, 1, 2),
	(2, 1, 2),
	(1, 2, 2),
	(2, 1, 1),
	(1, 4, 2),
	(3, 1, 2),
	(1, 3, 1);

-- 11. Серия-издатель
SELECT * FROM publisher_series;
INSERT INTO publisher_series (id_publisher, id_series) VALUES
	(1, 3),
	(2, 2),
	(3, 1),
	(4, 5),
	(5, 4);

-- 12. Книга-серия
SELECT * FROM books_series;
INSERT INTO  books_series (id_book, id_series_full_info, isbn, pages_amount, book_weight, published_date) VALUES
	(1, 1, 1234567891234, 500, 370.0, 2010),
	(2, 1, 1234567891235, 1300, 500.0, 1998),
	(3, 2, 1234567891236, 300, 300.0, 2021),
	(4, 4, 1234567891237, 200, 250.0, 2016),
	(5, 6, 1234567891238, 1000, 400.0, 2000);

-- 13. Магазины-книги
SELECT * FROM shops_books;
INSERT INTO shops_books (id_book_series, id_shop, default_price, sale, amount, valid_from_dttm) VALUES
	(1, 1, 400, 0.0, 3, NOW()),
	(2, 2, 500, 0.0, 2, NOW() - INTERVAL '1' DAY),
	(3, 2, 600, 7.0, 7, NOW());
	
	
-- Тестовая --
INSERT INTO shops_books (id_book_series, id_shop, default_price, sale, amount, valid_from_dttm, valid_to_dttm) VALUES
	(1,1, 800, 0.0, 10, '2020-01-01'::TIMESTAMP, '2020-01-31'::TIMESTAMP),
	(1,1, 1200, 0.0, 10, '2020-02-01'::TIMESTAMP, '2020-02-20'::TIMESTAMP);


-- 14. Покупатели
SELECT * FROM customers;
INSERT INTO customers (first_name, middle_name, last_name) VALUES
	('Артем', 'Константинович', 'Горяинов'),
	('Андрей', 'Александрович', 'Горлов'),
	('Данила', 'Вячеславович', 'Тихонов');

-- 15. Типы доставки
SELECT * FROM delivery_types;
INSERT INTO delivery_types (name_delivery_type) VALUES
	('Самовывоз'),
	('Доставка');

-- 16. Заказы
SELECT * FROM purchases;
INSERT INTO purchases (id_customer, id_delivery_type, purchase_dttm, coupon) VALUES
	(1, 1, NOW(), 0.0),
	(2, 2, NOW() - INTERVAL '1' DAY, 0.0),
	(3, 1, NOW(), 15.0);

-- Тестовая --
INSERT INTO purchases (id_customer, id_delivery_type, purchase_dttm, coupon) VALUES
	(1, 2, '2020-01-04'::TIMESTAMP, 5),
	(1, 2, '2020-02-14'::TIMESTAMP, 0);
SELECT * FROM purchases_detailed;
INSERT INTO purchases_detailed (id_purchase, id_book_shop, amount) VALUES
	(4, 4, 2),
	(5, 5, 1);

-- 17. Заказы-подробно
SELECT * FROM purchases_detailed;
INSERT INTO purchases_detailed (id_purchase, id_book_shop, amount) VALUES
	(1, 1, 2),
	(1, 2, 1),
	(1, 3, 1),
	(2, 1, 1),
	(3, 3, 1);

-- 18. Оценки
SELECT * FROM customers_votes;
INSERT INTO customers_votes (id_customer, id_book_series, vote) VALUES
	(1, 1, 7),
	(1, 2, 4);
	


-- Витрина "Покупки пользователей"--
CREATE OR REPLACE VIEW customers_purchases_information as (
	SELECT pur.id_customer, books.id_book, writers.name_writer, cust.first_name, cust.last_name, pur.id_purchase, books.name_book, series.name_series, 
	languages.name_language, bindings.name_binding, pd.amount, sb.default_price, 
	sb.sale, pur.purchase_dttm, shops.address 
	FROM purchases pur
	JOIN customers cust USING(id_customer)
	JOIN purchases_detailed pd USING(id_purchase)
	JOIN shops_books sb ON sb.id_book_shop = pd.id_book_shop AND pur.purchase_dttm BETWEEN sb.valid_from_dttm AND sb.valid_to_dttm
	JOIN books_series bs ON sb.id_book_series =  bs.id_book_full_info 
	JOIN books USING(id_book)
	JOIN shops USING(id_shop)
	JOIN languages_series_bindings lsb ON lsb.id_language_series_binding = bs.id_series_full_info
	JOIN series ON series.id_series = lsb.id_series
	JOIN languages USING(id_language)
	JOIN bindings USING(id_binding)
	JOIN books_writers USING(id_book)
	JOIN writers USING(id_writer)
);

SELECT * FROM customers_purchases_information;

-- Витрина "Статистика пользователя" --
WITH buf AS (
	SELECT *, default_price * (1 - 0.01 * sale) * (1 - 0.01 * coupon) AS price_with_sale,
	default_price * (1 - 0.01 * sale) * (1 - 0.01 * coupon) * pd.amount AS total_books_price_in_purchase,
	pd.amount as bought_books_amount
	FROM purchases pur
	JOIN customers cust USING(id_customer)
	JOIN purchases_detailed pd USING(id_purchase)
	JOIN shops_books sb ON sb.id_book_shop = pd.id_book_shop AND pur.purchase_dttm BETWEEN sb.valid_from_dttm AND sb.valid_to_dttm
	JOIN books_series bs ON sb.id_book_series =  bs.id_book_full_info 
	JOIN books USING(id_book)
	JOIN shops USING(id_shop)
	JOIN languages_series_bindings lsb ON lsb.id_language_series_binding = bs.id_series_full_info
	JOIN series ON series.id_series = lsb.id_series
	JOIN languages USING(id_language)
	JOIN bindings USING(id_binding)
	JOIN books_writers USING(id_book)
	JOIN writers USING(id_writer)
),
buf_2 AS (
	SELECT id_purchase, MAX(id_customer) as id_customer, 
	SUM(total_books_price_in_purchase) as purchase_price
	FROM buf
	GROUP BY id_purchase
),
buf_3 AS (
	SELECT id_customer, id_genre, COUNT(*) AS genres_amount FROM buf
	JOIN books_genres USING(id_book)
	GROUP BY id_customer, id_genre
	ORDER BY id_customer, id_genre
),
buf_4 AS (
	SELECT id_customer, id_writer, COUNT(*) AS writer_amount FROM buf
	GROUP BY id_customer, id_writer
	ORDER BY id_customer, id_writer
);

SELECT o.* FROM buf_3 o
LEFT JOIN buf_3 p
ON p.id_customer = o.id_customer AND o.genres_amount < p.genres_amount
WHERE p.genres_amount is NULL;


-- Витрина "Среднее значение выставленной оценки в зависимости от жанра" --
CREATE OR REPLACE VIEW customer_votes_range_by AS (
	SELECT * FROM customers_votes cv
	JOIN books_series bs ON bs.id_book_full_info = cv.id_book_series
	JOIN books USING(id_book)
);

CREATE OR REPLACE VIEW customer_votes_range_by_genres AS (
	SELECT id_customer, MAX(name_genre) as name_genre, ROUND(AVG(vote), 2) as avg_vote  FROM customer_votes_range_by
	JOIN books_genres USING(id_book)
	JOIN genres USING(id_genre)
	GROUP BY id_customer, id_genre
	ORDER BY id_customer, avg_vote DESC
);


-- Витрина "Среднее значение выставленной оценки в зависимости от автора книги" --
CREATE OR REPLACE VIEW customer_votes_range_by_writers AS (
	SELECT id_customer, MAX(name_writer) as name_writer, ROUND(AVG(vote), 2) as avg_vote  FROM customer_votes_range_by
	JOIN books_writers USING(id_book)
	JOIN writers USING(id_writer)
	GROUP BY id_customer, id_writer
	ORDER BY id_customer, avg_vote DESC
);


-- Витрина изначальная стоимость покупки / потраченные деньги для пользователя --
WITH buf AS (
	SELECT id_purchase, id_customer, sb.default_price, sb.default_price * (1 - 0.01 * sb.sale) AS price_with_sale, pur.coupon, pd.amount FROM purchases pur
	JOIN purchases_detailed pd USING(id_purchase)
	JOIN shops_books sb ON sb.id_book_shop = pd.id_book_shop AND pur.purchase_dttm BETWEEN sb.valid_from_dttm AND sb.valid_to_dttm
)
SELECT id_purchase, 
		MAX(id_customer) as id_customer, 
		SUM(amount * default_price) as expected_price, 
		SUM(amount * price_with_sale) * (1 - 0.01 * MAX(coupon)) AS paid_money
FROM buf 
GROUP BY id_purchase;


-- Витрина "Продажи магазинов" --
WITH buf AS (
	SELECT id_shop, sb.amount AS all_books, pd.amount, purchase_dttm, 
		EXTRACT(MONTH FROM purchase_dttm) as purchase_month, 
		EXTRACT(YEAR FROM purchase_dttm) as purchase_year, 
		sb.default_price * (1 - 0.01 * sb.sale) * (1 - 0.01 * coupon) AS price_with_sale_and_coupon FROM purchases pur
	JOIN purchases_detailed pd USING(id_purchase)
	JOIN shops_books sb ON sb.id_book_shop = pd.id_book_shop AND pur.purchase_dttm BETWEEN sb.valid_from_dttm AND sb.valid_to_dttm
)
SELECT id_shop, purchase_month, purchase_year, SUM(amount) AS books_sold, SUM(amount * price_with_sale_and_coupon) AS income
FROM buf
GROUP BY id_shop, purchase_month, purchase_year;


-- Витрина "Динамика цен" --
SELECT books.name_book, series.name_series, sb.default_price, sale, sb.valid_from_dttm,
	price_with_sale - LAG(price_with_sale, 1, price_with_sale) OVER (PARTITION BY id_book_series, id_shop ORDER BY valid_from_dttm) as price_change;

FROM (SELECT id_book_series, id_shop, default_price * (1 - 0.01 * sale) as price_with_sale, default_price, sale, valid_from_dttm FROM shops_books) sb
JOIN books_series bs ON sb.id_book_series =  bs.id_book_full_info
JOIN books USING(id_book)
JOIN languages_series_bindings lsb ON lsb.id_language_series_binding = bs.id_book_full_info
JOIN series USING(id_series);


-- Витрина "Бестселлеры" --
SELECT id_book_series, SUM(pd.amount) as total_amount FROM purchases pur
JOIN purchases_detailed pd USING(id_purchase)
JOIN shops_books sb ON sb.id_book_shop = pd.id_book_shop AND pur.purchase_dttm BETWEEN sb.valid_from_dttm AND sb.valid_to_dttm
JOIN books_series bs ON bs.id_book_full_info = sb.id_book_series
GROUP BY id_book_series
ORDER BY total_amount DESC;


-- Витрина "Скидки" --
SELECT DISTINCT books.name_book, shops.address, sale, default_price * (1-0.01 * sale) as price_with_sale FROM shops_books sb 
JOIN books_series bs ON sb.id_book_series =  bs.id_book_full_info 
JOIN books USING(id_book)
JOIN shops USING(id_shop)
WHERE valid_from_dttm <= NOW() AND valid_to_dttm >= NOW() AND sb.amount > 0 
ORDER BY sale DESC;



-- Функция для получения информации о покупках пользователя --
CREATE FUNCTION select_user_puchases_info (id INTEGER) 
RETURNS TABLE(id_customer INTEGER, 
			  first_name VARCHAR(50), 
			  last_name VARCHAR(50), 
			  id_purchase INTEGER, 
			  name_book VARCHAR(100), 
			  name_series VARCHAR(100), 
			  name_language VARCHAR(30), 
			  name_binding VARCHAR(100), 
			  amount INTEGER, 
			  default_price REAL, 
			  sale REAL, 
			  purchase_date DATE, 
			  address TEXT) AS
$$
	SELECT * FROM customers_purchases_information
	WHERE id_customer = id
$$ LANGUAGE SQL;

SELECT * FROM select_user_puchases_info(1);