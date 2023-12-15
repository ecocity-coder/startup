# startup
Проект по анализу рынка инвестиций в стартапы для венчурных фондов<br>
все записи из таблицы company по компаниям, которые закрылись.<br>
SELECT *<br>
FROM company<br>
WHERE status = 'closed'<br>

 количество привлечённых средств для новостных компаний США.<br>
SELECT funding_total<br>
FROM company <br>
WHERE category_code LIKE '%news%' AND country_code ='USA' ORDER BY funding_total DESC<br>

Найдием общую сумму сделок по покупке одних компаний другими в долларах. <br>
Отберем сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.<br>
SELECT SUM (price_amount)<br>
FROM acquisition<br>
WHERE term_code ='cash' AND EXTRACT (YEAR FROM acquired_at) IN (2011, 2012, 2013)<br>

Отобразим имя, фамилию и названия аккаунтов людей в поле network_username, у которых названия аккаунтов начинаются на 'Silver'.<br>
SELECT first_name, last_name, network_username<br>
FROM people<br>
WHERE network_username LIKE 'Silver%'<br>

Выведем на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'.<br>
SELECT *<br>
FROM people <br>
WHERE network_username LIKE '%money%' AND last_name LIKE 'K%'<br>

Для каждой страны отобразим общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируем данные по убыванию суммы.<br>
SELECT country_code,<br>
   SUM(funding_total)<br>
FROM company<br>
GROUP BY country_code<br>
ORDER BY SUM(funding_total) DESC<br>

Составим таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставим в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.<br>
SELECT funded_at,<br>
    MIN (raised_amount),<br>
    MAX (raised_amount)<br>
FROM funding_round<br>
GROUP BY funded_at<br>
HAVING MIN(raised_amount) NOT IN (0, MAX(raised_amount))<br>

Создадим поле с категориями:<br>
Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.<br>
Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.<br>
Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.<br>
Отобразим все поля таблицы fund и новое поле с категориями.<br>
SELECT *,<br>
      CASE<br>
          WHEN invested_companies > 100 THEN 'high_activity'<br>
          WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'<br>
          ELSE  'low_activity'<br>
      END<br>
FROM fund<br>

Для каждой из категорий, назначенных в предыдущем задании, посчитаем округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведем на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.<br>
SELECT CASE<br>
           WHEN invested_companies>=100 THEN 'high_activity'<br>
           WHEN invested_companies>=20 THEN 'middle_activity'<br>
           ELSE 'low_activity'<br>
       END AS activity,<br>
       ROUND(AVG(investment_rounds))<br>
FROM fund<br>
GROUP BY activity<br>
ORDER BY ROUND(AVG(investment_rounds))<br>

Проанализируем, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. <br>
Для каждой страны посчитайем минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключим страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Выгрузим десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. Затем добавим сортировку по коду страны в лексикографическом порядке.<br>
SELECT country_code,<br>
       MIN(invested_companies),<br>
       MAX(invested_companies),<br>
       AVG(invested_companies)<br>
FROM <br>
(SELECT *<br>
FROM fund<br>       
WHERE EXTRACT (YEAR FROM founded_at) BETWEEN 2010 AND 2012) AS f<br>
 
GROUP BY country_code<br>
HAVING MIN(invested_companies) > 0<br>
ORDER BY AVG(invested_companies) DESC<br>
LIMIT 10;<br>

Отобразим имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.<br>
SELECT p.first_name,<br>
       p.last_name,<br>
       ed.instituition<br>
FROM people AS p<br>
LEFT JOIN education AS ed ON p.id=ed.person_id<br>

Для каждой компании найдим количество учебных заведений, которые окончили её сотрудники. Выведем название компании и число уникальных названий учебных заведений. Составим топ-5 компаний по количеству университетов.<br>
SELECT c.name,<br>
       COUNT(DISTINCT e.instituition)<br>
FROM company AS c<br>
INNER JOIN people AS p ON c.id=p.company_id<br>
INNER JOIN education AS e ON p.id=e.person_id<br>
GROUP BY c.name<br>
ORDER BY COUNT(DISTINCT e.instituition) DESC<br>
LIMIT 5<br>

