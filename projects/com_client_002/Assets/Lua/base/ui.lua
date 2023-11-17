UI = {
    list = {},
    map = {},
}

resSound = {
    { "float1", "effect/get" },
    { "float2", "effect/get" }
}

UIPageName = {
    PlayerAttribute = {
        id = 1,
        path = "game.lobby.playerAttribute"
    }, -- 玩家信息
    TwoBeauty = {
        id = 2,
        path = "game.activity.twoBeauty"
    }, -- 绝代双骄
    PayReward = {
        id = 3,
        path = "game.activity.payReward"
    }, -- 充值奖励
    GuangNaHongYan = {
        id = 4,
        path = "game.activity.guangnahongyan"
    }, -- 广纳红颜
    HdEmpress = {
        id = 5,
        path = "game.activity.hdEmpress"
    }, -- 调教女王
    HuaLouQiRiYou = {
        id = 6,
        path = "game.activity.hualouqiriyou"
    }, -- 花楼七日游
    HdPunish = {
        id = 7,
        path = "game.activity.hdPunish"
    }, -- 惩罚女贼
    Industry = {
        id = 8,
        path = "game.lobby.industry"
    }, -- 经营
    WorkHouse = {
        id = 9,
        path = "game.lobby.workhouse"
    }, -- 书房（政务）
    Shop = {
        id = 10,
        path = "game.lobby.shop"
    }, -- 商店
    Wives = {
        id = 11,
        path = "game.lobby.wives"
    }, -- 群芳/红颜
    Heroes = {
        id = 12,
        path = "game.lobby.heroes"
    }, -- 豪杰
    YinYuanCi = {
        id = 13,
        --path = "game.lobby.yinyuanci"
        path = "game.lobby.childMarry"
    }, -- 姻缘祠
    Banquet = {
        id = 14,
        path = "game.lobby.banquet"
    }, -- 宴会
    School = {
        id = 15,
        path = "game.lobby.sishu"
    }, -- 私塾
    WareHouse = {
        id = 16,
        path = "game.lobby.warehouse"
    }, -- 库房
    Battle = {
        id = 17,
        path = "game.outdoor.battle"
    }, -- 征战/关卡
    Mail = {
        id = 18,
        path = "game.lobby.mail"
    }, -- 邮件
    FirstCharge = {
        id = 19,
        path = "game.lobby.benefits",
        param = 5
    }, -- 首冲
    FuLiPage = {
        id = 20,
        path = "game.lobby.benefits",
        param = 1
    }, -- 签到
    GuoZiJian = {
        id = 21,
        path = "game.outdoor.school"
    }, -- 国子监
    VisitPage = {
        id = 22,
        path = "game.outdoor.visitPage"
    }, -- 拜访
    PrisonPage = {
        id = 23,
        path = "game.outdoor.prisonPage"
    }, -- 大狱/监狱
    CatchAssailant = {
        id = 24,
        path = "game.outdoor.catchAssailant"
    }, -- 白夜缉凶
    DailyTask = {
        id = 25,
        path = "game.lobby.dailyTask"
    }, -- 日常任务
    Achievement = {
        id = 26,
        path = "game.lobby.achievement"
    }, -- 成就
    YiZhengTing = {
        id = 27,
        path = "game.outdoor.battleHall"
    }, -- 议政厅
    GuoGuanZhanJiang = {
        id = 28,
        path = "game.outdoor.battleLevel"
    }, -- 过关斩将
    Palace = {
        id = 29,
        path = "game.outdoor.palace"
    }, -- 皇宫
    MonthCardPage = {
        id = 30,
        path = "game.lobby.benefits",
        param = 2
    }, -- 月卡
    YearCardPage = {
        id = 31,
        path = "game.lobby.benefits",
        param = 3
    }, -- 年卡
    RankPage = {
        id = 32,
        path = "game.lobby.lobbyRank"
    }, -- 排行榜
    UnionPage = {
        id = 33,
        path = "game.outdoor.unity"
    }, -- 联盟
    SystemOpenPage = {
        id = 34,
        path = "game.lobby.systemOpen"
    }, -- 系统开放
    Chat = {
        id = 35,
        path = "game.other.msn"
    }, -- 聊天
    VipFuLi = {
        id = 36,
        path = "game.lobby.vipReward",
    }, -- Vip福利
    SuperShop = {
        id = 37,
        path = "game.lobby.shop",
        param = 2
    }, -- 优惠礼包
    LimitReward = {
        id = 38,
        path = "game.activity.limitReward"
    }, -- 限时奖励
    Mail = {
        id = 39,
        path = "game.lobby.mail"
    }, -- 邮箱
    LifeLong = {
        id = 40,
        path = "game.activity.hdLoveLife"
    }, -- 情定终身
    ActivityLoginTips = {
        id = 41,
        path = "game.activity.activityLoginTips"
    }, -- 活动登录提示
    LobbyMainWives = {
        id = 42,
        path = "game.lobby.main",
        param = 515
    }, -- 主界面群芳苑
    VipPrivilege = {
        id = 43,
        path = "game.lobby.recharge",
        param = 1
    }, -- vip 特权,
    RushRank = {
        id = 44,
        path = "game.lobby.rushRank",
    }, -- 冲榜活动
    ChatUnity = {
        id = 45,
        path = "game.other.msn",
        param = 3
    }, -- 聊天联盟频道
    NewYear = {
        id = 46,
        path = "game.activity.newYear",
    }, -- 新年礼包
    NewYearTips = {
        id = 47,
        path = "game.activity.newYear",
        param = true
    }, -- 新年礼包
    TreasureHouse = {
        id = 48,
        path = "game.activity.EventManager",
    }, -- 珍宝阁
}

