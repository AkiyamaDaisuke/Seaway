package br.com.seaway.web;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import br.com.seaway.model.Cliente;
import br.com.seaway.model.Fornecedor;
import br.com.seaway.model.Produto;
import br.com.seaway.repository.CatalogoRepository;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/api/*")
public class CatalogoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final Gson gson = new Gson();
    private final Map<String, CatalogoRepository<?>> repositorios = new ConcurrentHashMap<>();

    @Override
    public void init() {
        repositorios.put("clientes", new CatalogoRepository<Cliente>());
        repositorios.put("fornecedores", new CatalogoRepository<Fornecedor>());
        repositorios.put("produtos", new CatalogoRepository<Produto>());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String[] caminho = caminho(request);
        if (caminho.length == 0 || caminho.length > 2) { erro(response, HttpServletResponse.SC_NOT_FOUND, "Rota inválida."); return; }
        CatalogoRepository<?> repositorio = repositorio(caminho[0], response);
        if (repositorio == null) return;
        if (caminho.length == 1) {
            json(response, HttpServletResponse.SC_OK, repositorio.listar());
            return;
        }
        Long id = id(caminho[1], response);
        if (id == null) return;
        Object item = repositorio.buscar(id);
        if (item == null) { erro(response, HttpServletResponse.SC_NOT_FOUND, "Cadastro não encontrado."); return; }
        json(response, HttpServletResponse.SC_OK, item);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        salvar(request, response, false);
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        salvar(request, response, true);
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String[] caminho = caminho(request);
        if (caminho.length != 2) { erro(response, HttpServletResponse.SC_BAD_REQUEST, "Informe o ID do cadastro."); return; }
        CatalogoRepository<?> repositorio = repositorio(caminho[0], response);
        if (repositorio == null) return;
        Long id = id(caminho[1], response);
        if (id == null) return;
        if (!repositorio.excluir(id)) {
            erro(response, HttpServletResponse.SC_NOT_FOUND, "Cadastro não encontrado.");
            return;
        }
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    @SuppressWarnings("unchecked")
    private void salvar(HttpServletRequest request, HttpServletResponse response, boolean atualizar) throws IOException {
        String[] caminho = caminho(request);
        if (caminho.length != (atualizar ? 2 : 1)) {
            erro(response, HttpServletResponse.SC_BAD_REQUEST, atualizar ? "Informe o ID do cadastro." : "Rota inválida.");
            return;
        }
        String tipo = caminho[0];
        CatalogoRepository<?> repositorio = repositorio(tipo, response);
        if (repositorio == null) return;
        try {
            switch (tipo) {
                case "clientes" -> salvar((CatalogoRepository<Cliente>) repositorio, gson.fromJson(request.getReader(), Cliente.class), caminho, atualizar, response);
                case "fornecedores" -> salvar((CatalogoRepository<Fornecedor>) repositorio, gson.fromJson(request.getReader(), Fornecedor.class), caminho, atualizar, response);
                case "produtos" -> salvar((CatalogoRepository<Produto>) repositorio, gson.fromJson(request.getReader(), Produto.class), caminho, atualizar, response);
                default -> erro(response, HttpServletResponse.SC_NOT_FOUND, "Tipo de cadastro não encontrado.");
            }
        } catch (JsonSyntaxException | IllegalStateException e) {
            erro(response, HttpServletResponse.SC_BAD_REQUEST, "JSON inválido ou dados incompatíveis.");
        }
    }

    private <T> void salvar(CatalogoRepository<T> repositorio, T item, String[] caminho,
                            boolean atualizar, HttpServletResponse response) throws IOException {
        if (item == null) { erro(response, HttpServletResponse.SC_BAD_REQUEST, "Envie os dados do cadastro."); return; }
        Long id = atualizar ? id(caminho[1], response) : null;
        if (atualizar && id == null) return;
        if (atualizar && repositorio.buscar(id) == null) {
            erro(response, HttpServletResponse.SC_NOT_FOUND, "Cadastro não encontrado.");
            return;
        }
        json(response, atualizar ? HttpServletResponse.SC_OK : HttpServletResponse.SC_CREATED,
                repositorio.salvar(id, item));
    }

    private String[] caminho(HttpServletRequest request) {
        String info = request.getPathInfo();
        if (info == null || info.equals("/")) return new String[0];
        return java.util.Arrays.stream(info.split("/")).filter(parte -> !parte.isBlank()).toArray(String[]::new);
    }

    private CatalogoRepository<?> repositorio(String tipo, HttpServletResponse response) throws IOException {
        CatalogoRepository<?> repositorio = repositorios.get(tipo);
        if (tipo == null || repositorio == null) {
            erro(response, HttpServletResponse.SC_NOT_FOUND, "Tipo de cadastro não encontrado.");
            return null;
        }
        return repositorio;
    }

    private Long id(String valor, HttpServletResponse response) throws IOException {
        try { return Long.valueOf(valor); }
        catch (NumberFormatException e) {
            erro(response, HttpServletResponse.SC_BAD_REQUEST, "ID inválido.");
            return null;
        }
    }

    private void json(HttpServletResponse response, int status, Object corpo) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(gson.toJson(corpo));
    }

    private void erro(HttpServletResponse response, int status, String mensagem) throws IOException {
        json(response, status, Map.of("erro", mensagem));
    }
}
