-- ============================================
-- 数据库初始化脚本
-- 首次启动时会自动创建 scaffold_db 数据库和基础表
-- ============================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS scaffold_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE scaffold_db;

-- 用户表（示例）
CREATE TABLE IF NOT EXISTS `user` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username`    VARCHAR(50)  NOT NULL                COMMENT '用户名',
    `password`    VARCHAR(100) NOT NULL                COMMENT '密码',
    `email`       VARCHAR(100)                         COMMENT '邮箱',
    `phone`       VARCHAR(20)                          COMMENT '手机号',
    `status`      TINYINT      DEFAULT 1               COMMENT '状态: 1-正常 0-禁用',
    `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 插入一条测试数据
INSERT INTO `user` (`username`, `password`, `email`)
VALUES ('admin', '123456', 'admin@scaffold.com')
ON DUPLICATE KEY UPDATE `username` = `username`;