function UI.show(module, params)

    if UI.isPath(module) then
        return UI.showNode(module)
    end

    local base = require(module)

    local ui = {}

    for k, v in pairs(base) do
        ui[k] = v
    end

    ui.cls = "UI.Class"

    if ui.res then
        if ui.parent then
            local parent = CS.UnityEngine.GameObject.Find(ui.parent)
            -- log(parent)
            ui.node = UI.showNode(parent.transform, ui.res)
        else
            ui.node = UI.showNode(ui.res)
        end
    end

    ui.pageName = module
    if ui.res and (not ui.node) then
        log("can't found res:" .. ui.res)
    end

    if ui:init(params) == "close" then
        return
    end

    if UI.list ~= nil and #UI.list > 0 then
        local temp = UI.list[#UI.list]
        if temp ~= nil and temp.onBack ~= nil then
            temp:onBack()
        end
    end

    local mainUI = UI.getUI("game.lobby.main")
    if mainUI and mainUI.onBack then
        mainUI:onBack()
    end

    table.insert(UI.list, ui)

    local name = UI.getPathName(module)
    UI.map[name] = ui
    return ui
end

function UI.getUI(module)
    local name = UI.getPathName(module)
    return UI.map[name]
end

function UI.isOnTop(pageName)
    return UI.list[#(UI.list)].pageName == pageName
end

function UI.openPage(name)
    local systemOpenConfig = config["systemOpen"]
    for i = 1, #systemOpenConfig do
        if systemOpenConfig[i].page == name.id then
            local isOpen = SystemOpen.systemIsUnlock(systemOpenConfig[i].id)

            if is_debug then
                isOpen = true;
            end

            if isOpen then
                if name.path == nil then
                    UI.showHint("该功能暂未开发")
                else
                    UI.show(name.path, name.param)
                end
            end
            log("系统开放")
            return
        end
    end

    local systemEventOpenConfig = config["systemEventOpen"]
    for i = 1, #systemEventOpenConfig do
        if systemEventOpenConfig[i].page == name.id then
            local isOpen = SystemEventOpen.systemEventIsOpen(systemOpenConfig[i].id)
            log(isOpen)
            if isOpen then
                if name.path == nil then
                    UI.showHint("该功能暂未开发")
                else
                    UI.show(name.path, name.param)
                end
            end
            return
        end
    end

    if name.path == nil then
        UI.showHint("该功能暂未开发")
    else
        UI.show(name.path, name.param)
    end

end

function UI.showOne(module)

    local name = UI.getPathName(module)

    if UI.map[name] then
        if UI.check(UI.map[name]) then
            return UI.map[name]
        end
    end

    UI.map[name] = UI.show(module)

    return UI.map[name]
end

function UI.getPathName(str)

    local keys = { '/', '\\' }

    local len = string.len(str)
    local pos = 0
    while pos < len do
        local lastPos = pos

        for _, v in ipairs(keys) do
            local foundPos = string.find(str, v, pos + 1)
            if foundPos then
                pos = foundPos
            end
        end

        if lastPos == pos then
            break
        end
    end

    return string.sub(str, pos + 1)
end

function UI.addProccessUpdate(node, childOrMax, max, time, fun, stopAll)

    if type(childOrMax) == "string" then
        local child = UI.child(node, childOrMax)
        if child == nil then
            log_call("can't child [" .. pathOrValue .. "] in:", node.name)
            return
        end
        node = child
    else
        stopAll = fun
        fun = time
        time = max
        max = childOrMax
    end

    local callFun = function(value)
        --log(value)
        if value then
            local newValue = math.floor(value)
            if math.abs(newValue - value) < 0.0001 then
                fun(newValue)
            else
                fun(math.floor(value))
            end
        else
            fun(value)
        end
    end

    CS.UIAPI.AddProccessUpdate(node, max, time, callFun, stopAll)
end

function UI.removeProcessUpdate(node)
    CS.UIAPI.RemoveProcessUpdate(node)
end

function UI.stopAnim(node)
    -- print(node)
    -- print(CS.UIAPI.PlayAnim)
    CS.UIAPI.StopAnim(node)
end

function UI.playAnim(node, anim, notLoop)
    -- print(node)
    -- print(CS.UIAPI.PlayAnim)
    CS.UIAPI.PlayAnim(node, anim, not notLoop);
end

function UI.isEndAnim(node)
    return CS.UIAPI.IsEndAnim(node);
end

function UI.getAnimFrame(node)
    return CS.UIAPI.GetAnimFrame(node);
end

function UI.isPath(str)
    local found1 = string.find(str, '/')
    local found2 = string.find(str, '\\')
    return (found1 or found2)
end

function UI.getOne(module)
    local name = UI.getPathName(module)

    if UI.map[name] then
        if UI.check(UI.map[name]) then
            return UI.map[name]
        end
    end
    return nil
end

function UI.showNode(parent, path, res)

    if res == nil then
        res = path
        path = nil
    end

    if res == nil then
        res = parent
        parent = nil
    end

    if path then
        if path ~= "" then
            local child = parent:Find(path)
            if child == nil then
                log_call("can't child [" .. path .. "] in:", parent.name)
                return
            end
            parent = child
        end
    end

    -- log(res, parent)

    local node = CS.UIAPI.Load(res, parent)
    CS.UIAPI.Show(node)

    for _, v in ipairs(resSound) do
        if string.find(res, v[1]) then
            CS.Sound.Play(v[2])
        end
    end

    if not node then
        log("can't find res:" .. res)
    end

    return node
end

function UI.closeAll()
    for _, ui in pairs(UI.list) do
        if UI.check(ui) then
            CS.UIAPI.Destroy(ui.node)
            ui.node = nil
        end
    end
    UI.list = {}
    UI.map = {}
    UI.clearChildren("Canvas/Center")

    SystemOpen.init()
    SystemEventOpen.init()
end

function UI.close(ui)
    if not UI.check(ui) then
        return
    end

    --[[    log("准备改变：")
        if IsTable(ui) then
            log(ui.node)
        else
            log(ui)
        end

        local listCount = #UI.list
        log("关闭页面前：" .. listCount)
        for i = 1, listCount do
            log(UI.list[i].node)
        end]]

    if ui.cls == "UI.Class" then
        if ui.onClose then
            ui:onClose()
        end

        local count = #UI.list

        while count > 0 do
            local temp = UI.list[count]
            if temp == ui then

                table.remove(UI.list, count)

                count = count - 1
                if count > 0 and count == #UI.list then
                    temp = UI.list[count]
                    if temp.onFront then
                        log("++++++RefreshUIOnFront++++++")
                        temp:onFront()
                    end
                end
                break
            else
                count = count - 1
            end

            --if UI.check(temp) then
            --    --break
            --end
        end

        CS.UIAPI.Destroy(ui.node)
        ui.node = nil
    else
        CS.UIAPI.Destroy(ui)
    end
    --[[    listCount = #UI.list
        log("关闭页面后：" .. #UI.list)
        for i = 1, listCount do
            log(UI.list[i].node)
        end]]
end

function UI.check(ui)

    if not ui then
        return false
    end
    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if not node then
        return false
    end
    -- logDebug("node",node)
    return CS.API.Check(node)
end

function UI.addUpdate(ui, fun)
    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end
    CS.UIAPI.AddUpdate(node, fun)
end

function UI.delay(ui, time, fun)
    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end
    return CS.UIAPI.Delay(node, time, fun)
end

function UI.stopDelay(ui, id)

    if type(id) ~= "number" then
        log("stopDelay id is not number!")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end
    CS.UIAPI.RemoveDelay(node, id)
end

function UI.showWaitting(delayTime)

    if not UI.check(UI.waittingNode) then
        UI.waittingNode = UI.showNode("Base/Waitting")
        UI.waittingNode:SetParent(frontParent)
    else
        if UI.waittingNode.gameObject.activeSelf then
            return
        end
        UI.enable(UI.waittingNode, true)
    end

    if not delayTime then
        delayTime = 0
    end

    local child = UI.child(UI.waittingNode, "Image")
    local d = child.gameObject:GetComponent(typeof(CS.Waitting))
    d.DisDlayTime = delayTime

end

function UI.closeWaitting()
    if UI.waittingNode then
        if UI.check(UI.waittingNode) then
            UI.close(UI.waittingNode)
        end
        UI.waittingNode = nil
    end
end

function UI.showMask()
    if not UI.check(UI.maskNode) then
        UI.maskNode = UI.showNode("Base/Mask")
    else
        UI.enable(UI.maskNode, true)
    end
end

function UI.closeMask()
    if UI.maskNode then
        if UI.check(UI.maskNode) then
            UI.close(UI.maskNode)
        end
        UI.maskNode = nil
    elseif UI.isVisual(CS.UIAPI.gNode, "Mask") then
        local node = CS.UIAPI.gNode:Find("Mask")
        UI.enable(node, false)
    end
end

function UI.showHint(msg, offsetY)
    local node = UI.showNode("Base/hint")

    UI.text(node, "Text", msg)

    for i = 0, node.childCount - 1 do
        local child = node:GetChild(i)
        if offsetY ~= nil then
            child.localPosition = CS.UnityEngine.Vector3(0, child.localPosition.y + offsetY, 0)
        end
        CS.UIAPI.SetAlpha(child, 0);
        CS.UIAPI.TweenAlpha(child, 1, 0.5);
    end

    UI.delay(node, 2, function()
        for i = 0, node.childCount - 1 do
            local child = node:GetChild(i)
            CS.UIAPI.TweenAlpha(child, 0, 0.5);
        end
        UI.delay(node, 1, function()
            UI.close(node)
        end)
    end)
end

function UI.tweenList(ui, pathOrValue, values)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if IsStr(pathOrValue) then
        node = UI.child(node, pathOrValue)
    else
        values = pathOrValue
    end

    UI.tweenListFun(node, values)
end

function UI.tweenListFun(topNode, values, i)
    if not i then
        i = 1
    end

    local node = topNode
    if values[i].node then
        node = UI.child(node, values[i].node)
    end

    local time = 0

    if values[i].time then
        time = values[i].time
    end

    if values[i].type == "enableAll" then
        UI.enableAll(node, values[i].value)
    end

    if values[i].type == "scale" then
        CS.UIAPI.TweenScale(node, values[i].value, time);
    end

    if values[i].type == "alphaAll" then
        CS.UIAPI.TweenAlphaAll(node, values[i].value, time);
    end

    if values[i].type == "alpha" then
        CS.UIAPI.TweenAlpha(node, values[i].value, time);
    end

    if values[i].type == "position" then
        local p = values[i].pos
        local o = node.localPosition
        if p.x == nil then
            p.x = o.x;
        end
        if p.y == nil then
            p.y = o.y;
        end
        if p.z == nil then
            p.z = o.z;
        end
        CS.UIAPI.TweenPos(node, CS.UnityEngine.Vector3(p.x, p.y, p.z), time);
    end

    if values[i].type == "offset" then
        local p = values[i].pos
        local o = node.localPosition
        if p.x == nil then
            p.x = 0;
        end
        if p.y == nil then
            p.y = 0;
        end
        if p.z == nil then
            p.z = 0;
        end
        CS.UIAPI.TweenPos(node, CS.UnityEngine.Vector3(o.x + p.x, o.y + p.y, o.z + p.z), time);
    end

    if values[i].type == "delete" then
        UI.close(node)
        return
    end

    if values[i].rotation then
        local p = values[i].rotation
        if p.x == nil then
            p.x = 0
        end
        if p.y == nil then
            p.y = 0
        end
        if p.z == nil then
            p.z = 0
        end
        CS.UIAPI.TweenRotation(node, CS.UnityEngine.Vector3(p.x, p.y, p.z), time);
    end

    if values[i].position then
        local p = values[i].position
        local o = node.localPosition
        if p.x == nil then
            p.x = o.x;
        end
        if p.y == nil then
            p.y = o.y;
        end
        if p.z == nil then
            p.z = o.z;
        end
        CS.UIAPI.TweenPos(node, CS.UnityEngine.Vector3(p.x, p.y, p.z), time);
    end

    if values[i].offset then
        local p = values[i].offset
        local o = node.localPosition
        if p.x == nil then
            p.x = 0;
        end
        if p.y == nil then
            p.y = 0;
        end
        if p.z == nil then
            p.z = 0;
        end
        if time <= 0 then
            node.localPosition = CS.UnityEngine.Vector3(o.x + p.x, o.y + p.y, o.z + p.z)
        else
            CS.UIAPI.TweenPos(node, CS.UnityEngine.Vector3(o.x + p.x, o.y + p.y, o.z + p.z), time);
        end
    end

    if values[i].shake then
        CS.UIAPI.TweenShake(node, values[i].shake, time);
    end

    if values[i].shakeOne then
        CS.UIAPI.TweenShake(node, values[i].shakeOne, time, false);
    end

    if values[i].scale then
        CS.UIAPI.TweenScale(node, values[i].scale, time);
    end

    if values[i].addScale then
        CS.UIAPI.TweenAddScale(node, values[i].addScale, time);
    end

    if values[i].alpha then
        CS.UIAPI.TweenAlpha(node, values[i].alpha, time);
    end

    if values[i].alphaAll then
        CS.UIAPI.TweenAlphaAll(node, values[i].alphaAll, time);
    end

    if values[i].fun then
        values[i].fun(node)
    end

    if values[i].waitTime then
        time = values[i].waitTime
    end

    if i < #values then
        if time <= 0 then
            UI.tweenListFun(topNode, values, i + 1)
        else
            UI.delay(node, time, function()
                UI.tweenListFun(topNode, values, i + 1)
            end)
        end
    end
end

function UI.msgBoxTitle(title, msg, fnYes, fnNo)
    local node = UI.msgBox(msg, fnYes, fnNo)
    UI.text(node, "Title", title)
    return node
end

function UI.msgBoxTitleBtnText(title, msg, yesText, noText, fnYes, fnNo)
    local node = UI.msgBoxTitle(title, msg, fnYes, fnNo)
    UI.text(node, "BtnYes/Text", yesText)
    UI.text(node, "BtnNo/Text", noText)
end

function UI.msgBox(msg, fnYes, fnNo)
    local node
    if fnNo then
        node = UI.showNode("Base/MsgBox2")
        if fnYes then
            UI.button(node, "BtnYes", function()
                fnYes()
                UI.close(node)
            end)
        else
            UI.button(node, "BtnYes", function()
                UI.close(node)
            end)
        end
        local closeFun = function()
            fnNo()
            UI.close(node)
        end
        UI.button(node, "BtnNo", closeFun)
        UI.button(node, "BtnClose", closeFun)
    else
        node = UI.showNode("Base/MsgBox1")
        local closeFun
        if fnYes then
            closeFun = function()
                fnYes()
                UI.close(node)
            end
        else
            closeFun = function()
                UI.close(node)
            end
        end
        UI.button(node, "BtnYes", closeFun)
        UI.button(node, "BtnClose", closeFun)
    end

    UI.text(node, "Text", msg)

    return node
end

function UI.showCopyBox(copyMsg, reminder, btnText)
    local node = UI.showNode("Base/copyBox")
    local closeFun = function()
        CS.UIAPI.copyToClipBoard(copyMsg)
        UI.showHint("内容已拷贝到剪切板")
        UI.close(node)
    end
    UI.button(node, "BtnYes", closeFun)
    UI.text(node, "Text", copyMsg)
    UI.text(node, "reminder", reminder)
    UI.text(node, "BtnYes/Text", btnText)
    return node
end

function UI.showCounterBox(msg, counter, btnText, yesFun, closeFun, timeOverFunc)
    local node = UI.showNode("Base/MsgBox1")
    local closeFun = function()
        UI.close(node)
        closeFun()
    end

    local yesFun = function()
        UI.close(node)
        yesFun()
    end

    local counterOver = function()
        print("回调 counterOver")
        if timeOverFunc ~= nil then
            timeOverFunc()
        end
        UI.text(node, "BtnYes/Text", btnText)
        UI.button(node, "BtnYes", yesFun)
    end

    UI.txtUpdateTime2(node, "BtnYes/Text"
    , counter, counterOver, btnText .. "(", ")")
    UI.button(node, "BtnClose", closeFun)
    UI.text(node, "Text", msg)
    return node
end

function UI.msgBoxNoCloseBtn(title, msg, fnYes)
    local node = UI.showNode("Base/MsgBox1")
    UI.button(node, "BtnYes", function()
        fnYes()
        UI.close(node)
    end)
    UI.text(node, "Text", msg)
    UI.text(node, "Title", title)
    UI.enable(node, "BtnClose", false)
end

function UI.progress(ui, pathOrValue, value)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if value ~= nil then
        local child = UI.child(ui, pathOrValue)

        if child == nil then
            log_call("can't child [" .. pathOrValue .. "] in:", node.name)
            return
        end

        node = child
    else
        value = pathOrValue
    end

    local slider = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Slider))
    if slider then
        slider.value = value
    else
        log_call("can't find UI.Text in:", node.name)
    end
end

function UI.text(ui, pathOrValue, value)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if value ~= nil then
        local child = UI.child(node, pathOrValue)
        if child == nil then
            log_call("can't child [" .. pathOrValue .. "] in:", node.name)
            return
        end

        node = child
    else
        value = pathOrValue
    end

    local textUI = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Text))
    if textUI then
        textUI.text = value
        return
    else
        -- log("can't find UI.Text in:",node.name)
    end

    textUI = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.InputField))
    if textUI then
        textUI.text = value
        return
    else
        log_call("can't find UI.InputField or UI.Text in:" .. node.name)
    end
