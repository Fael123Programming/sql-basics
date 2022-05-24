CREATE DATABASE master_vendas;

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

INSERT INTO cliente (cliente_nome, cpf) VALUES 
('João de Castro Neves', '11122233344'),
('Maria Ferreira dos Reis', '22233344455'),
('Marcos Pedrosa Silva', '33344455566'),
('Lucas Benites de Souza', '44455566677'),
('Maria Eduarda Vinhal', '55566677788');

INSERT INTO cliente_endereco (fk_cliente, logradouro, bairro, cidade, cep) VALUES 
(1, 'Rua das Palmeiras Qd. 4 Lt. 10 No 10', 'Setor Vila Izabel', 'Morrinhos', '11122233'),
(2, 'Av. T-4 No 145', 'Setor Centro', 'Goiânia', '22233344'),
(3, 'Av. Pedro Ribeiro', 'Setor Sudeste', 'Rio Verde', '33344455'),
(4, 'Rua Castello Branco', 'Setor Ferreto Machado', 'Anápolis', '44455566'),
(5, 'Rua Padre Marinho', 'Setor Parque Machado', 'Piracanjuba', '55566677');
						
INSERT INTO cargo (cargo_nome, descricao) VALUES 
('Vendedor', 'Responsável pela comercialização dos produtos/serviços'),
('Secretária', 'Responsável pela parte documental e de registros da empresa'),
('Gerente', 'Responsável por coordenar e gerenciar um setor da empresa');

INSERT INTO funcionario (fk_cargo, funcionario_nome, cpf) VALUES 
(2, 'Vanessa Visconde de Melo', '99988877766'),
(2, 'Bruna dos Santos Carvalho', '88877766655'),
(3, 'Marcos Paulo Rocha Cordeiro', '77766655544'),
(1, 'Rafael da Silveira Alcântara', '66655544433'),
(1, 'Felipe André de Souza', '55544433322'),
(1, 'Paulo Marinho Figueiredo', '44433322211');

INSERT INTO fornecedor (fornecedor_nome, cpf) VALUES 
('Luciano Ribamar dos Santos', '11133355566'),
('Laura Pedrosa Farias', '33355577799'),
('Sebastião Milhograno dos Reis', '55577799911');

INSERT INTO produto (produto_nome, estoque_minimo, qtd_estoque) VALUES 
('Arroz 5KG', 500, 700),
('Feijão 1KG', 1000, 1500),
('Macarrão 1KG', 1000, 1500),
('Óleo de Soja 1L', 1500, 2500),
('Sal Iodado 1KG', 2000, 3000);

--Compras do fornecedor 1:

INSERT INTO compra (fk_fornecedor) VALUES (1);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES 
(1, 1, 100, 10.5),
(1, 2, 50, 5.89),
(1, 3, 30, 7.00);

INSERT INTO compra (fk_fornecedor) VALUES (1);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES 
(2, 1, 50, 10.3),
(2, 4, 300, 6.79),
(2, 5, 100, 3.5);

--Compras do fornecedor 2:

INSERT INTO compra (fk_fornecedor) VALUES (2);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES (3, 5, 10, 3.3),
(3, 1, 5, 9.89),
(3, 2, 50, 7.34);

INSERT INTO compra (fk_fornecedor) VALUES (2);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES 
(4, 4, 15, 6.79),
(4, 1, 50, 9.99),
(4, 3, 80, 5.5);

--Compras do fornecedor 3:

INSERT INTO compra (fk_fornecedor) VALUES (3);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES 
(5, 1, 3, 10),
(5, 5, 15, 3.2),
(5, 3, 5, 6.5);

INSERT INTO compra (fk_fornecedor) VALUES (3);

INSERT INTO compra_item (fk_compra, fk_produto, qtd, valor_unitario) VALUES 
(6, 1, 6, 11),
(6, 2, 22, 8.99),
(6, 3, 12, 6.78);

--Vendas cliente 1:

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (1, 4);

INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(1, 1, 30, 13.79),
(1, 2, 40, 8.67),
(1, 3, 20, 5.79);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (1, 6);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(2, 2, 40, 9),
(2, 5, 25, 4.69),
(2, 3, 50, 6.79);

--Vendas cliente 2:

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (2, 5);


INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(3, 5, 13, 3.79),
(3, 4, 40, 8.67),
(3, 1, 20, 15);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (2, 4);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(4, 4, 30, 8.5),
(4, 1, 5, 14.69),
(4, 2, 3, 8.5);

--Vendas cliente 3:

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (3, 6);


INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(5, 5, 10, 3.79),
(5, 4, 10, 8.67),
(5, 1, 10, 15);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (3, 5);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(6, 4, 30, 8.5),
(6, 1, 2, 14.69),
(6, 2, 21, 8.5);

--Vendas cliente 4:

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (4, 4);


INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(7, 5, 6, 3.79),
(7, 4, 20, 8.67),
(7, 1, 2, 15);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (4, 5);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(8, 4, 8, 8.5),
(8, 1, 15, 14.69),
(8, 2, 40, 8.5);

--Vendas cliente 5:

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (5, 5);

INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(9, 1, 15, 13.79),
(9, 2, 20, 8.67),
(9, 3, 40, 5.79);

