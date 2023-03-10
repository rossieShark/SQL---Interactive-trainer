USE stepik_book_shop;

/*2.5.2. Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве. 
Запросы на повторение по сути*/

INSERT INTO client (name_client, city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
FROM city
WHERE name_city = 'Москва';
SELECT * FROM client;

/*2.5.3.  Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки».
Аналогично предыдущего шага без использования VALUES*/

INSERT INTO buy (buy_description, client_id)
SELECT 'Связаться со мной по вопросу доставки', client_id FROM client
WHERE name_client = 'Попов Илья';
SELECT * FROM buy;

/*2.5.4. В таблицу buy_book добавить заказ с номером 5. 
Этот заказ должен содержать книгу Пастернака «Лирика» в количестве двух экземпляров и книгу Булгакова «Белая гвардия» в одном экземпляре.*/
/*1ый способ решения*/
INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book_id, 2 from  book, author
  WHERE  name_author = 'Пастернак Б.Л.' and title = 'Лирика';                  
INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book_id, 1 from  book, author
  WHERE  name_author Like 'Булгак%' and title LIKE 'Белая %';                  
  SELECT * FROM buy_book;

/* способ решения через IF*/

INSERT INTO buy_book(buy_id, book_id, amount)
        SELECT 5, book_id, IF(title = 'Лирика', 2, 1)
        FROM author
        INNER JOIN book USING(author_id)
        WHERE name_author IN ('Пастернак Б.Л.', 'Булгаков М.А.') AND title IN ('Лирика', 'Белая гвардия');
        
SELECT * FROM buy_book;

/*2.5.5. Количество тех книг на складе, которые были включены в заказ с номером 5, уменьшить на то количество, которое в заказе с номером 5  указано.
Повторяем запрос на обновление таблиц 
устанавливаем значения 
задаем условие номер заказа = 5 и id книг совпадают, иначе вычтет из каждого значения в таблице бук*/

UPDATE book,buy_book
SET book.amount = book.amount - buy_book.amount
WHERE buy_book.buy_id = 5 AND book.book_id = buy_book.book_id;
SELECT * FROM book;

/*2.5.6. Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, цену, количество заказанных книг и  стоимость. 
Последний столбец назвать Стоимость. 
Информацию в таблицу занести в отсортированном по названиям книг виде. 
В данном задании необходимо вернуться к главе с запросам корректировки данных. Запрос на создание новой таблицы и повторить главу по соединению таблиц 
Самое главное правильно запросить столбцы табличек*/

CREATE table buy_pay AS
SELECT book.title, author.name_author, book.price, buy_book.amount, book.price * buy_book.amount AS Стоимость
FROM buy_book JOIN book USING (book_id) 
JOIN author USING (author_id)
WHERE buy_book.buy_id = 5 
ORDER BY book.title;
SELECT * FROM buy_pay;

/*2.5.7. Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. 
Куда включить номер заказа, количество книг в заказе (название столбца Количество) и его общую стоимость (название столбца Итого). 
Для решения используйте ОДИН запрос.
Дополнительное повторение предыдущего шага, но! Необходимо просуммировать количество книг и их стоимость  */

CREATE TABLE buy_pay AS
SELECT buy_book.buy_id, sum(buy_book.amount) as Количество, sum(book.price * buy_book.amount) as Итого
from book JOIN buy_book USING (book_id)
WHERE buy_book.buy_id = 5;
SELECT * FROM buy_pay;


/*2.5.8. В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ. 
В столбцы date_step_beg и date_step_end всех записей занести Null.
В данном заданиее необходимо использовать перекрастное соединение таблиц CROSS JOIN 
метод кросс джойн можно прописать Таблица1, Таблица2 
В данной задаче мы выбираем все столбцы таблицы бай степ и добавляем в них смерженные данные из таблиц степ и бай*/ 

INSERT INTO buy_step (buy_id, step_id, date_step_beg, date_step_end)
SELECT buy_id, step_id, NULL, NULL from buy CROSS JOIN step
WHERE buy_id = 5;
SELECT * FROM buy_step;

/*2.5.9. В таблицу buy_step занести дату 12.04.2020 выставления счета на оплату заказа с номером 5.
Правильнее было бы занести не конкретную, а текущую дату. Это можно сделать с помощью функции Now(). 
Но при этом в разные дни будут вставляться разная дата, и задание нельзя будет проверить, поэтому  вставим дату 12.04.2020.
*/

UPDATE buy_step
SET buy_step.date_step_beg = '2020-04-12'
Where step_id = 1 and buy_id = 5;
SELECT * FROM buy_step;

/*2.5.10. Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020, и начать следующий этап («Упаковка»), задав в столбце date_step_beg для этого этапа ту же дату.
Реализовать два запроса для завершения этапа и начала следующего. 
Они должны быть записаны в общем виде, чтобы его можно было применять для любых этапов, изменив только текущий этап. 
Для примера пусть это будет этап «Оплата».*/

UPDATE buy_step SET 
date_step_end = If(step_id = (select step_id from step WHERE name_step = 'Оплата'), '2020-04-13', date_step_end ), date_step_beg = If(step_id = (select step_id + 1 from step WHERE name_step = 'Оплата'), '2020-04-13', date_step_beg)
WHERE buy_id = 5;
SELECT * FROM buy_step;