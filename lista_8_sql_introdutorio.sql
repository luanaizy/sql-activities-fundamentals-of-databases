
/*lista 8 - banco de dados
Luana Izy Veras Tavares - 511888



a)Identificar o domínio dos atributos:

empregado:
enome (character varying(20)); 
cpf (character varying(4));
endereco (character varying(50)); 
nasc (date);  sexo ("char"); 
salario (numeric(7,2)); 
chefe (character varying(4)); 
cdep (integer)
 
departamento:
dnome (character varying(20)); 
codigo (integer); 
gerente(character varying(4));
 
projeto:
pnome (character varying(20)); 
pcodigo(character varying(5)); 
cidade(character varying(30)); 
cdep(integer);
 
tarefa:
cpf(character varying(4)); 
pcodigo(character varying(5)); 
horas(numeric(3,1));
 
dunidade:
dcodigo(integer); 
dcidade(character varying(30))


o grau das relações (o número de atributos que seu esquema contém):
empregado: grau 7
departamento: grau 3
projeto: grau 4
tarefa: grau 3
dunidade: grau 2

a diferença entre esquema de relação e uma relação:

uma relação é uma tabela, um conjunto de tuplas.
um esquema de relação, por sua vez, é a descrição de uma relação, normalmente representada por:
nomeDaRelacao(Atributo1: tipodoA1, Atributo2: tipodoA2, ..., AtributoN: tipodoAN)

b) Identificar as chaves candidatas, a chave primária e as chaves estrangeiras para cada relação.
 
empregado:
chaves candidatas: (cpf) ;
chave primária: (cpf) ; 
chaves estrangeiras: (cdep -> departamento(codigo));
 
departamento:
chaves candidatas:(dnome), (codigo) ;
chave primária: (codigo) ;
 
projeto:
chaves candidatas: (pnome),(pcodigo) ;
chave primária: (pcodigo) ; 
chaves estrangeiras: ((cidade,cdep) -> dunidade(dcidade,dcodigo));
 
tarefa:
chaves candidatas:(cpf, pcodigo) ;
chave primária: (cpf, pcodigo) ; 
chaves estrangeiras: (cpf -> empregado(cpf)), (pcodigo -> projeto(pcodigo)) ;
 
dunidade:
chaves candidatas: (dcodigo,dcidade);
chave primária:(dcodigo, dcidade) ;



c) criar um database para o esquema*/

CREATE DATABASE fbd2023
WITH
OWNER = postgres
ENCODING='UTF8'
CONNECTION LIMIT=-1;


CREATE SCHEMA eempresa;


/*d)criar as relações mostradas no esquema*/

CREATE TABLE eempresa.departamento
(
    dnome character varying(20) NOT NULL,
    codigo integer NOT NULL,
    gerente character varying(4),
    CONSTRAINT primarykey_codigo PRIMARY KEY (codigo)
);

 
 
CREATE TABLE eempresa.dunidade
(
    dcodigo integer NOT NULL,
    dcidade character varying(30) NOT NULL,
    CONSTRAINT primarykey_dcodigo_dcidade PRIMARY KEY (dcodigo, dcidade)
);

 
 
CREATE TABLE eempresa.empregado
(
    enome character varying(20) NOT NULL,
    cpf character varying(4) NOT NULL,
    endereco character varying(50),
    nasc date,
    sexo "char",
    salario numeric(7, 2) NOT NULL,
    chefe character varying(4),
    cdep integer,
    CONSTRAINT primarykey_cpf PRIMARY KEY (cpf),
    CONSTRAINT foreignkey_cdep FOREIGN KEY (cdep)
        REFERENCES eempresa.departamento (codigo) MATCH SIMPLE
        ON DELETE NO ACTION
);

 
 
 
CREATE TABLE eempresa.projeto
(
    pnome character varying(20) NOT NULL,
    pcodigo character varying(5) NOT NULL,
    cidade character varying(30) NOT NULL,
    cdep integer NOT NULL,
    CONSTRAINT primarykey_pcodigo PRIMARY KEY (pcodigo),
CONSTRAINT foreignkey_cidade_cdep FOREIGN KEY (cidade, cdep)
REFERENCES eempresa.dunidade (dcidade, dcodigo)
);

CREATE TABLE eempresa.tarefa
(
	cpf character varying(4) NOT NULL,
	pcodigo character varying(5) NOT NULL,
	horas numeric(4,1) NOT NULL,
	CONSTRAINT primarykey_cpf_pcodigo PRIMARY KEY (cpf,pcodigo),
	CONSTRAINT foreignkey_cpf FOREIGN KEY (cpf)
	REFERENCES eempresa.empregado (cpf),
	CONSTRAINT foreignkey_pcodigo FOREIGN KEY(pcodigo)
	REFERENCES eempresa.projeto (pcodigo)
);


