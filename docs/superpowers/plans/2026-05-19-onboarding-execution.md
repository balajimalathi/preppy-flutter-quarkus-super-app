# Onboarding Execution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the mobile/backend onboarding slice that persists learner profile data, creates the first notebook, replaces static new-user dashboard data, and prepares notebook-scoped material contracts.

**Architecture:** Quarkus remains the authenticated product API and persists all user-scoped profile, notebook, dashboard, and material metadata in Postgres through Flyway. Flutter composes new `onboarding` and `notebook` feature packages into the app shell, gates routes through one backend-backed session coordinator, and uses typed `ScreenState` ViewModels for full screens.

**Tech Stack:** Quarkus 3, Java 17 records, Jakarta Bean Validation, Flyway/Postgres, SmallRye OpenAPI, Flutter, Riverpod, GoRouter, Dio, existing `core_state`, `core_models`, `core_network`, and `shared_ui` packages.

---

## Reference Documents

- Spec: `docs/superpowers/specs/2026-05-19-onboarding-execution-design.md`
- Backlog: `ISSUES.md`
- Roadmap: `ROADMAP.md`
- Architecture: `TECHNICAL.md`
- Flutter state rules: `.cursor/rules/state-architecture.mdc`

## File Structure

### Backend

- Create `backend/src/main/resources/db/migration/V2__onboarding_notebooks.sql` for profile, notebook, and material metadata tables.
- Modify `backend/src/main/java/com/preppy/auth/dto/ProfileResponse.java` to expose onboarding status.
- Modify `backend/src/main/java/com/preppy/user/UserResource.java` and `backend/src/main/java/com/preppy/user/UserService.java` for onboarding upsert and profile read.
- Create `backend/src/main/java/com/preppy/user/dto/OnboardingUpsertRequest.java`.
- Create `backend/src/main/java/com/preppy/user/dto/OnboardingProfileResponse.java`.
- Create profile enum classes under `backend/src/main/java/com/preppy/user/model/`.
- Create `backend/src/main/java/com/preppy/notebook/NotebookResource.java`, `NotebookService.java`, and `NotebookRepository.java`.
- Create notebook DTOs and enums under `backend/src/main/java/com/preppy/notebook/dto/` and `backend/src/main/java/com/preppy/notebook/model/`.
- Modify or introduce `backend/src/main/java/com/preppy/dashboard/DashboardService.java` and extend dashboard DTOs under `backend/src/main/java/com/preppy/dashboard/`.
- Add backend integration tests under `backend/src/test/java/com/preppy/`.

### Flutter

- Modify `apps/preppy_app/pubspec.yaml` to include `onboarding` and `notebook` feature packages.
- Modify `apps/preppy_app/lib/bootstrap/router.dart` to use a session gate.
- Create `apps/preppy_app/lib/bootstrap/session_gate_provider.dart`.
- Create `apps/packages/features/onboarding/` for onboarding domain, data, application, and presentation.
- Create `apps/packages/features/notebook/` for first notebook setup and material readiness.
- Modify `apps/packages/features/dashboard/lib/src/domain/entities/dashboard_summary.dart`.
- Modify `apps/packages/features/dashboard/lib/src/data/mappers/dashboard_summary_mapper.dart`.
- Modify `apps/packages/features/dashboard/lib/src/presentation/dashboard_screen.dart`.
- Add Flutter tests under the relevant feature package `test/` directories.

## Implementation Tasks

### Task 1: Backend Onboarding DTOs And Migration

**Files:**
- Create: `backend/src/test/java/com/preppy/user/OnboardingDtoTest.java`
- Create: `backend/src/main/java/com/preppy/user/dto/OnboardingUpsertRequest.java`
- Create: `backend/src/main/java/com/preppy/user/dto/OnboardingProfileResponse.java`
- Create: `backend/src/main/java/com/preppy/user/model/StudyLevel.java`
- Create: `backend/src/main/java/com/preppy/user/model/GoalType.java`
- Create: `backend/src/main/java/com/preppy/user/model/LearningMethod.java`
- Modify: `backend/src/main/java/com/preppy/auth/dto/ProfileResponse.java`
- Create: `backend/src/main/resources/db/migration/V2__onboarding_notebooks.sql`

- [ ] **Step 1: Write DTO serialization and validation test**

Create `backend/src/test/java/com/preppy/user/OnboardingDtoTest.java`:

```java
package com.preppy.user;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.preppy.user.dto.OnboardingUpsertRequest;
import com.preppy.user.model.GoalType;
import com.preppy.user.model.LearningMethod;
import com.preppy.user.model.StudyLevel;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import jakarta.validation.Validator;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;

@QuarkusTest
class OnboardingDtoTest {

    @Inject
    ObjectMapper objectMapper;

    @Inject
    Validator validator;

    @Test
    void serializesExpectedOnboardingRequestShape() throws Exception {
        final var request = new OnboardingUpsertRequest(
                "UPSC GS preparation",
                StudyLevel.COMPETITIVE_EXAM,
                GoalType.COMPETITIVE_EXAM,
                LocalDate.now().plusDays(90),
                90,
                List.of(LearningMethod.MCQ, LearningMethod.FLASHCARDS),
                true,
                java.time.LocalTime.of(22, 0),
                java.time.LocalTime.of(7, 0));

        final String json = objectMapper.writeValueAsString(request);

        assertThat(json).contains("\"learningTarget\":\"UPSC GS preparation\"");
        assertThat(json).contains("\"studyLevel\":\"competitive_exam\"");
        assertThat(json).contains("\"goalType\":\"competitive_exam\"");
        assertThat(json).contains("\"preferredLearningMethods\":[\"mcq\",\"flashcards\"]");
    }

    @Test
    void rejectsInvalidOnboardingRequest() {
        final var request = new OnboardingUpsertRequest(
                "",
                null,
                null,
                LocalDate.now().minusDays(1),
                0,
                List.of(),
                false,
                null,
                null);

        final var violations = validator.validate(request);

        assertThat(violations)
                .extracting(violation -> violation.getPropertyPath().toString())
                .contains("learningTarget", "studyLevel", "goalType", "targetDate", "dailyMinutes", "preferredLearningMethods");
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd backend && ./mvnw test -Dtest=OnboardingDtoTest
```

