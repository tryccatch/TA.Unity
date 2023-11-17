---
--- Generated by EmmyLua(https:--github.com/EmmyLua)
--- Created by Admin.
--- DateTime: 2021/8/23 10:08
---
RedDot = {
    res = "base/redDot",
    btnMap = {},
    btnIdMap = {},
    lastRedDotData = {}
}

RedDot.SystemID = {
    DatingHouseMarryRequest = 0, --姻缘祠 提请请求  新的提亲请求
    DatingHouseMarriedChild = 1, --姻缘祠 已婚子女  子女联姻成功
    PartyEnemy = 2, --宴会   仇人 新的捣乱信息
    Sign = 3, --签到  可签到
    MonthCardReward = 4, --月卡  可领取奖励
    YearCardReward = 5, --年卡  可领取奖励
    FirstChargeReward = 6, --首冲  可领取奖励
    GodShow = 7, --神迹  vip等级提升
    VipLevelUp = 8, --Vip等级提升
    DailyChargeReward = 9, --每日充值  领取奖励
    TotalChargeReward = 10, --累计充值  领取奖励
    TotalDayChargeReward = 11, --累天充值  领取奖励
    ShopVipCanBuy = 12, --商城VIP栏 满足购买条件
    LimitReward = 13, --限时奖励
    TwoBeauty = 14, --绝代双骄 满足任意可购买条件时
    QingDing = 15, --情定终身
    QingDingRank = 16, --情定终身 排行榜
    ConferenceHall = 17, --议政厅中，可挑战或者正在挑战中
    PrisonTreasure = 18, --大狱中 ，未选中刑具 or 当前名望>=15
    GameLevel = 19, --过关斩将，可出战豪杰> 0
    VisitVisit = 20, --微服私访 走访体力已满
    VisitBuGua = 21, --微服私访 免费卜卦
    UnityEnterReq = 22, --联盟 入盟申请
    UnityDailyBuild = 23, --联盟 每日建设
    UnitySecret = 24, --联盟 秘境
    UnityShop = 25, --联盟 商店
    UnityNoble = 26, --联盟 权贵
    SchoolRiseChild = 27, --私塾 培养子嗣
    HeroUpdate10 = 28, --豪杰 连升10级
    HeroGrowUpdate = 29, --豪杰 资质提升
    HeroSkillUpdate = 30, --豪杰 技能提升
    HeroPromote = 31, --豪杰 提拔豪杰
    DayFirstLogin = 32, --每天第一次登录
    SaleGift = 33, --优惠礼包
    TeachQueen = 34, --调教女王
    MarryAllGirls = 35, --广纳红颜
    FlowerStreet = 36, --花楼七日游
    PunishThief = 37, --惩罚女贼
    Palace = 38, --皇宫
    CatchAssailant = 39, --白夜缉凶
    CountrySchool = 40, --国子监
    Achievement = 41, --成就
    DailyTask = 42, --日常任务
    Email = 43, --邮箱
    Rank = 44, --排行榜
    WifeHouse = 45, --群芳苑
    Study = 46, --书房
    Business = 47, --经营
    WorkHouse = 48, --政务
    Prison = 49, --大狱
    Party = 50, --宴会
    VipReward = 51, --vip 可领取奖励
    BusinessTip = 52, --用于显示 商业tip（不是红点）
    NewYear = 53, --新年礼包
    TreasureHouse = 54, --珍宝阁
}

function RedDot.getSystemKeyById(id)
    for i, v in pairs(RedDot.SystemID) do
        if v == id then
            return i
        end
    end
    log_call("no key match id:" .. id)
end

function RedDot.getNodeSize(node)
    local rectTrans = UI.component2(node, typeof(CS.UnityEngine.RectTransform))
    local x = 0
    local y = 0
    if rectTrans then
        x = rectTrans.sizeDelta.x / 2
        y = rectTrans.sizeDelta.y / 2
    end
    return { x = x, y = y }
end

--[[
btnMap = {
        SystemID = {
            node = node,
            ids = {id1,di2}
        }
    }

btnMap2 = {SystemID = {node1,node2,node3}}

btnKeys = {node1={id1,id2,id3}}
--]]

