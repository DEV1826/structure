package com.NND.tech.Structure_Backend.DTO;

public class CampostWebhookEvent {
    private String event;
    private String reference;
    private String orderId;
    private Long amount;
    private String currency;
    private String status;
    private String timestamp;

    public String getEvent() { return event; }
    public void setEvent(String event) { this.event = event; }
    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public Long getAmount() { return amount; }
    public void setAmount(Long amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getTimestamp() { return timestamp; }
    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }
}