Expected: FAIL because DTOs and enums do not exist.

- [ ] **Step 3: Add DTOs and enums**

Create `backend/src/main/java/com/preppy/user/model/StudyLevel.java`:

```java
package com.preppy.user.model;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum StudyLevel {
    SCHOOL("school"),
    UNDERGRADUATE("undergraduate"),
    POSTGRADUATE("postgraduate"),
    COMPETITIVE_EXAM("competitive_exam"),
    PROFESSIONAL("professional");

    private final String value;

    StudyLevel(final String value) {
        this.value = value;
    }

    @JsonValue
    public String value() {
        return value;
    }

    @JsonCreator
    public static StudyLevel fromValue(final String value) {
        for (final var level : values()) {
            if (level.value.equals(value)) {
                return level;
            }
        }
        throw new IllegalArgumentException("Unsupported study level: " + value);
    }
}
```

Create `backend/src/main/java/com/preppy/user/model/GoalType.java`:

```java
package com.preppy.user.model;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum GoalType {
    SUBJECT("subject"),
    COURSE("course"),
    COMPETITIVE_EXAM("competitive_exam"),
    PROFESSIONAL_CERT("professional_cert");

    private final String value;

    GoalType(final String value) {
        this.value = value;
    }

    @JsonValue
    public String value() {
        return value;
    }

    @JsonCreator
    public static GoalType fromValue(final String value) {
        for (final var type : values()) {
            if (type.value.equals(value)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unsupported goal type: " + value);
    }
}
```

Create `backend/src/main/java/com/preppy/user/model/LearningMethod.java`:

```java
package com.preppy.user.model;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum LearningMethod {
    READING("reading"),
    VISUAL("visual"),
    MCQ("mcq"),
    FLASHCARDS("flashcards"),
    VIDEOS("videos"),
    WRITING("writing");

    private final String value;

    LearningMethod(final String value) {
        this.value = value;
    }

    @JsonValue
    public String value() {
        return value;
    }

    @JsonCreator
    public static LearningMethod fromValue(final String value) {
        for (final var method : values()) {
            if (method.value.equals(value)) {
                return method;
            }
        }
        throw new IllegalArgumentException("Unsupported learning method: " + value);
    }
}
```

Create `backend/src/main/java/com/preppy/user/dto/OnboardingUpsertRequest.java`:

```java
package com.preppy.user.dto;

import com.preppy.user.model.GoalType;
import com.preppy.user.model.LearningMethod;
import com.preppy.user.model.StudyLevel;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public record OnboardingUpsertRequest(
        @NotBlank @Size(max = 200) String learningTarget,
        @NotNull StudyLevel studyLevel,
        @NotNull GoalType goalType,
        @NotNull @FutureOrPresent LocalDate targetDate,
        @Min(5) @Max(480) int dailyMinutes,
        @NotEmpty List<LearningMethod> preferredLearningMethods,
        boolean notificationsEnabled,
        LocalTime quietHoursStart,
        LocalTime quietHoursEnd) {}
```

Create `backend/src/main/java/com/preppy/user/dto/OnboardingProfileResponse.java`:

```java
package com.preppy.user.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.preppy.user.model.GoalType;
import com.preppy.user.model.LearningMethod;
import com.preppy.user.model.StudyLevel;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record OnboardingProfileResponse(
        boolean onboardingCompleted,
        Instant onboardingCompletedAt,
        String learningTarget,
        StudyLevel studyLevel,
        GoalType goalType,
        LocalDate targetDate,
        int dailyMinutes,
        List<LearningMethod> preferredLearningMethods,
        boolean notificationsEnabled,
        LocalTime quietHoursStart,
        LocalTime quietHoursEnd) {}
```

Modify `backend/src/main/java/com/preppy/auth/dto/ProfileResponse.java`:

```java
package com.preppy.auth.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.preppy.user.dto.OnboardingProfileResponse;
import java.time.Instant;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ProfileResponse(
        String profileId,
        String email,
        String fullName,
        String avatarUrl,
        Instant createdAt,
        Map<String, Object> metadata,
        boolean onboardingCompleted,
        Instant onboardingCompletedAt,
        OnboardingProfileResponse onboardingProfile) {}
```

- [ ] **Step 4: Add Flyway migration**

Create `backend/src/main/resources/db/migration/V2__onboarding_notebooks.sql` using the SQL from `docs/superpowers/specs/2026-05-19-onboarding-execution-design.md`, Section `Backend Schema`.

- [ ] **Step 5: Run test to verify DTOs pass**

Run:

```bash
cd backend && ./mvnw test -Dtest=OnboardingDtoTest
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add backend/src/test/java/com/preppy/user/OnboardingDtoTest.java backend/src/main/java/com/preppy/user/dto/OnboardingUpsertRequest.java backend/src/main/java/com/preppy/user/dto/OnboardingProfileResponse.java backend/src/main/java/com/preppy/user/model/StudyLevel.java backend/src/main/java/com/preppy/user/model/GoalType.java backend/src/main/java/com/preppy/user/model/LearningMethod.java backend/src/main/java/com/preppy/auth/dto/ProfileResponse.java backend/src/main/resources/db/migration/V2__onboarding_notebooks.sql
git commit -m "$(cat <<'EOF'
feat(onboarding): add profile contracts and schema

EOF
)"
```

### Task 2: Backend Onboarding Upsert And Read API

