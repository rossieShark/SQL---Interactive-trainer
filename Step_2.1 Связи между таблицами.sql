
/*2.1.6. Создать таблицу author*/
CREATE TABLE author(
    author_id 	INT PRIMARY KEY AUTO_INCREMENT,
    name_author VARCHAR(50)
);

/*2.1.7. Внести данные в таблицу*/
INSERT INTO author (name_author) VALUES 
('Булгаков М.А.'),
('Достоевский Ф.М.'),
('Есенин С.А.'),
('Пастернак Б.Л.');

SELECT * FROM author;
  
 /*2.1.8. Перепишите запрос на создание таблицы book , чтобы ее структура соответствовала структуре, показанной на логической схеме (таблица genre уже создана, 
 порядок следования столбцов - как на логической схеме в таблице book, genre_id  - внешний ключ) . 
 Для genre_id ограничение о недопустимости пустых значений не задавать. В качестве главной таблицы для описания поля  genre_idиспользовать таблицу genre следующей структуры:*/
  
CREATE TABLE book(
    book_id INT PRIMARY KEY AUTO_INCREMENT ,
    title VARCHAR(50),
    author_id INT NOT NULL,
    genre_id INT,
    price DECIMAL(8,2),
    amount INT,
    FOREIGN KEY (author_id)  REFERENCES author (author_id),
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id)
);

/*2.1.8. Создать таблицу book той же структуры, что и на предыдущем шаге. Будем считать, что при удалении автора из таблицы author, 
должны удаляться все записи о книгах из таблицы book, написанные этим автором. А при удалении жанра из таблицы genre для соответствующей 
записи book установить значение Null в столбце genre_id. */

CREATE TABLE book(
    book_id INT PRIMARY KEY AUTO_INCREMENT ,
    title VARCHAR(50),
    author_id INT NOT NULL,
    genre_id INT,
    price DECIMAL(8,2),
    amount INT,
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) ON DELETE SET NULL
);

/*2.1.10. Добавьте три последние записи (с ключевыми значениями 6, 7, 8) в таблицу book, первые 5 записей уже добавлены:*/
INSERT INTO book (title, author_id,genre_id, price, amount) VALUES 
('Стихотворения и поэмы', 3, 2, 650.00, 15),
('Черный человек', 3, 2, 570.20, 6),
('Лирика', 4, 2, 518.99, 2);
SELECT * FROM book


