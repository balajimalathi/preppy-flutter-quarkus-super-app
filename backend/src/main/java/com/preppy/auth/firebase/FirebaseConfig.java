package com.preppy.auth.firebase;

import io.smallrye.config.ConfigMapping;
import io.smallrye.config.WithDefault;
import io.smallrye.config.WithName;

@ConfigMapping(prefix = "firebase")
public interface FirebaseConfig {

    @WithName("project-id")
    @WithDefault("preppy-dev")
    String projectId();

    @WithName("service-account.path")
    @WithDefault("classpath:firebase/service-account.json")
    String serviceAccountPath();
}