**Files:**
- Create: `backend/src/test/java/com/preppy/user/OnboardingResourceIT.java`
- Modify: `backend/src/main/java/com/preppy/user/UserResource.java`
- Modify: `backend/src/main/java/com/preppy/user/UserService.java`
- Modify: `backend/src/main/java/com/preppy/user/UserRepository.java`

- [ ] **Step 1: Write authenticated onboarding API test**

Create `backend/src/test/java/com/preppy/user/OnboardingResourceIT.java`:

```java
package com.preppy.user;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasItem;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

@QuarkusTest
class OnboardingResourceIT {

    @Test
    void upsertsAndReadsOnboardingProfile() {
        final String token = TestAuthTokens.firebaseToken("learner-onboarding-1", "learner@example.com");

        given()
                .auth().oauth2(token)
                .contentType("application/json")
                .body("""
                        {
                          "learningTarget": "UPSC GS preparation",
                          "studyLevel": "competitive_exam",
                          "goalType": "competitive_exam",
                          "targetDate": "2099-12-31",
                          "dailyMinutes": 90,
                          "preferredLearningMethods": ["mcq", "flashcards"],
                          "notificationsEnabled": true,
                          "quietHoursStart": "22:00:00",
                          "quietHoursEnd": "07:00:00"
                        }
                        """)
                .when()
                .put("/v1/users/me/onboarding")
                .then()
                .statusCode(200)
                .body("data.onboardingCompleted", equalTo(true))
                .body("data.learningTarget", equalTo("UPSC GS preparation"));

        given()
                .auth().oauth2(token)
                .when()
                .get("/v1/users/me")
                .then()
                .statusCode(200)
                .body("data.onboardingCompleted", equalTo(true))
                .body("data.onboardingProfile.learningTarget", equalTo("UPSC GS preparation"));
    }

    @Test
    void invalidOnboardingInputReturnsValidationErrors() {
        final String token = TestAuthTokens.firebaseToken("learner-onboarding-invalid", "invalid@example.com");

        given()
                .auth().oauth2(token)
                .contentType("application/json")
                .body("""
                        {
                          "learningTarget": "",
                          "studyLevel": "school",
                          "goalType": "subject",
                          "targetDate": "2000-01-01",
                          "dailyMinutes": 0,
                          "preferredLearningMethods": [],
                          "notificationsEnabled": false
                        }
                        """)
                .when()
                .put("/v1/users/me/onboarding")
                .then()
                .statusCode(400)
                .body("message", equalTo("Request validation failed"))
                .body("errors", hasItem(org.hamcrest.Matchers.containsString("learningTarget")));
    }
}
```

If the repo has a different auth test helper than `TestAuthTokens`, use the existing helper and keep the request/response assertions unchanged.

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd backend && ./mvnw test -Dtest=OnboardingResourceIT
```

Expected: FAIL because endpoint and persistence methods do not exist.

- [ ] **Step 3: Add resource method**

Modify `backend/src/main/java/com/preppy/user/UserResource.java`:

```java
@PUT
@Path("/me/onboarding")
@Consumes(MediaType.APPLICATION_JSON)
public ApiResponse<OnboardingProfileResponse> upsertOnboarding(
        @Valid final OnboardingUpsertRequest request) {
    final UserPrincipal principal = currentUser.principal();
    final var token = currentUser.firebaseToken();
    final var profile = userService.upsertOnboarding(token, request);
    return ApiResponse.of(profile);
}
```

Add imports for `ApiResponse`, `OnboardingProfileResponse`, `OnboardingUpsertRequest`, and `Valid`.

- [ ] **Step 4: Add service validation and transaction**

Modify `backend/src/main/java/com/preppy/user/UserService.java`:

```java
@Transactional
public OnboardingProfileResponse upsertOnboarding(
        final FirebaseToken token,
        final OnboardingUpsertRequest request) {
    validateQuietHours(request);
    final var profile = syncFromFirebaseToken(token);
    final var user = userRepository.findByProfileId(profile.profileId())
            .orElseThrow(() -> AppException.notFound("User profile not found"));
    return userRepository.upsertOnboarding(user.id(), request);
}

private static void validateQuietHours(final OnboardingUpsertRequest request) {
    final boolean hasStart = request.quietHoursStart() != null;
    final boolean hasEnd = request.quietHoursEnd() != null;
    if (hasStart != hasEnd) {
        throw AppException.badRequest("Invalid onboarding preference");
    }
    if (hasStart && request.quietHoursStart().equals(request.quietHoursEnd())) {
        throw AppException.badRequest("Invalid onboarding preference");
    }
}
```

Adapt `findByProfileId` to the actual repository method names in `UserRepository`.

- [ ] **Step 5: Add repository persistence methods**

Modify `backend/src/main/java/com/preppy/user/UserRepository.java` with methods equivalent to:

```java
public Optional<UserEntity> findByProfileId(final String profileId) {
    return find("id", UUID.fromString(profileId)).firstResultOptional();
}

public OnboardingProfileResponse upsertOnboarding(
        final UUID userId,
        final OnboardingUpsertRequest request) {
    upsertStudentProfile(userId, request);
    upsertLearningCapabilityProfile(userId, request);
    upsertNotificationPreference(userId, request);
    entityManager.createNativeQuery("""
            UPDATE users
            SET onboarding_completed_at = now(), updated_at = now()
            WHERE id = :userId
            """)
            .setParameter("userId", userId)
            .executeUpdate();
    return getOnboardingProfile(userId);
}

