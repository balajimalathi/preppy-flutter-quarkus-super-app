# Preppy

Super-app for exam prep — covers ingestion of study material, AI-generated MCQs and flashcards, spaced repetition, syllabus coverage tracking and PYQ pattern analysis.

Domain: **preppy.skndan.com**

## Repository layout

```
preppy/
├── melos.yaml                 # Melos workspace config
├── pubspec.yaml               # Root workspace pubspec
├── infra/                     # docker-compose, env templates
├── backend/                   # Quarkus 3.x monolith (JDK 17)
└── apps/
    ├── preppy_app/            # Flutter shell app
    └── packages/
        ├── core/              # Pure-Dart packages (network, storage, di, models)
        ├── shared_ui/         # Design system
        └── features/          # Feature packages (auth, dashboard, etc.)
```

## Prerequisites

| Tool        | Version            |
| ----------- | ------------------ |
| Flutter SDK | 3.41.9             |
| Dart SDK    | 3.11.5 (bundled)   |
| JDK         | 17 (Temurin)       |
| Quarkus CLI | 3.35+              |
| Docker      | 24+                |
| Melos       | 6.x (`dart pub global activate melos`) |

## Quick start

### 1. Bootstrap the Flutter workspace

```bash
dart pub global activate melos
melos bootstrap
```

### 2. Spin up local infra

```bash
cd infra
cp .env.example .env
docker compose up -d
```

### 3. Run the backend

```bash
cd backend
./mvnw quarkus:dev
```

The API is available at <http://localhost:8080>.

### 4. Run the app

```bash
cd apps/preppy_app
flutter run
```

## CI

GitHub Actions workflows live in [`.github/workflows`](.github/workflows):

- `flutter.yml` — analyzes and tests every Flutter package
- `quarkus.yml` — Maven verify against a Postgres service container

## License

UNLICENSED — internal project.