end
-- 改变文本颜色用  用于文本组件
-- str要更改的字体
-- color 颜色代码 可为空
-- size  字体大小  可为空
function UI.colorStr(str, color, size)
    if color ~= nil then
        if not tostring(color) then
            error("错误！颜色不为字符串类型")
            return
        else
            color = tostring(color);
            str = "<color=#" .. color .. ">" .. str .. "</color>"
        end
    end
    if size ~= nil then
        if not tonumber(size) then
            error("错误！大小必须为数字")
            return
        else
            size = tonumber(size)
            str = "<size=" .. size .. ">" .. str .. "</size>";
        end
    end
    if color ~= nil and size ~= nil then
        color = tostring(color);
        size = tonumber(size);
        str = "<color=#" .. color .. "><size=" .. size .. ">" .. str .. "</size></color>"
    end
    return str;
end

function UI.rawImage(ui, pathOrValue, res, cache)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if res ~= nil then
        local child = UI.child(node, pathOrValue)

        if child == nil then
            log_call("can't child " .. pathOrValue .. " in:", node.name)
            return
        end

        node = child
    else
        res = pathOrValue
    end

    if cache == nil then
        cache = true
    end
    CS.UIAPI.RawImage(node, res, cache)
end

function UI.rawImageResize(ui, pathOrValue, res, cache)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if res ~= nil then
        local child = UI.child(node, pathOrValue)

        if child == nil then
            log_call("can't child " .. pathOrValue .. " in:", node.name)
            return
        end

        node = child
    else
        res = pathOrValue
    end

    if cache == nil then
        cache = true
    end
    CS.UIAPI.RawImageResize(node, res, cache)
