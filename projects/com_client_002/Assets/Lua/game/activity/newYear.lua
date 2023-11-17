local Class = {
    res = "UI/newYear"
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
    if self.loginTips then
        UI.openPage(UIPageName.ActivityLoginTips)
    end
end

function Class:init(main)
    self.hasClose = false

    if main then
        self.loginTips = true
    end

    UI.enable(self.node, false)
    UI.button(self.node, "BtnClose", function()
        self:closePage()
    end)

    cfg = config.event401Map[1]

    log("new Year")

    if #cfg.itemID % 2 > 0 then
        self:closePage()
    end

    message:send("C2S_HD_NewYearOpen", {}, function(ret)
        if self.hasClose then
            return
        end

        log(ret)
        log("new Year")

        if not ret.open then
            self:closePage()
            return
        else
            UI.enable(self.node, true)
        end

        log("new Year open")

        if ret.Countdown > 0 then
            UI.CountDown(self.node, "countDown", ret.Countdown, function()
                self:closePage()
                return
            end)
        else
            UI.showHint("新年礼包活动已结束")
            self:closePage()
            return
        end

        log("new Year ing")

        self.info = ret
        self:show()
        self:button()

        local Anim = UI.showNode(self.node, "Anim", "Anim/hero" .. cfg.hero)
        UI.playAnim(Anim, "idle")
        UI.text(self.node, "grows", config.heroMap[cfg.hero].allGrows)
    end)
end

function Class:button()
    UI.button(self.node, "Box/Btn/Ack", function()
        if self.info.state < 0 then
            ComTools.charge(config.payMap[cfg.payID], "recharge", cfg.payID, function()
                message:send("C2S_HD_NewYearOpen", {}, function(ret)
                    self.info = ret
                    self:show()
                end)
            end)
        elseif self.info.state == 0 then
            message:send("C2S_HD_NewYearReceive", {}, function(ret)
                if ret.success then
                    self.info.state = 1
                    local count = #cfg.itemID / 2
                    local items = {}
                    for i = 1, count do
                        local item = { id = cfg.itemID[2 * i - 1],
                                       count = cfg.itemID[2 * i] }
                        table.insert(items, item)
                    end
                    if cfg.hero > 0 then
                        Story.show({ heroID = cfg.hero, endFun = function()
                            if cfg.wife > 0 then
                                Story.show({ wifeId = cfg.wife, endFun = function()
                                    ItemTools.showItemsResult(items)
                                end })
                            else
                                ItemTools.showItemsResult(items)
                            end
                        end })
                    end
                    self:show()
                end
            end)
        else
            UI.showHint("已领取")
        end
    end)
end

function Class:show()
    local node = UI.child(self.node, "Box/Item/S/V/C")

    local count = #cfg.itemID / 2
    log(#cfg.itemID)
    log(count)
    local items = {}
    UI.cloneChild(node, count)
    for i = 1, count do
        local child = UI.child(node, i - 1)
        local item = {
            icon = config.itemMap[cfg.itemID[2 * i - 1]].icon,
            count = cfg.itemID[2 * i],
            gotten = self.info.state > 0,
            fun = function()
                UI.showItemInfo(cfg.itemID[2 * i - 1])
            end }
        table.insert(items, item)

        self:showEffect(child, self.info.state < 1)

        UI.draw(child, item)
    end

    UI.enableOne(self.node, "Box/Btn", self.info.state > 0 and 1 or 0)

    if self.info.state == 0 then
        UI.text(self.node, "Box/Btn/Ack/Text", "领 取")
    else
        local py = config.payMap[cfg.payID].price
        UI.text(self.node, "Box/Btn/Ack/Text", Tools.showChannelValue(py))
    end
end

function Class:showEffect(node, value)
    if UI.check(node) then
        local effect = node:Find("effect")
        if value then
            if not effect then
                UI.showNode(node, "Effect/itemEffect").name = "effect"
            else
                UI.enable(effect, true)
            end
        else
            if effect then
                UI.enable(effect, false)
            end
        end
    end
end

return Class