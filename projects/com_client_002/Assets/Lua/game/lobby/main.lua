local Class = {
    res = "ui/LobbyMain"
}
-- local ret
function Class:setMsgListener()
    SystemOpen.initNewUnlockSystemData()
    SystemEventOpen.initNewUnlockSystemData()
    message:setOnMsg("S2C_shengji", ComTools.onShengJi)
    message:setOnMsg("S2C_updateMsg", client.msgData.updateMsg)
    message:setOnMsg("S2C_add_value", client.updateAddValue)
    message:setOnMsg("S2C_lockSystemChange", SystemOpen.updateLockSystem)
    message:setOnMsg("S2C_ResUpdateOpenEvent", SystemEventOpen.updateOpenEvent)
    message:setOnMsg("S2C_redDotChange", RedDot.onRedDotChange)
    message:setOnMsg("S2C_chargeCallback", function(msg)
        print("主动推送充值")
        GameStat.onChargeSuccess(msg.money, SdkMgr.getLastProductName())
    end)
    message:send("C2S_StartRedDot", {})
    local exit = function()
        setNet(0, 0, function()
        end)
        CS.UnityEngine.Application.Quit();
    end
    message:setOnMsg("S2C_ServerClose", function()
        local node = UI.msgBoxTitle("提示", "服务器维护中……", exit);
        UI.enable(node, "BtnClose", false)
    end)

    message:setOnMsg("S2C_RefreshRushState", function()
        self:showSystemEventOpen(true)
        self:refreshRushRank()
    end)
end