public OnboardingProfileResponse getOnboardingProfile(final UUID userId) {
    final Object[] row = (Object[]) entityManager.createNativeQuery("""
            SELECT u.onboarding_completed_at,
                   sp.learning_target,
                   sp.study_level,
                   sp.goal_type,
                   sp.target_date,
                   lcp.daily_minutes,
                   lcp.preferred_learning_methods,
                   np.notifications_enabled,
                   np.quiet_hours_start,
                   np.quiet_hours_end
            FROM users u
            LEFT JOIN student_profiles sp ON sp.user_id = u.id
            LEFT JOIN learning_capability_profiles lcp ON lcp.user_id = u.id
            LEFT JOIN notification_preferences np ON np.user_id = u.id
            WHERE u.id = :userId
            """)
            .setParameter("userId", userId)
            .getSingleResult();
    return mapOnboardingProfile(row);
}
```

Use the repository technology already present in `UserRepository` and keep all user IDs derived from the authenticated user.

- [ ] **Step 6: Extend profile reads**

Modify `UserService.syncFromFirebaseToken` and `UserService.getOrSyncProfile` so `ProfileResponse` includes `onboardingCompleted`, `onboardingCompletedAt`, and `onboardingProfile`.

- [ ] **Step 7: Run onboarding API test**

Run:

```bash
cd backend && ./mvnw test -Dtest=OnboardingResourceIT
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add backend/src/test/java/com/preppy/user/OnboardingResourceIT.java backend/src/main/java/com/preppy/user/UserResource.java backend/src/main/java/com/preppy/user/UserService.java backend/src/main/java/com/preppy/user/UserRepository.java
git commit -m "$(cat <<'EOF'
feat(onboarding): persist authenticated learner profiles

EOF
)"
```

### Task 3: Backend Notebook And Material Contracts

**Files:**
- Create: `backend/src/test/java/com/preppy/notebook/NotebookResourceIT.java`
- Create: `backend/src/test/java/com/preppy/notebook/NotebookMaterialContractTest.java`
- Create: `backend/src/main/java/com/preppy/notebook/NotebookResource.java`
- Create: `backend/src/main/java/com/preppy/notebook/NotebookService.java`
- Create: `backend/src/main/java/com/preppy/notebook/NotebookRepository.java`
- Create: `backend/src/main/java/com/preppy/notebook/dto/NotebookCreateRequest.java`
- Create: `backend/src/main/java/com/preppy/notebook/dto/NotebookResponse.java`
- Create: `backend/src/main/java/com/preppy/notebook/dto/NotebookMaterialResponse.java`
- Create: notebook enum classes under `backend/src/main/java/com/preppy/notebook/model/`

- [ ] **Step 1: Write notebook API tests**

Create `backend/src/test/java/com/preppy/notebook/NotebookResourceIT.java` with tests for create, list, detail, duplicate active name, and cross-user isolation:

```java
@QuarkusTest
class NotebookResourceIT {
    @Test
    void createsListsAndReadsCurrentUsersNotebook() {
        final String token = TestAuthTokens.firebaseToken("notebook-user-1", "notebook1@example.com");

        final String notebookId = given()
                .auth().oauth2(token)
                .contentType("application/json")
                .body("""
                        {
                          "name": "Polity",
                          "goalType": "competitive_exam",
                          "subjectLabel": "Indian Polity",
                          "targetDate": "2099-12-31",
                          "examTrack": "UPSC CSE"
                        }
                        """)
                .when()
                .post("/v1/notebooks")
                .then()
                .statusCode(200)
                .body("data.name", equalTo("Polity"))
                .extract()
                .path("data.id");

        given().auth().oauth2(token)
                .when().get("/v1/notebooks")
                .then().statusCode(200)
                .body("data[0].id", equalTo(notebookId));

        given().auth().oauth2(token)
                .when().get("/v1/notebooks/" + notebookId)
                .then().statusCode(200)
                .body("data.subjectLabel", equalTo("Indian Polity"));
    }
}
```

Add duplicate and foreign-user tests in the same file with exact assertions from the spec.

- [ ] **Step 2: Write material contract test**

Create `backend/src/test/java/com/preppy/notebook/NotebookMaterialContractTest.java`:

```java
@QuarkusTest
class NotebookMaterialContractTest {
    @Test
    void listsNotebookMaterialsForOwnedNotebook() {
        final String token = TestAuthTokens.firebaseToken("material-user-1", "material@example.com");
        final String notebookId = TestNotebookFixtures.createNotebook(token, "Chemistry");

        given().auth().oauth2(token)
                .when().get("/v1/notebooks/" + notebookId + "/materials")
                .then()
                .statusCode(200)
                .body("data", org.hamcrest.Matchers.empty());
    }
}
```

Use existing fixture style if present; otherwise create a helper in the test class.

- [ ] **Step 3: Run tests to verify they fail**

Run:

```bash
cd backend && ./mvnw test -Dtest=NotebookResourceIT,NotebookMaterialContractTest
```

Expected: FAIL because notebook resource does not exist.

- [ ] **Step 4: Add notebook DTOs and enums**

Create DTOs and enums matching the spec:

```java
public record NotebookCreateRequest(
        @NotBlank @Size(max = 120) String name,
        @NotNull GoalType goalType,
        @NotBlank @Size(max = 160) String subjectLabel,
        @NotNull @FutureOrPresent LocalDate targetDate,
        String board,
        String semester,
        String examTrack) {}
```

```java
public record NotebookResponse(
        UUID id,
        String name,
        GoalType goalType,
        String subjectLabel,
        LocalDate targetDate,
        String board,
        String semester,
        String examTrack,
        NotebookStatus status,
        Instant createdAt,
        Instant updatedAt) {}
```

```java
public record NotebookMaterialResponse(
        UUID id,
        UUID notebookId,
        MaterialType materialType,
        MaterialSourceRole sourceRole,
        String filename,
        MaterialStatus status,
        UUID documentId,
        UUID jobId,
        Instant createdAt,
        Instant updatedAt) {}
