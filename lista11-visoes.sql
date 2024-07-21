CREATE VIEW eempresa.view5
AS
SELECT d.codigo, d.dnome, tab.qtd_emp, tab.maior_sal, tab.menor_sal, tab.media_sal 
FROM eempresa.departamento d, (SELECT cdep, COUNT(cpf) as qtd_emp, MAX(salario) as maior_sal, MIN(salario) as menor_sal, AVG  (DISTINCT salario) as media_sal
								FROM eempresa.empregado
								GROUP BY cdep) as tab
WHERE d.codigo = tab.cdep



/*ALTERE A M�DIA SALARIAL DO DEPARTAMENTO DE C�DIGO IGUAL A 1*/

UPDATE eempresa.view5
SET media_sal = 3000
WHERE codigo = 1

A atualiza��o n�o foi permitida, pois a vis�o a ser atualizada se origina de um select de duas ou mais tabelas, condi��o que a impede de ser atualizada.
Al�m disso, a tabela base "tab" usada no select que origina a vis�o � formada por um group by, o que tamb�m a impede de ser alterada.
Para realizar esta atualiza��o nas tabelas base, seria preciso alterar os sal�rios dos empregados lotados no departamento 1 de forma a garantir que a m�dia entre esses sal�rios seja igual a 3000
Uma forma imprudente de garantir isso seria alterar todos os salarios para 3000:

UPDATE eempresa.empregado
SET salario = 3000
WHERE cdep = 1





/*ALTERE A QUANTIDADE DE EMPREGADOS DO DEPARTAMENTO DE C�DIGO 1*/

UPDATE eempresa.view5
SET qtd_emp = 5
WHERE codigo = 1

A atualiza��o n�o foi permitida, pois a vis�o a ser atualizada se origina de um select de duas ou mais tabelas, condi��o que a impede de ser atualizada
Al�m disso, a tabela base "tab" usada no select que origina a vis�o � formada por um group by, o que tamb�m a impede de ser alterada.
Para realizar esta atualiza��o nas tabelas base, seria preciso inserir ou deletar empregados cuja coluna cdep seja igual a 1

INSERT INTO eempresa.empregado
VALUES ('Luana', '2870', 'rua 7, 7', 20030125, 'F', null, 1) 



/*EXCLUA O DEPARTAMENTO DE C�DIGO 1*/

DELETE
FROM eempresa.view5
WHERE codigo = 1

A atualiza��o n�o foi permitida, pois a vis�o a ser atualizada se origina de um select de duas ou mais tabelas, condi��o que a impede de ser atualizada
A sem�ntica desta atualiza��o nas tabelas base correspondentes seria:


DELETE
FROM eempresa.departamento
WHERE codigo = 1


funciona, caso as tabelas que usem o atributo codigo como chave estrangeira tenham sido criadas com a restri�� ON DELETE CASCADE nestas colunas. Caso contr�rio, seria preciso deletar todas as tuplas nas demais tabelas que t�m o valor 1 na coluna que referencia departamento ou alterar o valor desta coluna nessas tuplas antes de fazer o delete.

UPDATE eempresa.dunidade
SET dcodigo = 5
WHERE dcodigo = 1

UPDATE eempresa.projeto
SET cdep = 5
WHERE cdep = 1

UPDATE eempresa.empregado
SET cdep = 5
WHERE cdep = 1

DELETE
FROM eempresa.departamento
WHERE codigo = 1






/*INSIRA UM NOVO DEPARTAMENTO*/

INSERT INTO eempresa.view5
VALUES (6, 'RH', 0, 0, 0, 0)

A atualiza��o n�o foi permitida, pois a vis�o a ser atualizada se origina de um select de duas ou mais tabelas, condi��o que a impede de ser atualizada
A sem�ntica desta atualiza��o nas tabelas base correspondentes seria:

INSERT INTO eempresa.departamento
VALUES ('RH', 6, '4321')







/*ALTERE O NOME DE UM DOS DEPARTAMENTOS QUE APARECEM NA VIS�O*/


UPDATE eempresa.view5
SET dnome = 'Design'
WHERE dnome = 'Pesquisa'

A atualiza��o n�o foi permitida, pois a vis�o a ser atualizada se origina de um select de duas ou mais tabelas, condi��o que a impede de ser atualizada
A sem�ntica desta atualiza��o nas tabelas base correspondentes seria:

UPDATE eempresa.departamento
SET dnome = 'Design'
WHERE dnome = 'Pesquisa'







