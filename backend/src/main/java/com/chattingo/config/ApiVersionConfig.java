package com.chattingo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class ApiVersionConfig implements WebMvcConfigurer {

    // API Versioning Configuration
    // Current API version: v1
    // Base path: /api/v1
    //
    // Future versions can be added as:
    // - /api/v2 for breaking changes
    // - /api/v1.x for backward compatible changes
    //
    // Version headers can be added for content negotiation:
    // Accept: application/vnd.chattingo.v1+json

    public static final String API_V1_PATH = "/api/v1";
    public static final String API_VERSION_HEADER = "X-API-Version";
    public static final String CURRENT_VERSION = "v1";

    // Migration notes:
    // - When creating v2, copy controllers to Controller/v2/
    // - Update request mappings to use /api/v2
    // - Add version-specific features in v2 controllers
    // - Keep v1 controllers for backward compatibility
}