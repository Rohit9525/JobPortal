package com.job_portal.job_service.dto;


import com.job_portal.job_service.entity.JobType;
import jakarta.validation.constraints.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class JobRequestDTO {

    @NotBlank(message = "Title is required")
    private String title;


    @NotBlank(message = "Description is required")
    private String description;

    @NotBlank(message = "Company name is required")
    private String companyName;

    @NotBlank(message = "Location is required")
    private String location;

    @NotNull(message = "Salary is required")
    private Double salary;

    @NotNull(message = "Experience is required")
    private Integer experience;

    @NotNull(message = "Job type is required")
    private JobType jobType;
}