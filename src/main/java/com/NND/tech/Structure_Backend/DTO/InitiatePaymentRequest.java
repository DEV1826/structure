package com.NND.tech.Structure_Backend.DTO;

import jakarta.validation.constraints.*;

public class InitiatePaymentRequest {
    @NotNull
    private Long structureId;
    @NotNull
    private Long serviceId;
    @NotNull
    @Positive
    private Long amount; // in XAF minor units if applicable (here integer XAF)
    @NotBlank
    private String currency; // XAF or EUR
    @NotBlank
    private String reason;
    private String orderId;

    @NotNull
    private Customer customer;

    public static class Customer {
        @NotBlank
        private String firstName;
        @NotBlank
        private String lastName;
        @NotBlank
        private String phoneNumber; // 69XXXXXXX
        @Email
        @NotBlank
        private String email;
        @NotBlank
        private String language; // fr or en

        public String getFirstName() { return firstName; }
        public void setFirstName(String firstName) { this.firstName = firstName; }
        public String getLastName() { return lastName; }
        public void setLastName(String lastName) { this.lastName = lastName; }
        public String getPhoneNumber() { return phoneNumber; }
        public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getLanguage() { return language; }
        public void setLanguage(String language) { this.language = language; }
    }

    public Long getStructureId() { return structureId; }
    public void setStructureId(Long structureId) { this.structureId = structureId; }
    public Long getServiceId() { return serviceId; }
    public void setServiceId(Long serviceId) { this.serviceId = serviceId; }
    public Long getAmount() { return amount; }
    public void setAmount(Long amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public Customer getCustomer() { return customer; }
    public void setCustomer(Customer customer) { this.customer = customer; }
}
