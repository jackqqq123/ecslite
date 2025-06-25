# LeoECS Lite 打包脚本
# 此脚本用于将项目编译成 .dll 程序集和 NuGet 包

param(
    [string]$Configuration = "Release",
    [string]$Framework = "netstandard2.1",
    [switch]$BuildNuGet = $false,
    [switch]$Clean = $false
)

$ProjectName = "Leopotam.EcsLite"
$ProjectFile = "$ProjectName.csproj"

Write-Host "开始构建 $ProjectName..." -ForegroundColor Green
Write-Host "配置: $Configuration" -ForegroundColor Yellow
Write-Host "目标框架: $Framework" -ForegroundColor Yellow

# 清理输出目录
if ($Clean) {
    Write-Host "清理构建输出..." -ForegroundColor Yellow
    if (Test-Path "bin") {
        Remove-Item -Recurse -Force "bin"
    }
    if (Test-Path "obj") {
        Remove-Item -Recurse -Force "obj"
    }
}

# 检查 .NET SDK
try {
    $dotnetVersion = dotnet --version
    Write-Host "使用 .NET SDK 版本: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Error ".NET SDK 未安装或不在 PATH 中。请安装 .NET SDK。"
    exit 1
}

# 恢复包依赖
Write-Host "恢复 NuGet 包..." -ForegroundColor Yellow
dotnet restore $ProjectFile
if ($LASTEXITCODE -ne 0) {
    Write-Error "包恢复失败"
    exit 1
}

# 构建项目
Write-Host "构建项目..." -ForegroundColor Yellow
dotnet build $ProjectFile --configuration $Configuration --framework $Framework --no-restore
if ($LASTEXITCODE -ne 0) {
    Write-Error "构建失败"
    exit 1
}

# 输出构建结果
$OutputPath = "bin\$Configuration\$Framework"
Write-Host "构建成功！输出文件:" -ForegroundColor Green
Write-Host "  程序集: $OutputPath\$ProjectName.dll" -ForegroundColor Cyan
Write-Host "  调试符号: $OutputPath\$ProjectName.pdb" -ForegroundColor Cyan

if (Test-Path "$OutputPath\$ProjectName.xml") {
    Write-Host "  XML 文档: $OutputPath\$ProjectName.xml" -ForegroundColor Cyan
}

# 创建 NuGet 包（如果请求）
if ($BuildNuGet) {
    Write-Host "创建 NuGet 包..." -ForegroundColor Yellow
    
    # 使用 dotnet pack
    dotnet pack $ProjectFile --configuration $Configuration --no-build --output "."
    if ($LASTEXITCODE -eq 0) {
        $nupkgFile = Get-ChildItem -Name "*.nupkg" | Select-Object -First 1
        if ($nupkgFile) {
            Write-Host "NuGet 包创建成功: $nupkgFile" -ForegroundColor Green
        }
    } else {
        Write-Warning "NuGet 包创建失败"
    }
}

Write-Host ""
Write-Host "=== 使用说明 ===" -ForegroundColor Magenta
Write-Host "1. 直接引用 DLL:" -ForegroundColor White
Write-Host "   将 $OutputPath\$ProjectName.dll 复制到目标项目并添加引用" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 在 .csproj 中添加项目引用:" -ForegroundColor White
Write-Host "   <ProjectReference Include=`"path\to\$ProjectFile`" />" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 使用 NuGet 包 (如果已创建):" -ForegroundColor White
Write-Host "   dotnet add package $ProjectName --source ." -ForegroundColor Gray
Write-Host ""
Write-Host "构建完成!" -ForegroundColor Green
