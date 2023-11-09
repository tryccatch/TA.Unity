public enum ItemType
{
    // 种子,商品,家具
    Seed, Commodity, Furniture,
    // 锄头,砍树,砸石,割草,浇水,收割
    HoeTool, ChopTool, BreakTool, ReapTool, WaterTool, CollectTool,
    // 被割杂草
    ReapableScenery,
}

public enum SlotType
{
    Bag, Box, Shop,
}

public enum InventoryLocation
{
    Player, Box, Shop
}

public enum PartType
{
    None, Carry, Hoe, Break, Water, Collect, Chop, Reap
}

public enum PartName
{
    Body, Hair, Arm, Tool,
}

public enum Season
{
    春天, 夏天, 秋天, 冬天
}

public enum GridType
{
    Diggable, DropItem, PlaceFurniture, NPCObstacle
}

public enum ParticleEffectType
{
    None, LeavesFalling01, LeavesFalling02, Rock, ReapableScenery
}

public enum GameState
{
    GamePlay, Pause
}

public enum LightShift
{
    Morning, Night,
}

public enum SoundName
{
    None,
    FootStepSoft = 01, FootStepHard,
    Axe = 10, Pickaxe, Hoe, Reap, Water, Basket, Chop,
    Pickup = 20, Plant, TreeFalling, Rustle,
    AmbientCountryside1 = 30, AmbientCountryside2,
    MusicCalm1 = 40, MusicCalm2, MusicCalm3, MusicCalm4, MusicCalm5, MusicCalm6,
    AmbientIndoor1 = 50,
}