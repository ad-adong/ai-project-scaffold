@echo off
REM ============================================
REM AI 项目脚手架 - 环境安装脚本 (Windows)
REM
REM 自动检测并安装项目所需的所有前置环境：
REM   winget -> JDK 17+ -> Node.js 18+ -> MySQL
REM ============================================

setlocal enabledelayedexpansion

set MISSING_ANY=false

echo ========================================
echo   AI 项目脚手架 - 环境安装 (Windows)
echo ========================================
echo.

REM ===========================================
REM 检查 winget
REM ===========================================
:check_winget
winget --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   [OK] winget 已可用
) else (
    echo   [WARN] winget 未安装（Win10 1809+ 自带，请确保系统已更新）
    echo          或从 Microsoft Store 安装"应用安装程序"
    set MISSING_ANY=true
)
echo.

REM ===========================================
REM 检查 JDK
REM ===========================================
:check_jdk
set JAVA_OK=false
java -version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do set JAVA_VER=%%~i
    for /f "tokens=1 delims=." %%i in ("!JAVA_VER!") do set JAVA_MAJOR=%%i
    if !JAVA_MAJOR! GEQ 17 (
        echo   [OK] Java: !JAVA_VER!
        set JAVA_OK=true
    ) else (
        echo   [WARN] JDK 版本过低 ^(!JAVA_VER!^)，需要 17+
        set MISSING_ANY=true
    )
) else (
    echo   [WARN] JDK 17+ 未安装
    set MISSING_ANY=true
)
echo.

REM ===========================================
REM 检查 Node.js
REM ===========================================
:check_node
set NODE_OK=false
node --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=1 delims=v." %%i in ('node --version') do set NODE_MAJOR=%%i
    if !NODE_MAJOR! GEQ 18 (
        for /f %%i in ('node --version') do echo   [OK] Node.js: %%i
        for /f "tokens=2 delims=v" %%i in ('npm --version 2^>nul') do echo   [OK] npm: v%%i
        set NODE_OK=true
    ) else (
        echo   [WARN] Node.js 版本过低，需要 18+
        set MISSING_ANY=true
    )
) else (
    echo   [WARN] Node.js 18+ 未安装
    set MISSING_ANY=true
)
echo.

REM ===========================================
REM 检查 MySQL
REM ===========================================
:check_mysql
mysql --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('mysql --version 2^>^&1') do echo   [OK] MySQL: %%i
) else (
    echo   [WARN] MySQL 未安装（可选，H2 模式不需要）
)
echo.

REM ===========================================
REM 如果全部就绪，退出
REM ===========================================
if "%MISSING_ANY%"=="false" (
    echo ========================================
    echo   所有环境已就绪，无需安装！
    echo ========================================
    goto :end
)

echo ========================================
echo   开始安装缺失组件...
echo ========================================
echo.

REM ===========================================
REM 安装 JDK 17
REM ===========================================
:install_jdk
if "%JAVA_OK%"=="true" goto :install_node
echo [1/3] 安装 JDK 17...
winget install EclipseAdoptium.Temurin.17.JDK --accept-source-agreements --accept-package-agreements
if %ERRORLEVEL% NEQ 0 (
    echo   [ERROR] JDK 安装失败，请手动安装: https://adoptium.net/
) else (
    echo   [OK] JDK 17 安装完成
    echo   请重新打开命令行窗口以使 JDK 生效
)
echo.

REM ===========================================
REM 安装 Node.js
REM ===========================================
:install_node
if "%NODE_OK%"=="true" goto :install_mysql
echo [2/3] 安装 Node.js 22 LTS...
winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
if %ERRORLEVEL% NEQ 0 (
    winget install OpenJS.NodeJS --accept-source-agreements --accept-package-agreements
    if %ERRORLEVEL% NEQ 0 (
        echo   [ERROR] Node.js 安装失败，请手动安装: https://nodejs.org/
    ) else (
        echo   [OK] Node.js 安装完成
    )
) else (
    echo   [OK] Node.js 22 LTS 安装完成
    echo   请重新打开命令行窗口以使 Node.js 生效
)
echo.

REM ===========================================
REM 安装 MySQL
REM ===========================================
:install_mysql
mysql --version >nul 2>&1
if %ERRORLEVEL% EQU 0 goto :done
echo [3/3] 安装 MySQL（可选）...
winget install Oracle.MySQL --accept-source-agreements --accept-package-agreements
if %ERRORLEVEL% NEQ 0 (
    echo   [WARN] MySQL 安装失败（H2 模式不需要 MySQL）
    echo         手动安装: https://dev.mysql.com/downloads/mysql/
) else (
    echo   [OK] MySQL 安装完成
)
echo.

:done
echo ========================================
echo   环境安装完成！
echo.
echo   请重新打开命令行窗口，然后运行:
echo     cd 项目目录
echo     dev.bat start
echo ========================================

:end
endlocal