function Class:init()
    setHasEnterMain(true)
    self:setMsgListener()

    self.canShowGuideEffect = true

    UI.show("game.other.guide", 1)

    if client.user.guildId > 0 and not is_debug then
        --if is_debug then
        UI.openPage(UIPageName.NewYearTips)
        --UI.openPage(UIPageName.ActivityLoginTips)
    end

    UI.text(self.node, "Top/TextName", client.user.name)

    local animNode = UI.showNode(self.node, "BG1/BtnIndustry/Anim", "Anim/wife19")
    UI.playAnim(animNode, "idle")
    UI.setLocalOffset(animNode, 0, -200)

    UI.button(self.node, "btnTest", function()
        UI.show("game.other.errPanel")
    end)

    UI.button(self.node, "Top/BtnHead", function()
        UI.show("game.lobby.playerAttribute")
    end)

    UI.button(self.node, "Top/VIP/BtnVIPTequan", function()
        UI.openPage(UIPageName.VipPrivilege)
    end)

    UI.enable(self.node, "Activity/BtnLimit/2", true)
    UI.enableAll(self.node, "Activity/BtnLimit/2", false)
    UI.enable(self.node, "Activity/BtnActivity/3", true)
    UI.enableAll(self.node, "Activity/BtnActivity/3", false)

    --限时活动
    UI.button(self.node, "Activity/BtnLimit", function()
        local child = UI.child(self.node, "Activity/BtnLimit/2")
        UI.enable(child, not child.gameObject.activeSelf)
    end)
    -- 充值奖励
    UI.button(self.node, "Activity/BtnLimit/2/BtnPayReward", function()
        UI.openPage(UIPageName.PayReward)
    end)
    -- 优惠礼包
    UI.button(self.node, "Activity/BtnLimit/2/BtnSuperBag", function()
        UI.openPage(UIPageName.SuperShop)
    end)
    -- 限时奖励
    UI.button(self.node, "Activity/BtnLimit/2/BtnLimitReward", function()
        UI.openPage(UIPageName.LimitReward)
    end)
    -- 绝代双骄
    UI.button(self.node, "Activity/BtnLimit/2/btnTwoBeauty", function()
        UI.openPage(UIPageName.TwoBeauty)
    end)
    -- 情定终身
    UI.button(self.node, "Activity/BtnLimit/2/btnloveLife", function()
        UI.openPage(UIPageName.LifeLong)
    end)

    -- 活动
    UI.button(self.node, "Activity/BtnActivity", function()
        local child = UI.child(self.node, "Activity/BtnActivity/3")
        UI.enable(child, not child.gameObject.activeSelf)
    end)
    -- 调教女皇
    UI.button(self.node, "Activity/BtnActivity/3/btnEmpress", function()
        UI.openPage(UIPageName.HdEmpress)
    end)
    -- 广纳红颜
    UI.button(self.node, "Activity/BtnActivity/3/guangnahongyan", function()
        UI.openPage(UIPageName.GuangNaHongYan)
    end)
    -- 花楼七日游
    UI.button(self.node, "Activity/BtnActivity/3/hualouqiriyou", function()
        UI.openPage(UIPageName.HuaLouQiRiYou)
    end)
    -- 惩罚女贼
    UI.button(self.node, "Activity/BtnActivity/3/btnPunish", function()
        UI.openPage(UIPageName.HdPunish)
    end)

    -- 首充
    UI.button(self.node, "Activity/BtnGroup/BtnShouChong", function()
        UI.openPage(UIPageName.FirstCharge)
    end)
    -- 月卡
    UI.button(self.node, "Activity/BtnGroup/BtnMonthCard", function()
        UI.openPage(UIPageName.MonthCardPage)
    end)
    --珍宝阁
    UI.button(self.node, "Activity/BtnGroup/BtnTreasureHouse", function()
        --UI.show("game.activity.EventManager")
        UI.openPage(UIPageName.TreasureHouse)
    end)
    -- 新年活动
    UI.button(self.node, "Activity/BtnGroup/BtnNewYear", function()
        UI.openPage(UIPageName.NewYear)
    end)
    -- vip福利
    UI.button(self.node, "Activity/BtnGroup/BtnVipfuli", function()
        UI.openPage(UIPageName.VipFuLi)
    end)
    -- 邮件
    UI.button(self.node, "Activity/BtnGroup/BtnMail", function()
        UI.show("game.lobby.mail")
    end)
    -- 排行榜
    UI.button(self.node, "Activity/BtnGroup/BtnRank", function()
        UI.openPage(UIPageName.RankPage)
    end)

    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnGroup/BtnShouChong"), 19, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnGroup/BtnMonthCard"), 30, true)
    --SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnGroup/BtnNewYear"), 46, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnGroup/BtnTreasureHouse"), 48, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnGroup/BtnVipfuli"), 36, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnGroup/BtnMail"), 39, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnGroup/BtnRank"), 32, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnLimit/2/BtnPayReward"), 3, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnLimit/2/BtnSuperBag"), 37, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnLimit/2/BtnLimitReward"), 38, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnLimit/2/btnTwoBeauty"), 2, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnLimit/2/btnloveLife"), 40, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnActivity/3/btnEmpress"), 5, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnActivity/3/guangnahongyan"), 4, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnActivity/3/hualouqiriyou"), 6, true)
    SystemEventOpen.registerBtn(UI.child(self.node, "Activity/BtnActivity/3/btnPunish"), 7, true)

    UI.button(self.node, "Activity/BtnRushRank", function()
        --UI.delay(self.node, 1, function()
        UI.openPage(UIPageName.RushRank)
        --end)
    end)
    -- 福利
    UI.button(self.node, "Bottom/BtnBenefits", function()
        UI.openPage(UIPageName.FuLiPage)
    end)

    -- 经营
    UI.button(self.node, "BG1/BtnIndustry", function()
        UI.openPage(UIPageName.Industry)
    end)
    UI.button(self.node, "BG1/BtnIndustry/Btn", function()
        UI.openPage(UIPageName.Industry)
    end)

    -- 书房
    UI.button(self.node, "BG1/BtnWork", function()
        UI.openPage(UIPageName.WorkHouse)
    end)
    UI.button(self.node, "BG1/BtnWork/Btn", function()
        UI.openPage(UIPageName.WorkHouse)
    end)

    -- 商店
    UI.button(self.node, "Top/BtnShop", function()
        UI.openPage(UIPageName.Shop)
    end)

    -- 群芳
    UI.button(self.node, "BG1/BtnWives", function()
        UI.openPage(UIPageName.Wives)
    end)
    UI.button(self.node, "BG1/BtnWives/Btn", function()
        UI.openPage(UIPageName.Wives)
    end)

    -- 英雄
    UI.button(self.node, "BG1/BtnHeroes", function()
        UI.openPage(UIPageName.Heroes)
    end)
    UI.button(self.node, "BG1/BtnHeroes/Btn", function()
        UI.openPage(UIPageName.Heroes)
    end)
    UI.button(self.node, "BG2/BtnHeroes", function()
        UI.openPage(UIPageName.Heroes)
    end)

    -- 大观园
    UI.button(self.node, "BG1/BtnBigView", function()
        UI.enable(self.node, "BgBigView", true)
        self:onBack()
        self:playBackMusic()
    end)

    -- 姻缘
    UI.button(self.node, "BgBigView/BtnChildLove", function()
        UI.openPage(UIPageName.YinYuanCi)
    end)

    -- 宴会
    UI.button(self.node, "BgBigView/BtnParty", function()
        UI.openPage(UIPageName.Banquet)
    end)

    -- 私塾
    UI.button(self.node, "BgBigView/BtnSchool", function()
        UI.openPage(UIPageName.School)
    end)
    UI.button(self.node, "BgBigView/BtnBack", function()
        UI.enable(self.node, "BgBigView", false);
        self:onFront()
    end)

    HeroTools.setCHeadSprite(self.node, "Top/BtnHead/Head", 1)

    local outDoor = function(value)
        UI.enable(self.node, "BG2", value)
        UI.enable(self.node, "BG1", not value)
        UI.enable(self.node, "Bottom/BtnGetOut", not value)
        UI.enable(self.node, "Activity", not value)
        UI.enable(self.node, "Task", not value and (not self.mainTaskOver))
        UI.enable(self.node, "Bottom/BtnComeBack", value)
        -- UI.enable(self.node, "SystemOpen", not value)
        self:showSystemOpen(not value)

        if value then
            local btnGuaFu = UI.child(self.node, "BG2/BtnGuanHu")
            SystemOpen.registerBtn(btnGuaFu, 1, false)
            SystemOpen.registerBtn(btnGuaFu, 21, false)
            SystemOpen.registerBtn(btnGuaFu, 8, false)
            SystemOpen.registerBtn(btnGuaFu, 21, false)
            local btnVisit = UI.child(self.node, "BG2/BtnVisit")
            SystemOpen.registerBtn(btnVisit, 3, true)
            local btnHero = UI.child(self.node, "BG2/BtnHeroes")
            SystemOpen.registerBtn(btnHero, 4, true)
            local btnBattle = UI.child(self.node, "BG2/BtnBattle")
            SystemOpen.registerBtn(btnBattle, 5, true)
            local btnUnity = UI.child(self.node, "BG2/BtnUnity")
            SystemOpen.registerBtn(btnUnity, 6, true)
            local btnPalace = UI.child(self.node, "BG2/BtnPalace")
            SystemOpen.registerBtn(btnPalace, 7, true)
            local btnCatch = UI.child(self.node, "BG2/BtnCatch")
            SystemOpen.registerBtn(btnCatch, 9, true)
            local btnSchool = UI.child(self.node, "BG2/BtnSchool")
            SystemOpen.registerBtn(btnSchool, 20, true)
        end

        self:playBackMusic()
    end

    -- 出府
    UI.button(self.node, "Bottom/BtnGetOut", function()
        outDoor(true)
        self:clearDelayShowGuideEffect()
    end)

    -- 回府
    UI.button(self.node, "Bottom/BtnComeBack", function()
        outDoor(false)
        self:addDelayShowGuideEffect()
    end)

    -- 库房
    UI.button(self.node, "Bottom/BtnWareHouse", function()
        UI.show("game.lobby.warehouse")
    end)

    -- 征战
    UI.button(self.node, "BG2/BtnBattle", function()
        UI.openPage(UIPageName.Battle)
    end)

    -- 国子监
    UI.button(self.node, "BG2/BtnSchool", function()
        UI.openPage(UIPageName.GuoZiJian)
    end)

    -- 皇宫
    UI.button(self.node, "BG2/BtnPalace", function()
        UI.openPage(UIPageName.Palace)
    end)

    UI.button(self.node, "BG2/BtnVisit", function()
        UI.openPage(UIPageName.VisitPage)
    end)
    outDoor(false)

    --官府
    UI.button(self.node, "BG2/BtnGuanHu", function()
        self:showGuanFu()
    end)

    UI.button(self.node, "BG2/BtnCatch", function()
        UI.openPage(UIPageName.CatchAssailant)
    end)

    UI.button(self.node, "Task/BtnTask", function()
        self:onMainTaskClick()
    end)

    print("im herere ---------------")
    self:showMainTaskInfo()

    UI.button(self.node, "Bottom/BtnEveryDay", function()
        UI.openPage(UIPageName.DailyTask)
    end)

    UI.button(self.node, "Bottom/BtnAchievement", function()
        UI.openPage(UIPageName.Achievement)
    end)

    UI.button(self.node, "Top/ImgGold/BtnRecharge", function()
        -- 询问打开首充还是充值页面
        ComTools.openRecharge();
    end)

    message:setOnMsg("S2C_TaskComplete", function(msg)
        self:dealWithMainTaskMsg(msg)
    end)

    UI.button(self.node, "SystemOpen/btn", function()
        UI.openPage(UIPageName.SystemOpenPage)
        UI.enable(self.node, "SystemOpen", false)
    end)

    self:showSystemOpen(true)
    --self:showSystemEventOpen(true)

    UI.button(self.node, "BG2/BtnUnity", function()
        UI.openPage(UIPageName.UnionPage)
        -- UI.show("game.outdoor.unity.unity_noble")
    end)

    local ui = UI.child(self.node, "Chat")
    client.msgData.registerNode("lobbyChat", ui)
    self:onFront()
    self:addRedDotBtn()
    self:showGameNotice()
