package com.preppy.question;

import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;

/**
 * Cloze-style flashcard CRUD, used by the SRS engine.
 */
@ApplicationScoped
public class FlashcardService {

    public List<Object> listDue() {
        return List.of(); // TODO: join flashcards with srs_state where due <= now().
    }
}
