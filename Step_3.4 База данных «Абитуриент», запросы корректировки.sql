/*3.4.2  Создать вспомогательную таблицу applicant,  куда включить id образовательной программы, 
id абитуриента, сумму баллов абитуриентов (столбец itog) в отсортированном сначала по id образовательной программы, 
а потом по убыванию суммы баллов виде (использовать запрос из предыдущего урока).    */
CREATE TABLE applicant
SELECT program.program_id, enrollee.enrollee_id, sum(result) as itog FROM
enrollee 
JOIN program_enrollee USING (enrollee_id) 
JOIN program USING(program_id) 
JOIN program_subject ON program.program_id = program_subject.program_id
JOIN subject USING (subject_id) 
JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id 
and enrollee_subject.enrollee_id = enrollee.enrollee_id
GROUP BY program_id, enrollee_id
ORDER BY program_id, itog DESC;
SELECT * FROM applicant;

/*3.4.3 Из таблицы applicant, созданной на предыдущем шаге, удалить записи,
если абитуриент на выбранную образовательную программу не набрал минимального балла хотя бы по одному предмету (использовать запрос из предыдущего урока). */
DELETE FROM applicant
 USING applicant
inner join program_subject using(program_id)
inner join enrollee_subject using(subject_id,enrollee_id)
WHERE result < min_result;
SELECT * FROM applicant;

/*3.4.4 Повысить итоговые баллы абитуриентов в таблице applicant на значения дополнительных баллов (использовать запрос из предыдущего урока). */
UPDATE applicant JOIN (
    SELECT enrollee_id, IFNULL(SUM(bonus), 0) AS Бонус FROM enrollee_achievement
    LEFT JOIN achievement USING(achievement_id)
    GROUP BY enrollee_id 
    ) AS t USING(enrollee_id)
SET itog = itog + Бонус;

/*3.4.5 Поскольку при добавлении дополнительных баллов, абитуриенты по каждой образовательной программе могут следовать не в порядке убывания суммарных баллов, необходимо создать новую таблицу applicant_order на основе таблицы applicant. 
При создании таблицы данные нужно отсортировать сначала по id образовательной программы, потом по убыванию итогового балла. 
А таблицу applicant, которая была создана как вспомогательная, необходимо удалить. */
CREATE TABLE applicant_order AS
SELECT program_id, enrollee_id, itog FROM applicant
ORDER BY 1, 3 DESC;
SELECT * FROM applicant_order;
DROP TABLE applicant;

/*3.4.6   Занести в столбец str_id таблицы applicant_order нумерацию абитуриентов, которая начинается с 1 для каждой образовательной программы.   */
SET @row_num := 1;
SET @num_pr := 0;
UPDATE applicant_order
    SET str_id = IF(program_id = @num_pr, @row_num := @row_num + 1, @row_num := 1 AND @num_pr := @num_pr + 1);

/*3.4.7 Создать таблицу student,  в которую включить абитуриентов, которые могут быть рекомендованы к зачислению  в соответствии с планом набора. 
Информацию отсортировать сначала в алфавитном порядке по названию программ, а потом по убыванию итогового балла.     */
create table student as
select program.name_program, enrollee.name_enrollee, applicant_order.itog 
from applicant_order
join program using (program_id)
join enrollee using (enrollee_id)
where applicant_order.str_id <= program.plan
order by 1, 3 desc ;



/* 3.5.2. Отобрать все шаги, в которых рассматриваются вложенные запросы (то есть в названии шага упоминаются вложенные запросы). Указать к какому уроку и модулю они относятся. 
Для этого вывести 3 поля:
в поле Модуль указать номер модуля и его название через пробел;
в поле Урок указать номер модуля, порядковый номер урока (lesson_position) через точку и название урока через пробел;
в поле Шаг указать номер модуля, порядковый номер урока (lesson_position) через точку, порядковый номер шага (step_position) через точку и название шага через пробел.
Длину полей Модуль и Урок ограничить 19 символами, при этом слишком длинные надписи обозначить многоточием в конце (16 символов - это номер модуля или урока, пробел и  название Урока или Модуля к ним присоединить "..."). 
Информацию отсортировать по возрастанию номеров модулей, порядковых номеров уроков и порядковых номеров шагов. */

select 
CONCAT(LEFT(CONCAT(module_id, ' ',module_name), 16), '...') as Модуль,
CONCAT(LEFT(CONCAT(module_id, '.', lesson_position, ' ', lesson_name), 16), '...') as Урок,
CONCAT(module_id, '.', lesson_position, '.', step_position, ' ',step_name) as Шаг
from module
JOIN lesson USING(module_id) 
JOIN step USING(lesson_id)
WHERE step_name LIKE '%ложенн% запрос%'
order by 1,2,3;