package com.NND.tech.Structure_Backend.entities;

import jakarta.persistence.*;

import java.io.Serializable;

@Entity
@Table(name = "roles")
public class Role implements Serializable{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //stoke le nom de l'enum dans la base
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, unique = true)
    private RoleType nom;

    public Role() {

    }

    public Role(RoleType nom) {
        this.nom = nom;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public RoleType getNom() {
        return nom;
    }

    public void setNom(RoleType nom) {
        this.nom = nom;
    }
}