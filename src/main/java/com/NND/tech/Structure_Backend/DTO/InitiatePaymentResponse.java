package com.NND.tech.Structure_Backend.DTO;

public class InitiatePaymentResponse {
    private String reference;
    private String paymentLink;
    private String orderId;

    public InitiatePaymentResponse() {}
    public InitiatePaymentResponse(String reference, String paymentLink, String orderId) {
        this.reference = reference;
        this.paymentLink = paymentLink;
        this.orderId = orderId;
    }

    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }
    public String getPaymentLink() { return paymentLink; }
    public void setPaymentLink(String paymentLink) { this.paymentLink = paymentLink; }
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
}
