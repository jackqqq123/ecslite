# LeoECS Lite

轻量级 C# Entity Component System 框架

## 简介

LeoECS Lite 是一个高性能、轻量级的 ECS（Entity Component System）框架，专为 C# 开发。它基于结构体设计，追求零分配或最小分配、最小化内存使用，且不依赖任何特定游戏引擎。

### 主要特性

- 🚀 **高性能**：零分配或最小分配设计
- 🪶 **轻量级**：程序集仅 19KB，无外部依赖
- 🎯 **内存友好**：最小化内存使用和分配
- 🔧 **引擎无关**：不依赖任何特定游戏引擎
- 📦 **易于集成**：标准 .NET 程序集，支持多种引用方式

## 快速开始

### 编译和构建

#### 方法一：使用构建脚本（推荐）

**PowerShell 脚本**
```powershell
# 基本构建
.\build.ps1

# 清理并构建
.\build.ps1 -Clean

# 构建并创建 NuGet 包
.\build.ps1 -BuildNuGet

# Debug 版本构建
.\build.ps1 -Configuration Debug
```

**批处理文件**
```cmd
build.bat
```

#### 方法二：使用 .NET CLI

```bash
# 恢复依赖包
dotnet restore Leopotam.EcsLite.csproj

# 构建 Release 版本
dotnet build Leopotam.EcsLite.csproj --configuration Release

# 创建 NuGet 包
dotnet pack Leopotam.EcsLite.csproj --configuration Release
```

### 构建输出

构建成功后，将在以下位置生成文件：

- **程序集**: `bin/Release/netstandard2.1/Leopotam.EcsLite.dll`
- **调试符号**: `bin/Release/netstandard2.1/Leopotam.EcsLite.pdb`
- **NuGet 包**: `bin/Release/Leopotam.EcsLite.2025.4.22.nupkg`

## 在项目中使用

### 方法一：直接引用 DLL

1. 将 `Leopotam.EcsLite.dll` 复制到目标项目
2. 在 Visual Studio 中右键项目 → 添加 → 引用
3. 浏览并选择 `Leopotam.EcsLite.dll`

### 方法二：在 .csproj 中添加引用

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>
  
  <ItemGroup>
    <!-- 直接引用 DLL -->
    <Reference Include="Leopotam.EcsLite">
      <HintPath>path\to\Leopotam.EcsLite.dll</HintPath>
    </Reference>
  </ItemGroup>
</Project>
```

### 方法三：项目引用

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>
  
  <ItemGroup>
    <!-- 引用源项目 -->
    <ProjectReference Include="path\to\Leopotam.EcsLite.csproj" />
  </ItemGroup>
</Project>
```

### 方法四：本地 NuGet 包

```bash
# 创建本地包源目录
mkdir C:\LocalNuGet

# 复制 .nupkg 文件到本地源
copy bin\Release\Leopotam.EcsLite.2025.4.22.nupkg C:\LocalNuGet\

# 安装包
dotnet add package Leopotam.EcsLite --version 2025.4.22 --source C:\LocalNuGet
```

## 核心概念

### 实体 (Entity)
实体是一个唯一的ID，用于标识游戏世界中的对象。

### 组件 (Component)
组件是纯数据结构，描述实体的属性。

```csharp
public struct PositionComponent {
    public float X, Y;
}

public struct VelocityComponent {
    public float X, Y;
}
```

### 系统 (System)
系统包含游戏逻辑，对具有特定组件的实体进行操作。

```csharp
public class MovementSystem : IEcsRunSystem {
    public void Run(IEcsSystems systems) {
        var world = systems.GetWorld();
        var positionPool = world.GetPool<PositionComponent>();
        var velocityPool = world.GetPool<VelocityComponent>();
        
        var filter = world.Filter<PositionComponent>()
            .Inc<VelocityComponent>()
            .End();
            
        foreach (var entity in filter) {
            ref var position = ref positionPool.Get(entity);
            ref var velocity = ref velocityPool.Get(entity);
            
            position.X += velocity.X;
            position.Y += velocity.Y;
        }
    }
}
```

## 完整示例

