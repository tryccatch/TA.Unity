---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Admin.
--- DateTime: 2021/11/11 14:45

if is_debug then
    INIT_STEP = -1
else
    INIT_STEP = 0
end

SdkMgr = {
    gkGameID = "34"
}

ChannelEnum = {
    GK = "GK",
    H365 = "H365",
    JGG = "JGG",
}

function SdkMgr.getCrtChannel()
    return CS.ChannelMgr.getChannel()
end

function SdkMgr.init()
    SdkMgr.channel = SdkMgr.getCrtChannel()
    if is_debug then
        SdkMgr.channel = nil
    end
end

function SdkMgr.waitSdkInitOver()
    if INIT_STEP == 0 then
        INIT_STEP = 1
        local node = UI.showNode("ui/Login")
        UI.enableAll(node, false)
        UI.showWaitting()
        CS.SDKMgr.Init(SdkMgr.gkGameID, function()
            log("init sdk ok!")
            UI.closeWaitting()
            INIT_STEP = 2
        end)
        initCfg()
    elseif INIT_STEP == -1 then
        initCfg()
        INIT_STEP = 100
    elseif INIT_STEP == 1 then
        -- waitting
    elseif INIT_STEP == 2 then
        -- login
        UI.showWaitting()
        if not SdkMgr.isLogingOut then
            print("login 等待SDK初始化login,", SdkMgr.isLogingOut)
            CS.SDKMgr.Login(SdkMgr.loginCallback)
        end
        INIT_STEP = 3
    elseif INIT_STEP == 3 then
        -- watting login
    end

    return INIT_STEP < 100
end

function SdkMgr.loginCallback(ret, userInfo, token, isGuest)
    isWaitingLogOutCallback = false
    if ret == "exception" then
        UI.msgBox("登录失败，重试", function()
            INIT_STEP = 2
            crtNetState = 1
            print("login 登录失败login")
            CS.SDKMgr.Login(SdkMgr.loginCallback)
        end)
        UI.closeWaitting()
    elseif SdkMgr.channel == ChannelEnum.GK then
        client.isGK = true
        client.isGuest = isGuest
        client.gkId = userInfo.user_id
        client.gkToken = token
        client.gkAccount = userInfo.account
        INIT_STEP = 100
    elseif SdkMgr.channel == ChannelEnum.H365 then
        client.isH365 = true
        client.h365Id = userInfo
        client.h365Token = token
        INIT_STEP = 100
    elseif SdkMgr.channel == ChannelEnum.JGG then
        if ret == "JGG" then
            client.isJGG = true
            client.jggId = userInfo.userId
            client.jggToken = token
            client.jggAccount = userInfo.nickname
        else
            client.isJGG = true
            client.isGuest = isGuest
            client.jggId = userInfo.user_id
            client.jggToken = token
            client.jggAccount = userInfo.account
        end
        INIT_STEP = 100
    end
end

isWaitingLogOutCallback = false
function SdkMgr.logOut()
    SdkMgr.isLogingOut = true
    GameStat.onUserLeave()
    isWaitingLogOutCallback = true
    CS.SDKMgr.LogOut(function(type, msg)
        print("登出回调:", type, msg)
        if type == nil then
            return
        end
        if type == "ok" then
            print("login 登出回调login")
            CS.SDKMgr.Login(SdkMgr.loginCallback)
        elseif type == "exception" then
            UI.showHint("登出失败：" .. msg)
        end
        SdkMgr.isLogingOut = false
        print("login 设置loginOut：", SdkMgr.isLogingOut)
    end)
end

function SdkMgr.clearData()
    if SdkMgr.channel == ChannelEnum.GK then
        client.isGK = nil
        client.isGuest = nil
        client.gkId = nil
        client.gkToken = nil
        client.gkAccount = nil
        INIT_STEP = 100
    elseif SdkMgr.channel == ChannelEnum.H365 then
        client.isH365 = nil
        client.h365Id = nil
        client.h365Token = nil
        INIT_STEP = 100
    elseif SdkMgr.channel == ChannelEnum.H365 then
        client.isJGG = nil
        client.jggId = nil
        client.jggToken = nil
        client.jggAccount = nil
        INIT_STEP = 100
    end
end

function SdkMgr.bindAccount(callback)
    if client.isGK and client.isGuest then
        CS.SDKMgr.GuestBindAccount(client.user.id .. "", callback)
    end
end

function SdkMgr.openPayment()
    CS.SDKMgr.OpenPayment()
end

function SdkMgr.isSdkLogin()
    --if SdkMgr.channel == "JGG" then
    --    return false
    --end
    return SdkMgr.channel ~= nil
end

function SdkMgr.loginToGameServer(callback, account, pwd)
    local msg
    if not SdkMgr.isSdkLogin() then
        msg = {
            account = account,
            pwd = pwd,
        }
    elseif SdkMgr.channel == ChannelEnum.JGG then
        msg = {
            account = client.jggAccount,
            id = client.jggId,
            pwd = client.jggToken,
            type = SdkMgr.channel,
        }
    elseif SdkMgr.channel == ChannelEnum.GK then
        msg = {
            account = client.gkAccount,
            id = client.gkId,
            pwd = client.gkToken,
            type = SdkMgr.channel
        }
    elseif SdkMgr.channel == ChannelEnum.H365 then
        msg = {
            account = "",
            id = client.h365Id,
            pwd = client.h365Token,
            type = SdkMgr.channel
        }
        print("-------------H365 token:", client.h365Token)
    end

    message:send("C2S_login", msg, function(ret)
        ret.account = msg.account
        ret.pwd = msg.pwd
        callback(ret)
        SdkMgr.OnLogin(ret)
    end)
end

function SdkMgr.charge(cfg, callbackUrl, type, count, money, callback)
    SdkMgr.payCfg = cfg
    SdkMgr.lastProductName = cfg.name_h365
    CS.SDKMgr.Pay(cfg.name_h365, cfg.des, cfg.url, client.user.id, callbackUrl, type, count, money / 100, os.time(), callback)
end

function SdkMgr.getLastProductName()
    local name = SdkMgr.lastProductName
    SdkMgr.lastProductName = nil
    print("上次充值名字：", name)
    return name
end

function SdkMgr.BindGameAccount(account)
    client.gkGameAccount = account
    CS.SDKMgr.PostAccountBindGame(SdkMgr.gkGameID, account, function(result, errCode)
        print("bind account,myAccount:", account, "result:", result, "errMsg:", errCode)
    end)
end

function SdkMgr.OnLogin(msg)
    if SdkMgr.channel == ChannelEnum.H365 then
        print("login isNew:", msg.isNewAccount)
        if CS.UnityEngine.Application.version == "1.2.0" then
            print("version=1.2.0")
            return
        end
        if msg.isNewAccount then
            CS.SDKMgr.H365RegistrationEvent();
        end
        CS.SDKMgr.H365LoginEvent();
    elseif SdkMgr.channel == ChannelEnum.GK then
        print("login token:", msg.token)
        local account = string.split(msg.token, '_')
        SdkMgr.BindGameAccount(account[2] .. "_" .. account[3])
    end
end