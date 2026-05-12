package com.preppy.taxonomy;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Loads + caches the syllabus tree per exam.
 */
@ApplicationScoped
public class TaxonomyService {

    public Object tree() {
        return null; // TODO: load nested SyllabusItem rows.
    }
}