Составим список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.<br>
SELECT DISTINCT com.name<br>
FROM company AS com<br>
LEFT JOIN funding_round AS fr ON com.id=fr.company_id<br>
WHERE STATUS LIKE '%closed%'<br>
  AND is_first_round = 1<br>
  AND is_last_round = 1<br>

Составим список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.<br>
SELECT DISTINCT p.id<br>
FROM company AS com<br>
INNER JOIN funding_round AS fr ON com.id=fr.company_id<br>
INNER JOIN people AS p ON com.id=p.company_id<br>
WHERE STATUS LIKE '%closed%'<br>
  AND is_first_round = 1<br>
  AND is_last_round = 1<br>


Составим таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.<br>
SELECT DISTINCT p.id, ed.instituition<br>
FROM company AS com<br>
INNER JOIN funding_round AS fr ON com.id=fr.company_id<br>
INNER JOIN people AS p ON com.id=p.company_id<br>
INNER JOIN education AS ed ON p.id=ed.person_id<br>
WHERE STATUS LIKE '%closed%'<br>
  AND is_first_round = 1<br>
  AND is_last_round = 1<br>

Посчитаем количество учебных заведений для каждого сотрудника из предыдущего задания. Некоторые сотрудники могли окончить одно и то же заведение дважды.<br>
SELECT DISTINCT p.id,<br>
       COUNT(ed.instituition)<br>
FROM company AS com<br>
INNER JOIN people AS p ON com.id=p.company_id<br>
LEFT JOIN education AS ed ON p.id=ed.person_id<br>
WHERE STATUS LIKE '%closed%'<br>
  AND com.id IN (SELECT company_id<br>
                FROM funding_round<br>
                 WHERE is_first_round = 1<br>
                   AND is_last_round = 1)<br>
AND ed.instituition IS NOT NULL<br>
GROUP BY p.id<br>

Дополним предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.<br>
WITH base AS<br>
(SELECT p.id,<br>
COUNT(e.instituition)<br>
FROM people AS p<br>
LEFT JOIN education AS e ON p.id = e.person_id<br>
WHERE p.company_id IN<br>
(SELECT c.id<br>
FROM company AS c<br>
JOIN funding_round AS fr ON c.id = fr.company_id<br>
WHERE STATUS ='closed'<br>
AND is_first_round = 1<br>
AND is_last_round = 1<br>
GROUP BY c.id)<br>
GROUP BY p.id<br>
HAVING COUNT(DISTINCT e.instituition) >0)<br>
SELECT AVG(COUNT)<br>
FROM base;<br>

Выведем среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet.<br>
SELECT AVG(fun.count_int)<br>
FROM (SELECT DISTINCT p.id,<br>
       COUNT(ed.instituition) AS count_int<br>
FROM company AS com<br>
INNER JOIN people AS p ON com.id=p.company_id<br>
LEFT JOIN education AS ed ON p.id=ed.person_id<br>
WHERE name LIKE 'Socialnet'<br>
      AND ed.instituition IS NOT NULL <br>
GROUP BY p.id) AS fun<br>

Составим таблицу из полей:<br>
name_of_fund — название фонда;<br>
name_of_company — название компании;<br>
amount — сумма инвестиций, которую привлекла компания в раунде.<br>
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.<br>
SELECT f.name AS name_of_fund,<br>
       com.name AS name_of_company,<br>
       fr.raised_amount AS amount<br>
FROM investment AS i<br>
INNER JOIN company AS com ON i.company_id=com.id<br>
INNER JOIN fund AS f ON i.fund_id=f.id<br>
INNER JOIN funding_round AS fr ON i.funding_round_id=fr.id<br>
WHERE com.milestones > 6<br>
   AND EXTRACT(YEAR FROM CAST (fr.funded_at AS TIMESTAMP)) BETWEEN 2012 AND 2013<br>

