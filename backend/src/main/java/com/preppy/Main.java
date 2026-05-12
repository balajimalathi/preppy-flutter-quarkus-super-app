package com.preppy;

import io.quarkus.runtime.Quarkus;
import io.quarkus.runtime.annotations.QuarkusMain;

/**
 * Entry point for the Preppy Quarkus monolith.
 * <p>
 * In dev mode use {@code ./mvnw quarkus:dev}. The {@link QuarkusMain} annotation
 * lets us still produce a runnable JAR for prod and tests.
 */
@QuarkusMain
public class Main {

    public static void main(final String... args) {
        Quarkus.run(args);
    }
}