end

function UI.image(ui, pathOrValue, value, index)
    UI.sprite(ui, pathOrValue, value, index)
end

function UI.sprite(ui, pathOrValue, value, index)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if index ~= nil then
        local child = UI.child(node, pathOrValue)

        if child == nil then
            log_call("can't child " .. pathOrValue .. " in:", node.name)
            return
        end

        node = child

    else
        index = value
        value = pathOrValue
    end

    if type(index) == "string" then
        return CS.Images.SetSpriteKey(node, value, index)
    else
        return CS.Images.SetSprite(node, value, index)
    end
end

function UI.changAnimSlot(ui, path, res, slot, replaceName)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if replaceName ~= nil then
        local child = UI.child(node, pathOrValue)

        if child == nil then
            log_call("can't child " .. pathOrValue .. " in:", node.name)
            return
        end

        node = child

    else
        index = value
        replaceName = slot
        slot = res
        res = path
    end

    CS.UIAPI.ChangAnimSlot(node, res, slot, replaceName)
end
-- 可以添加事件的组件有 button toggle InputField.onEndEdit
function UI.button(ui, childOrfun, fun)
    if not UI.check(ui) then
        log_call('无效UI')
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if type(childOrfun) == "string" or type(childOrfun) == "number" then
        local child = UI.child(ui, childOrfun, true)
        if not child then
            log("can't find child " .. childOrfun .. " in " .. node.name)
            return
        end
        node = child
    else
        fun = childOrfun
    end

    local ipt = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.InputField))
    if ipt ~= nil then
        ipt.onEndEdit:RemoveAllListeners();
        ipt.onEndEdit:AddListener(fun);
        return ;
    end
    -- print(node.gameObject.name)
    local button = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Button))
    if not button then
        button = node.gameObject:AddComponent(typeof(CS.UnityEngine.UI.Button))
    end
    button.onClick:RemoveAllListeners()

    local onDown = node.gameObject:GetComponent(typeof(CS.OnPointDown))
    if not onDown then
        onDown = node.gameObject:AddComponent(typeof(CS.OnPointDown))
    end

    if fun then
        button.onClick:AddListener(fun)
        onDown:SetDown(UI.playClick)
    else
        onDown:SetDown(nil)
    end
end

function UI.playClick()
    CS.Sound.Play("effect/button")
end

function UI.buttonMulti(ui, childOrfun, fun)
    if not UI.check(ui) then
        log_call('无效UI')
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if fun ~= nil then
        node = UI.child(ui, childOrfun)
    else
        fun = childOrfun
    end

    -- print(node.gameObject.name)
    local button = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Button))
    if not button then
        button = node.gameObject:AddComponent(typeof(CS.UnityEngine.UI.Button))
    end
    button.onClick:AddListener(fun)
end

