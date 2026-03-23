package com.job_portal.job_service.client;

//package com.job_portal.job_service.client;

import com.job_portal.job_service.dto.JobSearchRequest;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "SEARCH-SERVICE")
public interface SearchClient {

    @PostMapping("/api/search/add")
    void addJob(@RequestBody JobSearchRequest request);
}
