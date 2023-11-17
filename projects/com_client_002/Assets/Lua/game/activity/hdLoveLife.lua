local Class = {
    res = "ui/hdLoveLife"
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:addRedDot(add)
    local btnRank = UI.child(self.node, "Page/BtnRank")
    if add then
        RedDot.registerBtn(btnRank, RedDot.SystemID.QingDingRank)
    else
        RedDot.unregisterBtn(btnRank, RedDot.SystemID.QingDingRank)
    end
end

function Class:init()
    self.hasClose = false
    UI.enableAll(self.node, false)
    self.buildInfo = nil
    self.shopItem = nil
    self.changeItem = {}
    self.rankInfo = {}
    self:close()
    self:button()
    self:showEvent()
    self:addRedDot(true)
end

function Class:close()
    UI.button(self.node, "Page/Event/BtnClose", function()
        self:addRedDot(false)
        self:closePage()
    end)

    UI.button(self.node, "Page/Build/BtnClose", function()
        UI.enable(self.node, "Page/Build", false)
    end)

    UI.button(self.node, "Page/Rank/BtnClose", function()
        UI.enable(self.node, "Page/Rank", false)
    end)

    UI.button(self.node, "Shop/BtnClose", function()
        if UI.child(self.node, "Page/Build").gameObject.activeSelf then
            self.showTips = false
            self:showBuild()
        end
        UI.enable(self.node, "Shop", false)
    end)

    UI.button(self.node, "Change/BtnClose", function()
        UI.enable(self.node, "Change", false)
    end)

    UI.button(self.node, "BuildReward/BG/BtnSure", function()
        UI.enable(self.node, "BuildReward", false)
    end)

    UI.button(self.node, "RankReward/BtnClose", function()
        UI.enable(self.node, "RankReward", false)
    end)
end

function Class:button()
    UI.button(self.node, "Page/BtnHelp", function()
        self:showHelp()
    end)

    UI.button(self.node, "Page/BtnRank", function()
        self:showRank(0)
    end)
    UI.button(self.node, "Page/Rank/Btn/BtnOwner", function()
        self:showRank(0)
    end)
    UI.button(self.node, "Page/Rank/Btn/BtnUnity", function()
        self:showRank(1)
    end)
    UI.button(self.node, "Page/Rank/Bottom/BtnRankReward", function()
        self:showRankReward(self.rankIndex)
    end)

    UI.button(self.node, "Page/Event/BtnEnter", function()
        self.showTips = true
        self:showBuild()
    end)

    UI.button(self.node, "Page/Event/Bottom/BtnShop", function()
        self:showShop(0)
    end)
    UI.button(self.node, "Page/Build/Bottom/BtnShop", function()
        self:showShop(0)
    end)
    UI.button(self.node, "Shop/Btn/BtnShop", function()
        self:showShop(0)
    end)
    UI.button(self.node, "Shop/Btn/BtnWare", function()
        self:showShop(1)
    end)

    UI.button(self.node, "Page/Event/Bottom/BtnChange", function()
        self:showChange()
    end)
end

--2.3
function Class:showEvent()
    message:send("C2S_buildEvent", {}, function(ret)
        if self.hasClose then
            return
        end
        UI.CountDown(self.node, "Page/Event/Date/Timer", ret.eventDt - os.time(), function()
            self:closePage()
            UI.showHint("情定终身已结束")
        end, nil, false)
        if ret.countDown < 0 then
            self:closePage()

            UI.showHint("情定终身已结束")
        else
            UI.enable(self.node, "Page", true)
            UI.enableAll(self.node, "Page", true)
            UI.enable(self.node, "Page/Build", false)
            UI.enable(self.node, "Page/Rank", false)

            local eventBt = convertToTime(ret.eventBt)
            local eventDt = convertToTime(ret.eventDt)
            local everyBt = convertToTime(ret.everyBt)
            local everyDt = convertToTime(ret.everyDt)
            local event = { Date = { eventOt = eventBt.month .. "月" .. eventBt.day .. "日-" .. eventDt.month .. "月" .. eventDt.day .. "日" },
                            Open = { everyOt = everyBt.hour .. ":" .. everyBt.minute .. ":" .. everyBt.second .. "-" ..
                                    everyDt.hour .. ":" .. everyDt.minute .. ":" .. everyDt.second } }
            UI.txtUpdateTime(self.node, "Page/Event/Date/countDown", ret.countDown, function()
                UI.enable(self.node, "Page/Build", false)
                UI.enable(self.node, "Page/Rank", false)
                UI.enableOne(self.node, 0)
                UI.showHint("情定终身已结束")
                UI.text(self.node, "Page/Event/Date/countDown", "活动已结束")
                UI.refreshSVC(self.node, "Page/Event/Date", true, true)
            end)
            UI.draw(self.node, "Page/Event", event)
            UI.refreshSVC(self.node, "Page/Event/Date", true, true)
            UI.refreshSVC(self.node, "Page/Event/Open", true, true)
        end
    end)
end

--2.4
function Class:showShop(index)
    message:send("C2S_buildShop", {}, function(ret)
        if self.hasClose then
            return
        end
        UI.enable(self.node, "Shop", true)
        self:showShopSelect(index)
        local itemsNode = UI.child(self.node, "Shop/S/V/C")
        UI.cloneChild(itemsNode, #ret.items)
        for i, v in ipairs(ret.items) do
            local child = UI.child(itemsNode, i - 1)
            UI.enableAll(child, true)

            local des = ""
            local cfg = config.buildEventShopMap[i].item
            for i = 1, #cfg, 3 do
                des = des .. config.itemMap[cfg[i]].name .. (i < 6 and "," or "")
            end

            local fun = function()
                if v.type == 1 then
                    return "前往活动"
                else
                    UI.enableAll(child, "Price", true)
                    UI.enable(child, "Price/Shop", false)
                    UI.enableOne(child, "Price/icon", v.type / 2)
                    if v.limit > 0 then
                        UI.clearGray(child, "BtnBuy")
                        return "购 买"
                    else
                        UI.setGray(child, "BtnBuy")
                        return "售 馨"
                    end
                end
            end

            local data = { name = config.itemMap[v.id].name,
                           Price = { price = v.price },
                           Score = { score = "+" .. config.buildEventShopMap[i].point },
                           Des = { des = des },
                           item = { icon = config.itemMap[v.id].icon, count = index == 1 and v.count or false },
                           Limit = { limit = v.limit .. "/" .. config.buildEventShopMap[i].limit },
                           BtnBuy = { Text = fun(), fun = (v.limit > 0 or v.type == 1) and (function()
                               if v.type == 1 then
                                   UI.show("game.lobby.shop", 2);
                               else
                                   self:buyOrChange(0, v.id)
                               end
                           end) or nil } }
            UI.draw(child, data)

            if v.type == 1 then
                UI.enableOne(child, "Price", 3)
            end
            UI.enable(child, v.count > 0 or index == 0)
            UI.enable(child, "Price", index == 0)
            UI.enable(child, "Limit", index == 0 and v.type ~= 1)
            UI.enable(child, "BtnBuy", index == 0)
        end
        UI.refreshSVC(itemsNode, nil, true, true)
    end)
end

function Class:showShopSelect(index)
    local btnNode = UI.child(self.node, "Shop/Btn")
    for i = 0, 1 do
        local child = UI.child(btnNode, i)
        UI.enable(child, "selected", index == i)
    end
end

function Class:buyOrChange(type, id)
    message:send("C2S_buildGetItem", { type = type, id = id }, function(ret)
        if self.hasClose then
            return
        end
        if ret.code == "ok" then
            ItemTools.showItemResultById(id)
            if type == 0 then
                self:showShop(0)
            else
                self:showChange()
            end
        elseif ret.code == "error_Gold" then
            UI.showHint("元宝不足")
        elseif ret.code == "error_Money" then
            UI.showHint("银两不足")
        elseif ret.code == "error_Limit" then
            UI.showHint("次数不足")
        elseif ret.code == "error_Score" then
            UI.showHint("积分不足")
        end
    end)
end

--2.5
function Class:showChange()
    message:send("C2S_buildChange", {}, function(ret)
        if self.hasClose then
            return
        end
        UI.enable(self.node, "Change", true)
        local itemsNode = UI.child(self.node, "Change/S/V/C")
        UI.cloneChild(itemsNode, #config.buildEventChange)
        for i, v in ipairs(config.buildEventChange) do
            local child = UI.child(itemsNode, i - 1)

            local fun = function()
                if ret.limit[i] > 0 then
                    UI.clearGray(child, "change")
                    return "兑 换"
                else
                    UI.setGray(child, "change")
                    return "售 馨"
                end
            end

            UI.text(self.node, "Change/score", ret.score)

            self.changeItem[i] = { item = { icon = config.itemMap[v.itemID].icon,
                                            limit = ret.limit[i],
                                            fun = function()
                                                UI.showItemInfo(v.itemID)
                                            end },
                                   name = config.itemMap[v.itemID].name,
                                   score = v.pointCost .. "积分",
                                   change = { Text = fun(),
                                              fun = function()
                                                  if ret.limit[i] > 0 then
                                                      self:buyOrChange(1, v.itemID)
                                                  end
                                              end } }
            UI.draw(child, self.changeItem[i])
            if ret.limit[i] <= 0 then
                UI.desObj(child, "change/fun", CS.UnityEngine.UI.Button)
            end
        end
    end)
end

--2.6
function Class:showBuild()
    message:send("C2S_buildNumValue", {}, function(ret)
        if self.hasClose then
            return
        end
        if ret.code ~= "ok" and self.showTips then
            if ret.point < ret.pointMax then
                UI.showHint("还未到定情时间，请稍后再来")
            else
                UI.showHint("定情活动已结束")
            end
        end
        UI.enable(self.node, "Page/Build", true)
        UI.delay(self.node, 8, function()
            UI.enable(self.node, "Page/Build/Chat", false)
        end)
        self.buildInfo = ret
        self:showBuildProgress()
        self:showBuildItem()
        UI.SetToggleIsOn(UI.child(self.node, "Page/Build/S/V/C"), 0)
    end)
end

function Class:showBuildProgress()
    local progress = UI.child(self.node, "Page/Build/progress")
    local percent = self.buildInfo.point / self.buildInfo.pointMax
    UI.text(progress, "percent", "定情进度：" .. string.format("%.2f", percent * 100) .. "%")
    UI.progress(progress, self.buildInfo.point)
    UI.enable(self.node, "Page/Build/Box", percent == 1)
    if percent < 1 then
        --if self.buildInfo.code == "ok" then
        UI.clearGray(self.node, "Page/Build/Bottom/BtnUse")
        --else
        --    UI.setGray(self.node, "Page/Build/Bottom/BtnUse")
        --end
        UI.button(self.node, "Page/Build/Bottom/BtnUse", function()
            if self.selectItem.count > 0 then
                self:useBuildItem()
            else
                UI.showHint("道具不足");
            end
        end)

    else
        UI.setGray(self.node, "Page/Build/Bottom/BtnUse")
        UI.desObj(self.node, "Page/Build/Bottom/BtnUse", CS.UnityEngine.UI.Button)

        UI.enableOne(self.node, "Page/Build/Box", self.buildInfo.gotten and 1 or 0)
        if self.buildInfo.gotten then
            UI.desObj(self.node, "Page/Build/Box", CS.UnityEngine.UI.Button)
        else
            UI.button(self.node, "Page/Build/Box", function()
                message:send("C2S_completeReward", {}, function(ret)
                    if self.hasClose then
                        return
                    end
                    if ret.code == "ok" then
                        self.buildInfo.gotten = true
                        local items = {}
                        local cfg = config.buildEventMap[1]
                        for i = 1, #cfg.completeReward, 2 do
                            local item = {}
                            item.icon = config.itemMap[cfg.completeReward[i]].icon
                            item.count = cfg.completeReward[i + 1]
                            item.fun = function()
                                UI.showItemInfo(cfg.completeReward[i])
                            end
                            table.insert(items, item)
                        end
                        self:showBuildReward(items, 1)
                    else
                        UI.showHint("奖励不存在")
                        self:showBuild()
                    end
                end)
            end)
        end
    end
end

function Class:showBuildItem()
    local itemsNode = UI.child(self.node, "Page/Build/S/V/C")
    UI.draw(itemsNode, self.buildInfo.items)
    for i, v in ipairs(self.buildInfo.items) do
        local child = UI.child(itemsNode, i - 1)
        UI.text(child, "score", "+" .. v.score .. "分")
        UI.toggle(child, function()
            self.selectItem = v
            self.curIndex = i
            self.selectNode = child
        end)
    end
end

function Class:useBuildItem()
    message:send("C2S_UseItemToBuild", { id = self.selectItem.id }, function(ret)
        if self.hasClose then
            return
        end
        if ret.code == "ok" then
            self.buildInfo.point = ret.point
            self.buildInfo.items[self.curIndex].count = self.buildInfo.items[self.curIndex].count - 1
            UI.playEffect(self.node, "Page/Build/BG", "eft_04", 3);
            self:showBuildItem()
            self:showBuildProgress()
            local items = {}
            for i, v in ipairs(ret.items) do
                local item = { icon = config.itemMap[v.id].icon,
                               count = v.count,
                               fun = function()
                                   UI.showItemInfo(v.id)
                               end }
                table.insert(items, item)
            end
            self:showBuildReward(items, 0)
        else
            UI.showHint("您已错过定情时间，请下次再来")
            --self:showBuild()
        end
    end)
end

function Class:showBuildReward(item, type)
    UI.enable(self.node, "BuildReward", true)
    local node = UI.child(self.node, "BuildReward/BG/S/V/C")
    UI.enable(self.node, "BuildReward/BG/Score", type == 0)
    UI.enableOne(self.node, "BuildReward/BG/Title", type)
    if #item > 0 then
        UI.draw(node, item)
        self:showBuildProgress()
        UI.text(self.node, "BuildReward/BG/Score", "积分+" .. self.buildInfo.items[self.curIndex].score)
    else
        UI.enable(self.node, "BuildReward", false)
    end
end

--2.7
function Class:showRank(type)
    message:send("C2S_buildRank", { type = type }, function(ret)
        if self.hasClose then
            return
        end
        UI.enable(self.node, "Page/Rank", true)
        self:showRankSelect(type)

        UI.enableOne(self.node, "Page/Rank/P", #ret.player > 0 and 0 or 1)
        local rankNode = UI.child(self.node, "Page/Rank/P/S/V/C")
        UI.draw(rankNode, ret.player)
        local data = { rank = ret.rank > 0 and ret.rank or "未上榜",
                       score = ret.score,
                       name = string.len(ret.name) > 0 and ret.name or "无" }

        self.rankInfo[type] = (type == 1 and "联盟排名：" or "我的排名：") .. (ret.rank > 0 and ret.rank or "未上榜")

        UI.draw(self.node, "Page/Rank/Bottom", data)
    end)
end

function Class:showRankSelect(type)
    local btnNode = UI.child(self.node, "Page/Rank/Btn")
    self.rankIndex = type
    for i = 0, 1 do
        local child = UI.child(btnNode, i)
        UI.enable(child, "selected", type == i)
    end
    UI.enableOne(self.node, "Page/Rank/BG/Rank/Name", type)
    UI.enableOne(self.node, "Page/Rank/Bottom/Name", type)
    --UI.enableOne(self.node, "Page/Rank/Bottom/Rank", type)
end

function Class:showRankReward(type)
    message:send("C2S_buildRankReward", { type = type }, function(ret)
        if self.hasClose then
            return
        end
        UI.text(self.node, "RankReward/Tips", type == 1 and Tools.getEventTips(6) or Tools.getEventTips(5))
        UI.enableOne(self.node, "RankReward/Bottom/BtnGet", ret.gotten and 0 or 1)
        if ret.canGet then
            UI.clearGray(self.node, "RankReward/Bottom/BtnGet")
            UI.button(self.node, "RankReward/Bottom/BtnGet/Btn", function()
                self:getRankReward(self.rankIndex)
            end)
        else
            UI.setGray(self.node, "RankReward/Bottom/BtnGet")
            UI.desObj(self.node, "RankReward/Bottom/BtnGet/Btn", CS.UnityEngine.UI.Button)
        end
    end)

    UI.enable(self.node, "RankReward", true)
    local itemNode = type == 1 and UI.child(self.node, "RankReward/P/s/V/C") or UI.child(self.node, "RankReward/P/S/V/C")
    UI.enableOne(self.node, "RankReward/P", type == 1 and 1 or 0)
    local Items = Tools.getEventAllItems(type == 1 and config.buildEventRankGuild or config.buildEventRank)
    --log(Items)
    UI.cloneChild(itemNode, #Items)
    for i, v in ipairs(Items) do
        local child = UI.child(itemNode, i - 1)

        UI.text(child, "BG/Rank/rank", v.rank)
        local itemsNode = UI.child(child, "Item")
        UI.cloneChild(itemsNode, #v)

        for j, item in ipairs(v) do
            local itemNode = UI.child(itemsNode, j - 1)
            UI.draw(itemNode, item)
        end
        UI.refreshSVC(child, "BG/Rank")
    end
    if type == 1 then
        local Items2 = Tools.getEventAllItems(config.buildEventRankGuild, 2)
        for i, v in ipairs(Items2) do
            local child = UI.child(itemNode, i - 1)
            local itemsNode = UI.child(child, "Item2")
            UI.cloneChild(itemsNode, #v)
            for j, item in ipairs(v) do
                local itemNode = UI.child(itemsNode, j - 1)
                UI.draw(itemNode, item)
            end
        end
    end
    UI.text(self.node, "RankReward/Bottom/rank", self.rankInfo[type])
    UI.refreshSVC(itemNode)
end

function Class:getRankReward(type)
    message:send("C2S_getBuildReward", { type = type }, function(ret)
        if self.hasClose then
            return
        end
        if ret.code == "ok" then
            ItemTools.showItemsResult(ret.items)
            self:showRankReward(type)
        end
    end)
end

function Class:showHelp()
    showHelp("getengaged");
end

function Class:onFront()
    self:showShop(0)
    if UI.child(self.node, "Page/Build").gameObject.activeSelf then
        self.showTips = false
        self:showBuild()
    end
end

return Class
