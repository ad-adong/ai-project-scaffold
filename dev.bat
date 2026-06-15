@echo off
REM ============================================
REM AI 项目脚手架 - 开发环境管理脚本 (Windows)
REM
REM 用法:
REM   dev.bat start   启动所有服务
REM   dev.bat stop    停止所有服务
REM
REM 配置:
REM   编辑此文件修改 DB_MODE
REM   DB_MODE=h2      使用 H2 内存数据库（默认，无需安装）
REM   DB_MODE=mysql   使用本地 MySQL
REM ============================================

setlocal enabledelayedexpansion

REM ==================== 配置区 ====================
REM 数据库模式: h2（默认） | mysql
set DB_MODE=h2
REM =================================================

set SCRIPT_DIR=%~dp0
set BACKEND_DIR=%SCRIPT_DIR%backend
set FRONTEND_DIR=%SCRIPT_DIR%frontend

if "%1"=="start" goto :cmd_start
if "%1"=="stop" goto :cmd_stop

echo AI 项目脚手架 - 开发环境管理 (Windows)
echo.
echo 用法:  dev.bat ^<命令^>
echo.
echo 命令:
echo   start    启动所有服务（当前数据库模式: %DB_MODE%）
echo   stop     停止所有服务
echo.
echo 配置（编辑 dev.bat 顶部）:
echo   DB_MODE=h2      默认，H2 内存数据库，无需安装
echo   DB_MODE=mysql   使用本地 MySQL
echo.
echo 示例:
echo   dev.bat start
echo   dev.bat stop
goto :end

REM ===========================================
REM 工具函数
REM ===========================================

REM 根据端口号杀掉进程
:kill_by_port
set PORT=%1
set NAME=%~2
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":!PORT! " ^| findstr "LISTENING"') do (
    taskkill /PID %%a /F >nul 2>&1
    echo   [OK] %NAME% 已停止
    goto :eof
)
echo   [WARN] %NAME% 未在运行
goto :eof

REM 检查端口是否被占用
:port_in_use
set PORT=%1
netstat -ano | findstr ":!PORT! " | findstr "LISTENING" >nul 2>&1
exit /b %ERRORLEVEL%

REM ===========================================
REM start - 启动所有服务
REM ===========================================
:cmd_start
set MYSQL_NEEDED=false
if /i "%DB_MODE%"=="mysql" set MYSQL_NEEDED=true

echo ========================================
echo   启动开发环境
echo   数据库: %DB_MODE%
echo ========================================
echo.

REM [0/5] 清理残留端口
echo [0/5] 清理残留进程...
call :kill_by_port 8080 "后端 (8080)"
call :kill_by_port 3000 "前端 (3000)"
echo.

REM [1/5] 环境检测
echo [1/5] 检测运行环境...

where java >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [ERROR] 未检测到 Java，请安装 JDK 17+
    echo           一键安装: setup.bat install
    exit /b 1
)
for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do echo   [OK] Java: %%i

where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [ERROR] 未检测到 Node.js，请安装 Node.js 18+
    echo           一键安装: setup.bat install
    exit /b 1
)
for /f %%i in ('node --version') do echo   [OK] Node.js: %%i
echo.

REM [2/5] 数据库
if "%MYSQL_NEEDED%"=="true" (
    echo [2/5] 启动 MySQL...
    REM 尝试启动 MySQL 服务
    sc query MySQL80 >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        sc start MySQL80 >nul 2>&1
    ) else (
        sc query MySQL >nul 2>&1
        if %ERRORLEVEL% EQU 0 (
            sc start MySQL >nul 2>&1
        ) else (
            echo   [WARN] 未检测到 MySQL 服务，请手动启动
        )
    )
) else (
    echo [2/5] 数据库: H2 内存数据库（无需额外服务）
)
echo.

REM [3/5] 前端依赖
echo [3/5] 检查前端依赖...
cd /d "%FRONTEND_DIR%"
if not exist "node_modules" (
    echo   正在安装前端依赖...
    call npm install
    echo   [OK] 前端依赖安装完成
) else (
    echo   [OK] 前端依赖已存在
)
cd /d "%SCRIPT_DIR%"
echo.

REM [4/5] 启动后端
echo [4/5] 启动后端服务...
cd /d "%BACKEND_DIR%"

set MVN_CMD=mvnw.cmd spring-boot:run -q
if "%MYSQL_NEEDED%"=="true" (
    set MVN_CMD=set SPRING_PROFILES_ACTIVE=mysql ^&^& !MVN_CMD!
)

REM 新窗口启动后端
start "AI-Scaffold Backend" cmd /c "!MVN_CMD!"
echo   后端已在独立窗口启动

cd /d "%SCRIPT_DIR%"

echo   等待后端就绪...

REM 等待后端就绪（最多 4 分钟）
set BACKEND_READY=false
for /l %%i in (1,1,120) do (
    powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:8080/api/hello' -UseBasicParsing -TimeoutSec 2; exit 0 } catch { exit 1 }" >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo   [OK] 后端就绪！
        set BACKEND_READY=true
        goto :backend_done
    )
    <nul set /p =.
    timeout /t 2 /nobreak >nul
)
echo.

:backend_done
if "!BACKEND_READY!"=="false" (
    echo   [ERROR] 后端启动超时，请检查后端窗口的输出
    exit /b 1
)

REM [5/5] 启动前端
echo [5/5] 启动前端服务...
cd /d "%FRONTEND_DIR%"

REM 新窗口启动前端
start "AI-Scaffold Frontend" cmd /c "npm run dev"
echo   前端已在独立窗口启动

cd /d "%SCRIPT_DIR%"

echo.
echo ========================================
echo   全部启动完成！
echo   前端: http://localhost:3000
echo   后端: http://localhost:8080
if "%MYSQL_NEEDED%"=="false" echo   H2 控制台: http://localhost:8080/h2-console
echo   停止所有: dev.bat stop
echo ========================================
goto :end

REM ===========================================
REM stop - 停止所有服务
REM ===========================================
:cmd_stop
echo ========================================
echo   停止开发环境
echo ========================================
echo.

echo [1/3] 停止前端...
call :kill_by_port 3000 "前端 (3000)"

echo [2/3] 停止后端...
call :kill_by_port 8080 "后端 (8080)"

if "%MYSQL_NEEDED%"=="true" (
    echo [3/3] 停止 MySQL...
    sc stop MySQL80 >nul 2>&1
    sc stop MySQL >nul 2>&1
) else (
    echo [3/3] H2 内存数据库无需停止
)

echo.
echo ========================================
echo   所有服务已停止
echo ========================================

:end
endlocal
