using Leopotam.EcsLite;

// 示例组件
public struct PositionComponent {
    public float X, Y;
}

public struct VelocityComponent {
    public float X, Y;
}

public struct NameComponent {
    public string Name;
}

// 示例系统
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

public class LoggingSystem : IEcsRunSystem {
    public void Run(IEcsSystems systems) {
        var world = systems.GetWorld();
        var positionPool = world.GetPool<PositionComponent>();
        var namePool = world.GetPool<NameComponent>();
        
        var filter = world.Filter<PositionComponent>()
            .Inc<NameComponent>()
            .End();
            
        foreach (var entity in filter) {
            ref var position = ref positionPool.Get(entity);
            ref var name = ref namePool.Get(entity);
            
            Console.WriteLine($"{name.Name}: Position ({position.X:F2}, {position.Y:F2})");
        }
    }
}

class Program {
    static void Main(string[] args) {
        Console.WriteLine("LeoECS Lite 测试程序");
        Console.WriteLine("===================");
        
        // 创建 ECS 世界
        var world = new EcsWorld();
        var systems = new EcsSystems(world);
        
        // 添加系统
        systems
            .Add(new MovementSystem())
            .Add(new LoggingSystem())
            .Init();
            
        // 创建实体1
        var entity1 = world.NewEntity();
        world.GetPool<PositionComponent>().Add(entity1) = new PositionComponent { X = 0, Y = 0 };
        world.GetPool<VelocityComponent>().Add(entity1) = new VelocityComponent { X = 1, Y = 0.5f };
        world.GetPool<NameComponent>().Add(entity1) = new NameComponent { Name = "玩家" };
        
        // 创建实体2
        var entity2 = world.NewEntity();
        world.GetPool<PositionComponent>().Add(entity2) = new PositionComponent { X = 10, Y = 10 };
        world.GetPool<VelocityComponent>().Add(entity2) = new VelocityComponent { X = -0.5f, Y = 1 };
        world.GetPool<NameComponent>().Add(entity2) = new NameComponent { Name = "敌人" };
        
        // 创建静态实体（只有位置，没有速度）
        var entity3 = world.NewEntity();
        world.GetPool<PositionComponent>().Add(entity3) = new PositionComponent { X = 5, Y = 5 };
        world.GetPool<NameComponent>().Add(entity3) = new NameComponent { Name = "建筑物" };
        
        Console.WriteLine("初始状态:");
        systems.Run();
        
        Console.WriteLine("\n5帧模拟后:");
        for (int i = 0; i < 5; i++) {
            systems.Run();
        }
        
        Console.WriteLine($"\n世界统计信息:");
        Console.WriteLine($"已使用实体数量: {world.GetUsedEntitiesCount()}");
        Console.WriteLine($"总实体数量: {world.GetEntitiesCount()}");
        Console.WriteLine($"组件池数量: {world.GetPoolsCount()}");
        
        Console.WriteLine("\n按任意键退出...");
        Console.ReadKey();
        
        // 清理资源
        systems.Destroy();
        world.Destroy();
    }
}
