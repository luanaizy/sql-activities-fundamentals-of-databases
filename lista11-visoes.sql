CREATE VIEW eempresa.view5
AS
SELECT d.codigo, d.dnome, tab.qtd_emp, tab.maior_sal, tab.menor_sal, tab.media_sal 
FROM eempresa.departamento d, (SELECT cdep, COUNT(cpf) as qtd_emp, MAX(salario) as maior_sal, MIN(salario) as menor_sal, AVG  (DISTINCT salario) as media_sal
								FROM eempresa.empregado
								GROUP BY cdep) as tab
WHERE d.codigo = tab.cdep



/*ALTERE A MÉDIA SALARIAL DO DEPARTAMENTO DE CÓDIGO IGUAL A 1*/

UPDATE eempresa.view5
SET media_sal = 3000
WHERE codigo = 1

A atualização não foi permitida, pois a visão a ser atualizada se origina de um select de duas ou mais tabelas, condição que a impede de ser atualizada.
Além disso, a tabela base "tab" usada no select que origina a visão é formada por um group by, o que também a impede de ser alterada.
Para realizar esta atualização nas tabelas base, seria preciso alterar os salários dos empregados lotados no departamento 1 de forma a garantir que a média entre esses salários seja igual a 3000
Uma forma imprudente de garantir isso seria alterar todos os salarios para 3000:

UPDATE eempresa.empregado
SET salario = 3000
WHERE cdep = 1





/*ALTERE A QUANTIDADE DE EMPREGADOS DO DEPARTAMENTO DE CÓDIGO 1*/

UPDATE eempresa.view5
SET qtd_emp = 5
WHERE codigo = 1

A atualização não foi permitida, pois a visão a ser atualizada se origina de um select de duas ou mais tabelas, condição que a impede de ser atualizada
Além disso, a tabela base "tab" usada no select que origina a visão é formada por um group by, o que também a impede de ser alterada.
Para realizar esta atualização nas tabelas base, seria preciso inserir ou deletar empregados cuja coluna cdep seja igual a 1

INSERT INTO eempresa.empregado
VALUES ('Luana', '2870', 'rua 7, 7', 20030125, 'F', null, 1) 



/*EXCLUA O DEPARTAMENTO DE CÓDIGO 1*/

DELETE
FROM eempresa.view5
WHERE codigo = 1

A atualização não foi permitida, pois a visão a ser atualizada se origina de um select de duas ou mais tabelas, condição que a impede de ser atualizada
A semântica desta atualização nas tabelas base correspondentes seria:


DELETE
FROM eempresa.departamento
WHERE codigo = 1


funciona, caso as tabelas que usem o atributo codigo como chave estrangeira tenham sido criadas com a restriçã ON DELETE CASCADE nestas colunas. Caso contrário, seria preciso deletar todas as tuplas nas demais tabelas que têm o valor 1 na coluna que referencia departamento ou alterar o valor desta coluna nessas tuplas antes de fazer o delete.

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

A atualização não foi permitida, pois a visão a ser atualizada se origina de um select de duas ou mais tabelas, condição que a impede de ser atualizada
A semântica desta atualização nas tabelas base correspondentes seria:

INSERT INTO eempresa.departamento
VALUES ('RH', 6, '4321')







/*ALTERE O NOME DE UM DOS DEPARTAMENTOS QUE APARECEM NA VISÃO*/


UPDATE eempresa.view5
SET dnome = 'Design'
WHERE dnome = 'Pesquisa'

A atualização não foi permitida, pois a visão a ser atualizada se origina de um select de duas ou mais tabelas, condição que a impede de ser atualizada
A semântica desta atualização nas tabelas base correspondentes seria:

UPDATE eempresa.departamento
SET dnome = 'Design'
WHERE dnome = 'Pesquisa'







