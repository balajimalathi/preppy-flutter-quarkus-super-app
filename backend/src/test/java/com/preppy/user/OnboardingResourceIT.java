package com.preppy.user;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.containsString;
import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.preppy.auth.firebase.FirebaseAuthService;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

@QuarkusTest
class OnboardingResourceIT {

    @InjectMock
    FirebaseAuthService firebaseAuthService;

    @Inject
    UserRepository userRepository;

    @Inject
    StudentProfileRepository studentProfileRepository;

    @Inject
    LearningCapabilityProfileRepository learningCapabilityProfileRepository;

    @Inject
    NotificationPreferenceRepository notificationPreferenceRepository;

    @BeforeEach
    @Transactional
    void setUp() throws FirebaseAuthException {
        userRepository.findByOriginAndExternalUid(AuthOrigin.FIREBASE, "onboarding-test-firebase-uid")
                .ifPresent(user -> {
                    notificationPreferenceRepository.deleteById(user.getId());
                    learningCapabilityProfileRepository.deleteById(user.getId());
                    studentProfileRepository.deleteById(user.getId());
                    userRepository.delete(user);
                });

        final FirebaseToken token = Mockito.mock(FirebaseToken.class);
        when(token.getUid()).thenReturn("onboarding-test-firebase-uid");
        when(token.getEmail()).thenReturn("onboarding@example.com");
        when(token.getName()).thenReturn("Onboarding User");
        when(token.getClaims()).thenReturn(java.util.Map.of("picture", "https://example.com/avatar.png"));
        when(firebaseAuthService.verifyIdToken(anyString())).thenReturn(token);
    }

    @Test
    void onboardingUpsertPersistsProfileAndMeReadsItBack() {
        given().header("Authorization", "Bearer test-token")
                .contentType(ContentType.JSON)
                .body("""
                        {
                          "learningTarget": "JEE Physics",
                          "studyLevel": "competitive_exam",
                          "goalType": "competitive_exam",
                          "targetDate": "2026-12-31",
                          "dailyMinutes": 90,
                          "preferredLearningMethods": ["mcq", "flashcards"],
                          "notificationsEnabled": true,
                          "quietHoursStart": "22:00:00",
                          "quietHoursEnd": "06:00:00"
                        }
                        """)
                .when()
                .put("/v1/users/me/onboarding")
                .then()
                .statusCode(200)
                .contentType(ContentType.JSON)
                .body("data.onboardingCompleted", equalTo(true))
                .body("data.onboardingCompletedAt", notNullValue())
                .body("data.learningTarget", equalTo("JEE Physics"))
                .body("data.studyLevel", equalTo("competitive_exam"))
                .body("data.goalType", equalTo("competitive_exam"))
                .body("data.dailyMinutes", equalTo(90))
                .body("data.preferredLearningMethods[0]", equalTo("mcq"))
                .body("data.preferredLearningMethods[1]", equalTo("flashcards"))
                .body("data.notificationsEnabled", equalTo(true))
                .body("data.quietHoursStart", equalTo("22:00:00"))
                .body("data.quietHoursEnd", equalTo("06:00:00"));

        given().header("Authorization", "Bearer test-token")
                .when()
                .get("/v1/users/me")
                .then()
                .statusCode(200)
                .body("onboardingCompleted", equalTo(true))
                .body("onboardingCompletedAt", notNullValue())
                .body("onboardingProfile.learningTarget", equalTo("JEE Physics"))
                .body("onboardingProfile.dailyMinutes", equalTo(90));
    }

    @Test
    void invalidOnboardingInputReturnsValidationErrors() {
        given().header("Authorization", "Bearer test-token")
                .contentType(ContentType.JSON)
                .body("""
                        {
                          "learningTarget": "",
                          "studyLevel": "competitive_exam",
                          "goalType": "competitive_exam",
                          "targetDate": "2020-01-01",
                          "dailyMinutes": 4,
                          "preferredLearningMethods": [],
                          "notificationsEnabled": false
                        }
                        """)
                .when()
                .put("/v1/users/me/onboarding")
                .then()
                .statusCode(400)
                .body("message", equalTo("Request validation failed"))
                .body("errors.toString()", containsString("learningTarget"))
                .body("errors.toString()", containsString("targetDate"))
                .body("errors.toString()", containsString("dailyMinutes"))
                .body("errors.toString()", containsString("preferredLearningMethods"));

        given().header("Authorization", "Bearer test-token")
                .contentType(ContentType.JSON)
                .body("""
                        {
                          "learningTarget": "JEE Physics",
                          "studyLevel": "competitive_exam",
                          "goalType": "competitive_exam",
                          "targetDate": "2026-12-31",
                          "dailyMinutes": 90,
                          "preferredLearningMethods": ["mcq"],
                          "notificationsEnabled": true,
                          "quietHoursStart": "22:00:00"
                        }
                        """)
                .when()
                .put("/v1/users/me/onboarding")
                .then()
                .statusCode(400)
                .body("message", equalTo("Invalid onboarding preference"))
                .body("errors[0]", equalTo("quietHoursStart: quiet hours start and end must be provided together"));

        given().header("Authorization", "Bearer test-token")
                .contentType(ContentType.JSON)
                .body("""
                        {
                          "learningTarget": "JEE Physics",
                          "studyLevel": "competitive_exam",
                          "goalType": "competitive_exam",
                          "targetDate": "2026-12-31",
                          "dailyMinutes": 90,
                          "preferredLearningMethods": ["mcq"],
                          "notificationsEnabled": true,
                          "quietHoursStart": "22:00:00",
                          "quietHoursEnd": "22:00:00"
                        }
                        """)
                .when()
                .put("/v1/users/me/onboarding")
                .then()
                .statusCode(400)
                .body("message", equalTo("Invalid onboarding preference"))
                .body("errors[0]", equalTo("quietHoursStart: quiet hours start and end must be different"));

        given().header("Authorization", "Bearer test-token")
                .contentType(ContentType.JSON)
                .body("""
                        {
                          "learningTarget": "JEE Physics",
                          "studyLevel": "unknown",
                          "goalType": "competitive_exam",
                          "targetDate": "2026-12-31",
                          "dailyMinutes": 90,
                          "preferredLearningMethods": ["mcq"],
                          "notificationsEnabled": false
                        }
                        """)
                .when()
                .put("/v1/users/me/onboarding")
                .then()
                .statusCode(400);
    }
}
