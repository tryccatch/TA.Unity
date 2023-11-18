is_debug = CS.API.IsDebug()

-- 数据和模块需要的全局的变量
-- 请尽量挂在这个上面
client = {
    gameID = "34",
}

require "base.tools"
require "base.ui"
require "game.base"
require "base.constans"
require "config"
require "game.other.redDot"
require "game.other.gameStat"
require "game.sdkMgr"

-- 随机种子
math.randomseed(os.time())

if is_debug then
    GKStep = -1
else
    GKStep = 0
end

local connectedCount = 0
local onConnected = nil
local ip
local port

local Canvas = CS.UnityEngine.GameObject.Find("Canvas")
Canvas.gameObject:AddComponent(typeof(CS.GameFps))

local transform = CS.UnityEngine.GameObject.Find("Canvas/Center")
if not transform then
    transform = CS.UnityEngine.GameObject.Find("Canvas")
end

transform = transform.transform
CS.UIAPI.SetGlobalNode(transform)
CS.UIAPI.ClearAll()
reconnectParent = CS.UnityEngine.GameObject.Find("Canvas/Reconnect").transform
frontParent = CS.UnityEngine.GameObject.Find("Canvas/Front").transform
local comp = transform.gameObject:AddComponent(typeof(CS.GameLife))
if comp then
    comp:setExitCallback(function()
        print("game exit！")
        GameStat.onUserLeave()
    end)
end

--CS.UnityEngine.PlayerPrefs.DeleteAll()

if CS.UnityEngine.PlayerPrefs.GetInt("gameSound", 0) > 0 then
    CS.UnityEngine.AudioListener.volume = 0;
    --CS.Sound.SetOn(false)
else
    CS.UnityEngine.AudioListener.volume = 1;
    --CS.Sound.SetOn(true)
end

GameStat.init()
SdkMgr.init()

local waitingNet = false
local NetState = {
    WaitSDKInit = 1,     -- 等待SDK初始化
    StartConnect = 2,    -- 开始连接
    Connecting = 3,      -- 正在连接
    Connected = 4,       -- 已连接
    DisConnect = 5,      -- 断线
    AutoReConnect = 6,   -- 自动重连
    ManualReConnect = 7, -- 手动重连
    FailToConnect = 8    -- 重连失败，退回登录
}

crtNetState = NetState.WaitSDKInit

local timer = 0

local netConnected = true

local hasEnterMain = false
function setHasEnterMain(hasEnter)
    hasEnterMain = hasEnter
    --print("has Enter Main --",hasEnterMain,hasEnter)
end

function tryLog(...)
    if not netConnected then
        local msg = { ... }
        if #msg == 1 and type(msg[1]) == "table" then
            print(_s(msg[1]))
        else
            print(...)
        end
    end
end

local failMsgBox
function main_update(value)
    --timer = timer + CS.UnityEngine.Time.deltaTime
    --if timer < 1 then
    --    return
    --end
    --timer = 0
    receiveNetMsg()
    if crtNetState == NetState.WaitSDKInit then
        tryLog("111 wait sdk init over")
        if not SdkMgr.waitSdkInitOver() then
            tryLog("111 sdk init over")
            crtNetState = NetState.StartConnect
        end
    elseif crtNetState == NetState.StartConnect then
        tryLog("111 start connect")
        setNetIpAndPort(value)
        tryConnect()
        crtNetState = NetState.Connecting
    elseif crtNetState == NetState.Connecting then
        tryLog("111 connecting……")
    elseif crtNetState == NetState.AutoReConnect then
        print("111 auto reconnect:", hasEnterMain)
        if hasEnterMain then
            askReconnect()
        else
            autoReConnect()
        end
    elseif crtNetState == NetState.ManualReConnect then
        manualReConnect()
    elseif crtNetState == NetState.FailToConnect then
        if failMsgBox == nil then
            local func = function()
                setNet(defIP, defPort)
                clearAllUI()
                showReconnectNode()
                tryShowWaiting()
                crtNetState = NetState.WaitSDKInit
                failMsgBox = nil
            end
            failMsgBox = UI.msgBox("重连失败，请重新登录！", func)
            failMsgBox:SetParent(reconnectParent)
            UI.closeWaitting()
        end
    end