function UI.rmButtonListener(ui, childOrFun, fun)
    if not UI.check(ui) then
        log_call('无效UI')
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if fun ~= nil then
        node = UI.child(ui, childOrFun)
    else
        fun = childOrFun
    end

    -- print(node.gameObject.name)
    local button = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Button))
    if not button then
        button = node.gameObject:AddComponent(typeof(CS.UnityEngine.UI.Button))
    end
    button.onClick:RemoveListener(fun)
end

function UI.toggle(ui, childOrfun, fun, callWhenFalse)
    if not UI.check(ui) then
        log_call('无效UI')
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end
    if IsStr(childOrfun) then
        node = UI.child(ui, childOrfun);
    else
        fun = childOrfun;
    end

    local toggle = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Toggle))
    callWhenFalse = callWhenFalse and true or false
    if toggle ~= nil then
        CS.UIAPI.ToggleFun(node, fun, nil, callWhenFalse);
    end

    local onDown = node.gameObject:GetComponent(typeof(CS.OnPointDown))
    if not onDown then
        onDown = node.gameObject:AddComponent(typeof(CS.OnPointDown))
    end

    if fun then
        --toggle.onClick:AddListener(fun)
        onDown:SetDown(UI.playClick)
    else
        onDown:SetDown(nil)
    end
end
function UI.slider(ui, pathOrFun, value)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if value ~= nil then
        local child = node:Find(pathOrFun)
        if not child then
            log_call("can't find node " .. pathOrFun .. " in " .. node.name)
            return
        end

        node = child
    else
        value = pathOrFun
    end

    -- log(node.gameObject.name)
    local slider = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Slider))
    if slider then

        if value.maxValue then
            slider.maxValue = value.maxValue
        end

        if value.minValue then
            slider.minValue = value.minValue
        end

        if value.value then
            slider.value = value.value
        end

        if value.fun then
            CS.UIAPI.AddOnValueChanged(node, value.fun)
        end
    else
        log_call("can't find UI.Slider in:", node.name)
    end
end

function UI.getValueInt(ui, path)
    local ret = UI.getValue(ui, path)
    return tonumber(ret)
end

function UI.getChildIndex(ui)
    return CS.UIAPI.GetChildIndex(ui)
end

function UI.getValue(ui, path)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if path then
        node = UI.child(node, path)
    end

    local uiCom = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Text))
    if uiCom then
        local ret = uiCom.text
        if ret == "" then
            return ""
        else
            return ret
        end
    end

    uiCom = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.InputField))
    if uiCom then
        local ret = uiCom.text
        if ret == "" then
            return ""
        else
            return ret
        end
    end

    return nil
end

function UI.setValue(ui, pathOrValue, value)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if value == nil then
        value = pathOrValue
    else
        node = UI.child(node, pathOrValue)
    end

    local uiCom = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Text))
    if uiCom then
        uiCom.text = value
    end

    uiCom = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.InputField))
    if uiCom then
        uiCom.text = value
    end

    return defValue
end

function UI.enableImage(ui, value, value2)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if value2 ~= nil then
        node = node:Find(value)
        if not node then
            log_call("can't find node " .. value)
            return
        end

        value = value2
    end

    local image = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Image))
    image.enabled = value
end

function UI.enableRawImage(ui, value, value2)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if value2 ~= nil then
        node = node:Find(value)
        if not node then
            log_call("can't find node " .. value)
            return
        end

        value = value2
    end

    local image = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.RawImage))
    image.enabled = value
end

function UI.enable(ui, pathOrValue, value)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    -- log(pathOrValue,value)     

    if type(pathOrValue) == "boolean" then
        value = pathOrValue
    else
        local child = UI.child(node, pathOrValue, true)
        if not child then
            log_call("can't find[" .. pathOrValue .. "] in node " .. node.name)
            return
        end
        node = child
        if value == nil then
            value = true
        end
    end
    -- log(node)    
    -- log(pathOrValue,value)      
    node.gameObject:SetActive(value)
end

function UI.enableOne(ui, pathOrIndex, index)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    -- log(ui,pathOrIndex,index)
    if index ~= nil then
        node = UI.child(node, pathOrIndex)
        if not node then
            log_call("can't find node " .. value)
            return
        end
    else
        index = pathOrIndex
    end

    if not IsNum(index) then
        log_call("index is nil")
    end
    -- log(node)

    UI.enableAll(node, false)
    UI.enable(node, index, true)
end

function UI.enableAll(ui, pathOrValue, value)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if IsStr(pathOrValue) then
        node = UI.child(node, pathOrValue)
    else
        value = pathOrValue
    end

    CS.UIAPI.EnableAll(node, value)
end

function UI.showByChildCount(ui, pathOrFun, countNode, fun)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if IsStr(pathOrFun) then
        node = UI.child(node, pathOrFun)
    else
        fun = pathOrFun
    end

    local childCount = 0

    if countNode then
        for i = 1, countNode.childCount do
            local child = UI.child(countNode, i - 1)
            if child.gameObject.activeSelf then
                childCount = childCount + 1
                --log(child.name .. "激活")
            else
                --log(child.name .. "未激活")
            end
        end
    else
        childCount = node.childCount
    end
    --log(node.name .. "childCount:" .. childCount)
    if childCount > 0 then
        if fun then
            UI.button(node, fun)
        end
        UI.enable(node, true)
    else
        UI.enable(node, false)
    end
end

function UI.clone(node)
    return CS.UIAPI.Clone(node)
end

function UI.cloneChild(node, count, index, cloneNode)
    if index and cloneNode == nil then
        cloneNode = UI.child(node, index)
    end
    CS.UIAPI.CloneChild(node, count, index, cloneNode)
end

function UI.setAsLastChild(node)
    CS.UIAPI.SetAsLastChild(node)
end

function UI.isVisual(ui, path)
    if not UI.check(ui) then
        return false
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if path then
        node = UI.child(node, path, true)
    end

    if not node then
        return false
    end

    return node.gameObject.activeSelf
end

function UI.child(ui, path, dontDisError)
    if not UI.check(ui) then
        log_call("ui is nil")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    local ret = node

    if path ~= nil then
        if type(path) == "string" then
            ret = node:Find(path)
        else
            if path < node.childCount then
                ret = node:GetChild(path)
            else
                ret = nil
            end
        end

        if not ret then
            if dontDisError then
            else
                log_call("can't find[" .. path .. "] in node " .. node.name)
            end
        end
    end

    return ret
end

function UI.setLocalScale(node, x, y, z)
    if x == nil then
        x = node.localScale.x;
    end
    if y == nil then
        y = node.localScale.y;
    end
    if z == nil then
        z = node.localScale.z;
    end
    node.localScale = CS.UnityEngine.Vector3(x, y, z)
end

function UI.setLocalPosition(node, x, y, z)
    if x == nil then
        x = node.localPosition.x;
    end
    if y == nil then
        y = node.localPosition.y;
    end
    if z == nil then
        z = node.localPosition.z;
    end
    node.localPosition = CS.UnityEngine.Vector3(x, y, z)
end

