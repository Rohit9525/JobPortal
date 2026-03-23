package com.job_portal.job_service.dto;

//public class JobSearchRequest {
//}
//
//package com.job_portal.job_service.dto;

import lombok.Data;

@Data
public class JobSearchRequest {

    private Long jobId;
    private String title;
    private String company;
    private String location;
}