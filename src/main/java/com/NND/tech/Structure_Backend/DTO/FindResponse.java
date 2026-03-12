package com.NND.tech.Structure_Backend.DTO;

import java.util.List;

public class FindResponse {
    public static class Customer {
        private String firstName;
        private String lastName;
        private String phoneNumber;
        private String email;
        public String getFirstName() { return firstName; }
        public void setFirstName(String firstName) { this.firstName = firstName; }
        public String getLastName() { return lastName; }
        public void setLastName(String lastName) { this.lastName = lastName; }
        public String getPhoneNumber() { return phoneNumber; }
        public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
    }
    public static class TransactionItem {
        private String reason;
        private String orderId;
        private String operatorReference;
        private String operator;
        private String reference;
        private String type;
        private String currency;
        private Long amount;
        private Long fees;
        private String status;
        private String message;
        private Customer customer;
        public String getReason() { return reason; }
        public void setReason(String reason) { this.reason = reason; }
        public String getOrderId() { return orderId; }
        public void setOrderId(String orderId) { this.orderId = orderId; }
        public String getOperatorReference() { return operatorReference; }
        public void setOperatorReference(String operatorReference) { this.operatorReference = operatorReference; }
        public String getOperator() { return operator; }
        public void setOperator(String operator) { this.operator = operator; }
        public String getReference() { return reference; }
        public void setReference(String reference) { this.reference = reference; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getCurrency() { return currency; }
        public void setCurrency(String currency) { this.currency = currency; }
        public Long getAmount() { return amount; }
        public void setAmount(Long amount) { this.amount = amount; }
        public Long getFees() { return fees; }
        public void setFees(Long fees) { this.fees = fees; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public Customer getCustomer() { return customer; }
        public void setCustomer(Customer customer) { this.customer = customer; }
    }
    private List<TransactionItem> transactions;
    public List<TransactionItem> getTransactions() { return transactions; }
    public void setTransactions(List<TransactionItem> transactions) { this.transactions = transactions; }
}
