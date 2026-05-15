# backend

This project uses Quarkus, the Supersonic Subatomic Java Framework.

If you want to learn more about Quarkus, please visit its website: <https://quarkus.io/>.

## Firebase authentication

The backend verifies Firebase ID tokens via the Firebase Admin SDK. For local dev, copy `src/main/resources/firebase/service-account.json.example` to `service-account.json` (gitignored) or set `FIREBASE_SERVICE_ACCOUNT_PATH`.

For real token verification, set:

```shell
export FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/your/service-account.json
export FIREBASE_PROJECT_ID=your-firebase-project-id
```

Do not commit production service account JSON files to git. For local overrides, use `backend/firebase-service-account.json` (gitignored) and set `FIREBASE_SERVICE_ACCOUNT_PATH` to that path.

Public (unauthenticated) routes are configured in `application.properties` via `quarkus.http.auth.permission.public.paths` (e.g. `/q/*`, `/health`, `/metrics`).

## Test APIs in Swagger UI (dev)

Swagger UI is at <http://localhost:8080/q/swagger-ui>. Protected routes require a **Firebase ID token** (not a Google OAuth access token).

### 1. Start the backend

```shell
export FIREBASE_PROJECT_ID=hlp-chat   # must match your service account project_id
./mvnw quarkus:dev
```

### 2. Mint an ID token

From `backend/scripts` (uses `src/main/resources/firebase/service-account.json` by default):

```shell
cd backend/scripts
npm install
export FIREBASE_WEB_API_KEY=...   # Web API key from apps/preppy_app/lib/firebase/dev/firebase_options.dart
npm run mint-id-token
```

The script prints the JWT to stdout; metadata (`uid`, `expiresIn`) goes to stderr. Optional env vars:

| Variable | Default |
|----------|---------|
| `FIREBASE_SERVICE_ACCOUNT_PATH` | `../src/main/resources/firebase/service-account.json` |
| `FIREBASE_TEST_UID` | `dev-swagger-test` |

Same flow from Bruno: `cd bruno/auth && npm run mint-id-token` (defaults to `bruno/auth/service-account.json`).

Pipe into a shell variable:

```shell
export ID_TOKEN=$(FIREBASE_WEB_API_KEY=... npm run mint-id-token 2>/dev/null)
```

### 3. Authorize in Swagger UI

1. Open <http://localhost:8080/q/swagger-ui>
2. Click **Authorize**
3. Paste the token only (no `Bearer ` prefix)
4. Call protected endpoints (e.g. `POST /v1/auth/profile` to provision the user, then `GET /v1/auth/profile`)

ID tokens expire after about an hour; re-run the mint script when you get `401`.

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:

```shell script
./mvnw quarkus:dev
```

> **_NOTE:_**  Quarkus now ships with a Dev UI, which is available in dev mode only at <http://localhost:8080/q/dev/>.

## Packaging and running the application

The application can be packaged using:

```shell script
./mvnw package
```

It produces the `quarkus-run.jar` file in the `target/quarkus-app/` directory.
Be aware that it’s not an _über-jar_ as the dependencies are copied into the `target/quarkus-app/lib/` directory.

The application is now runnable using `java -jar target/quarkus-app/quarkus-run.jar`.

If you want to build an _über-jar_, execute the following command:

```shell script
./mvnw package -Dquarkus.package.jar.type=uber-jar
```

The application, packaged as an _über-jar_, is now runnable using `java -jar target/*-runner.jar`.

## Creating a native executable

You can create a native executable using:

```shell script
./mvnw package -Dnative
```

Or, if you don't have GraalVM installed, you can run the native executable build in a container using:

```shell script
./mvnw package -Dnative -Dquarkus.native.container-build=true
```

You can then execute your native executable with: `./target/backend-1.0.0-SNAPSHOT-runner`

If you want to learn more about building native executables, please consult <https://quarkus.io/guides/maven-tooling>.

## Related Guides

- Hibernate ORM with Panache ([guide](https://quarkus.io/guides/hibernate-orm-panache)): Simplified JPA/Hibernate data access layer with active record and repository patterns
- REST Jackson ([guide](https://quarkus.io/guides/rest#json-serialisation)): Jackson serialization support for Quarkus REST. This extension is not compatible with the quarkus-resteasy extension, or any of the extensions that depend on it
- Hibernate Validator ([guide](https://quarkus.io/guides/validation)): Bean validation using Hibernate Validator and Jakarta Validation annotations
- SmallRye JWT ([guide](https://quarkus.io/guides/security-jwt)): Secure your applications with JSON Web Token
- Flyway ([guide](https://quarkus.io/guides/flyway)): Handle your database schema migrations
- SmallRye OpenAPI ([guide](https://quarkus.io/guides/openapi-swaggerui)): Generate OpenAPI schemas and serve Swagger UI for REST API documentation
- Redis Client ([guide](https://quarkus.io/guides/redis)): Connect to Redis in either imperative or reactive style
- JDBC Driver - PostgreSQL ([guide](https://quarkus.io/guides/datasource)): Connect to the PostgreSQL database via JDBC
- Micrometer Registry Prometheus ([guide](https://quarkus.io/guides/micrometer)): Enable Prometheus support for Micrometer
