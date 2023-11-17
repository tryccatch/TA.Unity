local Class = {
    res = "ui/limitReward",
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()

    UI.enableAll(self.node, false)

    UI.button(self.node, "P1/BtnClose", function()
        UI.close(self)
    end)

    self.typeInfo = {}

    UI.button(self.node, "P2/BtnClose", function()
        UI.enable(self.node, "P2", false)
        self:showP1()
    end)

    self.typeNode = self.node:Find("P1/S/V/C")
    self.levelNode = self.node:Find("P2/S/V/C")

    self.getReward = true
    self:showP1()
end

function Class:showP1()
    if self.getReward then
        message:send("C2S_ReqLimitRewardType", {}, function(ret)
            if self.hasClose then
                return
            end
            if ret.countDown > 0 then
                self.getReward = false
                UI.enableOne(self.node, 0)

                local startDate = convertToTime(ret.startDate / 1000)
                local endDate = convertToTime((ret.endDate / 1000) - 1)
                self.date = startDate.month .. "月" .. startDate.day .. "日-" .. endDate.month .. "月" .. endDate.day .. "日"
                self.countDown = ret.countDown

                self.type = ret.type

                UI.cloneChild(self.typeNode, #self.type)

                for i, v in ipairs(self.type) do
                    local child = UI.child(self.typeNode, i - 1)

                    UI.draw(child, { date = self.date, title = v.title, redDot = v.redDot, BtnEnter = function()
                        self:showP2(i)
                    end })

                    UI.txtUpdateTime(child, "countDown", self.countDown / 1000, function()
                        UI.desObj(child, "countDown", CS.TxtTime);
                        UI.close(self);
                    end)
                end
            else
                UI.showHint("限时奖励已结束")
                UI.close(self)
            end
        end)
    end
end

function Class:sortRewardList(items)
    local newItems = {}
    local count = 0
    for i, v in ipairs(items) do
        if v.gotten then
            table.insert(newItems, #newItems + 1, v)
            count = count + 1
        else
            table.insert(newItems, i - count, v)
        end
    end

    return newItems
end

function Class:showP2(index)
    UI.text(self.node, "P2/title", self.type[index].title)
    if self.typeInfo[index] then
        UI.enable(self.node, "P2", true)
        local info = self.typeInfo[index]
        UI.draw(self.levelNode, info.level)
        for i, v in ipairs(self:sortRewardList(info.level)) do
            local child = UI.child(self.levelNode, i - 1)
            local cfg = config.limitedRewardMap[v.id]
            UI.draw(child, { title = cfg.description .. "(" .. info.value .. "/" .. cfg.num .. ")" })
            local items = self:showItemsById(v.id)
            UI.clearGray(child, "Btn")
            if v.gotten then
                UI.enableOne(child, "Btn", 2)
            else
                UI.enableOne(child, "Btn", 1)
                if v.canGet then
                    UI.enableOne(child, "Btn", 0)
                    UI.button(child, "Btn/Get", function()
                        UI.button(child, "Btn/Get", nil)
                        message:send("C2S_ReqGetLimitRewardItem", { type = self.type[index].type, level = v.level }, function(ret)
                            if self.hasClose then
                                return
                            end
                            self.typeInfo[index] = ret
                            ItemTools.showItemsResult(items)
                            self.getReward = true
                            self:showP2(index)
                        end)
                    end)
                else
                    UI.setGray(child, "Btn")
                end
            end

            local itemsNode = child:Find("Item")
            UI.cloneChild(itemsNode, 4)
            for i = 1, 4 do
                local item = UI.child(itemsNode, i - 1)
                if items[i] then
                    UI.draw(item, { icon = config.itemMap[items[i].id].icon, count = items[i].count })
                    UI.button(item, function()
                        UI.showItemInfo(items[i].id)
                    end)
                    if item:Find("effect") == nil then
                        UI.showNode(item, nil, "Effect/itemEffect").name = "effect"
                    else
                        UI.enableAll(item, true)
                    end
                else
                    UI.enableAll(item, false)
                end
            end
        end
    else
        message:send("C2S_ReqLimitRewardLevel", { type = self.type[index].type }, function(ret)
            if self.hasClose then
                return
            end
            self.typeInfo[index] = ret
            self:showP2(index)
        end)
    end

    UI.refreshSVC(self.levelNode)
end

function Class:showItemsById(id)
    local cfg = config.limitedRewardMap[id]
    local items = {}

    if cfg.money > 0 then
        local item = {}
        item.id = 1000
        item.count = cfg.money
        table.insert(items, item)
    end
    if cfg.food > 0 then
        local item = {}
        item.id = 2000
        item.count = cfg.food
        table.insert(items, item)
    end

    if cfg.soldier > 0 then
        local item = {}
        item.id = 3000
        item.count = cfg.soldier
        table.insert(items, item)
    end
    if cfg.gold > 0 then
        local item = {}
        item.id = 5000
        item.count = cfg.gold
        table.insert(items, item)
    end

    local itemCfg = cfg.item

    if #itemCfg > 1 then
        for i = 1, #itemCfg, 2 do
            local item = {}
            item.id = itemCfg[i]
            item.count = itemCfg[i + 1]
            table.insert(items, item)
        end
    end

    return items
end

return Class