local loadConfig = {
    "vip",
    "sceneSoldierConfigure",
    "childConfigure",
    "item",
    "story",
    "storyGet",
    "hero",
    "wife",
    "wifeConfigure",
    "searchBuilding",
    "searchCharacter",
    "searchConfig",
    "waterBattleBuff",
    "waterBattleWord",
    "waterBattleReward",
    "waterBattleRank",
    "dinnerGo",
    "prisoner",
    "treasure",
    "treasurePool",
    "treasureConfig",
    "treasureActive",
    "prisonerConfigure",
    "worldBossChange",
    "worldBossDetectTalk",
    "worldBossDetect",
    "worldBossDetectAffair",
    "tower",
    "dailyTaskReward",
    "dailyTask",
    "achievement",
    "pay",
    "gamePage",
    "mainTask",
    "systemOpen",
    "systemEventOpen",
    "level",
    "buildEventRank",
    "buildEventRankGuild",
    "allianceConfigure",
    "guide",
    "royal",
    "worldBoss",
    "alliance",
    "allianceBuild",
    "allianceBarrier",
    "childGrow",
    "event1",
    "event2",
    "event3",
    "event4",
    "event201",
    "event202",
    "event203",
    "event204",
    "event205",
    "event206",
    "event207",
    "event208",
    "event209",
    "event401",
    "event402",
    "event403",
    "rushLoop",
    "allianceNoble",
    "allianceShop",
    "limitedReward",
    "eventPay",
    "eventSeven",
    "buildEvent",
    "buildEventShop",
    "buildEventChange",
    "mail",
    "politics",
    "myRoad",
    "myRoadConfig",
    "promotion",
    "event17",
    "cardMonth",
    "cardYear",
    "currencyprice",
    "help",
    "lotteryShop",
    "treasureHouse",
}

config = {
}

IPGlobal = {}
IPGlobal[1] = {
    ip = "127.0.0.1",
    port = 9500,
    hotFixPort = 9701
}

IPGlobal[2] = {
    ip = "192.168.0.149",
    port = 9500,
    hotFixPort = 9701
}

IPGlobal[3] = {
    ip = "18.162.47.123",
    port = 9500,
    hotFixPort = 9701
}

IPGlobal[4] = {
    ip = "projectxx.xyz",
    port = 9500,
    hotFixPort = 9701
}

--JGG正式服域名
IPGlobal[5] = {
    ip = "13.215.78.223",
    port = 9500,
    hotFixPort = 9701
}

IPGlobal[6] = {
    ip = "harem2game.net",
    port = 9500,
    hotFixPort = 9701
}

clientChannel = Tools.getChannel()
server_enum = CS.API.ServerEnum()
defIP = IPGlobal[server_enum].ip
defPort = IPGlobal[server_enum].port
defHotFixPort = IPGlobal[server_enum].hotFixPort
print("IpGlobal:", defIP, defPort, defHotFixPort)

function initCfg()
    for _, key in ipairs(loadConfig) do

        local data = require("config." .. key)

        local dataMap = {}
        for _, d in ipairs(data) do
            dataMap[d.id] = d
        end

        config[key .. "Map"] = dataMap
        config[key] = data
    end
end