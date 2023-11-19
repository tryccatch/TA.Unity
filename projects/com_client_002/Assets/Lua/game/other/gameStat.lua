---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Admin.
--- DateTime: 2021/8/31 18:09
---
---
---
---
---
GameStat = {
    appId = "7j3joh0efvlw42ok",
    channel = "ALL",
    isOn = true
}

local tapDbIds = {
    ALL = "7j3joh0efvlw42ok",
    GK = "7j3joh0efvlw42ok",
    H365 = "wnl4362186c8nl0p",
    JGG = "uo486eik72u0jpl5",
}

-- local sdk = CS.TapDB
local sdk = nil

--local sdk = CS.SDKMgr
function GameStat.init()
    GameStat.isOn = CS.API.ServerEnum() >= 4 or CS.API.ServerEnum() == 6
    if not GameStat.isOn then
        print("not valid server！close game state")
        return
    end
    print("tap sdk init")
    if is_debug then
        sdk.enableLog(true)
    else
        sdk.enableLog(false)
    end

    local crtChannel = CS.ChannelMgr.getChannel()
    GameStat.channel = crtChannel
    GameStat.appId = tapDbIds[crtChannel]
    sdk.onStart(GameStat.appId, GameStat.channel, nil)
end

function GameStat.onLogin(userId, userName, userLv, userServer)
    if not GameStat.isOn then
        return
    end

    local userID = userId
    if client.isH365 then
        userID = client.h365Id
        print("h365 id :", userID)
    end

    sdk.setUser(userID)
    sdk.setName(userName)
    sdk.setLevel(userLv)
    sdk.setServer(userServer)
end

function GameStat.onUserLeave()
    if not GameStat.isOn then
        return
    end
    print("tap sdk userLeave:")
    sdk.clearUser()
end

function GameStat.onChargeSuccess(amount, productName)
    if not GameStat.isOn then
        return
    end

    if productName == nil then
        productName = amount
        if SdkMgr.payCfg ~= nil then
            productName = SdkMgr.payCfg.name_h365
            SdkMgr.payCfg = nil
        end
    end
    print("商品信息：：", productName)

    local money, moneyType = GameStat.getMoneyByCount(amount)
    print("上报充值---金额：", money, "币种：", moneyType)

    sdk.onChargeSuccess("null", productName, money * 100, moneyType, "平台兑换")
end

function GameStat.getMoneyByCount(count)
    local temp = config["currencyprice"]
    for i, v in ipairs(temp) do
        if v.sign == GameStat.channel then
            return count * v.getTapDB, v.moneyType
        end
    end
    return count, "CNY"
end