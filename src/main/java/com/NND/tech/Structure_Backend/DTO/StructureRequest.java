package com.NND.tech.Structure_Backend.DTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
public class StructureRequest {
    private String name;
    private String email;
    private String description;
    private String address;
    private String imageUrl;
    private String phone;


    public StructureRequest() {
    }

    public StructureRequest(String name, String email, String description, String address, String imageUrl, String phone) {
        this.name = name;
        this.email = email;
        this.description = description;
        this.address = address;
        this.imageUrl = imageUrl;
        this.phone = phone;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
}