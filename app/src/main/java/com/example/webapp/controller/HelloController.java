package com.example.webapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * HelloController - Handles HTTP requests for the web application.
 * 
 * This controller is mapped to the root path and provides the main
 * page that displays "hello from Java" message.
 */
@Controller
@RequestMapping("/")
public class HelloController {

    /**
     * Home page endpoint.
     * 
     * @return the name of the template to render (index.html)
     */
    @GetMapping
    public String home() {
        return "index";
    }
}
