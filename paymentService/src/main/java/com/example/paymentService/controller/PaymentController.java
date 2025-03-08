package com.example.paymentService.controller;

import com.example.paymentService.model.Payment;
import com.example.paymentService.service.PaymentService;
import com.stripe.exception.StripeException;
import com.stripe.model.PaymentIntent;
import com.stripe.model.Transfer;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/create-payment-intent")
    public ResponseEntity<Map<String, String>> createPaymentIntent(
            @RequestParam BigDecimal amount,
            @RequestParam String senderId,
            @RequestParam String receiverId,
            @RequestParam String description) throws StripeException {
        
        PaymentIntent paymentIntent = paymentService.createPaymentIntent(amount, senderId, receiverId, description);
        return ResponseEntity.ok(Map.of(
            "clientSecret", paymentIntent.getClientSecret(),
            "paymentIntentId", paymentIntent.getId()
        ));
    }

    @PostMapping("/confirm/{paymentIntentId}")
    public ResponseEntity<Payment> confirmPayment(
            @PathVariable String paymentIntentId) throws StripeException {
        Payment payment = paymentService.confirmPayment(paymentIntentId);
        return ResponseEntity.ok(payment);
    }

    @PostMapping("/transfer")
    public ResponseEntity<Transfer> transferToReceiver(
            @RequestParam String paymentIntentId,
            @RequestParam String receiverStripeAccountId) throws StripeException {
        Transfer transfer = paymentService.transferToReceiver(paymentIntentId, receiverStripeAccountId);
        return ResponseEntity.ok(transfer);
    }
} 