INSERT INTO venda (fk_cliente, fk_vendedor) VALUES (5, 6);
				
INSERT INTO venda_item (fk_venda, fk_produto, qtd, valor_unitario) VALUES 
(10, 2, 80, 9),
(10, 5, 2, 4.69),
(10, 3, 4, 6.79);

--Movimentações financeiras
--Compra 1:

INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES 
(1, '2022-06-10', '2022-06-01', 777.25, 'Pix'),
(1, '2022-07-10', '2022-07-01', 777.25,'Pix');

--Compra 2:

INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES 
(2, '2022-06-11', '2022-06-02', 1451.00, 'Pix'),
(2, '2022-07-11', '2022-07-02', 1451.00,'Pix');

--Compra 3:

INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES 
(3, '2022-06-12', '2022-06-03', 224.73, 'Pix'),
(3, '2022-07-12', '2022-07-03', 224.73,'Pix');

--Compra 4:

INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES 
(4, '2022-06-13', '2022-06-04', 520.68, 'Pix'),
(4, '2022-07-13', '2022-07-04', 520.68,'Pix');

--Compra 5:

INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES 
(5, '2022-06-14', '2022-06-05', 55.25, 'Pix'),
(5, '2022-07-14', '2022-07-05', 55.25,'Pix');

--Compra 6:

INSERT INTO financeiro_saida (fk_compra, data_vencimento, data_pagamento, valor, forma_pagamento) VALUES 
(6, '2022-06-15', '2022-06-06', 172.57, 'Pix'),
(6, '2022-07-15', '2022-07-06', 172.57,'Pix');

--Venda 1:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(1, '2022-06-10', '2022-06-01', 438.15, 'Pix'),
(1, '2022-07-10', '2022-07-01', 438.15, 'Pix');

--Venda 2:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(2, '2022-06-11', '2022-06-02', 408.38, 'Pix'),
(2, '2022-07-11', '2022-07-02', 408.38, 'Pix');

--Venda 3:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(3, '2022-06-12', '2022-06-03', 348.04, 'Pix'),
(3, '2022-07-12', '2022-07-03', 348.04, 'Pix');

--Venda 4:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(4, '2022-06-13', '2022-06-04', 176.98, 'Pix'),
(4, '2022-07-13', '2022-07-04', 176.98, 'Pix');

--Venda 5:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(5, '2022-06-14', '2022-06-05', 137.3, 'Pix'),
(5, '2022-07-14', '2022-07-05', 137.3, 'Pix');

--Venda 6:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(6, '2022-06-15', '2022-06-06', 231.44, 'Pix'),
(6, '2022-07-15', '2022-07-06', 231.44, 'Pix');

--Venda 7:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(7, '2022-06-16', '2022-06-07', 113.07, 'Pix'),
(7, '2022-07-16', '2022-07-07', 113.07, 'Pix');

--Venda 8:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(8, '2022-06-17', '2022-06-08', 314.18, 'Pix'),
(8, '2022-07-17', '2022-07-08', 314.18, 'Pix');

--Venda 9:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(9, '2022-06-18', '2022-06-09', 305.93, 'Pix'),
(9, '2022-07-18', '2022-07-09', 305.93, 'Pix');

--Venda 10:

INSERT INTO financeiro_entrada (fk_venda, data_vencimento, data_pagamento, valor, forma_recebimento) VALUES 
(10, '2022-06-19', '2022-06-10', 378.27, 'Pix'),
(10, '2022-07-19', '2022-07-10', 378.27, 'Pix');

--(2)
--(a)

SELECT produto_nome AS nome, estoque_minimo AS "estoqueMinimo", qtd_estoque AS qtd FROM produto;

--(b)

SELECT cliente_nome AS "nomeCliente", data_vencimento, valor FROM (
    SELECT fk_cliente, data_vencimento, valor FROM (
        SELECT data_vencimento, valor, fk_venda FROM financeiro_entrada WHERE data_pagamento IS NULL
    ) AS contas_a_receber INNER JOIN venda ON fk_venda = pk_venda
) AS contas_a_receber_venda INNER JOIN cliente ON fk_cliente = pk_cliente;

--(c)

SELECT fornecedor_nome AS "nomeFornecedor", data_vencimento, valor FROM (
    SELECT fk_fornecedor, data_vencimento, valor FROM (
        SELECT data_vencimento, valor, fk_compra FROM financeiro_saida WHERE data_pagamento IS NULL
    ) AS contas_a_pagar INNER JOIN compra ON fk_compra = pk_compra
) AS contas_a_pagar_compra INNER JOIN fornecedor ON fk_fornecedor = pk_fornecedor;

--(d)

