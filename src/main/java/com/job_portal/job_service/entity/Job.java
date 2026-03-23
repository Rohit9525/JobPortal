package com.job_portal.job_service.entity;
import jakarta.persistence.*;
import lombok.*;

@Entity
//@Table(name = "jobs")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Job {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(length = 2000)
    private String description;
    @Column(nullable = false)
    private String companyName;

    @Column(nullable = false)
    private String location;

    private Double salary;

    private Integer experience;

    @Enumerated(EnumType.STRING)
    private JobType jobType;

    @Column(nullable = false)
    private Long recruiterId;
    @Builder.Default
    private boolean isDeleted = false;
}