local Class = {
    res = "ui/vipReward"
}

function Class:closeSelf()
    self.hasClose = true
    UI.close(self)
end

local vipCfg = config.vip
local maxLevel = #vipCfg - 1

function Class:init()
    self.hasClose = false
    UI.button(self.node, "BtnClose", function()
        self:closeSelf()
    end)

    self.pos = {
        [2] = { x = -180, y = -1200 },
        [3] = { x = -120, y = -1200 },
        [4] = { x = -180, y = -400 },
        [5] = { x = -180, y = -1250 },
        [6] = { x = -180, y = -420 },
        [7] = { x = -180, y = -1280 },
        [8] = { x = -160, y = -420 },
        [9] = { x = -190, y = -1250 },
        [10] = { x = -190, y = -380 },
        [11] = { x = -200, y = -1250 },
        [12] = { x = -160, y = -1234 } }
    self.vipLevel = client.user.vip
    self.rate = Tools.getChannelMap().getGold
    self:btnAck()
    self.index = 1
    self:showBottom()
    self:open()
end

function Class:open()
    message:send("C2S_ReqVipRewardState", {}, function(ret)
        if self.hasClose then
            return
        end
        self.state = ret.state
        self:showRedDot()
        print("open------------------")
        self:showReward(self.index)
    end)
end

function Class:showBottom()
    local btnNode = UI.child(self.node, "Bottom/S/V/C")
    UI.cloneChild(btnNode, maxLevel - 1, 1)
    for i = 1, maxLevel do
        local child = UI.child(btnNode, i - 1)
        UI.draw(child, { icon = i, bg = { vipLevel = i } })
        UI.refreshSVC(child, "bg")
        UI.button(child, function()
            if self.index ~= i then
                self.index = i
                self:showReward(i)
            end
        end)
    end

    local rect = UI.component2(btnNode, typeof(CS.UnityEngine.RectTransform))
    log(rect.sizeDelta.x)

    --local width = rect.rect.width / maxLevel

    log(rect.rect.width)

    UI.enable(self.node, "Bottom/L", rect.anchoredPosition.x < -30)

    UI.button(self.node, "Bottom/L", function()
        UI.setLocalOffset(btnNode, 150, 0, 0)
    end)

    UI.button(self.node, "Bottom/R", function()
        UI.setLocalOffset(btnNode, -150, 0, 0)
    end)

    local S = UI.child(self.node, "Bottom/S")

    CS.UIAPI.ScrollRectFun(S, function(value)

        UI.enable(self.node, "Bottom/L", rect.anchoredPosition.x < -30)
        UI.enable(self.node, "Bottom/R", rect.anchoredPosition.x > -1170)

    end)

end

function Class:showRedDot()
    local btnNode = UI.child(self.node, "Bottom/S/V/C")
    for i = 1, maxLevel do
        local child = UI.child(btnNode, i - 1)
        UI.enable(child, "redDot", self.state[i] == 1)
    end
end

function Class:getReward()
    message:send("C2S_ReqGetVipReward", { index = self.index, state = self.state[self.index] }, function(ret)
        if self.hasClose then
            return
        end

        local itemAck = function()
            ItemTools.showItemsResult(self.items)
            self.state[self.index] = self.state[self.index] + 1
            self:showRedDot()
            self:showReward(self.index)
        end

        if ret.code == "_ok" then
            if self.hero > 0 then
                Story.show({ heroID = self.hero, endFun = function()
                    itemAck()
                end })
            elseif self.wife > 0 then
                Story.show({ wifeID = self.wife, endFun = function()
                    itemAck()
                end })
            else
                itemAck()
            end

        elseif ret.code == "haveHero" or ret.code == "haveWife" then
            UI.showHint((ret.code == "haveHero" and "您已获得该豪杰") or (ret.code == "haveWife" and "您已获得该红颜"))
            ItemTools.showItemsResult(self.items)
            self.state[self.index] = self.state[self.index] + 1
            self:showRedDot()
            self:showReward(self.index)
        elseif ret.code == "noGold" then
            UI.showHint("元宝不足")
        elseif ret.code == "noVipLevel" then
            UI.showHint("vip等级不足")
        else
            UI.showHint("领取失败")
            self:open()
        end
    end)