function UI.setLocalOffset(node, x, y, z)
    if x == nil then
        x = 0;
    end
    if y == nil then
        y = 0;
    end
    if z == nil then
        z = 0;
    end
    local p = node.localPosition
    node.localPosition = CS.UnityEngine.Vector3(p.x + x, p.y + y, p.z + z)
end

function UI.setRotation(node, x, y, z)
    CS.UIAPI.SetRotation(node, x, y, z)
end

function UI.setGray(ui, path)
    local node = UI.child(ui, path)
    CS.UIAPI.SetGray(node)
end

function UI.clearGray(ui, path)
    local node = UI.child(ui, path)
    CS.UIAPI.ClearGray(node)
end

function UI.draw(ui, pathOrDatas, datas)
    if not UI.check(ui) then
        log_call("draw child input ui is nil")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    local ret = node

    if datas ~= nil then
        local child = UI.child(node, pathOrDatas)

        if not child then
            log_call("can't find[" .. pathOrDatas .. "] in node " .. node.name)
        end

        node = child
    else
        datas = pathOrDatas
    end
    UI.drawFun(node, datas)
end

function UI.drawFun(node, datas)

    local count = #datas

    if count > 0 or next(datas) == nil then

        local lastCount = CS.UIAPI.GetCloneLastCount(node)
        if lastCount > 0 then
            CS.UIAPI.CloneChildLast(node, count, lastCount)
        end
    end

    for i, v in pairs(datas) do
        local child
        if type(i) == "number" then
            child = node:GetChild(i - 1)
        else
            child = node:Find(i)
        end

        if child then
            local needChild = CS.UIAPI.GetNeedToChild(child)
            if needChild then
                child = needChild
            end

            local t = type(v)

            if t == "table" then
                local slider = child.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Slider))
                if slider then
                    log(child.name)
                    log(v)
                    UI.slider(child, v)
                else
                    UI.drawFun(child, v)
                end
                UI.enable(child, true)
            elseif t == "number" then
                local disType = CS.UIAPI.GetDisType(child)
                local key = CS.UIAPI.GetResName(child)

                if key then
                    if disType == "Anim" then
                        if key == "hero" then
                            HeroTools.showAnim(child, v)
                        else
                            local animNode = child:Find("_animNode")
                            if animNode then
                                UI.close(animNode)
                            end

                            local node = UI.showNode(child, "Anim/" .. key .. v)
                            UI.playAnim(node, "idle")
                            node.name = "_animNode"
                        end
                        UI.enable(child, true)
                    else
                        local rawImage = child.gameObject:GetComponent(typeof(CS.UnityEngine.UI.RawImage))
                        if rawImage then
                            if v > 0 then
                                UI.rawImage(child, key .. v)
                                UI.enable(child, true)
                            end

                        else
                            if key == "HeroHead" then
                                HeroTools.setHeadSprite(child, v)
                                UI.enable(child, true)
                            elseif key == "CHeroHead" then
                                HeroTools.setCHeadSprite(child, v)
                                UI.enable(child, true)
                            else
                                if UI.sprite(child, key, v) then
                                    UI.enable(child, true)
                                else
                                    UI.enable(child, false)
                                end
                            end
                        end
                    end
                else
                    local slider = child.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Slider))
                    if slider then
                        if disType == "AnimSlider" then
                            CS.UIAPI.AnimSlider(child, v)
                        else
                            slider.value = v
                        end
                    else

                        if disType == "CountDownTimer" then
                            UI.txtUpdateTime(child, v)
                        elseif disType == "DateTime" then
                            v = os.date("%Y-%m-%d %H:%M:%S", math.floor(v / 1000))
                            UI.text(child, v)
                        else
                            UI.text(child, v)
                        end
                    end
                    UI.enable(child, true)
                end
            elseif t == "function" then
                UI.button(child, v)
                UI.enable(child, true)
            elseif v == true or v == false then
                UI.enable(child, v)
            else

                local disType = CS.UIAPI.GetDisType(child)
                local key = CS.UIAPI.GetResName(child)

                if disType == "Image" then
                    local rawImage = child.gameObject:GetComponent(typeof(CS.UnityEngine.UI.RawImage))
                    if rawImage then
                        UI.rawImage(child, key .. v)
                    else
                        if key == "CHeroHead" then
                            HeroTools.setCHeadSprite(child, v)
                        else
                            if UI.sprite(child, key, v) then
                                UI.enable(child, true)
                            else
                                UI.enable(child, false)
                            end
                        end
                    end
                elseif disType == "Anim" then
                    local animNode = child:Find("_animNode")
                    if animNode then
                        UI.close(animNode)
                    end

                    local node = UI.showNode(child, "Anim/" .. key .. v)
                    UI.playAnim(node, "idle")
                    node.name = "_animNode"
                else
                    UI.enable(child, true)
                    UI.text(child, v)
                end
            end
        end
    end
end