SELECT cliente_nome AS nome, data_vencimento, "forma_recebimento/pagamento", valor, 'E' AS origem FROM (
    SELECT fk_cliente, data_vencimento, "forma_recebimento/pagamento", valor FROM (
        SELECT fk_venda, data_vencimento, forma_recebimento AS "forma_recebimento/pagamento", valor FROM financeiro_entrada WHERE data_pagamento IS NOT NULL
    ) AS movimento_entradas INNER JOIN venda ON fk_venda = pk_venda
) AS movimento_entradas_venda INNER JOIN cliente ON fk_cliente = pk_cliente UNION 
SELECT fornecedor_nome AS nome, data_vencimento, "forma_recebimento/pagamento", valor, 'S' AS origem FROM (
    SELECT fk_fornecedor, data_vencimento, "forma_recebimento/pagamento", valor FROM (
        SELECT fk_compra, data_vencimento, forma_pagamento AS "forma_recebimento/pagamento", valor FROM financeiro_saida WHERE data_pagamento IS NOT NULL
    ) AS movimento_saidas INNER JOIN compra ON fk_compra = pk_compra
) AS movimento_saidas_compra INNER JOIN fornecedor ON fk_fornecedor = pk_fornecedor ORDER BY origem;

--(e)

SELECT dp_ano_fe AS ano, dp_mes_fe AS mes, entrada_total - saida_total AS saldo FROM (  
    (
        SELECT DATE_PART('year', data_pagamento) AS dp_ano_fe, DATE_PART('month', data_pagamento) AS dp_mes_fe, SUM(valor) AS entrada_total FROM financeiro_entrada WHERE data_pagamento IS NOT NULL GROUP BY dp_ano_fe, dp_mes_fe ORDER BY dp_ano_fe, dp_mes_fe
    ) fe INNER JOIN (
        SELECT DATE_PART('year', data_pagamento) AS dp_ano_fs, DATE_PART('month', data_pagamento) AS dp_mes_fs, SUM(valor) AS saida_total FROM financeiro_saida WHERE data_pagamento IS NOT NULL GROUP BY dp_ano_fs, dp_mes_fs ORDER BY dp_ano_fs, dp_mes_fs
    ) fs ON dp_ano_fe = dp_ano_fs AND dp_mes_fe = dp_mes_fs
) fe_fs_join;      

--(f)

SELECT cliente_nome AS nome, "valorTotal" FROM (
    SELECT fk_cliente, SUM(valor_total) AS "valorTotal" FROM (
        SELECT fk_venda, SUM(qtd * valor_unitario) AS valor_total FROM venda_item GROUP BY fk_venda
    ) venda_valor INNER JOIN venda ON pk_venda = fk_venda GROUP BY fk_cliente
) AS cliente_valor_total INNER JOIN cliente ON fk_cliente = pk_cliente ORDER BY "valorTotal" DESC;

--(g)

SELECT funcionario_nome AS nome, "valorTotal", "valorTotal" * 0.05 AS comissao FROM (
    SELECT fk_vendedor, SUM("valorTotal") AS "valorTotal" FROM (
        SELECT fk_venda, SUM(qtd * valor_unitario) AS "valorTotal" FROM venda_item GROUP BY fk_venda
    ) venda_valor_total INNER JOIN venda ON fk_venda = pk_venda GROUP BY fk_vendedor
) fk_vend_valor_total INNER JOIN (
    SELECT pk_funcionario, funcionario_nome FROM funcionario WHERE fk_cargo = 1
) func_vendedor ON fk_vendedor = pk_funcionario;

--(h)

SELECT cidade AS nome, SUM("valorTotal") AS "valorTotal" FROM (
    SELECT fk_cliente, SUM("valorTotal") AS "valorTotal" FROM (
        SELECT fk_venda, SUM(qtd * valor_unitario) AS "valorTotal" FROM venda_item GROUP BY fk_venda
    ) AS venda_valor_total INNER JOIN venda ON fk_venda = pk_venda GROUP BY fk_cliente
) AS cliente_valor_vendas INNER JOIN (
    SELECT fk_cliente, cidade FROM cliente_endereco
) cliente_cidade ON cliente_valor_vendas.fk_cliente = cliente_cidade.fk_cliente GROUP BY cidade;

--(i)

SELECT estado AS nome, SUM("valorTotal") AS "valorTotal" FROM (
    SELECT fk_cliente, SUM("valorTotal") AS "valorTotal" FROM (
        SELECT fk_venda, SUM(qtd * valor_unitario) AS "valorTotal" FROM venda_item GROUP BY fk_venda
    ) AS venda_valor_total INNER JOIN venda ON fk_venda = pk_venda GROUP BY fk_cliente
) AS cliente_valor_vendas INNER JOIN (
    SELECT fk_cliente, estado FROM cliente_endereco
) cliente_estado ON cliente_valor_vendas.fk_cliente = cliente_estado.fk_cliente GROUP BY estado;

--(j)

SELECT produto_nome AS nome, "qtd", "valorTotal" FROM (
    SELECT fk_produto, SUM(qtd) AS "qtd", SUM(qtd * valor_unitario) AS "valorTotal" FROM venda_item GROUP BY fk_produto
) produto_qtd_valor_vendas INNER JOIN (
    SELECT pk_produto, produto_nome FROM produto
) produto_nome ON fk_produto = pk_produto ORDER BY "valorTotal" DESC; 

--(k) vendedores: nomeProduto, nomeVendedor, ano, qtd

