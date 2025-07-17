package com.NND.tech.Structure_Backend.DTO;

public class AuthenticationResponse {

    private String token;
    private String type;
    private String email;
    private String role;
    private Long expiresIn;

    // Constructeur par défaut
    public AuthenticationResponse() {
        this.type = "Bearer";
    }

    // Constructeur avec token uniquement (pour compatibilité)
    public AuthenticationResponse(String token) {
        this.token = token;
        this.type = "Bearer";
        this.email = "";
        this.role = "";
        this.expiresIn = 3600L;
    }

    // Constructeur complet
    public AuthenticationResponse(String token, String email, String role, Long expiresIn) {
        this.token = token;
        this.type = "Bearer";
        this.email = email;
        this.role = role;
        this.expiresIn = expiresIn;
    }

    // Getters
    public String getToken() {
        return token;
    }

    public String getType() {
        return type;
    }

    public String getEmail() {
        return email;
    }

    public String getRole() {
        return role;
    }

    public Long getExpiresIn() {
        return expiresIn;
    }

    // Setters
    public void setToken(String token) {
        this.token = token;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setExpiresIn(Long expiresIn) {
        this.expiresIn = expiresIn;
    }

    // toString
    @Override
    public String toString() {
        return "AuthenticationResponse{" +
                "token='" + (token != null ? token.substring(0, Math.min(token.length(), 10)) + "..." : "null") + '\'' +
                ", type='" + type + '\'' +
                ", email='" + email + '\'' +
                ", role='" + role + '\'' +
                ", expiresIn=" + expiresIn +
                '}';
    }

    // equals
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        AuthenticationResponse that = (AuthenticationResponse) o;

        if (token != null ? !token.equals(that.token) : that.token != null) return false;
        if (type != null ? !type.equals(that.type) : that.type != null) return false;
        if (email != null ? !email.equals(that.email) : that.email != null) return false;
        if (role != null ? !role.equals(that.role) : that.role != null) return false;
        return expiresIn != null ? expiresIn.equals(that.expiresIn) : that.expiresIn == null;
    }

    // hashCode
    @Override
    public int hashCode() {
        int result = token != null ? token.hashCode() : 0;
        result = 31 * result + (type != null ? type.hashCode() : 0);
        result = 31 * result + (email != null ? email.hashCode() : 0);
        result = 31 * result + (role != null ? role.hashCode() : 0);
        result = 31 * result + (expiresIn != null ? expiresIn.hashCode() : 0);
        return result;
    }
}
