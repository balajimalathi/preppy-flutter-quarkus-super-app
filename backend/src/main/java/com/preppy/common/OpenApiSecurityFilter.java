package com.preppy.common;

import io.quarkus.arc.Unremovable;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;
import java.util.Set;
import org.eclipse.microprofile.openapi.OASFilter;
import org.eclipse.microprofile.openapi.OASFactory;
import org.eclipse.microprofile.openapi.models.Components;
import org.eclipse.microprofile.openapi.models.OpenAPI;
import org.eclipse.microprofile.openapi.models.Operation;
import org.eclipse.microprofile.openapi.models.Paths;
import org.eclipse.microprofile.openapi.models.security.SecurityRequirement;
import org.eclipse.microprofile.openapi.models.security.SecurityScheme;

/**
 * Registers the Bearer security scheme and attaches it to protected operations so Swagger UI
 * shows the Authorize control.
 */
@ApplicationScoped
@Unremovable
public class OpenApiSecurityFilter implements OASFilter {

    private static final String BEARER_AUTH = "bearerAuth";

    private static final Set<String> PUBLIC_PATHS = Set.of("/health", "/metrics");

    @Override
    public void filterOpenAPI(final OpenAPI openAPI) {
        final SecurityRequirement bearer =
                OASFactory.createSecurityRequirement().addScheme(BEARER_AUTH);
        final List<SecurityRequirement> security = List.of(bearer);

        registerBearerScheme(openAPI);
        openAPI.setSecurity(security);

        final Paths paths = openAPI.getPaths();
        if (paths == null) {
            return;
        }

        paths.getPathItems().forEach((path, pathItem) -> {
            if (isPublicPath(path)) {
                return;
            }
            applySecurity(pathItem.getGET(), security);
            applySecurity(pathItem.getPUT(), security);
            applySecurity(pathItem.getPOST(), security);
            applySecurity(pathItem.getDELETE(), security);
            applySecurity(pathItem.getPATCH(), security);
            applySecurity(pathItem.getHEAD(), security);
            applySecurity(pathItem.getOPTIONS(), security);
            applySecurity(pathItem.getTRACE(), security);
        });
    }

    private static void registerBearerScheme(final OpenAPI openAPI) {
        Components components = openAPI.getComponents();
        if (components == null) {
            components = OASFactory.createComponents();
            openAPI.setComponents(components);
        }
        if (components.getSecuritySchemes() != null
                && components.getSecuritySchemes().containsKey(BEARER_AUTH)) {
            return;
        }
        final SecurityScheme scheme = OASFactory.createSecurityScheme();
        scheme.setType(SecurityScheme.Type.HTTP);
        scheme.setScheme("bearer");
        scheme.setBearerFormat("JWT");
        scheme.setDescription(
                "Firebase ID token. Dev: run `node backend/scripts/mint-firebase-id-token.mjs`");
        components.addSecurityScheme(BEARER_AUTH, scheme);
    }

    private static void applySecurity(final Operation operation, final List<SecurityRequirement> security) {
        if (operation != null) {
            operation.setSecurity(security);
        }
    }

    private static boolean isPublicPath(final String path) {
        if (PUBLIC_PATHS.contains(path)) {
            return true;
        }
        return path.startsWith("/q/");
    }
}
