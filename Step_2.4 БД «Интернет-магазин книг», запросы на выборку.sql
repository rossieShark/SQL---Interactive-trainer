/*2.4.1. Создаю новую БД, которая должна использоваться в частях 2.4 и 2.5 */

CREATE SCHEMA `stepik_book_shop`;
USE stepik_book_shop;

CREATE TABLE genre(
	genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name_genre VARCHAR(30)
    );
    
INSERT INTO genre(name_genre)
VALUES ('Роман'),
       ('Поэзия'),
       ('Приключения');

CREATE TABLE author(
	author_id INT PRIMARY KEY AUTO_INCREMENT,
    name_author VARCHAR(50)
    );

INSERT INTO author (name_author)
VALUES ('Булгаков М.А.'),
       ('Достоевский Ф.М.'),
       ('Есенин С.А.'),
       ('Пастернак Б.Л.'),
       ('Лермонтов М.Ю.');
       
CREATE TABLE city(
	city_id INT PRIMARY KEY AUTO_INCREMENT,
    name_city VARCHAR(30),
    days_delivery INT
    );
    
INSERT INTO city(name_city, days_delivery)
VALUES ('Москва', 5),
       ('Санкт-Петербург', 3),
       ('Владивосток', 12);
       
CREATE TABLE book(
	book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(30),
    author_id INT NOT NULL,
    genre_id INT,
    price DECIMAL(8,2),
    amount INT,
    FOREIGN KEY (author_id)
		REFERENCES author (author_id)
		ON DELETE CASCADE,
    FOREIGN KEY (genre_id)
		REFERENCES genre (genre_id)
        ON DELETE SET NULL
        );
        
INSERT INTO book (title, author_id, genre_id, price, amount)
VALUES  ('Мастер и Маргарита', 1, 1, 670.99, 3),
        ('Белая гвардия ', 1, 1, 540.50, 5),
        ('Идиот', 2, 1, 460.00, 10),
        ('Братья Карамазовы', 2, 1, 799.01, 2),
        ('Игрок', 2, 1, 480.50, 10),
        ('Стихотворения и поэмы', 3, 2, 650.00, 15),
        ('Черный человек', 3, 2, 570.20, 6),
        ('Лирика', 4, 2, 518.99, 2);
        
CREATE TABLE client(
	client_id INT PRIMARY KEY AUTO_INCREMENT,
    name_client VARCHAR(50),
    city_id INT,
    email VARCHAR(30),
    FOREIGN KEY (city_id)
		REFERENCES city (city_id)
        );
INSERT INTO client(name_client, city_id, email)
VALUES ('Баранов Павел', 3, 'baranov@test'),
       ('Абрамова Катя', 1, 'abramova@test'),
       ('Семенонов Иван', 2, 'semenov@test'),
       ('Яковлева Галина', 1, 'yakovleva@test');
       
CREATE TABLE buy(
    buy_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_description VARCHAR(100),
    client_id INT,
    FOREIGN KEY (client_id) REFERENCES client (client_id)
);

INSERT INTO buy (buy_description, client_id)
VALUES ('Доставка только вечером', 1),
       (NULL, 3),
       ('Упаковать каждую книгу по отдельности', 2),
       (NULL, 1);

CREATE TABLE buy_book (
    buy_book_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id INT,
    book_id INT,
    amount INT,
    FOREIGN KEY (buy_id) REFERENCES buy (buy_id),
    FOREIGN KEY (book_id) REFERENCES book (book_id)
);

INSERT INTO buy_book(buy_id, book_id, amount)
VALUES (1, 1, 1),
       (1, 7, 2),
       (1, 3, 1),
       (2, 8, 2),
       (3, 3, 2),
       (3, 2, 1),
       (3, 1, 1),
       (4, 5, 1);

CREATE TABLE step (
    step_id INT PRIMARY KEY AUTO_INCREMENT,
    name_step VARCHAR(30)
);

INSERT INTO step(name_step)
VALUES ('Оплата'),
       ('Упаковка'),
       ('Транспортировка'),
       ('Доставка');

CREATE TABLE buy_step (
    buy_step_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id INT,
    step_id INT,
    date_step_beg DATE,
    date_step_end DATE,
    FOREIGN KEY (buy_id) REFERENCES buy (buy_id),
    FOREIGN KEY (step_id) REFERENCES step (step_id)
);

INSERT INTO buy_step(buy_id, step_id, date_step_beg, date_step_end)
VALUES (1, 1, '2020-02-20', '2020-02-20'),
       (1, 2, '2020-02-20', '2020-02-21'),
       (1, 3, '2020-02-22', '2020-03-07'),
       (1, 4, '2020-03-08', '2020-03-08'),
       (2, 1, '2020-02-28', '2020-02-28'),
       (2, 2, '2020-02-29', '2020-03-01'),
       (2, 3, '2020-03-02', NULL),
       (2, 4, NULL, NULL),
       (3, 1, '2020-03-05', '2020-03-05'),
       (3, 2, '2020-03-05', '2020-03-06'),
       (3, 3, '2020-03-06', '2020-03-10'),
       (3, 4, '2020-03-11', NULL),
       (4, 1, '2020-03-20', NULL),
       (4, 2, NULL, NULL),
       (4, 3, NULL, NULL),
       (4, 4, NULL, NULL);
       
