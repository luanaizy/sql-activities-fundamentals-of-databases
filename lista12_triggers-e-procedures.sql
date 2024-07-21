-- LUANA IZY VERAS TAVARES - 511888

-- 2.1 Crie um procedimento para cadastrar um empregado.


CREATE OR REPLACE FUNCTION eempresa.cadastrar_empregado(enome character varying, cpf character varying, endereco character varying, nasc date, sexo char, salario numeric, chefe character varying, cdep integer)
RETURNS void AS
$body$
DECLARE
linhaEmpregado eempresa.empregado%ROWTYPE;
BEGIN
linhaEmpregado:= (enome, cpf, endereco, nasc, sexo, salario, chefe, cdep);
INSERT INTO eempresa.empregado VALUES (linhaEmpregado);
END;
$body$
language 'plpgsql';




-- 2.2 Crie um procedimento que recebe como parâmetro de entrada o CPF de um empregado e
-- um valor para o número de horas e insere uma tupla em Tarefa para cada projeto (para
-- este empregado e número de horas).


CREATE OR REPLACE FUNCTION inserir_tarefa_para_cada_projeto(cpfemp character varying, numhoras numeric)
RETURNS void AS
$body$
DECLARE
c refcursor;
pcodigo character varying;
BEGIN
OPEN c FOR SELECT DISTINCT pcodigo FROM eempresa.projeto;
LOOP
	FETCH c INTO pcodigo;
	EXIT WHEN NOT FOUND;
	INSERT INTO eempresa.tarefa VALUES ($1, pcodigo, $2);
END LOOP;
END;
$body$
language 'plpgsql';



-- 2.3 Crie um procedimento que retorne o CPF do empregado com maior salário.


CREATE OR REPLACE FUNCTION eempresa.cpf_maior_salario()
RETURNS character varying AS
$body$
DECLARE
emp_maior_sal character varying;
BEGIN

SELECT cpf INTO emp_maior_sal FROM eempresa.empregado WHERE salario = (SELECT max(salario) FROM eempresa.empregado);
RETURN emp_maior_sal;

END;
$body$
language 'plpgsql';



-- 2.4 Crie um procedimento que recebe como parâmetro de entrada o código de um
-- departamento e retorna o CPF do empregado deste departamento com maior salário.

CREATE OR REPLACE FUNCTION eempresa.emp_maior_sal_depart(depid integer)
RETURNS character varying AS
$body$
DECLARE
emp_maior_sal character varying;
BEGIN

SELECT cpf INTO emp_maior_sal 
FROM eempresa.empregado
WHERE salario = (SELECT max(salario) FROM eempresa.empregado WHERE cdep = depid GROUP BY cdep );

RETURN emp_maior_sal;

END;
$body$
language 'plpgsql';





-- 2.5 Crie um procedimento que recebe como parâmetro de entrada o código de um projeto e
-- retorna o total de horas deste projeto.

CREATE OR REPLACE FUNCTION eempresa.total_horas(pid character varying)
RETURNS numeric AS
$body$
DECLARE
total_h numeric;
BEGIN

SELECT sum(horas) INTO total_h FROM eempresa.tarefa WHERE pcodigo = pid GROUP BY pcodigo; 
RETURN total_h;

END;
$body$
language 'plpgsql';




-- 2.6 Crie um procedimento que recebe como parâmetro de entrada a taxa de aumento de
-- salário e atualiza o salário de todos os empregados com esta taxa.


CREATE OR REPLACE FUNCTION aumento(taxa_aum numeric)
RETURNS void AS
$body$
BEGIN
UPDATE eempresa.empregado SET salario = salario + salario * taxa_aum;
END;
$body$
language 'plpgsql';


-- 2.7 Crie uma trigger para impedir que seja excluído um empregado que ainda esteja alocado
-- em alguma tarefa.

CREATE OR REPLACE FUNCTION verificar_alocado_em_tarefa()
RETURNS trigger AS
$body$
DECLARE
c refcursor;
linhaTarefa eempresa.tarefa%ROWTYPE;
BEGIN
	OPEN c FOR SELECT * FROM eempresa.tarefa;
	LOOP
		FETCH c INTO linhaTarefa;
		EXIT WHEN NOT FOUND;
		IF linhaTarefa.cpf = OLD.cpf THEN
			CLOSE c;
			RETURN NULL;
		END IF;
	END LOOP;
	CLOSE c;
	RETURN NEW;
END;
$body$
language 'plpgsql';

CREATE TRIGGER nao_excluir_empregado_com_tarefa
BEFORE DELETE ON eempresa.empregado
FOR EACH ROW
EXECUTE PROCEDURE verificar_alocado_em_tarefa();



-- 2.8 Crie uma trigger para sempre que seja excluído um projeto sejam automaticamente
-- excluídas todas as suas tarefas.

