package com.scaffold.demo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 示例 API 控制器
 * 提供欢迎接口，用于验证前后端联通和数据库连接状态
 */
@RestController
@RequestMapping("/api")
public class HelloController {

    @Autowired(required = false)
    private DataSource dataSource;

    /**
     * 欢迎接口 - 返回服务状态和数据库连接信息
     */
    @GetMapping("/hello")
    public Map<String, Object> hello() {
        Map<String, Object> result = new HashMap<>();
        result.put("message", "欢迎使用 AI 项目脚手架！");
        result.put("backend", "Spring Boot 3.x 运行正常");
        result.put("serverTime", LocalDateTime.now().toString());
        result.put("database", checkDatabase());
        return result;
    }

    /**
     * 检测数据库连接状态
     */
    private String checkDatabase() {
        if (dataSource == null) {
            return "未配置数据源（请检查 application.yml 中的数据库配置）";
        }
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT NOW()")) {
            if (rs.next()) {
                return "连接成功 - 数据库时间: " + rs.getString(1);
            }
            return "连接成功";
        } catch (Exception e) {
            return "连接失败: " + e.getMessage();
        }
    }
}