SELECT "nomeProduto", funcionario_nome AS "nomeVendedor", ano, qtd FROM (
    SELECT produto_nome AS "nomeProduto", fk_vendedor, ano, qtd FROM (
        SELECT fk_produto, fk_vendedor, DATE_PART('year', data_venda) AS ano, SUM(qtd) AS qtd FROM (
            SELECT fk_venda, fk_produto, qtd AS qtd FROM venda_item GROUP BY fk_venda, fk_produto, qtd
        ) venda_produto_qtd INNER JOIN venda ON fk_venda = pk_venda GROUP BY  fk_produto, fk_vendedor, ano
    ) produto_vendedor_ano_qtd INNER JOIN (
        SELECT pk_produto, produto_nome FROM produto
    ) produto_nome ON fk_produto = pk_produto
) produto_nome_vendedor_ano_qtd INNER JOIN (
    SELECT pk_funcionario, funcionario_nome FROM funcionario WHERE fk_cargo = 1
) vendedores ON pk_funcionario = fk_vendedor ORDER BY ano ASC, qtd DESC;

--(l)

SELECT produto_nome AS nome, qtd, "valorTotal" FROM (
    SELECT fk_produto, SUM(qtd) AS qtd, SUM(qtd * valor_unitario) AS "valorTotal" FROM compra_item GROUP BY fk_produto
) produto_qtd_valor_total INNER JOIN (
    SELECT pk_produto, produto_nome FROM produto
) produto_nome ON fk_produto = pk_produto ORDER BY "valorTotal" DESC;

--(m)

SELECT produto_nome AS nome, "valorTotalComprado", "valorTotalVendido", "LucroBruto" FROM (
    SELECT produto_valor_total_comprado.fk_produto, "valorTotalComprado", "valorTotalVendido", "valorTotalVendido" - "valorTotalComprado" AS "LucroBruto" FROM (
        SELECT fk_produto, SUM(qtd * valor_unitario) AS "valorTotalComprado" FROM compra_item GROUP BY fk_produto
    ) produto_valor_total_comprado INNER JOIN (
        SELECT fk_produto, SUM(qtd * valor_unitario) AS "valorTotalVendido" FROM venda_item GROUP BY fk_produto
    ) produto_valor_total_vendido ON produto_valor_total_comprado.fk_produto = produto_valor_total_vendido.fk_produto ORDER BY "LucroBruto" DESC
) produto_valor_total_comprado_vendido_lucro INNER JOIN (
    SELECT pk_produto, produto_nome FROM produto
) produto_nome ON fk_produto = pk_produto;

--(n)

SELECT cliente_nome AS nome, ROUND(valor_medio_efetivado, 2) AS "valorMédioEfetivado", ROUND(valor_medio_previsto, 2) AS "valorMédioPrevisto", ROUND(valor_medio_total, 2) AS "valorMédioTotal" FROM (
    SELECT fk_cliente, AVG(valor_total_efetivado) AS valor_medio_efetivado, AVG(valor_total_previsto) AS valor_medio_previsto, AVG(valor_total_efetivado) + AVG(valor_total_previsto) AS valor_medio_total FROM (
        SELECT venda_valor_total_efetivado.fk_venda, valor_total_efetivado, valor_total_previsto FROM (
            SELECT fk_venda, SUM(valor) AS valor_total_efetivado FROM financeiro_entrada WHERE data_pagamento IS NOT NULL GROUP BY fk_venda
        ) venda_valor_total_efetivado INNER JOIN (
        SELECT fk_venda, SUM(qtd * valor_unitario) AS valor_total_previsto FROM venda_item GROUP BY fk_venda
    ) venda_valor_total_previsto ON venda_valor_total_efetivado.fk_venda = venda_valor_total_previsto.fk_venda
    ) venda_valor_total_efetivado_previsto INNER JOIN (
        SELECT pk_venda, fk_cliente FROM venda
    ) venda_cliente ON fk_venda = pk_venda GROUP BY fk_cliente
) cliente_valor_medio_efetivado_previsto_total INNER JOIN (
    SELECT pk_cliente, cliente_nome FROM cliente
) cliente_nome ON fk_cliente = pk_cliente ORDER BY "valorMédioTotal" DESC;

--(o)

SELECT funcionario_nome AS nome, ROUND(valor_medio_efetivado, 2) AS "valorMédioEfetivado", ROUND(valor_medio_previsto, 2) AS "valorMédioPrevisto", ROUND(valor_medio_total, 2) AS "valorMédioTotal" FROM (
    SELECT fk_vendedor, AVG(valor_total_efetivado) AS valor_medio_efetivado, AVG(valor_total_previsto) AS valor_medio_previsto, AVG(valor_total_efetivado) + AVG(valor_total_previsto) AS valor_medio_total FROM (
        SELECT venda_valor_total_efetivado.fk_venda, valor_total_efetivado, valor_total_previsto FROM (
            SELECT fk_venda, SUM(valor) AS valor_total_efetivado FROM financeiro_entrada WHERE data_pagamento IS NOT NULL GROUP BY fk_venda
        ) venda_valor_total_efetivado INNER JOIN (
            SELECT fk_venda, SUM(qtd * valor_unitario) AS valor_total_previsto FROM venda_item GROUP BY fk_venda
        ) venda_valor_total_previsto ON venda_valor_total_efetivado.fk_venda = venda_valor_total_previsto.fk_venda
    ) venda_valor_total_efetivado_previsto INNER JOIN (
        SELECT pk_venda, fk_vendedor FROM venda
    ) venda_vendedor ON fk_venda = pk_venda GROUP BY fk_vendedor
) vendedor_valor_medio_efetivado_previsto_total INNER JOIN (
    SELECT pk_funcionario, funcionario_nome FROM funcionario WHERE fk_cargo = 1
) funcionario_nome ON fk_vendedor = pk_funcionario ORDER BY "valorMédioTotal" DESC;

