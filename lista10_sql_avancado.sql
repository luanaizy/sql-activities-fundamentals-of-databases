/*1. Recuperar o nome do departamento com maior média salarial.*/
SELECT dnome
FROM eempresa.departamento
WHERE codigo IN (SELECT cdep
				FROM eempresa.empregado
				GROUP BY cdep
				HAVING AVG(salario) >= ALL (SELECT AVG(salario)
							   				FROM eempresa.empregado
						  					GROUP BY cdep))

ou

SELECT d.dnome
FROM eempresa.departamento d, eempresa.empregado e
WHERE d.codigo = e.cdep
GROUP BY d.dnome
HAVING AVG(e.salario) >= ALL (SELECT AVG(salario)
							  FROM eempresa.empregado
						  	  GROUP BY cdep)

/*2. Recuperar para cada departamento: o seu nome, o maior e o menor salário recebido
por empregados do departamento e a média salarial do departamento.*/

SELECT	d.dnome, tab.max_sal, tab.min_sal, tab.media_sal
FROM 	(SELECT cdep, MAX(salario) AS max_sal, MIN(salario) AS min_sal, AVG(salario) AS media_sal
		 FROM eempresa.empregado
		 GROUP BY cdep) AS tab, eempresa.departamento d
WHERE d.codigo = tab.cdep


/*3. Recuperar para cada departamento: o seu nome, o nome do seu gerente, a
quantidade de empregados, a quantidade de projetos do departamento e a
quantidade de unidades do departamento.*/

SELECT d.dnome, gerente.enome, emps.qtde_em, pros.qtde_pro, unis.qtde_uni
FROM
		(SELECT dcodigo, COUNT(*) as qtde_uni
		FROM eempresa.dunidade
		GROUP BY dcodigo) AS unis,

		(SELECT cdep, COUNT(*) as qtde_pro
		FROM eempresa.projeto
		GROUP BY cdep) AS pros,

		(SELECT cdep, COUNT(*) as qtde_em
		FROM eempresa.empregado
		GROUP BY cdep) AS emps,

		(SELECT d.codigo, e.enome
		FROM eempresa.empregado e, eempresa.departamento d
		WHERE d.gerente = e.cpf) as gerente,
	
		eempresa.departamento d	
WHERE unis.dcodigo = d.codigo AND pros.cdep = d.codigo AND emps.cdep = d.codigo AND gerente.codigo = d.codigo


/*4. Recuperar o nome do projeto que consome o maior número de horas.*/


SELECT p.pnome

FROM  (SELECT pcodigo, sum(horas) AS phoras
	FROM eempresa.tarefa
	GROUP BY pcodigo)  AS tab, eempresa.projeto p

WHERE p.pcodigo = tab.pcodigo AND tab.phoras >= ALL (SELECT sum(horas) as phoras
							 FROM eempresa.tarefa
							GROUP BY pcodigo)

/*5. Recuperar o nome do projeto mais caro.*/



 
SELECT p.pnome
FROM (SELECT tab1.pcodigo, sum(tab1.custo_para_o_projeto) as preco_proj
	FROM (SELECT t.cpf, t.pcodigo,  t.horas*(e.salario/40) as custo_para_o_projeto
	 	FROM eempresa.empregado e, eempresa.tarefa t
 	 	WHERE e.cpf = t.cpf) AS tab1
	GROUP BY pcodigo) AS tab, eempresa.projeto p
WHERE tab.pcodigo = p.pcodigo AND preco_proj >= ALL (SELECT sum(tab2.custo_para_o_projeto) 
						     FROM (SELECT t.cpf, t.pcodigo, t.horas*(e.salario/40) as custo_para_o_projeto
							   FROM eempresa.empregado e, eempresa.tarefa t
							   WHERE e.cpf = t.cpf) AS tab2
						     GROUP BY pcodigo)

/*6. Recuperar para cada projeto: o seu nome, o nome gerente do departamento que
controla o projeto, a quantidade total de horas alocadas ao projeto, a quantidade de
empregados alocados ao projeto e o custo mensal do projeto.*/


SELECT tab1.pnome, tab1.gerente_dep, tab2.horas_alocadas, tab2.empregados_alocados, tab3.preco_proj

FROM (SELECT p.pnome, p.pcodigo, e.enome AS gerente_dep
		FROM eempresa.empregado e, eempresa.departamento d, eempresa.projeto p
		WHERE p.cdep = d.codigo AND d.gerente = e.cpf) as tab1,

	(SELECT pcodigo, SUM(horas) AS horas_alocadas, COUNT(ALL cpf) AS empregados_alocados
	FROM eempresa.tarefa
	GROUP BY pcodigo) AS tab2,

	(SELECT tab.pcodigo, SUM(tab.custo_para_o_projeto) AS preco_proj
	FROM (SELECT t.cpf, t.pcodigo,  t.horas*(e.salario/40) AS custo_para_o_projeto
	 	FROM eempresa.empregado e, eempresa.tarefa t
 	 	WHERE e.cpf = t.cpf) AS tab
	GROUP BY pcodigo) AS tab3
	
WHERE tab1.pcodigo = tab2.pcodigo AND tab2.pcodigo = tab3.pcodigo
	