Выгрузим таблицу, в которой будут такие поля:<br>
название компании-покупателя;<br>
сумма сделки;<br>
название компании, которую купили;<br>
сумма инвестиций, вложенных в купленную компанию;<br>
доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.<br>
Исключим сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. <br><br>
Отсортируем таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничим таблицу первыми десятью записями.<br>
WITH acquiring AS<br>
(SELECT c.name AS buyer,<br>
a.price_amount AS price,<br>
a.id AS KEY<br>
FROM acquisition AS a<br>
LEFT JOIN company AS c ON a.acquiring_company_id = c.id<br>
WHERE a.price_amount > 0),<br>
acquired AS<br>
(SELECT c.name AS acquisition,<br>
c.funding_total AS investment,<br>
a.id AS KEY<br>
FROM acquisition AS a<br>
LEFT JOIN company AS c ON a.acquired_company_id = c.id<br>
WHERE c.funding_total > 0)<br>
SELECT acqn.buyer,<br>
acqn.price,<br>
acqd.acquisition,<br>
acqd.investment,<br>
ROUND(acqn.price / acqd.investment) AS uplift<br>
FROM acquiring AS acqn<br>
JOIN acquired AS acqd ON acqn.KEY = acqd.KEY<br>
ORDER BY price DESC, acquisition<br>
LIMIT 10;<br>

Выгрузим таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Убедимся, что сумма инвестиций не равна нулю. Выведем также номер месяца, в котором проходил раунд финансирования.<br>
SELECT  c.name AS social_co,<br>
EXTRACT (MONTH FROM fr.funded_at) AS funding_month<br>
FROM company AS c<br>
LEFT JOIN funding_round AS fr ON c.id = fr.company_id<br>
WHERE c.category_code = 'social'<br>
AND fr.funded_at BETWEEN '2010-01-01' AND '2013-12-31'<br>
AND fr.raised_amount <> 0;<br>

Отберем данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируем данные по номеру месяца и получите таблицу, в которой будут поля:
номер месяца, в котором проходили раунды;<br>
количество уникальных названий фондов из США, которые инвестировали в этом месяце;<br>
количество компаний, купленных за этот месяц;<br>
общая сумма сделок по покупкам в этом месяце.<br>
WITH<br>
fundings AS (SELECT EXTRACT (MONTH FROM CAST(fr.funded_at AS DATE)) AS funding_month,<br>
      COUNT(DISTINCT f.id) AS id_fund<br>
FROM fund AS f   <br>  
LEFT JOIN investment AS i ON f.id=i.fund_id<br>
LEFT JOIN funding_round AS fr ON i.funding_round_id=fr.id<br>
WHERE f.country_code = 'USA'<br>
  AND EXTRACT(YEAR FROM CAST (fr.funded_at AS DATE)) BETWEEN 2010 AND 2013<br>
GROUP BY funding_month),<br>
 
acquisitions AS (SELECT EXTRACT (MONTH FROM CAST(acquired_at AS DATE)) AS funding_month,<br>
      COUNT(acquired_company_id) AS acquired,<br>
      SUM(price_amount) AS sum_total<br>
FROM acquisition<br>
WHERE EXTRACT(YEAR FROM CAST (acquired_at AS DATE)) BETWEEN 2010 AND 2013<br>
GROUP BY funding_month) <br>
SELECT fnd.funding_month,<br>
       fnd.id_fund,<br>
       acq.acquired,<br>
       acq.sum_total<br>
FROM fundings AS fnd <br>
LEFT JOIN acquisitions AS acq ON fnd.funding_month=acq.funding_month<br>

Составим сводную таблицу и выведием среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год должны быть в отдельном поле. Отсортируем таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.<br>
WITH<br>
a AS (SELECT country_code,<br>
      AVG(funding_total) AS totalavg_2011<br>
   FROM company<br>
   WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = 2011<br>
     GROUP BY country_code),<br>
b AS (SELECT country_code,<br>
      AVG(funding_total) AS totalavg_2012<br>
   FROM company<br>
   WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = 2012<br>
     GROUP BY country_code),<br>
c AS (SELECT country_code,<br>
      AVG(funding_total) AS totalavg_2013<br>
   FROM company<br>
   WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = 2013<br>
     GROUP BY country_code)<br>
SELECT a.country_code,<br>
       a.totalavg_2011,<br>
       b.totalavg_2012,<br>
       c.totalavg_2013<br>
FROM a INNER JOIN b ON a.country_code = b.country_code INNER JOIN c ON a.country_code = c.country_code<br>
ORDER BY totalavg_2011 DESC<br>