--(p)

SELECT produto_nome AS "nomeProduto", estoque_minimo AS "estoqueMinimo", qtd_estoque AS qtd FROM produto WHERE qtd_estoque < estoque_minimo;

--(3)
--(a)

--Quantas vendas não possuem cadastros de recebimentos:

SELECT COUNT(*) AS vendas_sem_recebimentos FROM (
    SELECT pk_venda FROM venda EXCEPT SELECT fk_venda FROM financeiro_entrada
) pk_vendas_sem_recebimentos;

--Nome do cliente, do vendedor e a data em que elas foram efetuadas:

SELECT cliente_nome, nome_do_vendedor, data_venda FROM (
    SELECT fk_cliente, funcionario_nome AS nome_do_vendedor, data_venda FROM (
        SELECT fk_cliente, fk_vendedor, data_venda FROM (
            SELECT pk_venda FROM venda EXCEPT SELECT fk_venda FROM financeiro_entrada
        ) vendas_sem_recebimentos INNER JOIN venda ON vendas_sem_recebimentos.pk_venda = venda.pk_venda
    ) cliente_vendedor_data INNER JOIN (
        SELECT pk_funcionario, funcionario_nome FROM funcionario WHERE fk_cargo = 1
    ) funcionario_nome ON fk_vendedor = pk_funcionario
) cliente_funcionario_data INNER JOIN (
    SELECT pk_cliente, cliente_nome FROM cliente
) cliente_nome ON fk_cliente = pk_cliente;

--(b)

--Quantas vendas cuja soma dos recebimentos relacionados é menor do que os seus respectivos valores totais

SELECT COUNT(*) AS vendas_com_recebimentos_pendentes FROM (
    SELECT venda_valor_total.fk_venda, valor_total, COALESCE(valor_pago, 0) AS valor_pago FROM (
        SELECT fk_venda, SUM(qtd * valor_unitario) AS valor_total FROM venda_item GROUP BY fk_venda
    ) venda_valor_total LEFT OUTER JOIN (
        SELECT fk_venda, SUM(valor) AS valor_pago FROM financeiro_entrada GROUP BY fk_venda
    ) venda_valor_pago ON venda_valor_total.fk_venda = venda_valor_pago.fk_venda
) venda_valor_total_pago WHERE valor_pago < valor_total;

--Nome do cliente, do vendedor e a data em que elas foram efetuadas

SELECT cliente_nome AS nome_cliente, nome_vendedor, data_venda FROM (
    (
        SELECT fk_cliente, funcionario_nome AS nome_vendedor, data_venda FROM (
            SELECT fk_cliente, fk_vendedor, data_venda FROM (
                SELECT fk_venda FROM (
                    SELECT venda_valor_total.fk_venda, valor_total, COALESCE(valor_pago, 0) AS valor_pago FROM (
                        SELECT fk_venda, SUM(qtd * valor_unitario) AS valor_total FROM venda_item GROUP BY fk_venda
                    ) venda_valor_total LEFT OUTER JOIN (
                        SELECT fk_venda, SUM(valor) AS valor_pago FROM financeiro_entrada GROUP BY fk_venda
                    ) venda_valor_pago ON venda_valor_total.fk_venda = venda_valor_pago.fk_venda
                ) venda_valor_total_pago WHERE valor_pago < valor_total
            ) venda_com_recebimentos_pendentes INNER JOIN venda ON venda_com_recebimentos_pendentes.fk_venda = pk_venda
        ) cliente_vendedor_data INNER JOIN (
            SELECT pk_funcionario, funcionario_nome FROM funcionario WHERE fk_cargo = 1
        ) vendedor_nome ON fk_vendedor = pk_funcionario
    ) cliente_nome_vendedor_data_venda INNER JOIN (
        SELECT pk_cliente, cliente_nome FROM cliente
    ) cliente_nome ON fk_cliente = pk_cliente
) cliente_nome_nome_vendedor_data_venda;

--(c)   

--Quantas compras com pagamento maior que o valor total:    

SELECT COUNT(*) AS compras_com_pagamento_maior_que_valor_total FROM (
    SELECT compra_valor_pago.fk_compra FROM (
        (
            SELECT fk_compra, SUM(valor) AS valor_pago FROM financeiro_saida WHERE data_pagamento IS NOT NULL GROUP BY fk_compra
        ) compra_valor_pago INNER JOIN 
        (
            SELECT fk_compra, SUM(qtd * valor_unitario) AS valor_total FROM compra_item GROUP BY fk_compra
        ) compra_valor_total ON compra_valor_pago.fk_compra = compra_valor_total.fk_compra
    ) WHERE valor_pago > valor_total
) compra_pagamento_maior_valor_total;

--Nome do fornecedor e a data

