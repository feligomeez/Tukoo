package com.example.paymentService.controller;

import com.example.paymentService.service.PaymentService;
import com.stripe.model.Event;
import com.stripe.model.EventDataObjectDeserializer;
import com.stripe.model.PaymentIntent;
import com.stripe.model.StripeObject;
import com.stripe.net.Webhook;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/webhook")
@RequiredArgsConstructor
@Slf4j
public class StripeWebhookController {

    @Value("${stripe.api.webhook-secret}")
    private String webhookSecret;

    private final PaymentService paymentService;

    @PostMapping("/stripe")
    public ResponseEntity<String> handleStripeWebhook(@RequestBody String payload, @RequestHeader("Stripe-Signature") String sigHeader) {
        try {
            Event event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
            EventDataObjectDeserializer dataObjectDeserializer = event.getDataObjectDeserializer();
            StripeObject stripeObject = null;
            
            if (dataObjectDeserializer.getObject().isPresent()) {
                stripeObject = dataObjectDeserializer.getObject().get();
            }

            switch (event.getType()) {
                case "payment_intent.succeeded":
                    PaymentIntent paymentIntent = (PaymentIntent) stripeObject;
                    log.info("Payment succeeded for PaymentIntent: " + paymentIntent.getId());
                    paymentService.confirmPayment(paymentIntent.getId());
                    break;
                    
                case "payment_intent.payment_failed":
                    paymentIntent = (PaymentIntent) stripeObject;
                    log.error("Payment failed for PaymentIntent: " + paymentIntent.getId());
                    // Aquí podrías implementar la lógica para manejar pagos fallidos
                    break;
                    
                case "payment_intent.canceled":
                    paymentIntent = (PaymentIntent) stripeObject;
                    log.info("Payment canceled for PaymentIntent: " + paymentIntent.getId());
                    // Implementar lógica para pagos cancelados
                    break;
                    
                case "transfer.created":
                    log.info("Transfer created: " + event.getId());
                    // Confirmar que la transferencia al vendedor se realizó
                    break;
                    
                case "transfer.failed":
                    log.error("Transfer failed: " + event.getId());
                    // Manejar el fallo en la transferencia al vendedor
                    break;
                    
                case "charge.dispute.created":
                    log.warn("Dispute created: " + event.getId());
                    // Manejar disputas o reclamaciones
                    break;
                    
                case "charge.refunded":
                    log.info("Charge refunded: " + event.getId());
                    // Manejar reembolsos
                    break;
                    
                default:
                    log.info("Unhandled event type: " + event.getType());
            }

            return ResponseEntity.ok().body("Webhook processed successfully");
        } catch (Exception e) {
            log.error("Error processing webhook: " + e.getMessage(), e);
            return ResponseEntity.badRequest().body("Webhook processing failed");
        }
    }
} 