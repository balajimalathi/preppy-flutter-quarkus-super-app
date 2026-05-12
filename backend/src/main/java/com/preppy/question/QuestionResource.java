package com.preppy.question;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * MCQ + flashcard generation and retrieval endpoints.
 */
@Path("/questions")
@Produces(MediaType.APPLICATION_JSON)
public class QuestionResource {

    @Inject
    QuestionService questionService;

    @Inject
    FlashcardService flashcardService;

    @POST
    @Path("/generate")
    public Object generate() {
        return questionService.generate();
    }

    @GET
    @Path("/flashcards")
    public Object flashcards() {
        return flashcardService.listDue();
    }
}