SELECT fornecedor_nome AS nome_fornecedor, data_compra FROM (
    SELECT DISTINCT fk_fornecedor, data_compra FROM (
        SELECT compra_valor_pago.fk_compra FROM (
            (
                SELECT fk_compra, SUM(valor) AS valor_pago FROM financeiro_saida WHERE data_pagamento IS NOT NULL GROUP BY fk_compra
            ) compra_valor_pago INNER JOIN 
            (
                SELECT fk_compra, SUM(qtd * valor_unitario) AS valor_total FROM compra_item GROUP BY fk_compra
            ) compra_valor_total ON compra_valor_pago.fk_compra = compra_valor_total.fk_compra
        )
        WHERE valor_pago > valor_total
    ) compra_pagamento_maior_valor_total INNER JOIN 
    (    
        SELECT pk_compra, fk_fornecedor, data_compra FROM compra 
    ) compra_fornecedor_data ON fk_compra = pk_compra
) fornecedor_data INNER JOIN (
    SELECT pk_fornecedor, fornecedor_nome FROM fornecedor
) fornecedor_nome ON fk_fornecedor = pk_fornecedor;

--(d): Não existem pagamentos que não pertencem a nenhuma compra devido à restrição da chave estrangeira 'fk_compra' dever sempre apontar para uma tupla válida da relação 'compra'.

SELECT COUNT(*) AS pagamentos_nao_pertencentes_a_compras FROM (
    SELECT fk_compra FROM financeiro_saida EXCEPT SELECT pk_compra FROM compra
) pagamento_sem_compra;

--(e): Não devido à restrição de não-negatividade da coluna 'qtd_estoque'. De qualquer forma, a consulta SQL para saber a quantidade de produtos com estoque negativo seria:

SELECT COUNT(*) AS produtos_estoque_negativo FROM (
    SELECT pk_produto FROM produto WHERE qtd_estoque < 0
) produto_estoque_negativo;

--Nome e a quantidade de estoque de cada um:

SELECT produto_nome, qtd_estoque FROM (
    SELECT produto_nome, qtd_estoque FROM produto WHERE qtd_estoque < 0
) produto_estoque_negativo;

--(f)

SELECT COUNT(*) AS clientes_que_sao_funcionarios FROM (
    SELECT cpf FROM cliente INTERSECT SELECT cpf FROM funcionario
) cliente_intersec_funcionario;

--(g)

SELECT COUNT(*) AS clientes_que_moram_em_mesmo_endereco_que_funcionarios FROM (
    SELECT logradouro, bairro, cidade, estado, pais, cep FROM cliente_endereco INTERSECT SELECT logradouro, bairro, cidade, estado, pais, cep FROM funcionario_endereco
) cliente_endereco_intersec_funcionario_endereco;


--(h)

SELECT COUNT(*) AS clientes_que_moram_em_mesmo_endereco FROM (
    (
        SELECT * FROM cliente_endereco
    ) cliente_endereco1 INNER JOIN (    
        SELECT * FROM cliente_endereco
    ) cliente_endereco2 ON cliente_endereco1.fk_cliente != cliente_endereco2.fk_cliente AND cliente_endereco1.logradouro = cliente_endereco2.logradouro AND cliente_endereco1.bairro = cliente_endereco2.bairro AND cliente_endereco1.cidade = cliente_endereco2.cidade AND cliente_endereco1.estado = cliente_endereco2.estado AND cliente_endereco1.pais = cliente_endereco2.pais
) juncao_cliente_endereco;

--(i)

SELECT COUNT(*) AS funcionarios_que_moram_em_mesmo_endereco FROM (
    (
        SELECT * FROM funcionario_endereco
    ) funcionario_endereco1 INNER JOIN (
        SELECT * FROM funcionario_endereco
    ) funcionario_endereco2 ON funcionario_endereco1.fk_funcionario != funcionario_endereco2.fk_funcionario AND funcionario_endereco1.logradouro = funcionario_endereco2.logradouro AND funcionario_endereco1.bairro = funcionario_endereco2.bairro AND funcionario_endereco1.cidade = funcionario_endereco2.cidade AND funcionario_endereco1.estado = funcionario_endereco2.estado AND funcionario_endereco1.pais = funcionario_endereco2.pais
) juncao_cliente_endereco;

--(j): Produtos vendidos abaixo do preço médio de compra

SELECT COUNT(*) AS produtos_vendidos_abaixo_preco_medio_compra FROM (
    SELECT DISTINCT produto_valor_unitario.fk_produto FROM (
        SELECT DISTINCT fk_produto, valor_unitario AS valor_produto FROM venda_item
    ) produto_valor_unitario INNER JOIN (
        SELECT fk_produto, ROUND(AVG(valor_unitario), 2) AS valor_medio_compra FROM compra_item GROUP BY fk_produto
    ) produto_valor_medio_compra ON produto_valor_unitario.fk_produto = produto_valor_medio_compra.fk_produto
    WHERE valor_produto < valor_medio_compra
) produto_vendido_abaixo_preco__medio_compra;

--Nome, valor médio de compra e o valor da venda desses produtos

