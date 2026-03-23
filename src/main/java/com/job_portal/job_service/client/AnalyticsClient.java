package com.job_portal.job_service.client;

//public class AnalyticsClient {
//}
//
//package com.job_portal.job_service.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;

@FeignClient(name = "ANALYTICS-SERVICE")
public interface AnalyticsClient {

    @PostMapping("/api/analytics/job-created")
    void jobCreated();

    @PostMapping("/api/analytics/recruiter-activity")
    void recruiterActivity();
}