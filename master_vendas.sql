/*CREATE DATABASE master_vendas;

CREATE TABLE cliente (
    pk_cliente SERIAL PRIMARY KEY,
    cliente_nome VARCHAR(60) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE
);

CREATE TABLE cliente_endereco (
    pk_cliente_endereco SERIAL PRIMARY KEY,
    fk_cliente INTEGER NOT NULL,
    logradouro VARCHAR(80) NOT NULL,
    bairro VARCHAR(40) NOT NULL,
    cidade VARCHAR(40) NOT NULL,
    estado CHAR(2) DEFAULT 'GO' NOT NULL,
    pais VARCHAR(30) DEFAULT 'Brasil' NOT NULL,
    cep CHAR(8),
    FOREIGN KEY (fk_cliente) REFERENCES cliente (pk_cliente) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE (fk_cliente, logradouro, bairro, cidade, estado, pais, cep)
);

CREATE TABLE cargo (
    pk_cargo SERIAL PRIMARY KEY,
    cargo_nome VARCHAR(30) NOT NULL UNIQUE,
    descricao VARCHAR(60)
);

CREATE TABLE funcionario (
    pk_funcionario SERIAL PRIMARY KEY,
    fk_cargo INTEGER NOT NULL,
    funcionario_nome VARCHAR(60) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    FOREIGN KEY (fk_cargo) REFERENCES cargo (pk_cargo) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE funcionario_endereco (
    pk_funcionario_endereco SERIAL PRIMARY KEY,
    fk_funcionario INTEGER NOT NULL,
    logradouro VARCHAR(80) NOT NULL,
    bairro VARCHAR(40) NOT NULL,
    cidade VARCHAR(40) NOT NULL,
    estado CHAR(2) DEFAULT 'GO' NOT NULL,
    pais VARCHAR(30) DEFAULT 'Brasil' NOT NULL,
    cep CHAR(8),
    FOREIGN KEY (fk_funcionario) REFERENCES funcionario (pk_funcionario) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE (fk_funcionario, logradouro, bairro, cidade, estado, pais, cep)
);

CREATE TABLE produto (
    pk_produto SERIAL PRIMARY KEY,
    produto_nome VARCHAR(30),
    estoque_minimo INTEGER DEFAULT 100 CHECK (estoque_minimo >= 0),
    qtd_estoque INTEGER DEFAULT 0 CHECK (qtd_estoque >= 0)
);

CREATE SEQUENCE venda_numero_seq; --it assumes the default set of values

CREATE TABLE venda (
    pk_venda SERIAL PRIMARY KEY,
    fk_cliente INTEGER NOT NULL,
    fk_vendedor INTEGER NOT NULL,
    numero INTEGER DEFAULT nextval('venda_numero_seq') NOT NULL CHECK (numero > 0),
    data_venda DATE DEFAULT CURRENT_DATE NOT NULL CHECK (data_venda >= CURRENT_DATE),
    FOREIGN KEY (fk_cliente) REFERENCES cliente (pk_cliente) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (fk_vendedor) REFERENCES funcionario (pk_funcionario) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE venda_item (
    pk_venda_item SERIAL PRIMARY KEY,
    fk_venda INTEGER NOT NULL,
    fk_produto INTEGER NOT NULL,
    qtd INTEGER DEFAULT 1 NOT NULL CHECK (qtd > 0),
    valor_unitario NUMERIC (10, 2) NOT NULL CHECK (valor_unitario > 0.0), --precision of 9 digits and scale of 2.
    FOREIGN KEY (fk_venda) REFERENCES venda (pk_venda) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (fk_produto) REFERENCES produto (pk_produto) ON UPDATE CASCADE ON DELETE NO ACTION,
    UNIQUE (fk_venda, fk_produto) --it restricts that a product is not repeated in a sale (the field qtd solves the problem of multiplicity of the same item).
);

CREATE TABLE fornecedor (
    pk_fornecedor SERIAL PRIMARY KEY,
    fornecedor_nome VARCHAR(60) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE
);

CREATE TABLE fornecedor_endereco (
    pk_fornecedor_endereco SERIAL PRIMARY KEY,
    fk_fornecedor INTEGER NOT NULL,
    logradouro VARCHAR(80) NOT NULL,    
    bairro VARCHAR(40) NOT NULL,
    cidade VARCHAR(40) NOT NULL,
    estado CHAR(2) DEFAULT 'GO' NOT NULL,
    pais VARCHAR(30) DEFAULT 'Brasil' NOT NULL,
    cep CHAR(8),
    FOREIGN KEY (fk_fornecedor) REFERENCES fornecedor (pk_fornecedor) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE (fk_fornecedor, logradouro, bairro, cidade, estado, pais, cep)
);

CREATE SEQUENCE compra_numero_seq;

CREATE TABLE compra (
    pk_compra SERIAL PRIMARY KEY,
    fk_fornecedor INTEGER NOT NULL,
    numero INTEGER DEFAULT nextval('compra_numero_seq') NOT NULL CHECK (numero > 0), 
    data_compra DATE DEFAULT CURRENT_DATE NOT NULL CHECK (data_compra >= CURRENT_DATE), 
    FOREIGN KEY (fk_fornecedor) REFERENCES fornecedor (pk_fornecedor) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE compra_item (
    pk_compra_item SERIAL PRIMARY KEY,
    fk_compra INTEGER NOT NULL,
    fk_produto INTEGER NOT NULL,
    qtd INTEGER DEFAULT 1 NOT NULL CHECK (qtd > 0),
    valor_unitario NUMERIC (10, 2) NOT NULL CHECK (valor_unitario > 0.0),
    FOREIGN KEY (fk_compra) REFERENCES compra (pk_compra) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (fk_produto) REFERENCES produto (pk_produto) ON UPDATE CASCADE ON DELETE RESTRICT,
    UNIQUE (fk_compra, fk_produto)
);

CREATE TABLE financeiro_entrada (
    pk_financeiro_entrada SERIAL PRIMARY KEY,
    fk_venda INTEGER NOT NULL,
    data_emissao DATE DEFAULT CURRENT_DATE NOT NULL CHECK (data_emissao >= CURRENT_DATE),
    data_vencimento DATE NOT NULL CHECK (data_vencimento >= data_emissao),
    data_pagamento DATE CHECK (data_pagamento >= data_emissao),
    valor NUMERIC (10, 2) NOT NULL CHECK (valor > 0.0),
    forma_recebimento VARCHAR(30) NOT NULL,
    FOREIGN KEY (fk_venda) REFERENCES venda (pk_venda) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE financeiro_saida (
    pk_financeiro_saida SERIAL PRIMARY KEY,
    fk_compra INTEGER NOT NULL,
    data_emissao DATE DEFAULT CURRENT_DATE NOT NULL CHECK (data_emissao >= CURRENT_DATE),
    data_vencimento DATE NOT NULL CHECK (data_vencimento >= data_emissao),
    data_pagamento DATE CHECK (data_pagamento >= data_emissao),
    valor NUMERIC (10, 2) NOT NULL CHECK (valor > 0.0),
    forma_pagamento VARCHAR(30) NOT NULL,
    FOREIGN KEY (fk_compra) REFERENCES compra (pk_compra) ON UPDATE CASCADE ON DELETE NO ACTION
);

--List T.2.2
--(1)
INSERT INTO cliente (cliente_nome, cpf) VALUES ('João de Castro Neves', '11122233344'),
					       ('Maria Ferreira dos Reis', '22233344455'),
					       ('Marcos Pedrosa Silva', '33344455566'),
                                               ('Lucas Benites de Souza', '44455566677'),
                                               ('Maria Eduarda Vinhal', '55566677788');

INSERT INTO cliente_endereco (fk_cliente, logradouro, bairro, cidade, cep) VALUES (1, 'Rua das Palmeiras Qd. 4 Lt. 10 No 10', 'Setor Vila Izabel', 'Morrinhos', '11122233'),
									          (2, 'Av. T-4 No 145', 'Setor Centro', 'Goiânia', '22233344'),
										  (3, 'Av. Pedro Ribeiro', 'Setor Sudeste', 'Rio Verde', '33344455'),
										  (4, 'Rua Castello Branco', 'Setor Ferreto Machado', 'Anápolis', '44455566'),
										  (5, 'Rua Padre Marinho', 'Setor Parque Machado', 'Piracanjuba', '55566677');
						
INSERT INTO cargo (cargo_nome, descricao) VALUES ('Vendedor', 'Responsável pela comercialização dos produtos/serviços'),
			    			 ('Secretária', 'Responsável pela parte documental e de registros da empresa'),
			    			 ('Gerente', 'Responsável por coordenar e gerenciar um setor da empresa');

INSERT INTO funcionario (fk_cargo, funcionario_nome, cpf) VALUES (2, 'Vanessa Visconde de Melo', '99988877766'),
				   				 (2, 'Bruna dos Santos Carvalho', '88877766655'),
								 (3, 'Marcos Paulo Rocha Cordeiro', '77766655544'),
								 (1, 'Rafael da Silveira Alcântara', '66655544433'),
								 (1, 'Felipe André de Souza', '55544433322'),
								 (1, 'Paulo Marinho Figueiredo', '44433322211');

INSERT INTO fornecedor (fornecedor_nome, cpf) VALUES ('Luciano Ribamar dos Santos', '11133355566'),
						     ('Laura Pedrosa Farias', '33355577799'),
						     ('Sebastião Milhograno dos Reis', '55577799911');

INSERT INTO produto (produto_nome, estoque_minimo, qtd_estoque) VALUES ('Arroz 5KG', 500, 700),
								       ('Feijão 1KG', 1000, 1500),
								       ('Macarrão 1KG', 1000, 1500),
								       ('Óleo de Soja 1L', 1500, 2500),
								       ('Sal Iodado 1KG', 2000, 3000);

--Compras do fornecedor 1:
INSERT INTO compra (fk_fornecedor) VALUES (1);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES (1, 1, 100, 10.5),
				    				     (1, 2, 50, 5.89),
				    				     (1, 3, 30, 7.00);

INSERT INTO compra (fk_fornecedor) VALUES (1);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES (2, 1, 50, 10.3),
							             (2, 4, 300, 6.79),
							 	     (2, 5, 100, 3.5);

--Compras do fornecedor 2:

INSERT INTO compra (fk_fornecedor) VALUES (2);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES (3, 5, 10, 3.3),
				    				     (3, 1, 5, 9.89),
				    				     (3, 2, 50, 7.34);

INSERT INTO compra (fk_fornecedor) VALUES (2);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES (4, 4, 15, 6.79),
							             (4, 1, 50, 9.99),
							 	     (4, 3, 80, 5.5);
	
--Compras do fornecedor 3:
INSERT INTO compra (fk_fornecedor) VALUES (3);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES (5, 1, 3, 10),
				    				     (5, 5, 15, 3.2),
				    				     (5, 3, 5, 6.5);

INSERT INTO compra (fk_fornecedor) VALUES (3);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES (6, 1, 6, 11),
							             (6, 2, 22, 8.99),
							 	     (6, 3, 12, 6.78);
--Vendas cliente 1:
INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (1, 4);

INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (1, 1, 30, 13.79),
				 					  (1, 2, 40, 8.67),
									  (1, 3, 20, 5.79);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (1, 6);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (2, 2, 40, 9),
									  (2, 5, 25, 4.69),
									  (2, 3, 50, 6.79);
--Vendas cliente 2:
INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (2, 5);


INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (3, 5, 13, 3.79),
				 					  (3, 4, 40, 8.67),
									  (3, 1, 20, 15);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (2, 4);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (4, 4, 30, 8.5),
									  (4, 1, 5, 14.69),
									  (4, 2, 3, 8.5);
--Vendas cliente 3:
INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (3, 6);


INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (5, 5, 10, 3.79),
				 					  (5, 4, 10, 8.67),
									  (5, 1, 10, 15);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (3, 5);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (6, 4, 30, 8.5),
									  (6, 1, 2, 14.69),
									  (6, 2, 21, 8.5);

--Vendas cliente 4:
INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (4, 4);


INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (7, 5, 6, 3.79),
				 					  (7, 4, 20, 8.67),
									  (7, 1, 2, 15);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (4, 5);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (8, 4, 8, 8.5),
									  (8, 1, 15, 14.69),
									  (8, 2, 40, 8.5);

--Vendas cliente 5:
INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (5, 5);

INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (9, 1, 15, 13.79),
				 					  (9, 2, 20, 8.67),
									  (9, 3, 40, 5.79);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (5, 6);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES (10, 2, 80, 9),
									  (10, 5, 2, 4.69),
									  (10, 3, 4, 6.79);*/

