SELECT *
FROM company
WHERE status = 'closed'

--количество привлечённых средств для новостных компаний США.
SELECT funding_total
FROM company 
WHERE category_code LIKE '%news%' AND country_code ='USA' ORDER BY funding_total DESC

--Найдием общую сумму сделок по покупке одних компаний другими в долларах. 
--Отберем сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.
SELECT SUM (price_amount)
FROM acquisition
WHERE term_code ='cash' AND EXTRACT (YEAR FROM acquired_at) IN (2011, 2012, 2013)

--Отобразим имя, фамилию и названия аккаунтов людей в поле network_username, у которых названия аккаунтов начинаются на 'Silver'.
SELECT first_name, last_name, network_username
FROM people
WHERE network_username LIKE 'Silver%'

--Выведем на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'.
SELECT *
FROM people 
WHERE network_username LIKE '%money%' AND last_name LIKE 'K%'

--Для каждой страны отобразим общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируем данные по убыванию суммы.
SELECT country_code,
   SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC

--Составим таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
--Оставим в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.
SELECT funded_at,
    MIN (raised_amount),
    MAX (raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) NOT IN (0, MAX(raised_amount))

--Создадим поле с категориями:
--Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
--Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
--Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
--Отобразим все поля таблицы fund и новое поле с категориями.
SELECT *,
      CASE
          WHEN invested_companies > 100 THEN 'high_activity'
          WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
          ELSE  'low_activity'
      END
FROM fund

--Для каждой из категорий, назначенных в предыдущем задании, посчитаем округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведем на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.
SELECT CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds))
FROM fund
GROUP BY activity
ORDER BY ROUND(AVG(investment_rounds))

--Проанализируем, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
--Для каждой страны посчитайем минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключим страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю.
--Выгрузим десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. Затем добавим сортировку по коду страны в лексикографическом порядке.
SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM 
(SELECT *
FROM fund
WHERE EXTRACT (YEAR FROM founded_at) BETWEEN 2010 AND 2012) AS f

GROUP BY country_code
HAVING MIN(invested_companies) > 0
ORDER BY AVG(invested_companies) DESC
LIMIT 10;

--Отобразим имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.
SELECT p.first_name,
       p.last_name,
       ed.instituition
FROM people AS p
LEFT JOIN education AS ed ON p.id=ed.person_id

--Для каждой компании найдим количество учебных заведений, которые окончили её сотрудники. Выведем название компании и число уникальных названий учебных заведений. Составим топ-5 компаний по количеству университетов.
SELECT c.name,
       COUNT(DISTINCT e.instituition)
FROM company AS c
INNER JOIN people AS p ON c.id=p.company_id
INNER JOIN education AS e ON p.id=e.person_id
GROUP BY c.name
ORDER BY COUNT(DISTINCT e.instituition) DESC
LIMIT 5

--Составим список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.
SELECT DISTINCT com.name
FROM company AS com
LEFT JOIN funding_round AS fr ON com.id=fr.company_id
WHERE STATUS LIKE '%closed%'
  AND is_first_round = 1
  AND is_last_round = 1

--Составим список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.
SELECT DISTINCT p.id
FROM company AS com
INNER JOIN funding_round AS fr ON com.id=fr.company_id
INNER JOIN people AS p ON com.id=p.company_id
WHERE STATUS LIKE '%closed%'
  AND is_first_round = 1
  AND is_last_round = 1


--Составим таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.
SELECT DISTINCT p.id, ed.instituition
FROM company AS com
INNER JOIN funding_round AS fr ON com.id=fr.company_id
INNER JOIN people AS p ON com.id=p.company_id
INNER JOIN education AS ed ON p.id=ed.person_id
WHERE STATUS LIKE '%closed%'
  AND is_first_round = 1
  AND is_last_round = 1

--Посчитаем количество учебных заведений для каждого сотрудника из предыдущего задания. Некоторые сотрудники могли окончить одно и то же заведение дважды.
SELECT DISTINCT p.id,
       COUNT(ed.instituition)
FROM company AS com
INNER JOIN people AS p ON com.id=p.company_id
LEFT JOIN education AS ed ON p.id=ed.person_id
WHERE STATUS LIKE '%closed%'
  AND com.id IN (SELECT company_id
                FROM funding_round
                 WHERE is_first_round = 1
                   AND is_last_round = 1)
AND ed.instituition IS NOT NULL
GROUP BY p.id

--Дополним предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.
WITH base AS
(SELECT p.id,
COUNT(e.instituition)
FROM people AS p
LEFT JOIN education AS e ON p.id = e.person_id
WHERE p.company_id IN
(SELECT c.id
FROM company AS c
JOIN funding_round AS fr ON c.id = fr.company_id
WHERE STATUS ='closed'
AND is_first_round = 1
AND is_last_round = 1
GROUP BY c.id)
GROUP BY p.id
HAVING COUNT(DISTINCT e.instituition) >0)
SELECT AVG(COUNT)
FROM base;