end

local canShowGameGuide
function Class:showGameNotice()
    if client.user.guildId > 0 then
        message:send("C2S_GetGameNotice", {}, function(msg)
            if msg.code == 1 then
                UI.show("game.other.Notice", { title = msg.title, content = msg.content })
            end
        end)
    end
end

function Class:showSystemOpen(show)
    --log("未解锁的系统")
    UI.enable(self.node, "SystemOpen", show)

    if show then
        message:send("C2S_showSystemOpen", {}, function(msg)
            print("send msg back:" .. msg.id)
            log("C2S_showSystemOpen")
            log(msg)
            SystemOpen.updateLockSystem(msg)
            --if msg.id == 0 then
            if #msg.ids > 0 then
                UI.enable(self.node, "SystemOpen", true)
                local data = {}
                if msg.id > 0 then
                    local temConfig = config["systemOpen"][msg.id]
                    local lvName = config["level"][msg.level].name
                    data.condi = lvName .. "开放"
                    data.name = temConfig.name
                else
                    local cfg = config["systemOpen"][msg.ids[#msg.ids]]

                    data.condi = cfg.unlock
                    data.name = cfg.name
                end
                UI.draw(self.node, "SystemOpen", data)
            else
                self:showSystemOpen(false)
            end
        end)
    end
end

function Class:showSystemEventOpen(show)
    if show then
        message:send("C2S_ReqOpenEvent", {}, function(ret)
            --log(ret)
            --local count = #ret.ids
            --ret.ids[count + 1] = 15
            log(ret)

            log("未解锁的活动")
            UI.enableAll(self.node, "Activity/BtnLimit/2", false)
            UI.enableAll(self.node, "Activity/BtnActivity/3", false)
            UI.enableAll(self.node, "Activity/BtnGroup", false)

            SystemEventOpen.updateOpenEvent(ret)
            UI.showByChildCount(self.node, "Activity/BtnLimit", UI.child(self.node, "Activity/BtnLimit/2"))
            UI.showByChildCount(self.node, "Activity/BtnActivity", UI.child(self.node, "Activity/BtnActivity/3"))
            --UI.enable(self.node, "Activity/BtnGroup/BtnTreasureHouse", true)
        end)
    end
end

-- msg MainTaskInfo
function Class:dealWithMainTaskMsg(msg)
    if self.lastRemindTipId == msg.id then
        return
    end
    self.lastRemindTipId = msg.id
    if not UI.isOnTop("game.lobby.main") then
        local node = UI.showNode(self.node.parent, "UI/taskComplete")
        UI.delay(self.node, 1, function()
            CS.UnityEngine.Object.Destroy(node.gameObject)
        end)
    end
end

function Class:onMainTaskClick()
    message:send("C2S_tryGetMainTaskReward", {}, function(msg)
        if msg.rewards and #msg.rewards > 0 then
            local resStr = ""
            local itemStr = ""
            local hero = ""
            log(msg.rewards)
            local time = 0
            for i, v in ipairs(msg.rewards) do
                if v.type == "Res" or v.type == "Item" then
                    UI.delay(self.node, time, function()
                        ItemTools.showItemResultById(v.id, v.count)
                    end)
                else
                    local config = config["hero"][v.id]
                    UI.delay(self.node, time, function()
                        ItemTools.showItemResultByResName({
                            name = config.name,
                            icon = config.head,
                            count = 1
                        }, "CHeroHead")
                    end)
                end
                time = time + 0.5
            end
            print("----on main task click")
            self:updateMainTaskShow(msg.task, msg.taskOver)
        elseif msg.task ~= nil and msg.task.state == "Doing" then
            local tempConfig = config["mainTask"][msg.task.id]
            local gamePageStr = config["gamePage"][tempConfig.page].name

            print("page name：" .. gamePageStr)
            UI.openPage(UIPageName[gamePageStr])
        end
    end)
end

function Class:showMainTaskInfo()
    --[[    local outDoorActive = UI.child(self.node, "BG2")
        if outDoorActive.gameObject.activeSelf then
            return
        end
        if UI.child(self.node, "BgBigView").gameObject.activeSelf then
            return
        end]]
    print("show main task info------------")
    message:send("C2S_openMainTask", {}, function(msg)
        client.newOpenMainTask = true
        log("TaskMsg------------:", msg.taskOver)
        self:updateMainTaskShow(msg.task, msg.taskOver)
        client.user.vip = msg.vip
        UI.image(self.node, "Activity/BtnGroup/BtnVipfuli", "VipIcon", client.user.vip)
        UI.text(self.node, "Top/VIP/Text", client.user.vip)
    end)
end

-- data MainTaskInfo
function Class:updateMainTaskShow(data, taskOver)
    print("update now a ------:", taskOver)
    if taskOver then
        UI.enable(self.node, "Task", false)
        self.canShowGuideEffect = false
        self.mainTaskOver = true
    else
        local config = config["mainTask"][data.id]
        local des = ""
        if data.state == "Complete" then
            des = config.description .. UI.colorStr("(已完成)", ColorStr.green)
        else
            des = config.description .. "(" .. data.crtValue .. "/" .. data.targetValue .. ")"
        end
        local drawData = {
            desc = des,
            reward = self:getMainTaskRewardStr(config)
        }
        UI.draw(self.node, "Task", drawData)
        UI.enable(self.node, "Task/completeEft", data.state == "Complete")
        self:addDelayShowGuideEffect()
        local outDoorActive = UI.child(self.node, "BG2")
        local bigViewActive = UI.child(self.node, "BgBigView")
        if outDoorActive.gameObject.activeSelf or bigViewActive.gameObject.activeSelf then
            UI.enable(self.node, "Task", false)
        else
            UI.enable(self.node, "Task", true)
        end
    end
end

function Class:showMainTaskGuideEffect(show)
    if self.canShowGuideEffect then
        UI.enable(self.node, "Task/GuideEffect", show)
    end
end

function Class:getMainTaskRewardStr(tempConfig)
    local str = ""
    if tempConfig.money > 0 then
        str = str .. "银两*" .. goldFormat(tempConfig.money) .. " "
    end

    if tempConfig.food > 0 then
        str = str .. "粮草*" .. goldFormat(tempConfig.food) .. " "
    end

    if tempConfig.soldier > 0 then
        str = str .. "士兵*" .. goldFormat(tempConfig.soldier) .. " "
    end

    if tempConfig.gold > 0 then
        str = str .. "元宝*" .. goldFormat(tempConfig.gold) .. " "
    end

    if #tempConfig.item > 0 then
        for i = 1, #tempConfig.item, 2 do
            local itemConfig = config["item"][tempConfig.item[i]]
            if itemConfig then
                str = str .. itemConfig.name .. "*" .. goldFormat(tempConfig.item[i + 1]) .. " "
            end
        end
    end
    return str
end

function Class:showGuanFu()
    if not self.nodeGuanFu then
        self.nodeGuanFu = UI.showNode(self.node, "GuanHu")
        local btnYiZheng = UI.child(self.nodeGuanFu, "btnYiZheng")
        local btnGuoGuan = UI.child(self.nodeGuanFu, "btnGuoGuan")
        local btnDaYu = UI.child(self.nodeGuanFu, "btnDaYu")
        UI.draw(self.nodeGuanFu, {
            btnBack = function()
                UI.enable(self.nodeGuanFu, false)
                self:playBackMusic()
            end,
            btnYiZheng = function()
                UI.openPage(UIPageName.YiZhengTing)
            end,
            btnGuoGuan = function()
                UI.openPage(UIPageName.GuoGuanZhanJiang)
            end,
            btnDaYu = function()
                UI.openPage(UIPageName.PrisonPage)
            end
        })

        SystemOpen.registerBtn(btnYiZheng, 1, true)
        SystemOpen.registerBtn(btnGuoGuan, 21, true)
        SystemOpen.registerBtn(btnDaYu, 8, true)
        RedDot.registerBtn(btnDaYu, RedDot.SystemID.Prison)
        RedDot.registerBtn(btnDaYu, RedDot.SystemID.PrisonTreasure)
    end

    UI.enable(self.nodeGuanFu, true)

    self:playBackMusic()
end

function Class:onFront()
    print("main on front ------------------------------")
    UI.text(self.node, "Top/TextName", client.user.name)
    UI.text(self.node, "Top/ImgGold/Text", goldFormat(client.user.gold))
    UI.text(self.node, "Top/ImgInfluence/Text", goldFormat(client.user.allValue))

    UI.image(self.node, "Top/Level", "PlayerLevel", client.user.level)
    HeroTools.setCHeadSprite(self.node, "Top/BtnHead/Head", 1)

    --UI.enable(self.node, "Top/BtnHead/canLevelUp", false)
    UI.showLevelUpEffect(UI.child(self.node, "Top/BtnHead"))

    UI.button(self.node, "Chat", function()
        UI.openPage(UIPageName.Chat)
    end)

    --client.msgData.disMsg()
    local onOutDoor = UI.child(self.node, "BG2").gameObject.activeSelf
    self:showSystemOpen(not onOutDoor)
    self:showMainTaskInfo()

    local BtnWives = UI.child(self.node, "BG1/BtnWives/Btn")
    SystemOpen.registerBtn(BtnWives, 12, true)
    local BtnBigView = UI.child(self.node, "BG1/BtnBigView")
    SystemOpen.registerBtn(BtnBigView, 13, false)
    SystemOpen.registerBtn(BtnBigView, 14, false)
    SystemOpen.registerBtn(BtnBigView, 22, false)
    local BtnYinYuan = UI.child(self.node, "BgBigView/BtnChildLove")
    SystemOpen.registerBtn(BtnYinYuan, 13, true)
    local BtnSiShu = UI.child(self.node, "BgBigView/BtnSchool")
    SystemOpen.registerBtn(BtnSiShu, 14, true)
    local BtnParty = UI.child(self.node, "BgBigView/BtnParty")
    SystemOpen.registerBtn(BtnParty, 22, true)
    self:playBackMusic()
    self:showPoliticsTip()
    self:showWifeTip()
    self:showBusinessTip()
    self:showSchoolTip()
    --冲榜活动名次刷新

    self:refreshRushRank()
    self:showSystemEventOpen(true)
    self:showNewYearEffect()
end

function Class:showNewYearEffect()
    local node = UI.child(self.node, "Activity/BtnGroup/BtnNewYear")
    if node.gameObject.activeSelf then
        local effect = node:Find("effect")
        if effect then
            UI.enable(effect, true)
        else
            UI.showNode(node, "Effect/itemEffect").name = "effect"
        end
    end
end

function Class:refreshRushRank()
    local node = UI.child(self.node, "Activity/BtnRushRank", true)
    message:send("C2S_ReqRushEvent", {}, function(ret)
        log(ret)
        if ret.eventId == 0 then
            UI.enable(node, false)
        else
            UI.enable(node, true)
            UI.draw(node, ret)
        end
    end)
end

function Class:showPoliticsTip()
    local show = RedDot.getDataById(RedDot.SystemID.WorkHouse)
    local btnWorkHouse = UI.child(self.node, "BG1/BtnWork/Btn")
    if show then
        UI.showMsgTips("politics", "政务堆积如山", btnWorkHouse, 0, -60)
    else
        UI.hideMsgTips(btnWorkHouse)
    end
end

function Class:showWifeTip()
    local show = RedDot.getDataById(RedDot.SystemID.WifeHouse)
    local btnWifeHouse = UI.child(self.node, "BG1/BtnWives/Btn")
    if show then
        UI.showMsgTips("wife", "夫君，快回来", btnWifeHouse, 0, -60)
    else
        UI.hideMsgTips(btnWifeHouse)
    end
end

function Class:showSchoolTip()
    local show = RedDot.getDataById(RedDot.SystemID.SchoolRiseChild)
    local btnSchool = UI.child(self.node, "BgBigView/BtnSchool")
    if show then
        UI.showMsgTips("child", "爹，快来跟我玩耍", btnSchool, 0, -60)
    else
        UI.hideMsgTips(btnSchool)
    end
end

function Class:showBusinessTip()
    local show = RedDot.getDataById(RedDot.SystemID.BusinessTip)
    local btnBusiness = UI.child(self.node, "BG1/BtnIndustry/Btn")
    if show then
        UI.showMsgTips("business", "大人，资产急需打理", btnBusiness, 100, -80)
    else
        UI.hideMsgTips(btnBusiness)
    end
end

function Class:addRedDotBtn()
    local btnBusiness = UI.child(self.node, "BG1/BtnIndustry/Btn")
    RedDot.registerBtn(btnBusiness, RedDot.SystemID.Business)
    local btnWorkHouse = UI.child(self.node, "BG1/BtnWork/Btn")
    RedDot.registerBtn(btnWorkHouse, RedDot.SystemID.WorkHouse)
    local btnHero = UI.child(self.node, "BG1/BtnHeroes/Btn")
    RedDot.registerBtn(btnHero, RedDot.SystemID.HeroSkillUpdate)
    RedDot.registerBtn(btnHero, RedDot.SystemID.HeroGrowUpdate)
    local btnBigPark = UI.child(self.node, "BG1/BtnBigView/Btn")
    RedDot.registerBtn(btnBigPark, RedDot.SystemID.DatingHouseMarryRequest)
    local btnWife = UI.child(self.node, "BG1/BtnWives/Btn")
    RedDot.registerBtn(btnWife, RedDot.SystemID.WifeHouse)
    local btnBenefits = UI.child(self.node, "Bottom/BtnBenefits")
    RedDot.registerBtn(btnBenefits, RedDot.SystemID.Sign)
    RedDot.registerBtn(btnBenefits, RedDot.SystemID.MonthCardReward)
    RedDot.registerBtn(btnBenefits, RedDot.SystemID.YearCardReward)
    RedDot.registerBtn(btnBenefits, RedDot.SystemID.FirstChargeReward)
    RedDot.registerBtn(btnBenefits, RedDot.SystemID.GodShow)
    local btnLimitTime = UI.child(self.node, "Activity/BtnLimit")
    RedDot.registerBtn(btnLimitTime, RedDot.SystemID.DailyChargeReward)
    RedDot.registerBtn(btnLimitTime, RedDot.SystemID.TotalChargeReward)
    RedDot.registerBtn(btnLimitTime, RedDot.SystemID.TotalDayChargeReward)
    RedDot.registerBtn(btnLimitTime, RedDot.SystemID.ShopVipCanBuy)
    RedDot.registerBtn(btnLimitTime, RedDot.SystemID.LimitReward)
    RedDot.registerBtn(btnLimitTime, RedDot.SystemID.QingDingRank)
    RedDot.registerBtn(btnLimitTime, RedDot.SystemID.QingDing)
    local btnActivity = UI.child(self.node, "Activity/BtnActivity")
    RedDot.registerBtn(btnActivity, RedDot.SystemID.MarryAllGirls)
    RedDot.registerBtn(btnActivity, RedDot.SystemID.FlowerStreet)
    RedDot.registerBtn(btnActivity, RedDot.SystemID.PunishThief)
    local btnFirstCharge = UI.child(self.node, "Activity/BtnGroup/BtnShouChong")
    RedDot.registerBtn(btnFirstCharge, RedDot.SystemID.FirstChargeReward)
    local btnVipReward = UI.child(self.node, "Activity/BtnGroup/BtnVipfuli")
    RedDot.registerBtn(btnVipReward, RedDot.SystemID.VipReward)
    local btnMonthCard = UI.child(self.node, "Activity/BtnGroup/BtnMonthCard")
    RedDot.registerBtn(btnMonthCard, RedDot.SystemID.MonthCardReward)
    local btnNewYear = UI.child(self.node, "Activity/BtnGroup/BtnNewYear")
    RedDot.registerBtn(btnNewYear, RedDot.SystemID.NewYear)
    local btnTreasureHouse = UI.child(self.node, "Activity/BtnGroup/BtnTreasureHouse")
    RedDot.registerBtn(btnTreasureHouse, RedDot.SystemID.TreasureHouse)
    local btnRank = UI.child(self.node, "Activity/BtnGroup/BtnRank")
    RedDot.registerBtn(btnRank, RedDot.SystemID.Rank)
    local btnEmail = UI.child(self.node, "Activity/BtnGroup/BtnMail")
    RedDot.registerBtn(btnEmail, RedDot.SystemID.Email)
    local btnDailyTask = UI.child(self.node, "Bottom/BtnEveryDay")
    RedDot.registerBtn(btnDailyTask, RedDot.SystemID.DailyTask)
    local btnOutDoor = UI.child(self.node, "Bottom/BtnGetOut")
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.Palace)
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.Prison)
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.VisitBuGua)
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.VisitVisit)
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.UnityShop)
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.UnityDailyBuild)
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.UnityEnterReq)
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.UnityNoble)
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.CatchAssailant)
    RedDot.registerBtn(btnOutDoor, RedDot.SystemID.CountrySchool)
    local BtnAchievement = UI.child(self.node, "Bottom/BtnAchievement")
    RedDot.registerBtn(BtnAchievement, RedDot.SystemID.Achievement)
    local btnDatingHouse = UI.child(self.node, "BgBigView/BtnChildLove")
    RedDot.registerBtn(btnDatingHouse, RedDot.SystemID.DatingHouseMarryRequest)
    local btnChargeReward = UI.child(self.node, "Activity/BtnLimit/2/BtnPayReward")
    RedDot.registerBtn(btnChargeReward, RedDot.SystemID.DailyChargeReward)
    RedDot.registerBtn(btnChargeReward, RedDot.SystemID.TotalDayChargeReward)
    RedDot.registerBtn(btnChargeReward, RedDot.SystemID.TotalDayChargeReward)
    local btnSaleGift = UI.child(self.node, "Activity/BtnLimit/2/BtnSuperBag")
    RedDot.registerBtn(btnSaleGift, RedDot.SystemID.ShopVipCanBuy)
    local btnLimitReward = UI.child(self.node, "Activity/BtnLimit/2/BtnLimitReward")
    RedDot.registerBtn(btnLimitReward, RedDot.SystemID.LimitReward)
    local btnLoveLife = UI.child(self.node, "Activity/BtnLimit/2/btnloveLife")
    RedDot.registerBtn(btnLoveLife, RedDot.SystemID.QingDing, true)
    local btnMarryAllGirls = UI.child(self.node, "Activity/BtnActivity/3/guangnahongyan")
    RedDot.registerBtn(btnMarryAllGirls, RedDot.SystemID.MarryAllGirls)
    local btnFlowerBuild = UI.child(self.node, "Activity/BtnActivity/3/hualouqiriyou")
    RedDot.registerBtn(btnFlowerBuild, RedDot.SystemID.FlowerStreet)
    local btnPunishThief = UI.child(self.node, "Activity/BtnActivity/3/btnPunish")
    RedDot.registerBtn(btnPunishThief, RedDot.SystemID.PunishThief)

    local BtnBattle = UI.child(self.node, "BG2/BtnBattle")

    local btnPalace = UI.child(self.node, "BG2/BtnPalace")
    local BtnGuanHu = UI.child(self.node, "BG2/BtnGuanHu")
    local BtnUnity = UI.child(self.node, "BG2/BtnUnity")
    local BtnCatch = UI.child(self.node, "BG2/BtnCatch")
    local BtnVisit = UI.child(self.node, "BG2/BtnVisit")
    local BtnHeroes = UI.child(self.node, "BG2/BtnHeroes")
    local BtnCountrySchool = UI.child(self.node, "BG2/BtnSchool")
    RedDot.registerBtn(btnPalace, RedDot.SystemID.Palace)
    RedDot.registerBtn(BtnGuanHu, RedDot.SystemID.Prison)
    RedDot.registerBtn(BtnGuanHu, RedDot.SystemID.PrisonTreasure)
    RedDot.registerBtn(BtnUnity, RedDot.SystemID.UnityNoble)
    RedDot.registerBtn(BtnUnity, RedDot.SystemID.UnityEnterReq)
    RedDot.registerBtn(BtnUnity, RedDot.SystemID.UnityDailyBuild)
    RedDot.registerBtn(BtnUnity, RedDot.SystemID.UnityShop)
    RedDot.registerBtn(BtnCatch, RedDot.SystemID.CatchAssailant, true)
    RedDot.registerBtn(BtnVisit, RedDot.SystemID.VisitVisit)
    RedDot.registerBtn(BtnVisit, RedDot.SystemID.VisitBuGua)
    RedDot.registerBtn(BtnHeroes, RedDot.SystemID.HeroSkillUpdate)
    RedDot.registerBtn(BtnHeroes, RedDot.SystemID.HeroGrowUpdate)
    RedDot.registerBtn(BtnCountrySchool, RedDot.SystemID.CountrySchool)

end

function Class:onBack()
    self:clearDelayShowGuideEffect()
    UI.enable(self.node, "Task", false)
end

function Class:clearDelayShowGuideEffect()
    if self.showMainTaskDelayId ~= nil then
        UI.stopDelay(UI.child(self.node, "Task"), self.showMainTaskDelayId)
    end
    self:showMainTaskGuideEffect(false)
end

function Class:addDelayShowGuideEffect()
    self.showMainTaskDelayId = UI.delay(UI.child(self.node, "Task"), 10, function()
        self:showMainTaskGuideEffect(true)
    end)
end

function Class:playBackMusic()
    local musicDef = {}
    musicDef["GuanHu"] = "government"
    musicDef["BG2"] = "capital"
    musicDef["BgBigView"] = "showplace"

    for i, v in pairs(musicDef) do
        if UI.isVisual(self.node, i) then
            log(i, v)
            CS.Sound.PlayMusic("music/" .. v, true, 0.4)
            return
        end
    end

    CS.Sound.PlayMusic("music/home", true, 0.4)
end

return Class