/*7. Recuperar o nome dos gerentes com sobrenome ‘Silva’.*/



SELECT e.enome
FROM eempresa.empregado e, eempresa.departamento d
WHERE d.gerente = e.cpf AND (e.enome LIKE '% Silva' OR e.enome LIKE '% Silva %')
	


/*8. Recupere o nome dos gerentes que estão alocados em algum projeto (ou seja,
possuem “alguma” tarefa em “algum” projeto).*/

SELECT DISTINCT e.enome
FROM eempresa.empregado e, eempresa.departamento d, eempresa.tarefa t
WHERE d.gerente = e.cpf AND t.cpf = d.gerente



/*9. Recuperar o nome dos empregados que participam de projetos que não são
gerenciados pelo seu departamento.*/



SELECT  t.cpf
FROM eempresa.tarefa t, eempresa.projeto p, eempresa.empregado e
WHERE t.pcodigo = p.pcodigo AND t.cpf = e.cpf

EXCEPT ALL

SELECT  t.cpf
FROM eempresa.tarefa t, eempresa.projeto p, eempresa.empregado e
WHERE t.pcodigo = p.pcodigo AND t.cpf = e.cpf AND e.cdep = p.cdep



/*10. Recuperar o nome dos empregados que participam de todos os projetos.*/



SELECT e.enome
FROM (SELECT cpf, COUNT( pcodigo) AS proj_em_que_participa
	  FROM eempresa.tarefa 
	  GROUP BY cpf) AS tab, eempresa.empregado e
WHERE tab.cpf=e.cpf AND tab.proj_em_que_participa = (SELECT COUNT(pcodigo) as qtde_proj
							FROM eempresa.projeto)

/*11. Recuperar para cada funcionário (empregado): o seu nome, o seu salário e o nome
do seu departamento. O resultado deve estar em ordem decrescente de salário.
Mostrar os empregados sem departamento e os departamentos sem empregados.*/

select empregado.enome,empregado.salario,departamento.dnome
from eempresa.empregado  FULL OUTER JOIN eempresa.departamento 
on empregado.cdep=departamento.codigo
order by empregado.salario desc

/*12. Recuperar para cada funcionário (empregado): o seu nome, o nome do seu chefe e
o nome do gerente do seu departamento.*/



SELECT e.enome, r1.chefe, r2.gerente

FROM		(SELECT enome as chefe, cpf
			FROM eempresa.empregado
			WHERE cpf IN (SELECT DISTINCT chefe 
						 FROM eempresa.empregado)) as r1,

			(SELECT e.enome as gerente, d.codigo
			FROM eempresa.empregado e, eempresa.departamento d
			WHERE d.codigo = e.cdep AND d.gerente = e.cpf) as r2,
			
			eempresa.empregado e
WHERE e.cdep = r2.codigo AND e.chefe = r1.cpf


/*13. Listar nome dos departamentos com média salarial maior que a média salarial da
empresa.*/


SELECT dnome
FROM eempresa.departamento
WHERE codigo IN		(SELECT cdep
					FROM eempresa.empregado
					GROUP BY cdep
					HAVING AVG(salario) > ALL (SELECT avg(salario) as media_empresa
						   						 FROM eempresa.empregado))




/*14. Listar todos os empregados que possuem salário maior que a média salarial de
seus departamentos.*/

SELECT e.enome, e.cpf, e.endereco, e.nasc, e.sexo, e.salario, e.chefe, e.cdep
FROM (SELECT cdep, avg(salario) as media_dep
	 FROM eempresa.empregado
	 GROUP BY cdep) as tab,
	 eempresa.empregado e
WHERE tab.cdep = e.cdep AND e.salario > tab.media_dep


/*15. Listar os empregados lotados nos departamentos localizados em “Fortaleza”.*/

SELECT e.enome
FROM eempresa.empregado e, eempresa.projeto p
WHERE p.cidade = 'Fortaleza' AND p.cdep = e.cdep

/*16. Listar nome de departamentos com empregados ganhando duas vezes mais que a
média do departamento*/

SELECT DISTINCT d.dnome
FROM(SELECT cdep, avg(salario) as media_dep
	FROM eempresa.empregado
	GROUP BY cdep) as tab,
	
	eempresa.departamento d, eempresa.empregado e
	
WHERE tab.cdep = e.cdep AND d.codigo = e.cdep AND e.salario >= 2*tab.media_dep

/*17. Recuperar o nome dos empregados com salário entre R$ 700 e R$ 2800.*/

SELECT enome
FROM eempresa.empregado
WHERE salario > 700 AND salario < 2800


/*18. Recuperar o nome dos departamentos que controlam projetos com mais de 50
empregados e que também controlam projetos com menos de 5 empregados.*/


SELECT distinct dnome
FROM (SELECT pcodigo, count(distinct cpf) as qtde_empregados
		FROM eempresa.tarefa
		group by pcodigo) AS tab, 
		
		eempresa.projeto p, eempresa.departamento d
WHERE tab.pcodigo = p.pcodigo AND p.cdep = d.codigo AND (tab.qtde_empregados > 50 OR tab.qtde_empregados < 5)