```

- [ ] **Step 5: Add resource, service, and repository**

Create `NotebookResource`:

```java
@Path("/v1/notebooks")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class NotebookResource {
    @Inject CurrentUser currentUser;
    @Inject NotebookService notebookService;

    @POST
    public ApiResponse<NotebookResponse> create(@Valid final NotebookCreateRequest request) {
        return ApiResponse.of(notebookService.create(currentUser.principal(), request));
    }

    @GET
    public ApiResponse<List<NotebookResponse>> list() {
        return ApiResponse.of(notebookService.list(currentUser.principal()));
    }

    @GET
    @Path("/{notebookId}")
    public ApiResponse<NotebookResponse> detail(@PathParam("notebookId") final UUID notebookId) {
        return ApiResponse.of(notebookService.detail(currentUser.principal(), notebookId));
    }

    @GET
    @Path("/{notebookId}/materials")
    public ApiResponse<List<NotebookMaterialResponse>> materials(@PathParam("notebookId") final UUID notebookId) {
        return ApiResponse.of(notebookService.materials(currentUser.principal(), notebookId));
    }
}
```

Implement `NotebookService` and `NotebookRepository` so every query filters by authenticated internal user ID and foreign notebooks return `AppException.notFound("Notebook not found")`.

- [ ] **Step 6: Run notebook tests**

Run:

```bash
cd backend && ./mvnw test -Dtest=NotebookResourceIT,NotebookMaterialContractTest
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add backend/src/test/java/com/preppy/notebook backend/src/main/java/com/preppy/notebook
git commit -m "$(cat <<'EOF'
feat(notebook): add user-scoped notebook contracts

EOF
)"
```

### Task 4: Backend Dashboard Summary

**Files:**
- Create: `backend/src/test/java/com/preppy/dashboard/DashboardResourceIT.java`
- Modify: `backend/src/main/java/com/preppy/dashboard/DashboardResource.java`
- Create or Modify: `backend/src/main/java/com/preppy/dashboard/DashboardService.java`
- Modify/Create dashboard DTOs in `backend/src/main/java/com/preppy/dashboard/`

- [ ] **Step 1: Write dashboard state tests**

Create `backend/src/test/java/com/preppy/dashboard/DashboardResourceIT.java`:

```java
@QuarkusTest
class DashboardResourceIT {
    @Test
    void emptyAccountNeedsOnboardingAndHasZeroMetrics() {
        final String token = TestAuthTokens.firebaseToken("dash-new", "dash-new@example.com");

        given().auth().oauth2(token)
                .when().get("/dashboard/summary")
                .then()
                .statusCode(200)
                .body("data.onboardingCompleted", equalTo(false))
                .body("data.notebookCount", equalTo(0))
                .body("data.nextAction", equalTo("complete_onboarding"))
                .body("data.metrics.streakDays", equalTo(0))
                .body("data.metrics.cardsDueToday", equalTo(0))
                .body("data.metrics.coveragePercent", equalTo(0))
                .body("data.metrics.pyqCoveragePercent", equalTo(0));
    }

