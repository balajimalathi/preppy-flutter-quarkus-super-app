package com.preppy.auth;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.preppy.auth.firebase.FirebaseAuthService;
import com.preppy.user.UserRepository;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

@QuarkusTest
class AuthProfileResourceTest {

    @InjectMock
    FirebaseAuthService firebaseAuthService;

    @Inject
    UserRepository userRepository;

    @BeforeEach
    @Transactional
    void setUp() throws FirebaseAuthException {
        userRepository.delete("origin = ?1 and externalUid = ?2", "firebase", "test-firebase-uid");

        final FirebaseToken token = Mockito.mock(FirebaseToken.class);
        when(token.getUid()).thenReturn("test-firebase-uid");
        when(token.getEmail()).thenReturn("test@example.com");
        when(token.getName()).thenReturn("Test User");
        when(token.getClaims()).thenReturn(java.util.Map.of("picture", "https://example.com/avatar.png"));
        when(firebaseAuthService.verifyIdToken(anyString())).thenReturn(token);
    }

    @Test
    void healthIsPublic() {
        given().when()
                .get("/health")
                .then()
                .statusCode(200)
                .body("status", equalTo("UP"));
    }

    @Test
    void profileRequiresBearerToken() {
        given().when()
                .get("/v1/auth/profile")
                .then()
                .statusCode(401)
                .body("message", equalTo("Missing or invalid Bearer token"));
    }

    @Test
    void syncProfileCreatesUser() {
        given().header("Authorization", "Bearer test-token")
                .when()
                .post("/v1/auth/profile")
                .then()
                .statusCode(200)
                .contentType(ContentType.JSON)
                .body("profileId", notNullValue())
                .body("email", equalTo("test@example.com"))
                .body("fullName", equalTo("Test User"))
                .body("avatarUrl", equalTo("https://example.com/avatar.png"))
                .body("metadata", notNullValue());
    }

    @Test
    void getProfileAfterSync() {
        given().header("Authorization", "Bearer test-token")
                .post("/v1/auth/profile")
                .then()
                .statusCode(200);

        given().header("Authorization", "Bearer test-token")
                .when()
                .get("/v1/auth/profile")
                .then()
                .statusCode(200)
                .body("email", equalTo("test@example.com"));
    }
}
