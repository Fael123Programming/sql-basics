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
    pais VARCHAR(30) DEFAULT 'BRASIL' NOT NULL,
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
    FOREIGN KEY (fk_fornecedor) REFERENCES fornecedor (pk_fornecedor) ON UPDATE CASCADE ON DELETE NO ACTION,
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
    data_pagamento DATE NOT NULL CHECK (data_pagamento >= data_emissao),
    valor NUMERIC (10, 2) NOT NULL CHECK (valor > 0.0),
    forma_recebimento VARCHAR(30) NOT NULL,
    FOREIGN KEY (fk_venda) REFERENCES venda (pk_venda) ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE financeiro_saida (
    pk_financeiro_saida SERIAL PRIMARY KEY,
    fk_compra INTEGER NOT NULL,
    data_emissao DATE DEFAULT CURRENT_DATE NOT NULL CHECK (data_emissao >= CURRENT_DATE),
    data_vencimento DATE NOT NULL CHECK (data_vencimento >= data_emissao),
    data_pagamento DATE NOT NULL CHECK (data_pagamento >= data_emissao),
    valor NUMERIC (10, 2) NOT NULL CHECK (valor > 0.0),
    forma_pagamento VARCHAR(30) NOT NULL,
    FOREIGN KEY (fk_compra) REFERENCES compra (pk_compra) ON UPDATE CASCADE ON DELETE NO ACTION
);