function RedDot.registerBtn(node, redDotId, isEnd, offsetX, offsetY)
    if node == nil then
        log_call("nil node with id:", redDotId)
        return
    end

    if redDotId < 0 or redDotId > 54 then
        log_call("valid red dot id：" .. redDotId)
        return
    end
    local child = UI.child(node, "redDot", true)
    if child == nil then
        child = UI.showNode(node, RedDot.res)
        local size = RedDot.getNodeSize(node)
        offsetX = offsetX == nil and 0 or offsetX
        offsetY = offsetY == nil and 0 or offsetY
        local rectTrans = UI.component(node, "redDot",
                typeof(CS.UnityEngine.RectTransform))
        if rectTrans then
            local center = CS.UnityEngine.Vector2(0.5, 0.5)
            local one = CS.UnityEngine.Vector2(1, 1)
            rectTrans.pivot = center
            rectTrans.anchorMin = one
            rectTrans.anchorMax = one
            rectTrans.anchoredPosition3D = CS.UnityEngine.Vector3(-3 + offsetX, -3 + offsetY, 0)
        end
        UI.enable(child, false)
    end

    if RedDot.btnMap[redDotId] == nil then
        RedDot.btnMap[redDotId] = {}
    end

    if RedDot.btnIdMap[node] == nil then
        RedDot.btnIdMap[node] = {}
    end

    local list = RedDot.btnMap[redDotId]
    local idsList = RedDot.btnIdMap[node]
    local temp = table.find(list, function(value)
        return value == node
    end)
    if temp == nil then
        table.insert(list, node)
    end
    local idTemp = table.find(idsList, function(value)
        return value == redDotId
    end)

    if idTemp == nil then
        table.insert(idsList, redDotId)
    end

    if isEnd then
        UI.buttonMulti(node, function()
            message:send("C2S_changeRedDot",
                    { id = RedDot.getSystemKeyById(redDotId) })
        end)
    end

    RedDot.updateShowById(redDotId)
end

function RedDot.unregisterBtn(node, redDotId)
    if RedDot.btnMap[redDotId] == nil or node == nil then
        return
    end

    local list = RedDot.btnMap[redDotId]
    for i, v in ipairs(list) do
        if v == node then
            table.remove(list, i)
            break
        end
    end

    local idList = RedDot.btnIdMap[node]
    if idList and #idList > 0 then
        for i = 1, #idList do
            if idList[i] == redDotId then
                table.remove(idList, i)
                return
            end
        end
    end

end

function RedDot.updateShow()
    for i, v in pairs(RedDot.SystemID) do
        RedDot.updateShowById(v)
    end
end

function RedDot.updateShowById(id)
    local list = RedDot.btnMap[id]
    --local idKey = RedDot.getSystemKeyById(id)
    if list and #list > 0 then
        for i, node in ipairs(list) do
            local show = false
            local ids = RedDot.btnIdMap[node]
            if ids and #ids > 0 then
                for key, systemId in ipairs(ids) do
                    local realIndex = #RedDot.lastRedDotData - systemId
                    if RedDot.lastRedDotData[realIndex] == 1 then
                        show = true
                        break ;
                    end
                end
            end
            UI.enable(node, "redDot", show)
            --print("show red dot:", node.name,idKey,show)
        end
    end
end

function RedDot.byte2bin(n, byteCount)
    byteCount = byteCount == nil and 64 or byteCount
    local t = {}
    for i = byteCount, 0, -1 do
        t[#t + 1] = math.floor(n / 2 ^ i)
        n = n % 2 ^ i
    end
    --print("red dot value:",table.concat(t),#t)
    RedDot.debug(t)
    return t
end


--msg S2C_redDotChange
function RedDot.onRedDotChange(msg)
    --print('收到红点数据更新-----')

    RedDot.lastRedDot = msg.byte
    RedDot.lastRedDotData = RedDot.byte2bin(RedDot.lastRedDot)
    RedDot.updateShow()
end

function RedDot.debug(value)
    local id = 0
    for i, v in pairs(RedDot.SystemID) do
        local realIndex = #value - v
        --print("red dot:",i,realIndex)
        if value[realIndex] == 1 then
            --print("显示红点系统:",i)
        end
    end
end

function RedDot.getDataById(id)
    local realIndex = #RedDot.lastRedDotData - id
    return RedDot.lastRedDotData[realIndex] == 1
end