package com.preppy.pyq;

import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;

/**
 * CRUD over the {@code pyq_papers} / {@code pyq_questions} tables.
 */
@ApplicationScoped
public class PyqService {

    public List<Object> list() {
        return List.of(); // TODO: filter by exam / year / topic.
    }
}
