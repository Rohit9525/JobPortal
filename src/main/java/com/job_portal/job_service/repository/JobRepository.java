package com.job_portal.job_service.repository;


import com.job_portal.job_service.entity.Job;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;

public interface JobRepository extends JpaRepository<Job, Long>, JpaSpecificationExecutor<Job> {

    List<Job> findByIsDeletedFalse();
    List<Job> findByRecruiterIdAndIsDeletedFalse(Long recruiterId);
}
