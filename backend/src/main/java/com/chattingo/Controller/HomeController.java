package com.chattingo.Controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.chattingo.Payload.ApiResponse;
import com.chattingo.config.ApiVersionConfig;

@RestController
@RequestMapping(ApiVersionConfig.API_V1_PATH)
public class HomeController {

    @GetMapping("/")
    public ResponseEntity<?> home() {
        return ResponseEntity.ok(new ApiResponse("Welcome to Chattingo API " + ApiVersionConfig.CURRENT_VERSION, true));
    }

    @GetMapping("/version")
    public ResponseEntity<?> version() {
        return ResponseEntity.ok(new ApiResponse("API Version: " + ApiVersionConfig.CURRENT_VERSION, true));
    }

}
