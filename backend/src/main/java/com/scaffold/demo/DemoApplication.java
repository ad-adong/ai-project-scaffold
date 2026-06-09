package com.scaffold.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
        System.out.println("========================================");
        System.out.println("  后端服务启动成功！");
        System.out.println("  API 地址: http://localhost:8080");
        System.out.println("========================================");
    }
}
