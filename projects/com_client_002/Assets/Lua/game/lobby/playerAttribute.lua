local Class = {
    res = "ui/roleInformation",
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()
    self.hasClose = false

    UI.enableAll(self.node, true)
    UI.enableAll(self.node, "LevelUp", false)

    self.mainAnim = UI.child(self.node, "Top/Anim")
    self.ackAnim = UI.child(self.node, "LevelUp/Ack/Anim")

    HeroTools.showAnim(self.mainAnim, 1)
    UI.draw(self.node, "Top/Info", client.user)
    self:showPage(1)

    self:close()

    message:send("C2S_ReqPlayerInfo", {}, function(ret)
        self.info = ret
        self:showTop()
        self:button()
    end)
end

function Class:close()
    UI.button(self.node, "BtnClose", function()
        self:closePage()
    end)

    UI.button(self.node, "LevelUp/Way/BtnClose", function()
        UI.enableAll(self.node, "LevelUp", false)
    end)
end

function Class:button()

    for i = 1, 3 do
        UI.button(self.node, "Btn/" .. i, function()
            log(i)
            self:showPage(i)
        end)
    end

    for i = 1, 4 do
        UI.button(self.node, "Page/P2/King/" .. i, function()
            if self.info.king[i] then
                if self.info.curKing == i then
                    self:changeKing(0)
                else
                    self:changeKing(i)
                end
            else
                UI.showHint(config.royalMap[i].way)
            end
        end)
    end

    for i = 1, 3 do
        UI.button(self.node, "LevelUp/Way/Btn/" .. i .. "/Go", function()
            if i == 1 then
                UI.openPage(UIPageName.WorkHouse)
            elseif i == 2 then
                UI.openPage(UIPageName.Battle)
            elseif i == 3 then
                UI.openPage(UIPageName.DailyTask)
            end
            self:closePage()
        end)
    end

    UI.button(self.node, "Page/P1/Up/Btn", function()
        if client.user.level < 18 then
            if client.user.levelExp >= config.levelMap[client.user.level + 1].score then
                self:showLevelUpAck(ret)
            else
                UI.enableOne(self.node, "LevelUp", 1)
            end
        else
            UI.showHint("已达最高官位")
        end
    end)

    UI.button(self.node, "LevelUp/Ack", function()
        if self.next.hero > 0 then
            Story.show({ heroID = self.next.hero, endFun = function()
                self:closePage()
                if client.user.level == 3 then
                    UI.show("game.other.guide", 3)
                end
            end })
        else
            HeroTools.showAnim(self.mainAnim, 1)
            self:showPage(1)
            UI.enableAll(self.node, "LevelUp", false)
        end
    end)

    UI.button(self.node, "Page/P3/Account/BtnChange", function()
        local deal = function()
            mainRestart(true)
            client.msgData.clear()
        end

        if client.isGK and client.isGuest then
            UI.msgBox("您的账号尚未绑定，登出后将无法恢复，\n请小心操作", function()
                deal()
            end, function()
            end)
        else
            deal()
        end
    end)

    UI.button(self.node, "Page/P3/Account/BtnBin", function()
        SdkMgr.bindAccount(function(ret, userInfo, token)
            if ret then
                client.isGuest = false
                client.gkId = userInfo.user_id
                client.gkAccount = userInfo.account
                client.gkToken = token
                UI.showHint("绑定成功")
                message:send("C2S_bind", { account = userInfo.account, id = userInfo.user_id, pwd = token, type = "GK" })
                self:showPage(3)
            else
                UI.showHint("绑定失败")
            end
        end)

    end)

    UI.button(self.node, "Page/P3/Server/Btn", function()
        mainRestart()
        client.msgData.clear()
    end)

    UI.button(self.node, "Page/P3/Music/Btn", function()
        --          1->off||0->on
        CS.UnityEngine.PlayerPrefs.SetInt("gameSound", CS.UnityEngine.PlayerPrefs.GetInt("gameSound", 0) > 0 and 0 or 1)
        --CS.Sound.SetOn(CS.UnityEngine.PlayerPrefs.GetInt("gameSound", 0) < 1)
        if CS.UnityEngine.PlayerPrefs.GetInt("gameSound", 0) > 0 then
            CS.UnityEngine.AudioListener.volume = 0;
        else
            CS.UnityEngine.AudioListener.volume = 1;
        end
        CS.Sound.Play("effect/switch")
        UI.text(self.node, "Page/P3/Music/Btn/Text", CS.UnityEngine.PlayerPrefs.GetInt("gameSound", 0) > 0 and "开 启" or "关 闭")

    end)

    UI.button(self.node, "Page/P3/Exchange/Btn", function()
        self:exchangeGift()
    end)

    UI.button(self.node, "LevelUp/Item", function()
        UI.enableAll(self.node, "LevelUp", false)
    end)
end

function Class:showTop()
    local data = {}
    data = self.info
    data.rank = self.info.rank > 0 and "全服排行：" .. self.info.rank or "未上榜"
    data.allValue = client.user.allValue
    UI.draw(self.node, "Top", data)
end

function Class:showPage(index)
    for i = 1, 3 do
        UI.enable(self.node, "Btn/" .. i .. "/select", i == index)
    end

    local showP1 = function()
        local node = UI.child(self.node, "Page/P1")

        local now = config.levelMap[client.user.level]

        local next = client.user.level < 18
                and config.levelMap[client.user.level + 1]
                or { ERP1max = false, ERP2max = false, ERP3max = false, politicMax = false, gold = false }

        next.Hero = (next.hero and next.hero > 0) and config.heroMap[next.hero].name or "无"
        self.next = next

        local data = { Cfg = { Now = now, Next = next },
                       Level = { level = client.user.level },
                       Slider = client.user.level < 18
                               and client.user.levelExp / config.levelMap[client.user.level + 1].score
                               or 1,
                       LevelExp = client.user.level < 18
                               and client.user.levelExp .. "/" .. config.levelMap[client.user.level + 1].score
                               or "已满级",
                       Up = { Btn = client.user.level < 18
                               and { canUp = client.user.levelExp >= config.levelMap[client.user.level + 1].score }
                               or false,
                              Max = client.user.level >= 18
                       }
        }

        UI.draw(node, data)
    end

    local showP2 = function()
        local node = UI.child(self.node, "Page/P2")

        self:showKingCheck()

        for i, v in ipairs(self.info.king) do
            if v then
                UI.clearGray(node, "King/" .. i .. "/Icon")
            else
                UI.setGray(node, "King/" .. i .. "/Icon")
            end
        end
    end

    local showP3 = function()
        log("GK")
        log(client.isGK)
        log("Bin")
        log(client.isGuest)
        log("H365")
        log(client.isH365)

        local crtSdk = SdkMgr.getCrtChannel()

        if crtSdk == ChannelEnum.GK then
            UI.enable(self.node, "Page/P3/Account/BtnBin", client.isGuest)
            UI.enableOne(self.node, "Page/P3/Account/Tips", client.isGuest and 0 or 1)
        elseif crtSdk == ChannelEnum.H365 then
            UI.enableAll(self.node, "Page/P3/Account/Tips", false)
            UI.enable(self.node, "Page/P3/Account/BtnBin", false)
        elseif crtSdk == ChannelEnum.JGG then
            UI.enableAll(self.node, "Page/P3/Account/Tips", false)
            UI.enable(self.node, "Page/P3/Account/BtnBin", false)
        end

        UI.text(self.node, "Page/P3/Server/Tips/name", client.curServer.name)

        UI.text(self.node, "Page/P3/Music/Btn/Text", CS.UnityEngine.PlayerPrefs.GetInt("gameSound", 0) > 0 and "开 启" or "关 闭")
    end

    if index == 1 then
        showP1()
    elseif index == 2 then
        showP2()
    elseif index == 3 then
        showP3()
    end

    UI.enableOne(self.node, "Page", index - 1)
end

function Class:showLevelUpAck()
    local node = UI.child(self.node, "LevelUp/Ack")
    local ack = function()
        UI.showMask()
        client.user.level = client.user.level + 1

        HeroTools.showAnim(self.ackAnim, 1)
        UI.text(node, "Level/level", self.next.name)
        UI.text(node, "Paper/V/title", "荣升" .. self.next.name .. "大员")
        UI.text(node, "Paper/V/title/tq/Text",
                "1.解锁豪杰" .. self.next.Hero ..
                        "\n2.经营商产累积上限" .. self.next.ERP1max ..
                        "\n3.经营农产累积上限" .. self.next.ERP2max ..
                        "\n4.招募士兵累积上限" .. self.next.ERP3max ..
                        "\n2.处理政务累积上限" .. self.next.politicMax ..
                        "\n2.每日官品俸禄" .. self.next.gold)

        UI.enableAll(node, true)
        UI.enable(node, "Paper", true)
        UI.enableOne(self.node, "LevelUp", 0)

        local scaleAck = {
            {
                scale = 0.3,
            },
            {
                scale = 1,
                time = 0.3,
            },
        }
        UI.tweenList(node, "Title", scaleAck)
        UI.tweenList(node, "Level", scaleAck)

        local paper = UI.child(node, "Paper").gameObject:GetComponent(typeof(CS.SAnim))
        paper.gameObject:SetActive(true)
        paper:Reset()

        CS.Sound.Play("effect/upoffical")
        UI.delay(self.node, 1, function()
            UI.closeMask()
        end)
    end

    message:send("C2S_ReqLevelUp", {}, function(ret)
        if self.hasClose then
            return
        end
        if ret.code == "ok" then
            ack()
            self.info = ret.info
            self:showTop()
        else
            UI.showHint("升级失败")
        end
    end)
end

function Class:exchangeGift()
    local code = UI.getValue(self.node, "Page/P3/Exchange/code/Input")
    log(code)
    message:send("C2S_getGift", { code = code }, function(ret)
        if self.hasClose then
            return
        end

        UI.text(self.node, "Page/P3/Exchange/code/Input", "")

        if ret.hero < 0 or ret.wife < 0 then
            UI.showHint("您已获得该豪杰/红颜")
            return
        end

        if ret.succeed then
            UI.showHint("兑换成功！")
            if ret.hero > 0 then
                Story.show({ heroId = ret.hero, endFun = function()
                    if ret.wife > 0 then
                        Story.show({ wifeId = ret.hero })
                    end
                end })
            else
                if ret.wife > 0 then
                    Story.show({ wifeId = ret.wife })
                end
            end
            self:showReward(ret.item)
        else
            UI.msgBox(ret.error)
        end
    end)
end

function Class:showReward(items)
    log(items)
    if #items > 0 then
        local node = UI.child(self.node, "LevelUp/Item/Base")

        UI.enableOne(self.node, "LevelUp", 2)
        UI.cloneChild(node, #items, 2, UI.child(node, 2))

        for i, v in ipairs(items) do
            local child = UI.child(node, i + 1)
            local item = {
                icon = config.itemMap[v.id].icon,
                count = v.count,
                fun = function()
                    UI.showItemInfo(v.id)
                end
            }
            UI.draw(child, item)
        end

        UI.refreshSVC(node, true)
    end
end

function Class:changeKing(index)
    message:send("C2S_ReqChangeKing", { kingId = index }, function(ret)
        if ret.code == "ok" then
            self.info = ret.info
            self:showTop()
        else
            UI.showHint("设置失败")
        end
        self:showPage(2)
    end)
end

function Class:showKingCheck()
    for i = 1, 4 do
        log(self.info.curKing)
        UI.enable(self.node, "Page/P2/King/" .. i .. "/check", self.info.curKing == i)
    end
end

return Class