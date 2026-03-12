package com.NND.tech.Structure_Backend.Controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "Bienvenue sur Structure Backend API ! Accédez à /api/health pour vérifier l'état ou /swagger-ui.html pour la documentation.";
    }
}