```csharp
using Leopotam.EcsLite;

class Program {
    static void Main() {
        // 创建 ECS 世界
        var world = new EcsWorld();
        var systems = new EcsSystems(world);
        
        // 添加系统
        systems
            .Add(new MovementSystem())
            .Init();
            
        // 创建实体
        var entity = world.NewEntity();
        world.GetPool<PositionComponent>().Add(entity) = new PositionComponent { X = 0, Y = 0 };
        world.GetPool<VelocityComponent>().Add(entity) = new VelocityComponent { X = 1, Y = 1 };
        
        // 运行系统
        for (int i = 0; i < 10; i++) {
            systems.Run();
        }
        
        // 清理
        systems.Destroy();
        world.Destroy();
    }
}
```

## 技术规格

- **目标框架**: .NET Standard 2.1
- **兼容性**: 
  - .NET Core 3.0+
  - .NET 5+
  - .NET Framework 4.7.2+ (部分功能)
  - Unity 2021.2+
- **程序集大小**: ~19KB (非常轻量)
- **依赖项**: 无外部依赖
- **性能**: 零分配，高性能ECS框架

## 使用场景

### ✅ 适用于
- 游戏开发 (Unity, Godot, 自制引擎)
- 高性能模拟系统
- 实时数据处理
- 需要ECS架构的任何.NET应用

### ❌ 不适用于
- 多线程环境 (需要自行实现同步)
- .NET Framework 4.6.1及更低版本
- 需要反射密集操作的场景

## 项目结构

```
├── src/                        # 源代码目录
│   ├── components.cs           # 组件相关代码
│   ├── entities.cs             # 实体相关代码
│   ├── filters.cs              # 过滤器相关代码
│   ├── systems.cs              # 系统相关代码
│   └── worlds.cs               # 世界相关代码
├── TestProject/                # 测试项目
│   ├── TestProject.csproj      # 测试项目配置
│   └── Program.cs              # 测试示例代码
├── Leopotam.EcsLite.csproj     # 主项目配置
├── Leopotam.EcsLite.nuspec     # NuGet 包配置
├── build.ps1                   # PowerShell 构建脚本
├── build.bat                   # 批处理构建脚本
├── BUILD_GUIDE.md              # 详细构建指南
├── PACKAGE_SUMMARY.md          # 打包总结
└── README.zh.md                # 中文说明文档
```

## 注意事项

### ⚠️ 重要提醒

- **线程安全**: LeoECS Lite 框架**不是线程安全的**，如需多线程请自行实现同步机制
- **版本选择**: 开发时使用 Debug 版本（包含错误检查），发布时使用 Release 版本（性能最优）
- **生命周期**: 框架处于稳定状态，活跃开发已停止，仅进行错误修复
- **支持期限**: 支持将于 2026年4月22日 结束

### 调试与发布

```bash
# Debug 版本 - 包含错误检查，适合开发
dotnet build --configuration Debug

# Release 版本 - 移除检查，性能最优，适合生产
dotnet build --configuration Release
```

## 扩展生态

LeoECS Lite 拥有丰富的扩展生态系统，包括：

- Unity 集成扩展
- 可视化调试工具
- 序列化支持
- 更多系统类型

详细信息请参考 [官方扩展列表](https://github.com/Leopotam/ecslite#%D0%A0%D0%B0%D1%81%D1%88%D0%B8%D1%80%D0%B5%D0%BD%D0%B8%D1%8F)。

## 资源链接

- **官方仓库**: https://github.com/Leopotam/ecslite
- **开发者博客**: https://leopotam.ru/
- **Unity Package Manager**: `com.leopotam.ecslite`
- **许可证**: MIT-Red License

## 贡献

由于项目已停止活跃开发，我们主要接受错误修复的贡献。如果您发现问题，请在 GitHub 仓库中提交 Issue。

## 许可证

本项目采用 MIT-Red License 开源协议。详细信息请参考 [LICENSE.md](LICENSE.md) 文件。

---

**版本**: 2025.4.22  
**构建日期**: 2025年6月25日  
**目标框架**: .NET Standard 2.1