--Выведем среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet.
SELECT AVG(fun.count_int)
FROM (SELECT DISTINCT p.id,
       COUNT(ed.instituition) AS count_int
FROM company AS com
INNER JOIN people AS p ON com.id=p.company_id
LEFT JOIN education AS ed ON p.id=ed.person_id
WHERE name LIKE 'Socialnet'
      AND ed.instituition IS NOT NULL 
GROUP BY p.id) AS fun

--Составим таблицу из полей:
--name_of_fund — название фонда;
--name_of_company — название компании;
--amount — сумма инвестиций, которую привлекла компания в раунде.
--В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.
SELECT f.name AS name_of_fund,
       com.name AS name_of_company,
       fr.raised_amount AS amount
FROM investment AS i
INNER JOIN company AS com ON i.company_id=com.id
INNER JOIN fund AS f ON i.fund_id=f.id
INNER JOIN funding_round AS fr ON i.funding_round_id=fr.id
WHERE com.milestones > 6
   AND EXTRACT(YEAR FROM CAST (fr.funded_at AS TIMESTAMP)) BETWEEN 2012 AND 2013

--Выгрузим таблицу, в которой будут такие поля:
--название компании-покупателя;
--сумма сделки;
--название компании, которую купили;
--сумма инвестиций, вложенных в купленную компанию;
--доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
--Исключим сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
--Отсортируем таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничим таблицу первыми десятью записями.
WITH acquiring AS
(SELECT c.name AS buyer,
a.price_amount AS price,
a.id AS KEY
FROM acquisition AS a
LEFT JOIN company AS c ON a.acquiring_company_id = c.id
WHERE a.price_amount > 0),
acquired AS
(SELECT c.name AS acquisition,
c.funding_total AS investment,
a.id AS KEY
FROM acquisition AS a
LEFT JOIN company AS c ON a.acquired_company_id = c.id
WHERE c.funding_total > 0)
SELECT acqn.buyer,
acqn.price,
acqd.acquisition,
acqd.investment,
ROUND(acqn.price / acqd.investment) AS uplift
FROM acquiring AS acqn
JOIN acquired AS acqd ON acqn.KEY = acqd.KEY
ORDER BY price DESC, acquisition
LIMIT 10;

--Выгрузим таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Убедимся, что сумма инвестиций не равна нулю. Выведем также номер месяца, в котором проходил раунд финансирования.
SELECT  c.name AS social_co,
EXTRACT (MONTH FROM fr.funded_at) AS funding_month
FROM company AS c
LEFT JOIN funding_round AS fr ON c.id = fr.company_id
WHERE c.category_code = 'social'
AND fr.funded_at BETWEEN '2010-01-01' AND '2013-12-31'
AND fr.raised_amount <> 0;

--Отберем данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируем данные по номеру месяца и получите таблицу, в которой будут поля:
--номер месяца, в котором проходили раунды;
--количество уникальных названий фондов из США, которые инвестировали в этом месяце;
--количество компаний, купленных за этот месяц;
--общая сумма сделок по покупкам в этом месяце.
WITH
fundings AS (SELECT EXTRACT (MONTH FROM CAST(fr.funded_at AS DATE)) AS funding_month,
      COUNT(DISTINCT f.id) AS id_fund
FROM fund AS f   
LEFT JOIN investment AS i ON f.id=i.fund_id
LEFT JOIN funding_round AS fr ON i.funding_round_id=fr.id
WHERE f.country_code = 'USA'
  AND EXTRACT(YEAR FROM CAST (fr.funded_at AS DATE)) BETWEEN 2010 AND 2013
GROUP BY funding_month),

acquisitions AS (SELECT EXTRACT (MONTH FROM CAST(acquired_at AS DATE)) AS funding_month,
      COUNT(acquired_company_id) AS acquired,
      SUM(price_amount) AS sum_total
FROM acquisition
WHERE EXTRACT(YEAR FROM CAST (acquired_at AS DATE)) BETWEEN 2010 AND 2013
GROUP BY funding_month) 
SELECT fnd.funding_month,
       fnd.id_fund,
       acq.acquired,
       acq.sum_total
FROM fundings AS fnd 
LEFT JOIN acquisitions AS acq ON fnd.funding_month=acq.funding_month

--Составим сводную таблицу и выведием среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год должны быть в отдельном поле. Отсортируем таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.
WITH
a AS (SELECT country_code,
      AVG(funding_total) AS totalavg_2011
   FROM company
   WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = 2011
     GROUP BY country_code),
b AS (SELECT country_code,
      AVG(funding_total) AS totalavg_2012
   FROM company
   WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = 2012
     GROUP BY country_code),
c AS (SELECT country_code,
      AVG(funding_total) AS totalavg_2013
   FROM company
   WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = 2013
     GROUP BY country_code)
SELECT a.country_code,
       a.totalavg_2011,
       b.totalavg_2012,
       c.totalavg_2013
FROM a INNER JOIN b ON a.country_code = b.country_code INNER JOIN c ON a.country_code = c.country_code
ORDER BY totalavg_2011 DESC