/*Выполнение заданий*/

/*2.4.5. Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал) в отсортированном по номеру заказа и названиям книг виде.
В данном запросе:
выбираем необходимые нам столбцы из таблицы buy
присоединяем к ней таблицы клиент, buy_book и book
где имя клиента Баранов Павел
сортируем*/
SELECT buy_id, title, price, buy_book.amount from 
client JOIN buy USING (client_id)
JOIN buy_book USING (buy_id)
JOIN book USING (book_id)
WHERE name_client = 'Баранов Павел'
ORDER BY buy_id, title;

/*2.4.6. Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, в каком количестве заказов фигурирует каждая книга).  
Вывести фамилию и инициалы автора, название книги, последний столбец назвать Количество. 
Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг.
Из таблицы автора подтягиваем имя автора
мержим обычным джоином с таблицей бук
мержим с таблицей байбук левым джоином (вот с этим надо разобраться)
группируем по названию и имени
сортируем*/

SELECT name_author, title, Count(buy_book.amount) AS Количество FROM
author JOIN book USING (author_id) 
LEFT JOIN buy_book USING (book_id)
 GROUP BY book.title, name_author
ORDER BY name_author, title;

/*2.4.7. Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. 
Указать количество заказов в каждый город, этот столбец назвать Количество. 
Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке по названию городов.
Нужны таблицы: city, client, buy
Выводим наименования городов через простой запрос
Далее необходимо присоединить к таблице client (т.к. таблица buy не соеденина напрямую в citу)
Произвести группировку по city_id и client_id
Отсортировать согласно задания*/
SELECT name_city,count(client_id) as Количество from
buy JOIN client USING (client_id)
JOIN city USING (city_id)
GROUP BY name_city
ORDER BY Количество DESC, name_city;


/*2.4.8. Вывести номера всех оплаченных заказов и даты, когда они были оплачены.*/
/*Ход решения:
Используем таблицу step, чтобы понять, что заказ оплачен, id=1 или name_step = Оплата
Запрашиваем необходимые нам столбцы из таблицы buy_step
Мержим таблички 
Где наименование шага или id равен вышеуказаным и не равен NULL, т.к. не все заказы могут быть оплачены*/
SELECT buy_id, date_step_end from
buy JOIN buy_step USING (buy_id)
JOIN step USING (step_id)
WHERE step_id = 1 AND date_step_end is not NULL;


/*2.4.9. Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) и его стоимость (сумма произведений количества заказанных книг и их цены), в отсортированном по номеру заказа виде. 
Последний столбец назвать Стоимость.*/
/*Ход решения:
Выбираю необходимые столбцы 
Мержу 4 табицы
группирую по id клиента, т.к. одному клиенту может принадлежать множество заказов 
Сортирую */

SELECT buy_id, name_client, Sum(book.price * buy_book.amount) AS Стоимость FROM
client JOIN buy USING (client_id)
JOIN buy_book USING (buy_id)
JOIN book USING (book_id)
Group BY buy_id,name_client
ORDER BY buy_id;


/*2.4.10. Вывести номера заказов (buy_id) и названия этапов,  на которых они в данный момент находятся. Если заказ доставлен –  информацию о нем не выводить. Информацию отсортировать по возрастанию buy_id.*/
/*Ход решения 
выбрать необходимые столбцы
Сджойнить таблицы степ и бай_степ
Вывести наименования этапов согласно date_step_end = NULL
Если date_step_beg IS NOT NULL AND date_step_end IS NULL*/

SELECT buy_id, name_step FROM
step JOIN buy_step USING (step_id)
WHERE date_step_end is NULL AND date_step_beg is not NULL; 

/*2.4.11. В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город (рассматривается только этап Транспортировка). 
Для тех заказов, которые прошли этап транспортировки, вывести количество дней за которое заказ реально доставлен в город. 
А также, если заказ доставлен с опозданием, указать количество дней задержки, в противном случае вывести 0. 
В результат включить номер заказа (buy_id), а также вычисляемые столбцы Количество_дней и Опоздание. 
Информацию вывести в отсортированном по номеру заказа виде. 
Для подсчета опоздания место оператора IF() можно использовать функцию GREATEST(). Данная функция возвращает наибольшее значение. В данном случае либо то, на которое была задержка, либо ее отсутствие
Опять же временной интервал который нам нужен это только Транспортировка он начался, но еще не закончился */

