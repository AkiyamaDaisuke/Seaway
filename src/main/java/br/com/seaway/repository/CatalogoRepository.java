package br.com.seaway.repository;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

public class CatalogoRepository<T> {
    private final ConcurrentHashMap<Long, T> registros = new ConcurrentHashMap<>();
    private final AtomicLong proximoId = new AtomicLong(1);

    public List<T> listar() {
        List<T> resultado = new ArrayList<>(registros.values());
        resultado.sort(Comparator.comparing(item -> idDe(item)));
        return resultado;
    }

    public T buscar(Long id) { return registros.get(id); }

    public T salvar(Long id, T registro) {
        long idFinal = id == null ? proximoId.getAndIncrement() : id;
        definirId(registro, idFinal);
        registros.put(idFinal, registro);
        proximoId.accumulateAndGet(idFinal + 1, Math::max);
        return registro;
    }

    public boolean excluir(Long id) { return registros.remove(id) != null; }

    private Long idDe(T item) {
        try { return (Long) item.getClass().getMethod("getId").invoke(item); }
        catch (ReflectiveOperationException e) { throw new IllegalStateException("Entidade sem campo id", e); }
    }

    private void definirId(T item, Long id) {
        try { item.getClass().getMethod("setId", Long.class).invoke(item, id); }
        catch (ReflectiveOperationException e) { throw new IllegalStateException("Entidade sem campo id", e); }
    }
}