    @Test
    void onboardedAccountWithoutNotebookGetsCreateNotebookAction() {
        final String token = TestAuthTokens.firebaseToken("dash-onboarded", "dash-onboarded@example.com");
        TestOnboardingFixtures.completeOnboarding(token);

        given().auth().oauth2(token)
                .when().get("/dashboard/summary")
                .then()
                .statusCode(200)
                .body("data.onboardingCompleted", equalTo(true))
                .body("data.notebookCount", equalTo(0))
                .body("data.nextAction", equalTo("create_notebook"));
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd backend && ./mvnw test -Dtest=DashboardResourceIT
```

Expected: FAIL because dashboard is static.

- [ ] **Step 3: Add dashboard response DTOs**

Add records:

```java
public record DashboardSummaryResponse(
        String greeting,
        boolean onboardingCompleted,
        int notebookCount,
        DashboardNextAction nextAction,
        DashboardMetricsResponse metrics,
        DashboardPlanTodayResponse planToday) {}
```

```java
public record DashboardMetricsResponse(
        int streakDays,
        int cardsDueToday,
        int coveragePercent,
        int pyqCoveragePercent) {}
```

Use `null` for `DashboardPlanTodayResponse` until plan summaries are implemented.

- [ ] **Step 4: Replace static resource logic**

Modify `DashboardResource.summary()` to delegate to `DashboardService.summary(currentUser.principal())`. The service must:

- Ensure profile sync if needed using the current auth path.
- Read `users.onboarding_completed_at`.
- Count active notebooks.
- Count material-ready records when available.
- Return zero metrics and `complete_onboarding`, `create_notebook`, or `upload_material`.

- [ ] **Step 5: Run dashboard tests**

Run:

```bash
cd backend && ./mvnw test -Dtest=DashboardResourceIT
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add backend/src/test/java/com/preppy/dashboard/DashboardResourceIT.java backend/src/main/java/com/preppy/dashboard
git commit -m "$(cat <<'EOF'
feat(dashboard): return onboarding-aware summary

EOF
)"
```

### Task 5: Flutter Onboarding Feature And Route Gate

**Files:**
- Modify: `apps/preppy_app/pubspec.yaml`
- Modify: `apps/preppy_app/lib/bootstrap/router.dart`
- Create: `apps/preppy_app/lib/bootstrap/session_gate_provider.dart`
- Create package: `apps/packages/features/onboarding/`
- Test: `apps/packages/features/onboarding/test/application/onboarding_view_model_test.dart`

- [ ] **Step 1: Write onboarding ViewModel test**

Create `apps/packages/features/onboarding/test/application/onboarding_view_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding/feature_onboarding.dart';

void main() {
  test('initial onboarding draft uses empty profile defaults', () {
    const draft = OnboardingDraft.initial();

    expect(draft.learningTarget, '');
    expect(draft.dailyMinutes, 30);
    expect(draft.preferredLearningMethods, isEmpty);
  });

  test('validate blocks missing required fields', () {
    const draft = OnboardingDraft.initial();

    final errors = draft.validate();

    expect(errors, containsPair('learningTarget', 'Tell us what you are learning.'));
    expect(errors, containsPair('targetDate', 'Choose a target date.'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test apps/packages/features/onboarding/test/application/onboarding_view_model_test.dart
```

Expected: FAIL because package and types do not exist.

- [ ] **Step 3: Scaffold package**

Create `apps/packages/features/onboarding/pubspec.yaml` with dependencies on `flutter`, `flutter_riverpod`, `core_models`, `core_network`, `core_state`, and `shared_ui` matching existing feature package patterns.

Create `apps/packages/features/onboarding/lib/feature_onboarding.dart`:

```dart
export 'src/application/state/onboarding_screen_state.dart';
export 'src/domain/entities/onboarding_draft.dart';
export 'src/feature_onboarding_routes.dart';
```

Create `OnboardingDraft`, `OnboardingScreenState`, `OnboardingViewModel`, providers, repository interface, API repository, mapper, and screen files listed in the spec. Keep the first implementation minimal enough to satisfy the tests and render the route.

- [ ] **Step 4: Add session gate provider**

Create `apps/preppy_app/lib/bootstrap/session_gate_provider.dart`:

```dart
enum SessionGateDestination {
  splash,
  login,
  onboarding,
  firstNotebook,
  dashboard,
}
```

Add a Riverpod provider that reads auth state plus backend-backed profile and notebook count. The initial implementation can use repositories directly; do not watch multiple unrelated providers in full-screen widgets.

- [ ] **Step 5: Wire router**

Modify `apps/preppy_app/lib/bootstrap/router.dart` so authenticated users are routed:

- Not onboarded -> `/onboarding`
- Onboarded with zero active notebooks -> `/onboarding/first-notebook`
- Onboarded with active notebook -> `/dashboard`

Add `onboarding` dependency to `apps/preppy_app/pubspec.yaml`.

- [ ] **Step 6: Run onboarding tests**

Run:

```bash
flutter test apps/packages/features/onboarding/test/application/onboarding_view_model_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add apps/preppy_app/pubspec.yaml apps/preppy_app/lib/bootstrap/router.dart apps/preppy_app/lib/bootstrap/session_gate_provider.dart apps/packages/features/onboarding
git commit -m "$(cat <<'EOF'
feat(onboarding): add mobile route gate and state

EOF
)"
```

### Task 6: Flutter Onboarding Form Persistence

**Files:**
- Create/Modify: onboarding presentation widgets under `apps/packages/features/onboarding/lib/src/presentation/`
- Create/Modify: onboarding repository and mapper under `apps/packages/features/onboarding/lib/src/data/`
- Test: `apps/packages/features/onboarding/test/presentation/onboarding_screen_test.dart`

- [ ] **Step 1: Write form submit widget test**

Create `apps/packages/features/onboarding/test/presentation/onboarding_screen_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('submits valid onboarding request', (tester) async {
    final repository = FakeOnboardingRepository();
    await tester.pumpWidget(buildOnboardingTestApp(repository: repository));

    await tester.enterText(find.byKey(const Key('learningTargetField')), 'UPSC GS preparation');
    await tester.tap(find.byKey(const Key('studyLevel_competitive_exam')));
    await tester.tap(find.byKey(const Key('goalType_competitive_exam')));
    await tester.tap(find.byKey(const Key('targetDateField')));
    await tester.tap(find.text('2099-12-31'));
    await tester.enterText(find.byKey(const Key('dailyMinutesField')), '90');
    await tester.tap(find.byKey(const Key('learningMethod_mcq')));
    await tester.tap(find.byKey(const Key('learningMethod_flashcards')));
    await tester.tap(find.byKey(const Key('notificationsEnabledSwitch')));
    await tester.enterText(find.byKey(const Key('quietHoursStartField')), '22:00');
    await tester.enterText(find.byKey(const Key('quietHoursEndField')), '07:00');
    await tester.tap(find.byKey(const Key('saveOnboardingButton')));
    await tester.pump();

    expect(repository.lastRequest!.learningTarget, 'UPSC GS preparation');
    expect(repository.lastRequest!.dailyMinutes, 90);
    expect(repository.lastRequest!.preferredLearningMethods, contains(LearningMethod.mcq));
  });

  testWidgets('keeps entered values after validation error', (tester) async {
    final repository = FakeOnboardingRepository(
      saveError: const ValidationError({'dailyMinutes': 'Choose at least 5 minutes.'}),
    );
    await tester.pumpWidget(buildOnboardingTestApp(repository: repository));

    await tester.enterText(find.byKey(const Key('learningTargetField')), 'Physics term exam');
    await tester.enterText(find.byKey(const Key('dailyMinutesField')), '1');
    await tester.tap(find.byKey(const Key('saveOnboardingButton')));
    await tester.pump();

    expect(find.text('Choose at least 5 minutes.'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Physics term exam'), findsOneWidget);
  });
}
```

Use the repo's widget test harness names if they differ, but keep these fields, keys, and assertions.

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test apps/packages/features/onboarding/test/presentation/onboarding_screen_test.dart
```

Expected: FAIL until screen fields and repository are implemented.

- [ ] **Step 3: Implement form and repository**

Implement:

- Text field for `learningTarget`.
- Enum selectors for `studyLevel` and `goalType`.
- Target date picker.
- Daily minutes field.
- Multi-select preferred learning methods.
- Notification opt-in and quiet hours fields.
- `ApiOnboardingRepository.upsertOnboarding` calling `PUT /v1/users/me/onboarding`.

- [ ] **Step 4: Run form tests**

Run:

```bash
flutter test apps/packages/features/onboarding/test/presentation/onboarding_screen_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add apps/packages/features/onboarding
git commit -m "$(cat <<'EOF'
feat(onboarding): persist learner onboarding form

EOF
)"
```

### Task 7: Flutter Notebook Feature

**Files:**
- Modify: `apps/preppy_app/pubspec.yaml`
- Modify: `apps/preppy_app/lib/bootstrap/router.dart`
- Create package: `apps/packages/features/notebook/`
- Test: `apps/packages/features/notebook/test/presentation/first_notebook_screen_test.dart`

- [ ] **Step 1: Write first notebook screen test**

Create `apps/packages/features/notebook/test/presentation/first_notebook_screen_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creates a notebook from valid input', (tester) async {
    final repository = FakeNotebookRepository();
    await tester.pumpWidget(buildFirstNotebookTestApp(repository: repository));

    await tester.enterText(find.byKey(const Key('notebookNameField')), 'Polity');
    await tester.tap(find.byKey(const Key('goalType_competitive_exam')));
    await tester.enterText(find.byKey(const Key('subjectLabelField')), 'Indian Polity');
    await tester.tap(find.byKey(const Key('targetDateField')));
    await tester.tap(find.text('2099-12-31'));
    await tester.enterText(find.byKey(const Key('examTrackField')), 'UPSC CSE');
    await tester.tap(find.byKey(const Key('createNotebookButton')));
    await tester.pump();

    expect(repository.lastRequest!.name, 'Polity');
    expect(repository.lastRequest!.subjectLabel, 'Indian Polity');
    expect(repository.lastRequest!.examTrack, 'UPSC CSE');
  });

  testWidgets('retains input after duplicate name error', (tester) async {
    final repository = FakeNotebookRepository(
      createError: const ValidationError({'name': 'active notebook names must be unique per user'}),
    );
    await tester.pumpWidget(buildFirstNotebookTestApp(repository: repository));

    await tester.enterText(find.byKey(const Key('notebookNameField')), 'Polity');
    await tester.tap(find.byKey(const Key('createNotebookButton')));
    await tester.pump();

    expect(find.text('active notebook names must be unique per user'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Polity'), findsOneWidget);
  });
}
```

Use local feature test utilities if their names differ, but preserve these interactions and assertions.

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test apps/packages/features/notebook/test/presentation/first_notebook_screen_test.dart
```

Expected: FAIL because package does not exist.

- [ ] **Step 3: Scaffold notebook package**

Create package exports:

```dart
export 'src/domain/entities/notebook.dart';
export 'src/domain/entities/notebook_draft.dart';
export 'src/feature_notebook_routes.dart';
```

Create state, ViewModel, repository, mapper, and presentation screen for first notebook setup. Use `ScreenState<NotebookDraft>` and typed `ValidationError` mapping.

- [ ] **Step 4: Wire route and dependency**

Add notebook dependency in `apps/preppy_app/pubspec.yaml`. Import `feature_notebook` in `router.dart` and include notebook routes. Ensure `/onboarding/first-notebook` is available.

- [ ] **Step 5: Run notebook Flutter tests**

Run:

```bash
flutter test apps/packages/features/notebook/test/presentation/first_notebook_screen_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add apps/preppy_app/pubspec.yaml apps/preppy_app/lib/bootstrap/router.dart apps/packages/features/notebook
git commit -m "$(cat <<'EOF'
feat(notebook): add first notebook setup flow

EOF
)"
```

### Task 8: Dashboard Empty State And CTA Wiring

**Files:**
- Modify: `apps/packages/features/dashboard/lib/src/domain/entities/dashboard_summary.dart`
- Modify: `apps/packages/features/dashboard/lib/src/data/mappers/dashboard_summary_mapper.dart`
- Modify: `apps/packages/features/dashboard/lib/src/presentation/dashboard_screen.dart`
- Test: `apps/packages/features/dashboard/test/presentation/dashboard_screen_test.dart`

- [ ] **Step 1: Write dashboard fixture tests**

Create or extend `apps/packages/features/dashboard/test/presentation/dashboard_screen_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows create notebook CTA for onboarded empty account', (tester) async {
    const summary = DashboardSummary(
      greeting: 'Welcome to Preppy',
      onboardingCompleted: true,
      notebookCount: 0,
      nextAction: DashboardNextAction.createNotebook,
      metrics: DashboardMetrics.zero(),
      planToday: null,
    );

    await tester.pumpWidget(buildDashboardTestApp(summary: summary));

    expect(find.text('Create notebook'), findsOneWidget);
  });

  testWidgets('does not show fake metrics for empty account', (tester) async {
    const summary = DashboardSummary(
      greeting: 'Welcome to Preppy',
      onboardingCompleted: true,
      notebookCount: 0,
      nextAction: DashboardNextAction.createNotebook,
      metrics: DashboardMetrics.zero(),
      planToday: null,
    );

    await tester.pumpWidget(buildDashboardTestApp(summary: summary));

    expect(find.text('7'), findsNothing);
    expect(find.text('24'), findsNothing);
    expect(find.text('68%'), findsNothing);
  });
}
```

Use the repo's dashboard test harness if its helper names differ, but keep the zero-metric assertions.

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test apps/packages/features/dashboard/test/presentation/dashboard_screen_test.dart
```

Expected: FAIL because dashboard entity has the old four-field shape.

- [ ] **Step 3: Extend dashboard domain and mapper**

Update `DashboardSummary` to include:

```dart
final bool onboardingCompleted;
final int notebookCount;
final DashboardNextAction nextAction;
final DashboardMetrics metrics;
final DashboardPlanToday? planToday;
```

Keep convenience getters if they reduce presentation branching, but do not preserve fake metric compatibility.

- [ ] **Step 4: Update dashboard UI**

Render CTA from `nextAction`:

- `completeOnboarding` -> `/onboarding`
- `createNotebook` -> `/onboarding/first-notebook`
- `uploadMaterial` -> notebook material route or existing ingestion route with notebook context
- `startPractice` -> practice route
- `none` -> no setup CTA

Show zero metrics honestly for empty accounts.

- [ ] **Step 5: Run dashboard Flutter test**

Run:

```bash
flutter test apps/packages/features/dashboard/test/presentation/dashboard_screen_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add apps/packages/features/dashboard
git commit -m "$(cat <<'EOF'
feat(dashboard): show onboarding-aware empty states

EOF
)"
```

### Task 9: Notebook Material Readiness UI State

**Files:**
- Create/Modify: `apps/packages/features/notebook/lib/src/domain/entities/notebook_material.dart`
- Create/Modify: `apps/packages/features/notebook/lib/src/presentation/notebook_material_entry_card.dart`
- Test: `apps/packages/features/notebook/test/presentation/notebook_material_state_test.dart`

- [ ] **Step 1: Write material state widget test**

Create `apps/packages/features/notebook/test/presentation/notebook_material_state_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders no material state', (tester) async {
    await tester.pumpWidget(buildNotebookMaterialTestApp(
      status: MaterialStatus.none,
      notebookId: 'notebook_1',
    ));

    expect(find.text('Add syllabus or source material'), findsOneWidget);
  });

  testWidgets('renders processing state', (tester) async {
    await tester.pumpWidget(buildNotebookMaterialTestApp(
      status: MaterialStatus.processing,
      notebookId: 'notebook_1',
    ));

    expect(find.text('Material is being prepared'), findsOneWidget);
    expect(find.text('Generate practice now'), findsNothing);
  });

  testWidgets('renders failed state', (tester) async {
    await tester.pumpWidget(buildNotebookMaterialTestApp(
      status: MaterialStatus.failed,
      notebookId: 'notebook_1',
    ));

    expect(find.text('Material setup failed'), findsOneWidget);
  });
}
```

Use the local test app helper name if it differs, but keep these statuses and visible-copy assertions.

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test apps/packages/features/notebook/test/presentation/notebook_material_state_test.dart
```

Expected: FAIL until material state UI exists.

- [ ] **Step 3: Implement material state enum and card**

Add:

```dart
enum MaterialStatus { none, pending, processing, ready, failed }

enum NotebookMaterialUiState {
  noMaterial,
  uploadPending,
  uploadProcessing,
  uploadReady,
  uploadFailed,
}
```

Map backend enum to UI state exactly as the spec table defines. Render a notebook-scoped material CTA that carries the notebook ID.

- [ ] **Step 4: Run material state test**

Run:

```bash
flutter test apps/packages/features/notebook/test/presentation/notebook_material_state_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add apps/packages/features/notebook
git commit -m "$(cat <<'EOF'
feat(notebook): define material readiness states

EOF
)"
```

### Task 10: OpenAPI And Full Verification

**Files:**
- Create/Modify: `backend/src/test/java/com/preppy/common/OpenApiContractTest.java`
- Modify as needed: backend resource annotations

- [ ] **Step 1: Write OpenAPI contract assertions**

Create or extend `backend/src/test/java/com/preppy/common/OpenApiContractTest.java`:

```java
@QuarkusTest
class OpenApiContractTest {
    @Test
    void openApiContainsOnboardingAndNotebookContracts() {
        given()
                .when().get("/q/openapi")
                .then()
                .statusCode(200)
                .body(org.hamcrest.Matchers.containsString("/v1/users/me/onboarding"))
                .body(org.hamcrest.Matchers.containsString("/v1/notebooks"))
                .body(org.hamcrest.Matchers.containsString("/dashboard/summary"));
    }
}
```

- [ ] **Step 2: Run backend suite**

Run:

```bash
cd backend && ./mvnw test
```

Expected: PASS.

- [ ] **Step 3: Run Flutter targeted suites**

Run:

```bash
flutter test apps/packages/features/onboarding/test
flutter test apps/packages/features/notebook/test
flutter test apps/packages/features/dashboard/test
```

Expected: PASS.

- [ ] **Step 4: Run analyzer**

Run:

```bash
flutter analyze
```

Expected: PASS with no newly introduced analyzer errors.

- [ ] **Step 5: Commit verification polish**

```bash
git add backend/src/test/java/com/preppy/common/OpenApiContractTest.java backend/src/main/java/com/preppy apps/packages/features apps/preppy_app
git commit -m "$(cat <<'EOF'
test(onboarding): cover contracts and route states

EOF
)"
```

## Self-Review Checklist

| Issue | Implemented by task(s) |
| --- | --- |
| ONB-MOB-01 | Task 5 |
| ONB-MOB-02 | Task 5 |
| ONB-MOB-03 | Task 6 |
| ONB-MOB-04 | Task 6 |
| ONB-BE-01 | Task 1 |
| ONB-BE-02 | Task 1 |
| ONB-BE-03 | Task 2 |
| ONB-BE-04 | Task 2 |
| ONB-BE-05 | Task 10 |
| ONB-MOB-05 | Task 5, Task 7 |
| ONB-MOB-06 | Task 7 |
| ONB-MOB-07 | Task 7 |
| ONB-BE-06 | Task 1, Task 3 |
| ONB-BE-07 | Task 3 |
| ONB-BE-08 | Task 3 |
| ONB-BE-09 | Task 10 |
| ONB-MOB-08 | Task 8 |
| ONB-MOB-09 | Task 8 |
| ONB-BE-10 | Task 4 |
| ONB-BE-11 | Task 4 |
| ONB-MOB-10 | Task 9 |
| ONB-MOB-11 | Task 9 |
| ONB-BE-12 | Task 3 |
| ONB-BE-13 | Task 3, Task 10 |

- [ ] MS-01 is covered by Tasks 1, 2, 5, and 6.
- [ ] MS-02 is covered by Tasks 3 and 7.
- [ ] MS-03 is covered by Tasks 4 and 8.
- [ ] MS-04 is covered by Tasks 3 and 9.
- [ ] Every issue in `ISSUES.md` maps to at least one task.
- [ ] No task preserves static dashboard assumptions for empty users.
- [ ] No upload path creates material without notebook scope.
- [ ] Backend tests and Flutter tests are listed with exact commands.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-19-onboarding-execution.md`. Two execution options:

**1. Subagent-Driven (recommended)** - Dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints.
