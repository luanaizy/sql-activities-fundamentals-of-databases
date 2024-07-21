/* Universidade Federal do Ceará - Fundamentos de Banco de Dados - Lista 03
Luana Izy Veras Tavares - 511888 */



/* 1) Identificar o domínio dos atributos:

empregado:
enome (character varying(20)); 
cpf (character varying(4));
"endereço" (character varying(50)); 
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
*/


/*
2) Identificar as chaves candidatas, a chave primária e as chaves estrangeiras para cada relação.

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
*/

-- 3) Criar um Database chamado "fbd2023".
CREATE DATABASE fbd2023
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

-- 4) Criar um esquema chamado "eempresa" (no Database fbd2023).
CREATE SCHEMA eempresa
    

-- 5) Utilizando o PostgreSQL crie as relações do esquema fornecido anteriormente (no esquema eempresa).




CREATE TABLE eempresa.departamento
(
    dnome character varying(20) NOT NULL,
    codigo integer NOT NULL,
    gerente character varying(4),
    CONSTRAINT primarykey_codigo PRIMARY KEY (codigo)
)
WITH (
    OIDS = FALSE
);




CREATE TABLE eempresa.dunidade
(
    dcodigo integer NOT NULL,
    dcidade character varying(30) NOT NULL,
    CONSTRAINT primarykey_dcodigo_dcidade PRIMARY KEY (dcodigo, dcidade)
)
WITH (
    OIDS = FALSE
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
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)
WITH (
    OIDS = FALSE
);




CREATE TABLE eempresa.projeto
(
    pnome character varying(20) NOT NULL,
    pcodigo character varying(5) NOT NULL,
    cidade character varying(30) NOT NULL,
    cdep integer NOT NULL,
    CONSTRAINT primarykey_pcodigo PRIMARY KEY (pcodigo),
CONSTRAINT foreignkey_cidade_cdep FOREIGN KEY (cidade, cdep)
REFERENCES eempresa.dunidade (dcidade, dcodigo);
)
WITH (
    OIDS = FALSE
);


CREATE TABLE eempresa.tarefa
(
	cpf character varying(4) NOT NULL,
	pcodigo character varying(5) NOT NULL,
	horas numeric(3,1) NOT NULL,
	CONSTRAINT primarykey_cpf_pcodigo PRIMARY KEY (cpf,pcodigo),
	CONSTRAINT foreignkey_cpf FOREIGN KEY (cpf)
	REFERENCES eempresa.empregado (cpf),
	CONSTRAINT foreignkey_pcodigo FOREIGN KEY (pcodigo)
	REFERENCES eempresa.projeto (pcodigo)
)
WITH(
	OIDS = FALSE
);


--6) Incluir a seguinte restrição: o salário de um empregado não pode ser menor que R$ 1320,00.
ALTER TABLE eempresa.empregado
ADD CONSTRAINT check_salariomaiorque1320
CHECK (salario>1320);



--7) Povoe as relações conforme o esquema de trabalho apresentado anteriormente.
INSERT INTO eempresa.departamento
VALUES('Pesquisa', 3, '1234'),
('Marketing', 2, '6543'),
('Admnistração', 4, '8765');


INSERT INTO eempresa.dunidade
VALUES (2,'Morro Branco'), 
(3,'Cumbuco'),
(3,'Prainha'),
(3,'Taíba'),
(3,'Icapuí'),
(4,'Fortaleza');


INSERT INTO eempresa.empregado
VALUES('Chiquin','1234','rua 1, 1', '02/02/62', 'M', 10000.00,'8765',3),
('Helenita','4321','rua 2, 2', '03/03/63', 'F', 12000.00,'6543',2),
('Pedrin','5678','rua 3, 3', '04/04/64', 'M', 9000.00,'6543',2),
('Valtin','8765','rua 4, 4', '05/05/65', 'M', 15000.00,null,4),
('Zulmira','3456','rua 5, 5', '06/06/66', 'F', 12000.00,'8765',3),
('Zefinha','6543','rua 6, 6', '07/07/67', 'F', 10000.00,'8765',2);


INSERT INTO eempresa.projeto
VALUES ('ProdutoA', 'PA', 'Cumbuco', 3),
('ProdutoB', 'PB', 'Icapuí', 3),
('Informatização', 'Inf', 'Fortaleza', 4),
('Divulgação', 'Div', 'Morro Branco', 2);


INSERT INTO eempresa.tarefa
VALUES ('1234', 'PA', 30.0),
('1234', 'PB', 10.0),
('4321', 'PA', 5.0),
('4321', 'Div', 35.0),
('5678', 'Div', 40.0),
('8765', 'Inf', 32.0),
('8765', 'Div', 8.0),
('3456', 'PA', 10.0),
('3456', 'PB', 25.0),
('3456', 'Div', 5.0),
('6543', 'PB', 40.0);