package com.preppy.auth.firebase;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.inject.Produces;
import jakarta.inject.Singleton;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;

@ApplicationScoped
public class FirebaseProducer {

    @Produces
    @Singleton
    FirebaseAuth firebaseAuth(final FirebaseConfig config) throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            final GoogleCredentials credentials = loadCredentials(config.serviceAccountPath());
            final FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(credentials)
                    .setProjectId(config.projectId())
                    .build();
            FirebaseApp.initializeApp(options);
        }
        return FirebaseAuth.getInstance();
    }

    private GoogleCredentials loadCredentials(final String path) throws IOException {
        if (path.startsWith("classpath:")) {
            final String resource = path.substring("classpath:".length());
            try (InputStream in = Thread.currentThread()
                    .getContextClassLoader()
                    .getResourceAsStream(resource.startsWith("/") ? resource.substring(1) : resource)) {
                if (in == null) {
                    throw new IOException("Firebase service account not found on classpath: " + resource);
                }
                return GoogleCredentials.fromStream(in);
            }
        }
        final Path file = Path.of(path);
        if (!Files.exists(file)) {
            throw new IOException("Firebase service account file not found: " + path);
        }
        try (InputStream in = Files.newInputStream(file)) {
            return GoogleCredentials.fromStream(in);
        }
    }
}
