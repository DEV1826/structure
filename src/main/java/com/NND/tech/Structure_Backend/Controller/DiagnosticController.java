package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.Repository.UserRepository;
import com.NND.tech.Structure_Backend.model.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/auth/diagnostic")
@RequiredArgsConstructor
public class DiagnosticController {

    private final UserRepository userRepository;

    @GetMapping("/users")
    public Map<String, Object> checkUsers() {
        Map<String, Object> stats = new HashMap<>();
        try {
            long count = userRepository.count();
            stats.put("total_users", count);

            List<User> allUsers = userRepository.findAll();
            List<String> userEmails = allUsers.stream()
                    .map(User::getEmail)
                    .collect(Collectors.toList());
            
            stats.put("emails", userEmails);
            stats.put("status", "success");
        } catch (Exception e) {
            stats.put("status", "error");
            stats.put("message", e.getMessage());
        }
        return stats;
    }
}
