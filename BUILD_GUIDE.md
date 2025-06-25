# LeoECS Lite 程序集使用指南

本指南说明如何将 LeoECS Lite 项目打包成程序集并在其他C#项目中使用。

## 项目构建

### 自动构建

#### 方法 1: 使用 PowerShell 脚本
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

#### 方法 2: 使用批处理文件
```cmd
build.bat
```

### 手动构建

#### 使用 .NET CLI
```bash
# 恢复依赖包
dotnet restore Leopotam.EcsLite.csproj

# 构建 Release 版本
dotnet build Leopotam.EcsLite.csproj --configuration Release

# 创建 NuGet 包
dotnet pack Leopotam.EcsLite.csproj --configuration Release
```

## 构建输出

构建成功后，将在以下位置生成文件：

- **程序集**: `bin/Release/netstandard2.1/Leopotam.EcsLite.dll`
- **调试符号**: `bin/Release/netstandard2.1/Leopotam.EcsLite.pdb`
- **NuGet 包**: `bin/Release/Leopotam.EcsLite.2025.4.22.nupkg`

## 在其他项目中使用

### 方法 1: 直接引用 DLL

1. 将 `Leopotam.EcsLite.dll` 复制到目标项目
2. 在 Visual Studio 中右键项目 → 添加 → 引用
3. 浏览并选择 `Leopotam.EcsLite.dll`

### 方法 2: 在 .csproj 中添加引用

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

### 方法 3: 项目引用

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

### 方法 4: 本地 NuGet 包

1. 创建本地 NuGet 源：
   ```bash
   # 创建本地包源目录
   mkdir C:\LocalNuGet
   
   # 复制 .nupkg 文件到本地源
   copy bin\Release\Leopotam.EcsLite.2025.4.22.nupkg C:\LocalNuGet\
   ```

2. 在目标项目中添加包源：
   ```xml
   <!-- NuGet.config -->
   <?xml version="1.0" encoding="utf-8"?>
   <configuration>
     <packageSources>
       <add key="Local" value="C:\LocalNuGet" />
     </packageSources>
   </configuration>
   ```

3. 安装包：
   ```bash
   dotnet add package Leopotam.EcsLite --version 2025.4.22 --source C:\LocalNuGet
   ```

## 代码示例

```csharp
using Leopotam.EcsLite;

// 创建组件
public struct PositionComponent {
    public float X, Y;
}

public struct VelocityComponent {
    public float X, Y;
}

// 创建系统
public class MovementSystem : IEcsRunSystem {
    public void Run(EcsSystems systems) {
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

// 初始化 ECS 世界
class Program {
    static void Main() {
        var world = new EcsWorld();
        var systems = new EcsSystems(world);
        
        systems
            .Add(new MovementSystem())
            .Init();
            
        // 创建实体
        var entity = world.NewEntity();
        world.GetPool<PositionComponent>().Add(entity) = new PositionComponent { X = 0, Y = 0 };
        world.GetPool<VelocityComponent>().Add(entity) = new VelocityComponent { X = 1, Y = 1 };
        
        // 运行系统
        systems.Run();
        
        // 清理
        systems.Destroy();
        world.Destroy();
    }
}
```

## 注意事项

1. **目标框架**: 生成的程序集目标框架为 .NET Standard 2.1，兼容：
   - .NET Core 3.0+
   - .NET 5+
   - .NET Framework 4.7.2+ (部分功能)
   - Unity 2021.2+

2. **调试版本**: 开发时建议使用 Debug 版本，包含完整的错误检查
   ```bash
   dotnet build --configuration Debug
   ```

3. **性能**: Release 版本移除了所有调试检查，性能最优

4. **多线程**: LeoECS Lite 不是线程安全的，需要自行实现同步机制

5. **Unity 集成**: 如果在 Unity 中使用，建议直接使用 Unity Package Manager 安装

## 兼容性

- **最低要求**: .NET Standard 2.1
- **推荐环境**: .NET 6.0 或更高版本
- **Unity 支持**: Unity 2021.2 或更高版本

## 故障排除

### 常见问题

1. **构建失败**: 确保安装了 .NET SDK 8.0 或更高版本
2. **引用错误**: 检查目标项目的框架版本是否兼容
3. **运行时错误**: 确保使用正确的配置版本（Debug/Release）

### 获取帮助

- **官方仓库**: https://github.com/Leopotam/ecslite
- **开发者博客**: https://leopotam.ru/

## 版本信息

- **当前版本**: 2025.4.22
- **目标框架**: .NET Standard 2.1
- **许可证**: MIT-Red License