end

autoReConnectCount = 0;
maxAutoReConnectCount = 3;
retryWindow = nil
manualReConnectCount = 0;
maxManualReConnectCount = 3
manualReConnectTime = 5

function getCrtStateName()
    for i, v in pairs(NetState) do
        if v == crtNetState then
            return i
        end
    end
end

reconnectNode = nil

function showReconnectNode()
    if reconnectNode == nil then
        reconnectNode = UI.showNode("ui/reconnect")
    end
end

function clearReconnectNode()
    if reconnectNode ~= nil then
        UI.close(reconnectNode)
        reconnectNode = nil
    end
end

function receiveNetMsg()
    tryLog("111 receive net msg:", crtNetState, getCrtStateName())
    if crtNetState == NetState.WaitSDKInit or
        crtNetState == NetState.StartConnect or
        crtNetState == NetState.FailToConnect then
        tryLog("111 receive net msg: wait sdk init return")
        return
    end

    if not CS.API.Check(net) or (not net:CheckState()) then
        tryLog("111 receive net msg: net is null or state is false")
        net = nil
        client.msgData.clear()

        if crtNetState ~= NetState.ManualReConnect then
            crtNetState = NetState.AutoReConnect
        end

        return
    end

    if net:IsConnecting() then
        tryLog("111 receive net msg: net is connecting")
        --crtNetState = NetState.Connecting
        return
    end

    if crtNetState == NetState.Connecting
        or crtNetState == NetState.AutoReConnect
        or crtNetState == NetState.ManualReConnect then
        tryLog("111 receive net msg: init connect")
        clearRetryWindow()
        initConnected()
        if onConnected then
            tryLog("执行连接回调方法")
            onConnected()
        else
            UI.show("game.login")
        end
    end

    tryLog("111 receive net msg: read msg")
    clearReconnectNode()
    crtNetState = NetState.Connected
    local bin = net:Read()
    while bin do
        autoReConnectCount = 0
        manualReConnectCount = 0
        message:onMsg(bin)
        bin = net:Read()
    end
end

function setNetIpAndPort(value)
    if not ip then
        ip = defIP
        if value and value ~= "" then
            ip = value
        end
        port = defPort
    end
end

-- 初始化 联网成功数据
function initConnected()
    UI.closeWaitting()
    UI.deleteNode("Canvas/Mask/guide")
    clearAllUI()
    if not message then
        message = require "base.message"
    end
    message:init()
end

function setNet(ipValue, portValue, fun)
    log("set net", ipValue, portValue)
    if message then
        message:clear()
    end

    CS.TcpNet.Close()
    ip = ipValue
    port = portValue
    onConnected = fun
    connectedCount = 0
    net = nil
    if onConnected ~= nil then
        crtNetState = NetState.StartConnect
    end
end

function setNetNotClear(ipValue, portValue, fun)
    ip = ipValue
    port = portValue
    onConnected = fun
    hasSetNetNoClear = true
end

hasSetNetNoClear = false
function clearNet()
    if hasSetNetNoClear then
        if message then
            message:clear()
        end
        CS.TcpNet.Close()
        connectedCount = 0
        net = nil
        if onConnected ~= nil then
            crtNetState = NetState.StartConnect
        end
        hasSetNetNoClear = false
    end
end

function mainRestart(logout)
    setNet(defIP, defPort)
    if client.isGK or client.isH365 or client.isJGG then
        INIT_STEP = 2
    else
        INIT_STEP = 100
    end
    setHasEnterMain(false)
    if logout then
        UI.closeAll()
        onConnected = nil
        crtNetState = NetState.WaitSDKInit
        SdkMgr.logOut()
    end
end

function stopForKickout()
    INIT_STEP = 99
    local node = UI.msgBox("你被其他玩家踢下线！\n是否重连？", function()
        mainRestart(true)
    end, function()
        CS.UnityEngine.Application.Quit()
    end)
    node:SetParent(reconnectParent)
end