CREATE OR REPLACE FUNCTION excluir_tarefas_do_projeto()
RETURNS trigger AS
$body$
DECLARE
c refcursor;
linhaTarefa eempresa.tarefa%ROWTYPE;

BEGIN

OPEN c FOR SELECT * FROM eempresa.tarefa;

LOOP
FETCH c INTO linhaTarefa;
EXIT WHEN NOT FOUND;
IF linhaTarefa.pcodigo = OLD.pcodigo THEN
	DELETE
	FROM eempresa.tarefa
	WHERE cpf = linhaTarefa.cpf AND pcodigo = linhaTarefa.pcodigo;
END IF;
END LOOP;
RETURN NEW;
END;
$body$
language 'plpgsql';

CREATE TRIGGER excluir_tarefas_ao_excluir_projeto
BEFORE DELETE ON eempresa.projeto
FOR EACH ROW
EXECUTE PROCEDURE excluir_tarefas_do_projeto();

-- 2.9 Crie uma trigger para que sempre que seja cadastrado um novo empregado, seja alocado
-- para ele uma tarefa de 20 horas no projeto com menor número de horas.

CREATE OR REPLACE FUNCTION atarefar_empregado()
RETURNS trigger AS
$body$
DECLARE
projeto_menos_h character varying;
BEGIN

SELECT pcodigo INTO projeto_menos_h
FROM(SELECT pcodigo, SUM(horas) AS somahoras FROM eempresa.tarefa GROUP BY pcodigo) as tab
WHERE tab.somahoras <= ALL (SELECT SUM(horas) FROM eempresa.tarefa GROUP BY pcodigo);

INSERT INTO eempresa.tarefa VALUES (NEW.cpf, projeto_menos_h, 20);
RETURN NEW;

END;
$body$
language 'plpgsql';

CREATE TRIGGER atarefar_novo_emp
BEFORE INSERT ON eempresa.empregado
FOR EACH ROW
EXECUTE PROCEDURE atarefar_empregado();


-- 3. Implemente as regras de negócio mostradas a seguir utilizando triggers

-- a) Todo e qualquer departamento deve possuir uma unidade na cidade de “Fortaleza”.

CREATE OR REPLACE FUNCTION verificar_unid_fortaleza()
RETURNS trigger AS
$body$
DECLARE
d refcursor;
cdepar integer;
u refcursor;
linhaDunidade eempresa.dunidade%ROWTYPE;
has boolean;

BEGIN

OPEN d FOR SELECT codigo FROM eempresa.departamento;
OPEN u FOR SELECT * FROM eempresa.dunidade;

LOOP
	has := false;
	FETCH d INTO cdepar;
	EXIT WHEN NOT FOUND;
	LOOP
		FETCH u INTO linhaDunidade;
		EXIT WHEN NOT FOUND;
		IF linhaDunidade.dcodigo = cdepar and linhaDunidade.dcidade = 'Fortaleza' THEN			
			has := true;
		END IF;
	END LOOP;
	IF has = false THEN
		INSERT INTO eempresa.dunidade VALUES (cdepar, 'Fortaleza');
	END IF;
END LOOP;
close u;
close d;
RETURN NEW;

END;
$body$
language 'plpgsql';

CREATE TRIGGER depar_tem_unid_fortal
BEFORE INSERT ON eempresa.dunidade
FOR EACH ROW
EXECUTE PROCEDURE verificar_unid_fortaleza();


-- b) Um empregado não pode ter salário maior que o do seu gerente.

CREATE OR REPLACE FUNCTION verificar_salario_chefe()
RETURNS trigger AS
$body$
DECLARE
salarioChefe numeric;
BEGIN
	SELECT salario INTO salarioChefe FROM eempresa.empregado WHERE cpf = NEW.chefe;

	IF NEW.salario > salarioChefe THEN
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END;
$body$
language 'plpgsql';

CREATE TRIGGER salario_emp_menor_que_chefe
BEFORE INSERT OR UPDATE ON eempresa.empregado
FOR EACH ROW
EXECUTE PROCEDURE verificar_salario_chefe();

-- c) Cada empregado não pode trabalhar mais do que 40 horas.

CREATE OR REPLACE FUNCTION verificar_horas_por_emp()
RETURNS trigger AS
$body$
DECLARE
totalhoras numeric;

BEGIN
SELECT sum(horas) INTO totalhoras FROM eempresa.tarefa WHERE cpf = NEW.cpf;
totalhoras := totalhoras + NEW.horas;
IF totalhoras > 40 THEN
	RETURN NULL;
ELSE 
	RETURN NEW;
END IF;
END;
$body$
language 'plpgsql';

CREATE TRIGGER max_40_h_por_emp
BEFORE INSERT OR UPDATE ON eempresa.tarefa
FOR EACH ROW
EXECUTE PROCEDURE verificar_horas_por_emp();


