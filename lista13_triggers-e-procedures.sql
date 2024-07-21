-- 2.1. Crie uma stored procedure que receba como parâmetro de entrada três parâmetros a matrícula do empregado, o ano e o mês. Este procedimento deve inserir uma tupla no banco de horas referente ao empregado e período em questão.

CREATE OR REPLACE FUNCTION inserir_banco_horas(matr int, ano int, mes char)
RETURNS void AS
$body$
BEGIN

INSERT INTO BANCO_HORAS (BAN_ANO, BAN_MES, EMP_MATRICULA) VALUES (ano, mes, matr);

END;
$body$
language 'plpgsql';


-- 2.2. Crie uma stored procedure que receba como parâmetro de entrada dois parâmetros o ano e o mês. Este procedimento deve inserir uma tupla no banco de horas para todos os empregados referente período em questão.

CREATE OR REPLACE FUNCTION inserir_emps_banco_horas(ano int, mes char)
RETURNS void AS
$body$
DECLARE
c refcursor;
empregado int;
BEGIN

OPEN c FOR SELECT EMP_MATRICULA FROM EMPREGADO;

LOOP
	FETCH C INTO empregado;
	EXIT WHEN NOT FOUND;
	INSERT INTO BANCO_HORAS (BAN_ANO, BAN_MES, EMP_MATRICULA) VALUES (ano, mes, empregado);
END LOOP;

END;
$body$
language 'plpgsql';


-- 2.3. Crie uma stored procedure que receba como parâmetro de entrada dois parâmetros o ano e o mês. Este procedimento deve retornar a matrícula do empregado com maior número de horas no banco de horas.

CREATE OR REPLACE FUNCTION emp_mais_horas(ano int, mes char)
RETURNS int AS
$body$
DECLARE
empregado int;

BEGIN
SELECT EMP_MATRICULA INTO empregado
FROM (SELECT SUM(BAN_TOTAL_HORAS) AS HORAS, EMP_MATRICULA FROM BANCO_HORAS WHERE BAN_ANO = ano AND BAN_MES = mes GROUP BY EMP_MATRICULA) AS TAB
WHERE TAB.HORAS >= ALL (SELECT SUM(BAN_TOTAL_HORAS) FROM BANCO_HORAS WHERE BAN_ANO = ano AND BAN_MES = mes GROUP BY EMP_MATRICULA);
RETURN empregado;

END;
$body$
language 'plpgsql';


-- 2.4.Crie uma stored procedure que receba como parâmetro de entrada quatro parâmetros a matrícula do empregado, o ano, o mês e o último dia do mês. Este procedimento deve inserir um conjunto de tuplas na relação freqüência referentes ao empregado e período em questão.

CREATE OR REPLACE FUNCTION inserir_em_frequencia(matr int, ano int, mes int, ultdia int )
RETURNS void AS
$body$
DECLARE
dia int;
dataform date;
BEGIN
dia:= 1;
WHILE dia <= ultdia LOOP
	dataform := MAKE_DATE(ano, mes, dia);
	INSERT INTO FREQUENCIA (EMP_MATRICULA, FREQ_DATA)VALUES (matr, dataform);
	dia:= dia + 1;
END LOOP;
END;
$body$
language 'plpgsql';


-- 2.5. Crie uma stored procedure que receba como parâmetro de entrada três parâmetros a matrícula do empregado, o ano e o mês. Este procedimento deve atualizar o valor do banco de horas neste mês para o empregado em questão.


CREATE OR REPLACE FUNCTION atualizar_no_banco_h(matr int, ano int, mes int )
RETURNS void AS
$body$
DECLARE
dataform char;
totalhoras real;
mesnome char;
BEGIN
dataform := TO_CHAR(ano) || TO_CHAR(mes) || '__';
SELECT SUM(FREQ_HORA_SAIDA - FREQ_HORA_ENTRADA + FREQ_HORAS_EXCEDENTES + FREQ_HORAS_NOTURNAS) INTO totalhoras FROM FREQUENCIA WHERE EMP_MATRICULA = matr AND TO_CHAR(FREQ_DATA) LIKE dataform  

if mes = 1 then
meschar := 'Janeiro';
else if mes = 2 then
meschar := 'Fevereiro';
else if mes = 3 then
meschar:= 'Março';
else if mes = 4 then
meschar := 'Abril';
else if mes = 5 then
meschar := 'Maio';
else if mes = 6 then
meschar := 'Junho'
else if mes = 7 then
meschar := 'Julho'
else if mes = 8 then
meschar := 'Agosto'
else if mes = 9 then
meschar := 'Setembro'
else if mes = 10 then
meschar := 'Outubro'
else if mes = 11 then
meschar := 'Novembro'
else if mes = 12 then
meschar := 'Dezembro'
END IF;

UPDATE BANCO_HORAS SET BAN_TOTAL_HORAS = totalhoras WHERE EMP_MATRICULA = matr AND BAN_ANO = ano AND BAN_MES = meschar;

END;
$body$
language 'plpgsql';


