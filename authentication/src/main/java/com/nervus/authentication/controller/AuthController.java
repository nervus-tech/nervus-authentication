package com.nervus.authentication.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AuthController {
    @GetMapping("/test")
    public String test() {
        return "Authentication Service is running";
    }
}