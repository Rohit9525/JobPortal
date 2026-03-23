package com.job_portal.job_service.service.impl;



import com.job_portal.job_service.client.AnalyticsClient;
import com.job_portal.job_service.client.SearchClient;
import com.job_portal.job_service.dto.JobRequestDTO;
import com.job_portal.job_service.dto.JobResponseDTO;
import com.job_portal.job_service.dto.JobSearchRequest;
import com.job_portal.job_service.entity.Job;
import com.job_portal.job_service.entity.JobType;
import com.job_portal.job_service.exception.ResourceNotFoundException;
import com.job_portal.job_service.repository.JobRepository;
import com.job_portal.job_service.service.JobService;
import com.job_portal.job_service.specification.JobSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class JobServiceImpl implements JobService {

    private final JobRepository repo;
    private final SearchClient searchClient;
    private final AnalyticsClient analyticsClient;
    // ✅ CREATE
    @Override
    public JobResponseDTO createJob(JobRequestDTO dto, Long recruiterId) {

        Job job = Job.builder()
                .title(dto.getTitle())
                .description(dto.getDescription())
                .companyName(dto.getCompanyName())
                .location(dto.getLocation())
                .salary(dto.getSalary())
                .experience(dto.getExperience())
                .jobType(dto.getJobType())
                .recruiterId(recruiterId) // 🔥 IMPORTANT
                .isDeleted(false)
                .build();

        Job savedJob = repo.save(job);

        // 🔥 CALL ANALYTICS
        analyticsClient.jobCreated();
        analyticsClient.recruiterActivity();

        // 🔥 CALL SEARCH SERVICE
        JobSearchRequest searchReq = new JobSearchRequest();
        searchReq.setJobId(savedJob.getId());
        searchReq.setTitle(savedJob.getTitle());
        searchReq.setCompany(savedJob.getCompanyName());
        searchReq.setLocation(savedJob.getLocation());

        searchClient.addJob(searchReq);

        return mapToDTO(savedJob);
    }

    // ✅ GET ALL (exclude deleted)
    @Override
    public List<JobResponseDTO> getAllJobs() {
        return repo.findByIsDeletedFalse()
                .stream()
                .map(this::mapToDTO)
                .toList();
    }

    // ✅ GET BY ID
    @Override
    public JobResponseDTO getJobById(Long id) {

        Job job = repo.findById(id)
                .filter(j -> !j.isDeleted())
                .orElseThrow(() ->
                        new ResourceNotFoundException("Job not found with id: " + id));

        return mapToDTO(job);
    }

    // ✅ UPDATE
    @Override
    public JobResponseDTO updateJob(Long id, JobRequestDTO dto) {

        Job job = repo.findById(id)
                .filter(j -> !j.isDeleted())
                .orElseThrow(() ->
                        new ResourceNotFoundException("Job not found with id: " + id));

        analyticsClient.recruiterActivity();

        job.setTitle(dto.getTitle());
        job.setDescription(dto.getDescription()); // ✅ FIXED
        job.setCompanyName(dto.getCompanyName());
        job.setLocation(dto.getLocation());
        job.setSalary(dto.getSalary());
        job.setExperience(dto.getExperience());
        job.setJobType(dto.getJobType());

        return mapToDTO(repo.save(job));
    }

    // ✅ SOFT DELETE
    @Override
    public void deleteJob(Long id) {

        Job job = repo.findById(id)
                .filter(j -> !j.isDeleted())
                .orElseThrow(() ->
                        new ResourceNotFoundException("Job not found with id: " + id));

        job.setDeleted(true); // soft delete
        repo.save(job);
        analyticsClient.recruiterActivity();
    }

    @Override
    public Page<JobResponseDTO> searchJobs(
            String title,
            String location,
            Integer experience,
            JobType jobType,
            int page,
            int size) {

        Specification<Job> spec = Specification.allOf(
                JobSpecification.notDeleted(),
                JobSpecification.hasTitle(title),
                JobSpecification.hasLocation(location),
                JobSpecification.hasExperience(experience),
                JobSpecification.hasJobType(jobType)
        );

        Pageable pageable = PageRequest.of(page, size);

        return repo.findAll(spec, pageable)
                .map(this::mapToDTO);
    }
    // ✅ MAPPER (FIXED - DESCRIPTION ADDED 🔥)
    private JobResponseDTO mapToDTO(Job job) {

        return JobResponseDTO.builder()
                .id(job.getId())
                .title(job.getTitle())
                .description(job.getDescription())
                .companyName(job.getCompanyName())
                .location(job.getLocation())
                .salary(job.getSalary())
                .experience(job.getExperience())
                .jobType(job.getJobType())
                .recruiterId(job.getRecruiterId()) // 🔥 ADD THIS
                .build();
    }

    @Override
    public List<JobResponseDTO> getJobsByRecruiter(Long recruiterId) {

        return repo.findByRecruiterIdAndIsDeletedFalse(recruiterId)
                .stream()
                .map(this::mapToDTO)
                .toList();
    }
}