function UI.drawAppend(ui, pathOrDatas, oldDatas, newDatas)
    if not UI.check(ui) then
        log_call("child input ui is nil")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    local ret = node

    if type(pathOrDatas) == "string" then
        local child = UI.child(node, pathOrDatas)

        if not child then
            log_call("can't find[" .. pathOrDatas .. "] in node " .. node.name)
        end

        node = child
    else
        newDatas = oldDatas
        oldDatas = pathOrDatas
    end

    local needChild = CS.UIAPI.GetNeedToChild(node)
    if needChild then
        node = needChild
    end

    local count = #newDatas + #oldDatas
    UI.cloneChild(node, count)

    for i, v in ipairs(newDatas) do
        local child = node:GetChild(#oldDatas + i - i)
        UI.drawFun(child, v)
    end

    for i, v in ipairs(newDatas) do
        table.insert(oldDatas, v)
    end
end

function UI.replaceImage(ui, path1, path2)
    if not UI.check(ui) then
        log_call("child input ui is nil")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if type(path1) == "string" then
        local node1 = UI.child(node, path1)
        local node2 = UI.child(node, path2)
        CS.UIAPI.ReplaceImage(node1, node2)
    else
        CS.UIAPI.ReplaceImage(node, path1)
    end
end

-- 时间更新  设置文本
function UI.txtUpdateTime(ui, pathOrValue, value, fun)
    if not UI.check(ui) then
        log_call("child input ui is nil")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if IsStr(pathOrValue) then
        node = UI.child(node, pathOrValue);
    else
        fun = value;
        value = pathOrValue;
    end
    CS.TxtTime.SetShowTxtTime(node, value, fun);
end

function UI.txtUpdateTime2(ui, pathOrValue, value, fun, prefix, ending)
    if not UI.check(ui) then
        log_call("child input ui is nil")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if IsStr(pathOrValue) then
        node = UI.child(node, pathOrValue);
    else
        fun = value;
        value = pathOrValue;
    end
    CS.TxtTime.SetShowTxtTime(node, value, fun, prefix, ending);
end

-- 时间更新  设置文本
function UI.CountDown(ui, pathOrValue, value, fun, type, visual, server)
    if not UI.check(ui) then
        log_call("countDown child input ui is nil")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if IsStr(pathOrValue) then
        node = UI.child(node, pathOrValue)
    else
        visual = type
        type = fun
        fun = value
        value = pathOrValue
    end

    if visual == nil then
        visual = true
    end

    if type == nil then
        type = 0
    end

    if server == nil then
        server = true
    end

    CS.CountDown.SetCountDownTimer(node, value, type, visual, server, fun)
end

---移除某个组件
---@param ui any 节点
---@param pathOrValue any 路径或者组件
---@param com any  组件
---@param delay any 延时（秒）
function UI.desObj(ui, pathOrValue, com, delay)
    if not UI.check(ui) then
        log_call("child input ui is nil")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end
    if com == nil then
        delay = com;
        com = pathOrValue;
    else
        node = UI.child(node, pathOrValue);
    end
    local component = node.gameObject:GetComponent(typeof(com))
    if component ~= nil then
        if delay == nil then
            delay = 0;
        end
        CS.UnityEngine.Object.Destroy(component, delay)
    end
end
--- 显示提示页面
---@param strMainTip any 不能为空  字符串
---@param itemID any 可以为空 空不显示返还物品页面
function UI.ShowTipReturnItem(strMainTip, itemID, count)
    local node = UI.showNode("Base/tipReturnItem")
    UI.button(node, "btnClose", function()
        UI.close(node)
    end)
    UI.text(node, "txtbg/txtMain", strMainTip);
    if itemID ~= nil then
        UI.enable(node, "Item", true);
        UI.image(node, "Item/item", "Item", itemID);
        local itemName = config.item[itemID].name;
        UI.text(node, "Item/itemName", itemName .. " X" .. count);
    end
end
--- 设置toggle为选中
function UI.SetToggleIsOn(ui, pathOrValue)
    local toggle = UI.child(ui, pathOrValue);
    CS.UIAPI.ToggleIsOn(toggle);
end

function UI.dragBottom(ui, pathOrFun, fun)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if type(pathOrFun) == "function" then
        fun = pathOrFun
    else
        node = UI.child(node, pathOrFun)
    end
    CS.UIAPI.AddViewDragBottom(node, fun)
end

function UI.addFresh(ui, pathOrFun)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if pathOrFun then
        node = UI.child(node, pathOrFun)
    end

    local node = UI.showNode(node, "Base/fresh")
    node.name = "_fresh"
end

function UI.delFresh(ui, pathOrFun)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if pathOrFun then
        node = UI.child(node, pathOrFun)
    end

    local childCount = node.childCount

    if childCount >= 1 then
        local node = node:GetChild(childCount - 1)
        if node.name == "_fresh" then
            UI.close(node)
        end
    end
end

function UI.ShowCatchPrisoner(prisonerId, fun)
    local pageRoot = UI.showNode("base/CatchPrisoner")
    local config = config["prisoner"][prisonerId]
    UI.button(pageRoot, function()
        UI.close(pageRoot)
        if fun then
            fun()
        end
    end)
    UI.enable(pageRoot, true)
    UI.rawImage(pageRoot, "icon", "character/storyShowCharacter" .. config.head)
    UI.text(pageRoot, "name", config.name)
end

-- 格式化  5/10 这种文本
-- 数量不够用红色，或者给出得颜色
function UI.formatCountText(count, need, color)

    if not color then
        color = "#FF2900"
    end

    if count >= need then
        return count .. "/" .. need
    else
        return "<color=" .. color .. ">" .. count .. "/" .. need .. "</color>"
    end
end

function UI.showItemInfo(item)
    if IsNum(item) then
        local itemNode = UI.show("Base/ItemInfo")
        local cfg = config.itemMap[item];
        UI.image(itemNode, "icon", "Item", "item" .. cfg.icon)
        UI.text(itemNode, "name", cfg.name)
        UI.text(itemNode, "des", cfg.description)
        UI.button(itemNode, "BtnClose", function()
            UI.close(itemNode)
        end)
    else
        local itemNode = UI.show("Base/ItemInfo")
        UI.image(itemNode, "icon", "Item", "item" .. item.icon)
        UI.text(itemNode, "name", item.name)
        UI.text(itemNode, "des", item.des)
        UI.button(itemNode, "BtnClose", function()
            UI.close(itemNode)
        end)
    end
end

function UI.showItemEffect(node, visual)
    if not UI.check(node) then
        log_call("itemEffect node is nil")
        return
    end
    local effect = node:Find("effect")

    if effect then
        UI.enable(effect, visual)
        return
    end

    if visual then
        UI.showNode(node, "Effect/itemEffect").name = "effect"
    end
end

function UI.playEffect(ui, childOrValue, res, time)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if time == nil then
        if res == nil then
            res = childOrValue
            time = 3
        else
            if type(res) == "number" then
                time = res
                res = childOrValue
            else
                node = UI.child(node, childOrValue)
                time = 3
            end
        end
    else
        node = UI.child(node, childOrValue)
    end

    local effect = UI.showNode(node, "Effect/" .. res)
    UI.delay(CS.UIAPI.gNode, time, function()
        UI.close(effect)
    end)
    return node;
end

function UI.showHeroInfo(heroid)
    local itemNode = UI.show("Base/ItemInfo")
    local cfg = config.heroMap[heroid];
    UI.image(itemNode, "icon", "HeroHead", "hero_square_small_" .. cfg.head)
    UI.text(itemNode, "name", cfg.name)
    UI.text(itemNode, "des", cfg.description)
    UI.button(itemNode, "BtnClose", function()
        UI.close(itemNode)
    end)
end
function UI.showWifeInfo(wifeid)
    local itemNode = UI.show("Base/ItemInfo")
    local cfg = config.wifeMap[wifeid];
    UI.image(itemNode, "icon", "WifeHead", "wife_new_" .. wifeid)
    UI.text(itemNode, "name", cfg.name)
    UI.text(itemNode, "des", cfg.describe)
    UI.button(itemNode, "BtnClose", function()
        UI.close(itemNode)
    end)
end

function UI.setScale(node, x, y, z)
    CS.UIAPI.SetScale(node, x, y, z);
end
function UI.setScaleX(node, x)
    CS.UIAPI.SetScaleX(node, x);
end
function UI.setScaleY(node, y)
    CS.UIAPI.SetScaleY(node, y);
end
function UI.setScaleZ(node, z)
    CS.UIAPI.SetScaleZ(node, z);
end
--- 遍历替换字符串  
---@param str any 需要替换的字符串
---@param table_ any 替换字符串的表
---@param num any 替换数  可选
function UI.gsub(str, table_, num)
    if not IsTable(table_) then
        log_call("table_ not table")
        return ;
    end
    if not IsStr(str) then
        log_call("str not string")
        return ;
    end
    if num == nil then
        num = 1;
    end

    for key, value in pairs(table_) do
        str = string.gsub(str, tostring(key), tostring(value), num);
    end
    return str;
end

function UI.setAlpha(ui, pathOrValue, value)
    if not UI.check(ui) then
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if IsStr(pathOrValue) then
        node = UI.child(node, pathOrValue)
    else
        value = pathOrValue
    end

    CS.UIAPI.SetAlpha(node, value);
end
---隐藏或显示单独组件
---@param ui any 节点
---@param pathOrValue any 路径或者组件
---@param com any  组件
---@param value any true或false
function UI.enableCom(ui, pathOrValue, com, value)
    if not UI.check(ui) then
        log_call("child input ui is nil")
        return
    end

    local node
    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end
    if value == nil then
        value = com;
        com = pathOrValue;
    else
        node = UI.child(node, pathOrValue);
    end
    local component = node.gameObject:GetComponent(typeof(com))
    if component ~= nil then
        component.enabled = value;
    end
end

function UI.showPlayerAnim(AnimNode, res, body, head)
    local animNode = AnimNode:Find("_animNode")
    if animNode then
        UI.close(animNode)
    end

    local node = UI.showNode(AnimNode, "Anim/" .. res .. body)
    UI.playAnim(node, "idle")
    UI.changAnimSlot(node, res .. body, "191", "" .. head)
    node.name = "_animNode"
end

function UI.component(ui, path, componentType, dontDisError)
    local node = UI.child(ui, path, dontDisError)
    if node then
        local com = node.gameObject:GetComponent(componentType)
        if com == nil and not dontDisError then
            log_call("cant find component ：" .. componentType .. "on" .. ui.name .. "/" .. path)
        end
        return com
    end
end

function UI.component2(ui, componentType, dontDisError)
    if ui then
        local com = ui.gameObject:GetComponent(componentType)
        if com == nil and not dontDisError then
            log_call("cant find component ：" .. componentType .. "on" .. ui.name)
        end
        return com
    end
end

function UI.refreshSVC(ui, pathOrValue, value, change)

    if not UI.check(ui) then
        return
    end

    local node

    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    if type(pathOrValue) == "boolean" then
        value = pathOrValue
    else
        local child = UI.child(node, pathOrValue, true)
        if not child then
            log_call("can't find[" .. pathOrValue .. "] in node " .. node.name)
            return
        end
        node = child
        if value == nil then
            value = true
        end
    end

    if node and value then
        CS.UIAPI.RefreshSVC(node, change);
    end
end

function UI.clearChildren(path)
    local node = CS.UnityEngine.GameObject.Find(path)
    if node then
        node.transform:DetachChildren()
    end
end

function UI.deleteNode(path)
    local node = CS.UnityEngine.GameObject.Find(path)
    if node then
        CS.UnityEngine.Object.Destroy(node)
    end
end

function UI.TextSpacing(ui, path, strSpacing, numSpacing)
    if not UI.check(ui) then
        return
    end

    local node

    if ui.cls == "UI.Class" then
        node = ui.node
    else
        node = ui
    end

    local child = UI.child(node, path, true)

    if child.gameObject:GetComponent(typeof(CS.TextSpacing)) then
        return
    else
        local com = child.gameObject:AddComponent(typeof(CS.TextSpacing))
        com.Spacing = strSpacing
        com.NumberSpacing = numSpacing
    end
end

function UI.showMsgTips(icon, content, parent, x, y)
    local msgTipName = "msgTip--"
    local child = UI.child(parent, msgTipName, true)
    if child then
        UI.enable(child, true)
        return
    end

    local node = UI.showNode(parent, "base/MsgTip")
    local root = UI.child(node, "root")
    UI.enable(root, "iconPolitics", icon == "politics")
    UI.enable(root, "iconWife", icon == "wife")
    UI.enable(root, "iconChild", icon == "child")
    UI.enable(root, "iconBusiness", icon == "business")
    UI.enable(root, "Text", false)
    node.localPosition = CS.UnityEngine.Vector3(x, y, 0)

    local index = 1;
    local timer = 0;
    local timer2 = 0
    local timer3 = 0
    local printText = function(deltaTime)
        timer = timer + deltaTime
        if timer < 1 then
            return
        end
        UI.enable(root, "Text", true)
        index = deltaTime * 20 + index
        if index >= string.len(content) then
            index = string.len(content)
            timer2 = timer2 + deltaTime
            if timer2 > 0.5 then
                UI.enable(root, false)
                timer3 = timer3 + deltaTime
                if timer3 > 3 then
                    UI.enable(root, true)
                    UI.enable(root, "Text", false)
                    timer3 = 0
                    timer = 0
                    timer2 = 0
                    index = 1
                end
            end
        end
        local i = 1
        while i <= index do
            local curByte = string.byte(content, i)
            local byteCount = 1;
            if curByte > 127 then
                byteCount = 3
            end
            i = i + byteCount
        end

        UI.text(root, "Text", string.sub(content, 1, i - 1))
    end

    CS.UIAPI.AddUpdate(node, printText)
    node.gameObject.name = msgTipName
end

function UI.hideMsgTips(parent)
    local msgTipName = "msgTip--"
    local child = UI.child(parent, msgTipName, true)
    if child then
        UI.enable(child, false)
        return
    end
end

function UI.showLevelUpEffect(ui)
    local canUpName = "canLevelUp"
    local node = UI.child(ui, canUpName, true)
    if client.user.level < 18 then
        local cfg = config.levelMap[client.user.level + 1]
        log(cfg.score)
        UI.enable(node, client.user.levelExp >= cfg.score)
    else
        UI.enable(node, false)
    end
end

function UI.showTextByTypeWriter(node, content, speed)

    if speed == nil then
        speed = 10
    end
    local index = 1;
    local timer = 0;
    local printText = function(deltaTime)
        timer = timer + deltaTime
        index = deltaTime * speed + index
        if index >= string.len(content) then
            index = string.len(content)
            --return
            CS.UIAPI.EnableUpdate(node)
        end
        local i = 1
        while i <= index do
            local curByte = string.byte(content, i)
            local byteCount = 1;
            if curByte > 127 then
                byteCount = 3
            end
            i = i + byteCount
        end
        UI.text(node, string.sub(content, 1, i - 1))
    end
    CS.UIAPI.AddUpdate(node, printText)
end

function UI.showProcessAck(node, value, time, fun)
    if not time or time <= 0 then
        UI.progress(node, value)
        return
    end

    local slider = node.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Slider))
    if slider.value == 1 then
        UI.progress(node, 0)
    end

    if value == 0 then
        CS.UIAPI.TweenProcessValue(node, 1, time);
        UI.delay(node, time, function()
            if fun then
                fun()
            end
            UI.progress(node, 0)
        end)
    elseif value < slider.value then
        local t1 = 1 - slider.value
        local t2 = value
        local t = t1 + t2
        CS.UIAPI.TweenProcessValue(node, 1, time * t1 / t);
        UI.delay(node, time * t1 / t, function()
            if fun then
                fun()
            end
            UI.progress(node, 0)
            CS.UIAPI.TweenProcessValue(node, value, time * t2 / t);
        end)
    else
        CS.UIAPI.TweenProcessValue(node, value, time);
    end

end