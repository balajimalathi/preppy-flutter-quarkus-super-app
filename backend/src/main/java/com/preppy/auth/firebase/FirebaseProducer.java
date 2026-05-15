package com.preppy.auth.firebase;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.inject.Produces;
import jakarta.inject.Singleton;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

@ApplicationScoped
public class FirebaseProducer {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Produces
    @Singleton
    FirebaseAuth firebaseAuth(final FirebaseConfig config) throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            final ServiceAccountMaterial material = loadServiceAccount(config.serviceAccountPath());
            final String projectId =
                    resolveProjectId(config.projectId().orElse(""), material.projectId());
            final FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(material.credentials())
                    .setProjectId(projectId)
                    .build();
            FirebaseApp.initializeApp(options);
        }
        return FirebaseAuth.getInstance();
    }

    /**
     * Uses {@code FIREBASE_PROJECT_ID} when set; otherwise the {@code project_id} from the service
     * account JSON (must match token {@code iss}/{@code aud}).
     */
    static String resolveProjectId(final String configuredProjectId, final String serviceAccountProjectId) {
        if (configuredProjectId != null && !configuredProjectId.isBlank()) {
            return configuredProjectId.trim();
        }
        return serviceAccountProjectId;
    }

    private ServiceAccountMaterial loadServiceAccount(final String path) throws IOException {
        if (path.startsWith("classpath:")) {
            final String resource = path.substring("classpath:".length());
            final String normalized = resource.startsWith("/") ? resource.substring(1) : resource;
            try (InputStream in = Thread.currentThread().getContextClassLoader().getResourceAsStream(normalized)) {
                if (in == null) {
                    throw new IOException("Firebase service account not found on classpath: " + normalized);
                }
                final byte[] bytes = in.readAllBytes();
                return parseServiceAccount(bytes);
            }
        }
        final Path file = Path.of(path);
        if (!Files.exists(file)) {
            throw new IOException("Firebase service account file not found: " + path);
        }
        return parseServiceAccount(Files.readAllBytes(file));
    }

    private ServiceAccountMaterial parseServiceAccount(final byte[] jsonBytes) throws IOException {
        final JsonNode root = MAPPER.readTree(jsonBytes);
        final JsonNode projectIdNode = root.get("project_id");
        if (projectIdNode == null || projectIdNode.asText().isBlank()) {
            throw new IOException("Firebase service account JSON is missing project_id");
        }
        final GoogleCredentials credentials =
                GoogleCredentials.fromStream(new java.io.ByteArrayInputStream(jsonBytes));
        return new ServiceAccountMaterial(credentials, projectIdNode.asText());
    }

    private record ServiceAccountMaterial(GoogleCredentials credentials, String projectId) {}
}
