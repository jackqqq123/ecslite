@echo off
setlocal enabledelayedexpansion

echo ====================================
echo LeoECS Lite 构建脚本
echo ====================================

set PROJECT_NAME=Leopotam.EcsLite
set PROJECT_FILE=%PROJECT_NAME%.csproj
set CONFIGURATION=Release
set FRAMEWORK=netstandard2.1

echo 检查 .NET SDK...
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo 错误: .NET SDK 未安装或不在 PATH 中
    echo 请从 https://dotnet.microsoft.com/download 下载并安装 .NET SDK
    pause
    exit /b 1
)

echo 恢复 NuGet 包...
dotnet restore %PROJECT_FILE%
if errorlevel 1 (
    echo 错误: 包恢复失败
    pause
    exit /b 1
)

echo 构建项目...
dotnet build %PROJECT_FILE% --configuration %CONFIGURATION% --framework %FRAMEWORK% --no-restore
if errorlevel 1 (
    echo 错误: 构建失败
    pause
    exit /b 1
)

set OUTPUT_PATH=bin\%CONFIGURATION%\%FRAMEWORK%

echo.
echo ====================================
echo 构建成功！
echo ====================================
echo 输出文件:
echo   程序集: %OUTPUT_PATH%\%PROJECT_NAME%.dll
echo   调试符号: %OUTPUT_PATH%\%PROJECT_NAME%.pdb
if exist "%OUTPUT_PATH%\%PROJECT_NAME%.xml" (
    echo   XML 文档: %OUTPUT_PATH%\%PROJECT_NAME%.xml
)

echo.
echo 使用方法:
echo 1. 直接引用 DLL: 将 %OUTPUT_PATH%\%PROJECT_NAME%.dll 复制到目标项目并添加引用
echo 2. 项目引用: 在目标项目的 .csproj 中添加 ^<ProjectReference Include="path\to\%PROJECT_FILE%" /^>
echo.

pause
