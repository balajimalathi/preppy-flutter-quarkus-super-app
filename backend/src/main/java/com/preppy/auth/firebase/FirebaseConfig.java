package com.preppy.auth.firebase;

import io.smallrye.config.ConfigMapping;
import io.smallrye.config.WithDefault;
import io.smallrye.config.WithName;
import java.util.Optional;

@ConfigMapping(prefix = "firebase")
public interface FirebaseConfig {

    /** Optional override; when unset, project_id is read from the service account JSON. */
    @WithName("project-id")
    Optional<String> projectId();

    @WithName("service-account.path")
    @WithDefault("classpath:firebase/service-account.json")
    String serviceAccountPath();
}