SELECT buy_id, DATEDIFF(date_step_end, date_step_beg) as  Количество_дней, IF(DATEDIFF(date_step_end, date_step_beg)  > days_delivery, DATEDIFF(date_step_end, date_step_beg) - days_delivery, 0) AS'Опоздание' FROM
city JOIN client USING (city_id)
JOIN buy USING (client_id)
JOIN buy_step USING (buy_id)
JOIN step USING (step_id)
WHERE name_step LIKE 'Транспортировка' AND date_step_end IS NOT NULL ORDER BY buy_id;

/*2.4.12. Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде. 
В решении используйте фамилию автора, а не его id.
Выбираем "Уникальное имя" клиент, т.к. человечек может заказать книгу достоевского не один раз
Джойним таблички
Задаем имя автора = Достоевский
Сортируем*/

select Distinct name_client FROM
client JOIN buy USING (client_id)
JOIN buy_book USING (buy_id)
JOIN book USING (book_id)
JOIN author USING (author_id)
WHERE author.name_author LIKE 'Досто%' ORDER BY name_client;


/*2.4.13. Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество. Последний столбец назвать Количество.
Выбираем жанр
Джойним таблички
группируем и через сумм эмаунт делаем подсчет количества книг c помощью вложенного запроса с подзапросом*/

SELECT name_genre, sum(buy_book.amount) AS Количество FROM
genre JOIN book USING (genre_id)
JOIN buy_book USING (book_id)
GROUP BY name_genre
HAVING SUM(buy_book.amount)=
    (SELECT MAX(sum_amount) 
            FROM 
            (SELECT SUM(buy_book.amount) AS sum_amount
                FROM book 
             INNER JOIN buy_book USING(book_id)
             GROUP BY genre_id) query_in) ;
            
/*2.4.14. Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. 
Для этого вывести год, месяц, сумму выручки в отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде. 
Название столбцов: Год, Месяц, Сумма.
Во-первых создаем табличку, которой у нас раньше не было*/

CREATE TABLE buy_archive
(
    buy_archive_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id         INT,
    client_id      INT,
    book_id        INT,
    date_payment   DATE,
    price          DECIMAL(8, 2),
    amount         INT
);

INSERT INTO buy_archive (buy_id, client_id, book_id, date_payment, amount, price)
VALUES (2, 1, 1, '2019-02-21', 2, 670.60),
       (2, 1, 3, '2019-02-21', 1, 450.90),
       (1, 2, 2, '2019-02-10', 2, 520.30),
       (1, 2, 4, '2019-02-10', 3, 780.90),
       (1, 2, 3, '2019-02-10', 1, 450.90),
       (3, 4, 4, '2019-03-05', 4, 780.90),
       (3, 4, 5, '2019-03-05', 2, 480.90),
       (4, 1, 6, '2019-03-12', 1, 650.00),
       (5, 2, 1, '2019-03-18', 2, 670.60),
       (5, 2, 4, '2019-03-18', 1, 780.90);

/*РЕШЕНИЕ ЗАДАЧИ: 
*/       
SELECT YEAR(date_payment) as Год, Monthname(date_payment) as Месяц, sum(price * amount) as Сумма FROM buy_archive
GROUP BY Год, Месяц
UNION
SELECT YEAR(date_step_end) as Год, Monthname(date_step_end) as Месяц, sum(book.price * buy_book.amount) as Сумма FROM book JOIN buy_book USING (book_id)
JOIN buy USING (buy_id)
JOIN buy_step USING (buy_id)
JOIN step USING (step_id)
WHERE  date_step_end IS NOT Null and name_step = "Оплата"
GROUP BY Год, Месяц
ORder by Месяц, Год;

/*2.4.15. Для каждой отдельной книги необходимо вывести информацию о количестве проданных экземпляров и их стоимости за 2020 и 2019 год . 
Вычисляемые столбцы назвать Количество и Сумма. 
Информацию отсортировать по убыванию стоимости.
Делаем запрос из прошлогодней таблицы 
Далее составляем запрос из таблиц нынешнего года, мержим их, группируем по автору и названию книги */

SELECT title, sum(query_in.sum_amount) AS Количество, sum(query_in.sum_price) AS Сумма
FROM
    (SELECT title, sum(buy_archive.amount) AS sum_amount, 
                   sum(buy_archive.amount * buy_archive.price) AS sum_price
     FROM book JOIN buy_archive USING(book_id)
     GROUP BY title  
     UNION ALL
     SELECT title, sum(buy_book.amount) AS sum_amount, sum(buy_book.amount * book.price) as sum_price
     FROM buy_step JOIN step USING (step_id)
         JOIN buy USING (buy_id)
     JOIN buy_book USING (buy_id)
     JOIN book USING (book_id)
     WHERE date_step_end is NOT NULL and name_step = 'Оплата'
     GROUP BY title
    ) AS query_in
GROUP BY query_in.title
ORDER BY Сумма DESC;



