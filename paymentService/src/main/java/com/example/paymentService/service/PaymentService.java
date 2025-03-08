package com.example.paymentService.service;

import com.example.paymentService.model.Payment;
import com.example.paymentService.model.PaymentStatus;
import com.stripe.exception.StripeException;
import com.stripe.model.PaymentIntent;
import com.stripe.model.Transfer;
import com.stripe.param.PaymentIntentCreateParams;
import com.stripe.param.TransferCreateParams;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
@Slf4j
@RequiredArgsConstructor
public class PaymentService {

    private static final String DEFAULT_CURRENCY = "eur";
    
    public PaymentIntent createPaymentIntent(BigDecimal amount, String senderId, String receiverId, String description) throws StripeException {
        long amountInCents = amount.multiply(new BigDecimal(100)).longValue();
        
        PaymentIntentCreateParams params = PaymentIntentCreateParams.builder()
            .setAmount(amountInCents)
            .setCurrency(DEFAULT_CURRENCY)
            .setDescription(description)
            .putMetadata("sender_id", senderId)
            .putMetadata("receiver_id", receiverId)
            .setAutomaticPaymentMethods(
                PaymentIntentCreateParams.AutomaticPaymentMethods.builder()
                    .setEnabled(true)
                    .build()
            )
            .build();
            
        return PaymentIntent.create(params);
    }
    
    public Transfer transferToReceiver(String paymentIntentId, String receiverStripeAccountId) throws StripeException {
        PaymentIntent paymentIntent = PaymentIntent.retrieve(paymentIntentId);
        
        // Transferir el 90% al receptor (10% de comisión para la plataforma)
        long transferAmount = (long) (paymentIntent.getAmount() * 0.9);
        
        TransferCreateParams params = TransferCreateParams.builder()
            .setAmount(transferAmount)
            .setCurrency(DEFAULT_CURRENCY)
            .setDestination(receiverStripeAccountId)
            .setSourceTransaction(paymentIntentId)
            .build();
            
        return Transfer.create(params);
    }
    
    public Payment confirmPayment(String paymentIntentId) throws StripeException {
        PaymentIntent paymentIntent = PaymentIntent.retrieve(paymentIntentId);
        
        if ("succeeded".equals(paymentIntent.getStatus())) {
            return Payment.builder()
                .stripePaymentId(paymentIntentId)
                .senderId(paymentIntent.getMetadata().get("sender_id"))
                .receiverId(paymentIntent.getMetadata().get("receiver_id"))
                .amount(new BigDecimal(paymentIntent.getAmount()).divide(new BigDecimal(100)))
                .currency(paymentIntent.getCurrency())
                .status(PaymentStatus.COMPLETED)
                .description(paymentIntent.getDescription())
                .build();
        } else {
            throw new StripeException("Payment failed", null, null, 0) {};
        }
    }
}