SELECT produto_nome, valor_medio_compra, valor_venda FROM (
    SELECT produto_valor_unitario.fk_produto, valor_medio_compra, valor_produto AS valor_venda FROM (
        SELECT DISTINCT fk_produto, valor_unitario AS valor_produto FROM venda_item
    ) produto_valor_unitario INNER JOIN (
        SELECT fk_produto, ROUND(AVG(valor_unitario), 2) AS valor_medio_compra FROM compra_item GROUP BY fk_produto
    ) produto_valor_medio_compra ON produto_valor_unitario.fk_produto = produto_valor_medio_compra.fk_produto
    WHERE valor_produto < valor_medio_compra
) produto_valor_medio_compra_venda INNER JOIN (
    SELECT pk_produto, produto_nome FROM produto
) produto_nome ON fk_produto = pk_produto;

--(k): Quantos recebimentos estão em atraso

SELECT COUNT(*) AS recebimentos_em_atraso FROM financeiro_entrada WHERE data_pagamento IS NULL AND CURRENT_DATE > data_vencimento;

--Nome do cliente, data de emissão e vencimento e valor

SELECT cliente_nome, data_emissao, data_vencimento, valor FROM (
    SELECT fk_cliente, data_emissao, data_vencimento, valor FROM (
        SELECT fk_venda, data_emissao, data_vencimento, valor FROM financeiro_entrada WHERE data_pagamento IS NULL AND CURRENT_DATE > data_vencimento
    ) venda_data_emissao_vencimento_valor INNER JOIN (
        SELECT pk_venda, fk_cliente FROM venda
    ) venda_cliente ON fk_venda = pk_venda
) cliente_data_emissao_vencimento_valor INNER JOIN (
    SELECT pk_cliente, cliente_nome FROM cliente
) cliente_nome ON fk_cliente = pk_cliente;

--(l): Quantos pagamentos adiantados existem

SELECT COUNT(*) AS pagamentos_adiantados FROM financeiro_saida WHERE data_pagamento < data_vencimento;

--Nome do fornecedor, data de emissão, vencimento e baixa (pagamento)

SELECT fornecedor_nome, data_emissao, data_vencimento, data_pagamento FROM (
    SELECT fk_fornecedor, data_emissao, data_vencimento, data_pagamento FROM (
        SELECT fk_compra, data_emissao, data_vencimento, data_pagamento FROM financeiro_saida WHERE data_pagamento < data_vencimento
    ) compra_data_emissao_vencimento_pagamento INNER JOIN (
        SELECT pk_compra, fk_fornecedor FROM compra
    ) compra_fornecedor ON fk_compra = pk_compra
) fornecedor_data_emissao_vencimento_pagamento INNER JOIN (
    SELECT pk_fornecedor, fornecedor_nome FROM fornecedor    
) fornecedor_nome ON fk_fornecedor = pk_fornecedor;  

--(4)

--View para a consulta 2 da letra (j)

CREATE VIEW produtos_vendidos_abaixo_preco_medio_compra AS
SELECT produto_nome, valor_medio_compra, valor_venda FROM (
    SELECT produto_valor_unitario.fk_produto, valor_medio_compra, valor_produto AS valor_venda FROM (
        SELECT DISTINCT fk_produto, valor_unitario AS valor_produto FROM venda_item
    ) produto_valor_unitario INNER JOIN (
        SELECT fk_produto, ROUND(AVG(valor_unitario), 2) AS valor_medio_compra FROM compra_item GROUP BY fk_produto
    ) produto_valor_medio_compra ON produto_valor_unitario.fk_produto = produto_valor_medio_compra.fk_produto
    WHERE valor_produto < valor_medio_compra
) produto_valor_medio_compra_venda INNER JOIN (
    SELECT pk_produto, produto_nome FROM produto
) produto_nome ON fk_produto = pk_produto;

--View para a consulta 2 da letra (k)

CREATE VIEW recebimentos_em_atraso AS 
SELECT cliente_nome, data_emissao, data_vencimento, valor FROM (
    SELECT fk_cliente, data_emissao, data_vencimento, valor FROM (
        SELECT fk_venda, data_emissao, data_vencimento, valor FROM financeiro_entrada WHERE data_pagamento IS NULL AND CURRENT_DATE > data_vencimento
    ) venda_data_emissao_vencimento_valor INNER JOIN (
        SELECT pk_venda, fk_cliente FROM venda
    ) venda_cliente ON fk_venda = pk_venda
) cliente_data_emissao_vencimento_valor INNER JOIN (
    SELECT pk_cliente, cliente_nome FROM cliente
) cliente_nome ON fk_cliente = pk_cliente;

--View para a consulta 2 da letra (l)

CREATE VIEW pagamentos_adiantados AS 
SELECT fornecedor_nome, data_emissao, data_vencimento, data_pagamento FROM (
    SELECT fk_fornecedor, data_emissao, data_vencimento, data_pagamento FROM (
        SELECT fk_compra, data_emissao, data_vencimento, data_pagamento FROM financeiro_saida WHERE data_pagamento < data_vencimento
    ) compra_data_emissao_vencimento_pagamento INNER JOIN (
        SELECT pk_compra, fk_fornecedor FROM compra
    ) compra_fornecedor ON fk_compra = pk_compra
) fornecedor_data_emissao_vencimento_pagamento INNER JOIN (
    SELECT pk_fornecedor, fornecedor_nome FROM fornecedor    
) fornecedor_nome ON fk_fornecedor = pk_fornecedor;