needReconnectWindow = nil
function askReconnect()
    if needReconnectWindow == nil then
        needReconnectWindow = UI.msgBox("网络异常，是否重试？", function()
            crtNetState = NetState.ManualReConnect
            needReconnectWindow = nil
        end, function()
            CS.UnityEngine.Application.Quit()
            needReconnectWindow = nil
        end)
        needReconnectWindow:SetParent(reconnectParent)
        UI.closeWaitting()
    end
end

function autoReConnect()
    tryLog("111 autoReConnect")
    showReconnectNode()
    if autoReConnectCount >= maxAutoReConnectCount then
        tryLog("111 autoReConnect: autoReConnectCount >= max")
        --if autoReConnectCount == maxAutoReConnectCount then
        --    tryLog("111 autoReConnect: autoReConnectCount == max")
        --    UI.closeWaitting()
        --    UI.deleteNode("Canvas/Mask/guide")
        --    autoReConnectCount = autoReConnectCount + 1
        --    local node = UI.msgBox("网络异常，是否重试？", function()
        --        crtNetState = NetState.ManualReConnect
        --    end, function()
        --        crtNetState = NetState.FailToConnect
        --    end)
        --    node:SetParent(reconnectParent)
        --else
        --    crtNetState = NetState.ManualReConnect
        --end
        crtNetState = NetState.ManualReConnect
    else
        autoReConnectCount = autoReConnectCount + 1
        tryLog("111 autoReConnect: try connect ------------次数：", autoReConnectCount)
        tryConnect()
        crtNetState = NetState.Connecting
    end
end

function clearRetryWindow()
    if retryWindow ~= nil then
        UI.close(retryWindow)
        retryWindow = nil
    end
end

function manualReConnect()
    tryLog("111 manualReConnect")
    showReconnectNode()
    if crtNetState == NetState.Connected then
        clearRetryWindow()
        return
    end

    if manualReConnectCount > maxManualReConnectCount then
        crtNetState = NetState.FailToConnect
        clearRetryWindow()
        return
    end

    if crtNetState ~= NetState.ManualReConnect then
        tryLog("111 manualReConnect:state not right:", crtNetState, getCrtStateName())
        if retryWindow ~= nil then
            tryLog("111 manualReConnect:close exist window")
            UI.close(retryWindow)
            manualReConnectCount = 0
        end
        return
    end

    if retryWindow == nil then
        tryLog("111 manualReConnect:build window")
        local btnYesFunc = function()
            tryLog("111 manualReConnect: yes function")
            clearNet()
            clearRetryWindow()
            manualReConnect()
        end

        local btCloseFun = function()
            if crtNetState == NetState.Connected then
                return
            end
            retryWindow = nil
            crtNetState = NetState.FailToConnect
        end

        local timeOverFun = function()
            UI.closeWaitting()
        end

        tryLog("111 manualReConnect: show retry window")
        retryWindow = UI.showCounterBox("正在尝试连接……",
            manualReConnectTime, "重试", btnYesFunc, btCloseFun, timeOverFun)
        tryConnect()
        retryWindow:SetParent(reconnectParent)
        manualReConnectCount = manualReConnectCount + 1
    end
end

function backToLogin()
    clearAllUI()
    crtNetState = NetState.WaitSDKInit
    UI.show("game.login")
end

local count = 0
function tryConnect()
    count = count + 1
    tryLog("111 try connecting 次数：", count)
    tryLog("连接：", ip, port)
    net = CS.TcpNet.Connect(ip, port)
    tryShowWaiting()
end

function clearAllUI()
    if reconnectNode ~= nil then
        UI.close(reconnectNode)
        reconnectNode = nil
    end
    UI.closeAll()
    --print("has Enter Main -- clear All UI")
    setHasEnterMain(false)
end

function tryShowWaiting()
    if needReconnectWindow == nil then
        UI.showWaitting()
    end
end

function reportLuaException(debug)
    local info = "Version:" .. Tools.getVersion() .. "\tRes:" .. Tools.getResVersion() .. "\n" .. debug
    if message then
        message:send("C2S_ClientError", { info = info })
    end
end
