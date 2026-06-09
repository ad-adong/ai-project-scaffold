-- ============================================
-- H2 初始化脚本（默认，内存数据库）
-- ============================================

CREATE TABLE IF NOT EXISTS `user` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT,
    `username`    VARCHAR(50)  NOT NULL,
    `password`    VARCHAR(100) NOT NULL,
    `email`       VARCHAR(100),
    `phone`       VARCHAR(20),
    `status`      TINYINT      DEFAULT 1,
    `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
);

-- 插入测试数据（H2 不支持 ON DUPLICATE KEY，用 MERGE INTO）
MERGE INTO `user` (`username`, `password`, `email`, `phone`, `status`)
    KEY (`username`)
    VALUES ('admin', '123456', 'admin@scaffold.com', '13800138000', 1);