/*e)Povoar as relações:*/

INSERT INTO eempresa.departamento
VALUES ('Pesquisa', 3, 1234),
('Marketing', 2, 6543),
('Administracao', 4, 8765);

INSERT INTO eempresa.dunidade
VALUES (2, 'Morro Branco'),
(3, 'Cumbuco'),
(3, 'Prainha'),
(3, 'Taiba'),
(3, 'Icapui'),
(4, 'Fortaleza');

INSERT INTO eempresa.empregado
VALUES ('Chiquin', 1234 ,'rua 1, 1', '19620202', 'M', 10000.00, 8765, 3),
('Helenita', 4321, 'rua 2, 2', '19630303', 'F', 12000.00, 6543, 2),
('Pedrin', 5678, 'rua 3, 3', '19640404', 'M', 9000.00, 6543, 2),
('Valtin', 8765, 'rua 4, 4', '19650505', 'M', 15000.00, null, 4),
('Zulmira', 3456, 'rua 5, 5', '19660606', 'F', 12000.00, 8765, 3),
('Zefinha', 6543, 'rua 6, 6', '19670707', 'F', 10000.00, 8765, 2);

INSERT INTO eempresa.projeto
VALUES ('ProdutoA', 'PA', 'Cumbuco', 3),
('ProdutoB', 'PB', 'Icapui', 3),
('Informatizacao', 'Inf', 'Fortaleza', 4),
('Divulgacao', 'Div', 'Morro Branco', 2);

INSERT INTO eempresa.tarefa
VALUES (1234, 'PA', 30.0),
(1234, 'PB', 10.0),
(4321, 'PA', 5.0),
(4321, 'Div', 35.0),
(5678, 'Div', 40.0),
(8765, 'Inf', 32.0),
(8765, 'Div', 8.0),
(3456, 'PA', 10.0),
(3456, 'PB', 25.0),
(3456, 'Div', 5.0),
(6543, 'PB', 40.0);





/*a) Recupere o nome e o salário de todos os empregados que trabalham em Marketing.*/

SELECT e.enome, e.salario 
FROM eempresa.empregado e, eempresa.departamento d
WHERE e.cdep = d.codigo AND d.dnome = 'Marketing'

/*b) Recupere o CPF de todos os empregados que trabalham em Pesquisa ou que diretamente gerenciam um empregado que trabalha em Pesquisa.*/

SELECT e.cpf
FROM eempresa.empregado e, eempresa.departamento d
WHERE e.cdep = d.codigo AND d.dnome = 'Pesquisa'
UNION
SELECT e.cpf
FROM eempresa.empregado e, eempresa.departamento d
WHERE d.dnome = 'Pesquisa' AND e.cpf = d.gerente

/*c) Recupere o nome e a cidade dos projetos que envolvem (contêm) pelo menos um empregado que trabalha mais de 30 horas nesse projeto.*/

SELECT DISTINCT p.pnome, p.cidade
FROM eempresa.projeto p, eempresa.tarefa t
WHERE t.horas > 30 AND t.pcodigo = p.pcodigo


/*d) Recupere o nome e a data de nascimento dos gerentes de cada departamento.*/

SELECT e.enome, e.nasc
FROM eempresa.empregado e, eempresa.departamento d
WHERE e.cpf = d.gerente



/*e) Recupere o nome e o endereço de todos os empregados que trabalham para o departamento “Pesquisa”.*/

SELECT e.enome, e.endereco
FROM eempresa.empregado e, eempresa.departamento d
WHERE d.dnome = 'Pesquisa' AND d.codigo = e.cdep



/*f) Para cada projeto localizado em Icapuí, recupere o código do projeto, o nome do
departamento que o controla e o nome do seu gerente.*/

SELECT p.pcodigo, d.dnome, e.enome
FROM eempresa.empregado e, eempresa.departamento d, eempresa. projeto p
WHERE p.cidade = 'Icapui' AND p.cdep = d.codigo AND d.gerente = e.cpf




/*g) Recupere o nome e o sexo dos empregados que não são gerentes.*/

SELECT e.enome, e.sexo
FROM (SELECT cpf
        FROM eempresa.empregado 
        EXCEPT
        SELECT e.cpf
        FROM eempresa.empregado e, eempresa.departamento d
        WHERE e.cpf = d.gerente) AS tabela, eempresa.empregado e
WHERE tabela.cpf = e.cpf