end

function Class:btnAck()
    local btnNode = UI.child(self.node, "Reward/Btn")

    UI.button(btnNode, "Pay", function()
        ComTools.openRecharge()
    end)

    UI.button(btnNode, "Get", function()
        self:getReward()
    end)

    UI.button(btnNode, "Buy", function()
        self:getReward()
    end)
end

function Class:showReward(index)
    print("index= ", index)
    log(vipCfg)
    local cfg = vipCfg[index + 1]
    local rewardNode = UI.child(self.node, "Reward")
    local SVC = UI.child(rewardNode, "S/V/C")
    print("has rewardNode", rewardNode ~= nil, "hasSvc:", SVC ~= nil)
    local itemsCfg
    log(cfg)
    self.hero = 0
    self.wife = 0

    UI.enableOne(rewardNode, "Btn", self.state[index])
    if self.state[index] <= 1 then
        itemsCfg = cfg.itemID
        UI.draw(rewardNode, { vip = 0 })
        self.hero = cfg.heroID
        self.wife = cfg.wifeID
    else
        itemsCfg = cfg.itemOnlyID
        UI.draw(rewardNode, { vip = index })
        UI.text(rewardNode, "Btn/Buy/gold", cfg.itemOnlyCost)
        UI.refreshSVC(self.node, "Reward/Btn/Buy")
    end
    UI.child(rewardNode, "vip"):GetComponent(typeof(CS.UnityEngine.UI.Image)):SetNativeSize()

    UI.cloneChild(SVC, #itemsCfg / 2)
    local items = {}
    for i = 1, #itemsCfg / 2 do
        local child = UI.child(SVC, i - 1)
        local item = { id = itemsCfg[2 * i - 1],
                       icon = config.itemMap[itemsCfg[2 * i - 1]].icon,
                       count = itemsCfg[2 * i],
                       fun = function()
                           UI.showItemInfo(itemsCfg[2 * i - 1])
                       end }
        UI.draw(child, item)
        table.insert(items, item)
    end
    self.items = items

    UI.enableOne(self.node, "Page", index > 1 and 1 or 0)
    if index > 1 then
        local node = UI.child(self.node, "Page/P2")
        local data = {}
        local animNode = UI.child(node, "Anim/pos/anim", true)
        if animNode then
            UI.close(animNode)
        end
        local pos = UI.child(node, "Anim/pos")
        UI.setLocalPosition(pos, self.pos[index].x, self.pos[index].y)
        if cfg.heroID > 0 then
            local heroCfg = config.hero[cfg.heroID]
            data.name = cfg.heroID + 100
            data.specialty = heroCfg.specialty
            data.grows = heroCfg.allGrows
            local animNode = UI.showNode(node, "Anim/pos", "Anim/hero" .. cfg.heroID)
            animNode.name = "anim"
            UI.playAnim(animNode, "idle")
        elseif cfg.wifeID > 0 then
            local wifeCfg = config.wife[cfg.wifeID]
            data.name = cfg.wifeID + 200
            data.specialty = 3
            data.grows = wifeCfg.beauty
            local animNode = UI.showNode(node, "Anim/pos", "Anim/wife" .. cfg.wifeID)
            animNode.name = "anim"
            UI.playAnim(animNode, "idle")
        end
        data.pay = math.floor(cfg.pay / self.rate)
        data.vipLevel = index
        UI.draw(node, data)
        UI.child(node, "name"):GetComponent(typeof(CS.UnityEngine.UI.Image)):SetNativeSize()
        --UI.child(node, "pay"):GetComponent(typeof(CS.UnityEngine.UI.Image)):SetNativeSize()
    end
end

function Class:onFront()
    --if client.user.vip > self.vipLevel then
    --self.vipLevel = client.user.vip
    self:open()
    --end
end

return Class