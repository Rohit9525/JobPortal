package com.job_portal.job_service.service;



import com.job_portal.job_service.dto.*;
import com.job_portal.job_service.entity.JobType;
import org.springframework.data.domain.Page;

import java.util.List;

public interface JobService {

    JobResponseDTO createJob(JobRequestDTO dto, Long recruiterId);

    List<JobResponseDTO> getJobsByRecruiter(Long recruiterId);

    List<JobResponseDTO> getAllJobs();

    JobResponseDTO getJobById(Long id);

    JobResponseDTO updateJob(Long id, JobRequestDTO dto);

    void deleteJob(Long id);


    Page<JobResponseDTO> searchJobs(
            String title,
            String location,
            Integer experience,
            JobType jobType,
            int page,
            int size
    );
}