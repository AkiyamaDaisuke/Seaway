#Seaway
##1. O que é o Projeto

O Seaway é um sistema web desenvolvido para gerenciar os cadastros de clientes, fornecedores e produtos de uma vidraçaria. Seu principal objetivo é fornecer uma interface simples e eficiente para o controle operacional do negócio.
##2. Entidades do Sistema

O sistema é estruturado em torno de três classes principais de cadastro:

    Cliente: Responsável por armazenar dados como ID, nome, CPF, e-mail e telefone.
    Produto: Armazena informações sobre os itens, incluindo ID, nome, preço, descrição e quantidade.
    Fornecedor: Responsável pelo fornecimento de matérias-primas e outros produtos para o comércio. Armazena dados como ID, nome, CNPJ, telefone e e-mail.

##3. Tecnologias Utilizadas

A arquitetura do sistema foi desenvolvida utilizando as seguintes tecnologias:

    JSP (JavaServer Pages): Utilizado para a criação de páginas web dinâmicas e a renderização da interface do usuário.
    JSON (JavaScript Object Notation): Formato leve utilizado para a troca de dados estruturados entre o front-end e o back-end.
    Gson: Biblioteca desenvolvida pelo Google, utilizada para converter objetos Java em JSON e vice-versa de forma automatizada.
    Apache Tomcat: Servidor web e contêiner de Servlets utilizado para hospedar e executar a aplicação localmente.

##4. Diagrama de Classes

Diagrama de classes pendente de implementação.

##5. Como Executar o Projeto

Siga os passos abaixo para executar a aplicação no Eclipse:

    Importar o projeto:
        Abra o Eclipse.
        Importe o projeto para o ambiente de desenvolvimento.
    Executar o projeto:
        Configure o servidor Apache Tomcat no Eclipse, caso ainda não esteja configurado.
        Inicie o servidor e execute a aplicação.
