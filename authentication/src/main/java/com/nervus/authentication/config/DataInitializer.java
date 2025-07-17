package com.nervus.authentication.config;

import com.nervus.authentication.model.User;
import com.nervus.authentication.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {
    private final UserRepository userRepository;

    public DataInitializer(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        // Check if data already exists to avoid duplication
        if (userRepository.count() == 0) {
            // Seed sample users
            User user1 = new User("raphael", "raphael@example.com", "hashedpassword1");
            User user2 = new User("admin", "admin@example.com", "hashedpassword2");
            userRepository.save(user1);
            userRepository.save(user2);
            System.out.println("Seeded 2 users into auth.users");
        } else {
            System.out.println("Users already seeded, skipping...");
        }
    }
}
