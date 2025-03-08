package com.example.paymentService.config;

import com.stripe.Stripe;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;

@Configuration
public class StripeConfig {
    
    @Value("${stripe.api.key}")
    private String secretKey;
    
    @PostConstruct
    public void initStripe() {
        Stripe.apiKey = secretKey;
    }
} 