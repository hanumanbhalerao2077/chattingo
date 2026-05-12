package com.chattingo.Controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.chattingo.Payload.ApiResponse;

@RestController
public class HomeController {

    @GetMapping("/")
    public ResponseEntity<?> home() {
        return ResponseEntity.ok(new ApiResponse("Welcome to Chattingo API", true));
    }

}
