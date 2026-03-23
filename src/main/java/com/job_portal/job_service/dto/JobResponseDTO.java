package com.job_portal.job_service.dto;

import com.job_portal.job_service.entity.JobType;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class JobResponseDTO {

    private Long id;
    private String title;
    private String description;
    private String companyName;
    private String location;
    private Double salary;
    private Integer experience;
    private JobType jobType;
    private Long recruiterId;
}