<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Seaway | Cadastros</title>
    <style>
        :root { font-family: Inter, "Segoe UI", sans-serif; color: #182433; background: #f3f6f9; }
        * { box-sizing: border-box; }
        body { margin: 0; }
        header { background: #103a52; color: white; padding: 24px max(24px, calc((100% - 1120px)/2)); }
        header h1 { margin: 0; font-size: 1.65rem; }
        header p { margin: 6px 0 0; color: #c4d8e2; }
        main { max-width: 1120px; margin: 32px auto; padding: 0 20px; }
        .layout { display: grid; grid-template-columns: minmax(260px, 340px) 1fr; gap: 22px; align-items: start; }
        section { background: white; border: 1px solid #e1e8ed; border-radius: 12px; padding: 22px; box-shadow: 0 4px 18px #17394c0a; }
        h2 { margin: 0 0 18px; font-size: 1.15rem; }
        label { display: block; margin: 13px 0 6px; font-size: .9rem; font-weight: 600; }
        input, select { width: 100%; border: 1px solid #cbd6dd; border-radius: 7px; padding: 10px 11px; font: inherit; background: #fff; }
        input:focus, select:focus { outline: 2px solid #62a9c6; border-color: transparent; }
        button { border: 0; border-radius: 7px; padding: 10px 14px; font: inherit; font-weight: 600; cursor: pointer; }
        .primary { color: white; background: #176b8a; width: 100%; margin-top: 18px; }
        .secondary { background: #e9eff3; color: #294354; }
        .danger { background: #fff0ef; color: #a5322a; }
        .actions { display: flex; gap: 7px; }
        .actions button { padding: 7px 10px; font-size: .84rem; }
        .toolbar { display: flex; justify-content: space-between; align-items: center; gap: 12px; margin-bottom: 14px; }
        .toolbar h2 { margin: 0; }
        .toolbar select { max-width: 190px; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; font-size: .9rem; }
        th, td { text-align: left; padding: 12px 10px; border-bottom: 1px solid #e7edf1; }
        th { color: #567080; font-size: .78rem; text-transform: uppercase; letter-spacing: .04em; }
        .empty { color: #6c7d87; text-align: center; padding: 28px 10px; }
        #status { min-height: 22px; color: #a5322a; font-size: .9rem; margin-top: 12px; }
        @media (max-width: 760px) { .layout { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<header>
    <h1>Seaway</h1>
    <p>Controle de clientes, fornecedores e produtos</p>
</header>
<main>
    <div class="layout">
        <section>
            <h2 id="form-title">Novo cadastro</h2>
            <label for="tipo-form">Tipo de cadastro</label>
            <select id="tipo-form">
                <option value="clientes">Cliente</option>
                <option value="fornecedores">Fornecedor</option>
                <option value="produtos">Produto</option>
            </select>
            <form id="cadastro-form"></form>
            <div id="status" role="status" aria-live="polite"></div>
        </section>
        <section>
            <div class="toolbar">
                <h2>Cadastros</h2>
                <select id="tipo-lista" aria-label="Filtrar tipo de cadastro">
                    <option value="clientes">Clientes</option>
                    <option value="fornecedores">Fornecedores</option>
                    <option value="produtos">Produtos</option>
                </select>
            </div>
            <div class="table-wrap"><table>
                <thead id="cabecalho"></thead>
                <tbody id="registros"></tbody>
            </table></div>
        </section>
    </div>
</main>
<script>
(() => {
    const context = '<%= request.getContextPath() %>';
    const definicoes = {
        clientes: { nome: 'Cliente', campos: [['nome','Nome','text'],['cpf','CPF','text'],['email','E-mail','email'],['telefone','Telefone','tel']] },
        fornecedores: { nome: 'Fornecedor', campos: [['nome','Nome','text'],['cnpj','CNPJ','text'],['telefone','Telefone','tel'],['email','E-mail','email']] },
        produtos: { nome: 'Produto', campos: [['nome','Nome','text'],['preco','Preço (R$)','number'],['descricao','Descrição','text'],['quantidade','Quantidade','number']] }
    };
    const tipoForm = document.querySelector('#tipo-form');
    const tipoLista = document.querySelector('#tipo-lista');
    const form = document.querySelector('#cadastro-form');
    const status = document.querySelector('#status');
    let editando = null;

    function montarFormulario(item = {}) {
        const tipo = tipoForm.value;
        form.replaceChildren();
        for (const [campo, rotulo, tipoInput] of definicoes[tipo].campos) {
            const label = document.createElement('label');
            label.htmlFor = 'campo-' + campo;
            label.textContent = rotulo;
            const input = document.createElement('input');
            input.id = 'campo-' + campo;
            input.name = campo;
            input.type = tipoInput;
            input.required = true;
            if (tipoInput === 'number') input.min = '0';
            if (campo === 'preco') input.step = '0.01';
            input.value = item[campo] ?? '';
            form.append(label, input);
        }
        const submit = document.createElement('button');
        submit.className = 'primary';
        submit.type = 'submit';
        submit.textContent = editando ? 'Salvar alterações' : 'Adicionar cadastro';
        form.append(submit);
        document.querySelector('#form-title').textContent = editando ? 'Editar ' + definicoes[tipo].nome.toLowerCase() : 'Novo cadastro';
    }

    async function carregar() {
        const tipo = tipoLista.value;
        const cabecalho = document.querySelector('#cabecalho');
        cabecalho.replaceChildren();
        const linha = document.createElement('tr');
        const titulos = tipo === 'clientes' ? ['ID','Nome','CPF','E-mail','Telefone']
            : tipo === 'fornecedores' ? ['ID','Nome','CNPJ','Telefone','E-mail']
            : ['ID','Nome','Preço','Descrição','Quantidade'];
        for (const titulo of [...titulos, 'Ações']) {
            const th = document.createElement('th'); th.textContent = titulo; linha.append(th);
        }
        cabecalho.append(linha);
        try {
            const resposta = await fetch(context + '/api/' + tipo);
            const dados = await resposta.json();
            if (!resposta.ok) throw new Error(dados.erro || 'Não foi possível carregar os cadastros.');
            const tbody = document.querySelector('#registros');
            tbody.replaceChildren();
            if (!dados.length) {
                const tr = document.createElement('tr'); const td = document.createElement('td');
                td.colSpan = titulos.length + 1; td.className = 'empty'; td.textContent = 'Nenhum cadastro ainda.';
                tr.append(td); tbody.append(tr); return;
            }
            for (const item of dados) {
                const tr = document.createElement('tr');
                const valores = tipo === 'clientes' ? [item.id,item.nome,item.cpf,item.email,item.telefone]
                    : tipo === 'fornecedores' ? [item.id,item.nome,item.cnpj,item.telefone,item.email]
                    : [item.id,item.nome,Number(item.preco).toLocaleString('pt-BR',{style:'currency',currency:'BRL'}),item.descricao,item.quantidade];
                for (const valor of valores) { const td = document.createElement('td'); td.textContent = valor ?? ''; tr.append(td); }
                const acoes = document.createElement('td'); acoes.className = 'actions';
                const editar = document.createElement('button'); editar.className = 'secondary'; editar.textContent = 'Editar';
                editar.addEventListener('click', () => {
                    tipoForm.value = tipo; editando = item.id; montarFormulario(item);
                    window.scrollTo({top:0,behavior:'smooth'});
                });
                const excluir = document.createElement('button'); excluir.className = 'danger'; excluir.textContent = 'Excluir';
                excluir.addEventListener('click', async () => {
                    if (!window.confirm('Excluir o cadastro #' + item.id + '?')) return;
                    const r = await fetch(context + '/api/' + tipo + '/' + item.id, {method:'DELETE'});
                    if (!r.ok) { status.textContent = 'Não foi possível excluir o cadastro.'; return; }
                    carregar();
                });
                acoes.append(editar, excluir); tr.append(acoes); tbody.append(tr);
            }
        } catch (erro) { status.textContent = erro.message; }
    }

    tipoForm.addEventListener('change', () => { editando = null; montarFormulario(); });
    tipoLista.addEventListener('change', carregar);
    form.addEventListener('submit', async event => {
        event.preventDefault(); status.textContent = '';
        const dados = Object.fromEntries(new FormData(form).entries());
        if (tipoForm.value === 'produtos') { dados.preco = Number(dados.preco); dados.quantidade = Number(dados.quantidade); }
        const url = context + '/api/' + tipoForm.value + (editando ? '/' + editando : '');
        try {
            const resposta = await fetch(url, {method:editando ? 'PUT' : 'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(dados)});
            const resultado = await resposta.json();
            if (!resposta.ok) throw new Error(resultado.erro || 'Não foi possível salvar o cadastro.');
            editando = null; form.reset(); montarFormulario();
            tipoLista.value = tipoForm.value; carregar();
        } catch (erro) { status.textContent = erro.message; }
    });
    montarFormulario(); carregar();
})();
</script>
</body>
</html>