--(5)

--(a): valor_medio_compra - valor_venda > 0.7 * valor_compra

SELECT * FROM produtos_vendidos_abaixo_preco_medio_compra WHERE valor_medio_compra - valor_venda > 0.7 * valor_medio_compra;

--(b): recebimentos com mais de um mês de atraso

SELECT * FROM recebimentos_em_atraso WHERE CURRENT_DATE - data_vencimento > 30;

--(c): pagamentos adiantados em mais que 15 dias

SELECT * FROM pagamentos_adiantados WHERE data_vencimento - data_pagamento > 15;

--(6): view com todas as vendas com nome do cliente, vendedor, valor total, valor já pago e valor a receber

CREATE VIEW rel_venda AS 
SELECT cliente_nome, nome_vendedor, valor_total, valor_pago, valor_a_receber FROM (
    SELECT fk_cliente, funcionario_nome AS nome_vendedor, valor_total, valor_pago, valor_a_receber FROM (
        SELECT fk_cliente, fk_vendedor, valor_total, valor_pago, valor_a_receber FROM (
            SELECT venda_valor_total.fk_venda, valor_total, COALESCE(valor_pago, 0) AS valor_pago, valor_total - COALESCE(valor_pago, 0) AS valor_a_receber FROM (
                SELECT fk_venda, SUM(qtd * valor_unitario) AS valor_total FROM venda_item GROUP BY fk_venda
            ) venda_valor_total LEFT OUTER JOIN (
                SELECT fk_venda, SUM(valor) AS valor_pago FROM financeiro_entrada WHERE data_pagamento IS NOT NULL GROUP BY fk_venda
            ) venda_valor_pago ON venda_valor_total.fk_venda = venda_valor_pago.fk_venda    
        ) venda_valor_total_pago_receber INNER JOIN (
            SELECT pk_venda, fk_cliente, fk_vendedor FROM venda
        ) venda_cliente_vendedor ON fk_venda = pk_venda
    ) cliente_vendedor_valor_total_pago_receber INNER JOIN (
        SELECT pk_funcionario, funcionario_nome FROM funcionario WHERE fk_cargo = 1 
    ) funcionario_nome ON fk_vendedor = pk_funcionario
) cliente_nome_vendedor_valor_total_pago_receber INNER JOIN (
    SELECT pk_cliente, cliente_nome FROM cliente
) cliente_nome ON fk_cliente = pk_cliente;

--(7)

--(a)

ALTER TABLE funcionario ADD COLUMN salario NUMERIC(10, 2) DEFAULT 1100.00;  

--(b)

ALTER TABLE funcionario ADD CONSTRAINT salario_nao_negativo_constraint CHECK(salario >= 0);

--(c)

ALTER TABLE cargo DROP COLUMN descricao;

--(d)

ALTER TABLE cargo DROP CONSTRAINT cargo_cargo_nome_key;

--(e)

ALTER TABLE funcionario ALTER COLUMN funcionario_nome TYPE VARCHAR(110);

--(f)

ALTER TABLE fornecedor_endereco DROP CONSTRAINT fornecedor_endereco_fk_fornecedor_fkey;

--(g)

ALTER TABLE fornecedor_endereco ADD CONSTRAINT fornecedor_endereco_fk_fornecedor_fkey FOREIGN KEY (fk_fornecedor) REFERENCES fornecedor (pk_fornecedor) ON UPDATE CASCADE ON DELETE CASCADE;

--(h)

CREATE TABLE log_alteracoes (
    pk_log SERIAL PRIMARY KEY,
    data_hora TIMESTAMP,
    usuario INTEGER,
    tabela VARCHAR(30),
    tipo_acao VARCHAR(30)
);

--(i)
--Como data_hora é uma data com tempo, achei conveniente trocar de CURRENT_TIME (apenas tempo) para CURRENT_TIMESTAMP (data e tempo).

--(I)
ALTER TABLE log_alteracoes ALTER COLUMN data_hora SET DEFAULT CURRENT_TIMESTAMP;

--(II)

ALTER TABLE log_alteracoes ADD CONSTRAINT data_hora_nao_retroativa CHECK (data_hora >= CURRENT_TIMESTAMP);

--(III)

ALTER TABLE log_alteracoes ALTER COLUMN data_hora SET NOT NULL, ALTER COLUMN usuario SET NOT NULL;

--(IV)

ALTER TABLE log_alteracoes ADD COLUMN acao VARCHAR(100) NOT NULL;

--(V)

ALTER TABLE log_alteracoes RENAME TO log;

--(VI)

ALTER TABLE log ALTER COLUMN acao TYPE VARCHAR(200);

--(VII)

ALTER TABLE log ALTER COLUMN acao DROP NOT NULL;

--(8): salario *= 1.05, estado = GO

UPDATE funcionario SET salario = salario * 1.05 WHERE pk_funcionario IN (
    SELECT pk_funcionario FROM funcionario WHERE fk_cargo = 1
    INTERSECT SELECT fk_funcionario FROM funcionario_endereco WHERE estado = 'GO'
);
