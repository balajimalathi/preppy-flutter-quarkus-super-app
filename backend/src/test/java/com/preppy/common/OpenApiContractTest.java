package com.preppy.common;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.containsString;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

@QuarkusTest
class OpenApiContractTest {

    @Test
    void openApiIncludesOnboardingEndpointAndSchemas() {
        given().when()
                .get("/q/openapi")
                .then()
                .statusCode(200)
                .body(containsString("/v1/users/me/onboarding"))
                .body(containsString("OnboardingUpsertRequest"))
                .body(containsString("OnboardingProfileResponse"))
                .body(containsString("bearerAuth"));
    }
}
