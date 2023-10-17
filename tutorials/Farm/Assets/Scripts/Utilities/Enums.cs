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
    None, Carry, Hoe, Break, Water, Collect, Chop,
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