--Movimentações financeiras
--Compra 1:
/*INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES (1, '2022-06-10', '2022-06-01', 777.25, 'Pix'),
													 (1, '2022-07-10', '2022-07-01', 777.25,'Pix');
--Compra 2:
INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES (2, '2022-06-11', '2022-06-02', 1451.00, 'Pix'),
													 (2, '2022-07-11', '2022-07-02', 1451.00,'Pix');
--Compra 3:
INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES (3, '2022-06-12', '2022-06-03', 224.73, 'Pix'),
													 (3, '2022-07-12', '2022-07-03', 224.73,'Pix');
--Compra 4:
INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES (4, '2022-06-13', '2022-06-04', 520.68, 'Pix'),
													 (4, '2022-07-13', '2022-07-04', 520.68,'Pix');
--Compra 5:
INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES (5, '2022-06-14', '2022-06-05', 55.25, 'Pix'),
													 (5, '2022-07-14', '2022-07-05', 55.25,'Pix');
--Compra 6:
INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES (6, '2022-06-15', '2022-06-06', 172.57, 'Pix'),
													 (6, '2022-07-15', '2022-07-06', 172.57,'Pix');
--Venda 1:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (1, '2022-06-10', '2022-06-01', 438.15, 'Pix'),
													  (1, '2022-07-10', '2022-07-01', 438.15, 'Pix');
--Venda 2:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (2, '2022-06-11', '2022-06-02', 408.38, 'Pix'),
													  (2, '2022-07-11', '2022-07-02', 408.38, 'Pix');
--Venda 3:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (3, '2022-06-12', '2022-06-03', 348.04, 'Pix'),
													  (3, '2022-07-12', '2022-07-03', 348.04, 'Pix');
--Venda 4:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (4, '2022-06-13', '2022-06-04', 176.98, 'Pix'),
													  (4, '2022-07-13', '2022-07-04', 176.98, 'Pix');
--Venda 5:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (5, '2022-06-14', '2022-06-05', 137.3, 'Pix'),
													  (5, '2022-07-14', '2022-07-05', 137.3, 'Pix');
--Venda 6:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (6, '2022-06-15', '2022-06-06', 231.44, 'Pix'),
													  (6, '2022-07-15', '2022-07-06', 231.44, 'Pix');
--Venda 7:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (7, '2022-06-16', '2022-06-07', 113.07, 'Pix'),
													  (7, '2022-07-16', '2022-07-07', 113.07, 'Pix');
--Venda 8:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (8, '2022-06-17', '2022-06-08', 314.18, 'Pix'),
													  (8, '2022-07-17', '2022-07-08', 314.18, 'Pix');
--Venda 9:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (9, '2022-06-18', '2022-06-09', 305.93, 'Pix'),
													  (9, '2022-07-18', '2022-07-09', 305.93, 'Pix');
--Venda 10:
INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES (10, '2022-06-19', '2022-06-10', 378.27, 'Pix'),
													  (10, '2022-07-19', '2022-07-10', 378.27, 'Pix');

--(2)
--(a)
SELECT produto_nome AS nome, estoque_minimo AS "estoqueMinimo", qtd_estoque AS qtd FROM produto;

--(b)
SELECT cliente_nome AS "nomeCliente", data_vencimento, valor FROM 
       (SELECT fk_cliente, data_vencimento, valor FROM (SELECT data_vencimento, valor, fk_venda 
		FROM financeiro_entrada WHERE data_pagamento IS NULL) AS contas_a_receber INNER JOIN venda ON fk_venda = pk_venda) AS contas_a_receber_venda 
				INNER JOIN cliente ON fk_cliente = pk_cliente;
--(c)
SELECT fornecedor_nome AS "nomeFornecedor", data_vencimento, valor FROM 
	(SELECT fk_fornecedor, data_vencimento, valor FROM (SELECT data_vencimento, valor, fk_compra 
		FROM financeiro_saida WHERE data_pagamento IS NULL) AS contas_a_pagar INNER JOIN compra ON fk_compra = pk_compra) AS contas_a_pagar_compra 
			INNER JOIN fornecedor ON fk_fornecedor = pk_fornecedor;

--(d)
SELECT cliente_nome AS nome, data_vencimento, "forma_recebimento/pagamento", valor, 'E' AS origem 
FROM (SELECT fk_cliente, data_vencimento, "forma_recebimento/pagamento", valor 
FROM (SELECT fk_venda, data_vencimento, forma_recebimento AS "forma_recebimento/pagamento", valor 
FROM financeiro_entrada WHERE data_pagamento IS NOT NULL) AS movimento_entradas INNER JOIN venda ON fk_venda = pk_venda) AS 
movimento_entradas_venda INNER JOIN cliente ON fk_cliente = pk_cliente UNION SELECT fornecedor_nome 
AS nome, data_vencimento, "forma_recebimento/pagamento", valor, 'S' AS origem FROM (SELECT fk_fornecedor, 
data_vencimento, "forma_recebimento/pagamento", valor FROM (SELECT fk_compra, data_vencimento, forma_pagamento 
AS "forma_recebimento/pagamento", valor	FROM financeiro_saida WHERE data_pagamento IS NOT NULL) AS movimento_saidas 
INNER JOIN compra ON fk_compra = pk_compra) AS movimento_saidas_compra INNER JOIN fornecedor ON fk_fornecedor = pk_fornecedor
ORDER BY origem;
*/	

