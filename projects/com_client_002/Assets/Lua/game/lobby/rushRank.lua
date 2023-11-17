local Class = {
    res = "ui/rushRank",
}

function Class:init()
    UI.button(self.node, "P1/BtnClose", function()
        UI.close(self)
    end)
    CS.Sound.PlayMusic("music/activity")
    UI.enableAll(self.node, false)
    self.RankTypeNode = self.node:Find("P1/S/V/C")
    self.firstRewardNode = self.node:Find("P2/Bottom/S/V/C")
    self.rankNode = self.node:Find("Rank/P/S/V/C")

    message:send("C2S_ReqRushRankType", {}, function(ret)
        self.rankType = ret.rankType
        self:showP1()
    end)

end

function Class:showP1()
    UI.enableOne(self.node, 0)

    --UI.draw(self.RankTypeNode, self.rankType)
    UI.enable(self.node, "P1/S", true)
    UI.cloneChild(self.RankTypeNode, #self.rankType)
    for i, v in ipairs(self.rankType) do
        local child = UI.child(self.RankTypeNode, i - 1)

        UI.enableAll(child, true)

        if i == 1 then
            UI.enable(child, "Top", false)
        elseif i ~= #self.rankType then
            UI.enable(child, "Bottom", false)
        end

        UI.draw(child, { eventId = v.eventId, date = self:changeTime(v.startDate, v.endDate) })

        log(v.countDown)
        if v.countDown > 0 then
            UI.txtUpdateTime(child, "countDown", v.countDown, function()
                UI.desObj(child, "countDown", CS.TxtTime);
                if v.countDown > 0 then
                    for j, event in ipairs(config.rushLoop) do
                        if event.eventId == v.eventId then
                            UI.showHint(event.name .. "已结束");
                        end
                    end
                end
                UI.text(child, "countDown", "活动已结束")
                --UI.close(child);
            end)
        else
            if is_debug then
                UI.text(child, "countDown", v.countDown < 0 and "活动未开始" or "领奖时间")
                --if v.countDown < 0 then
                --    UI.close(child);
                --end
            else
                UI.close(child);
            end
        end

        UI.button(child, "BtnEnter", function()
            self.index = i
            self:showP2(self.index)
            local Path = self.node:Find("P2/Active/CountDown")
            local path = self.node:Find("P2/Active/countDown")
            self:upDateTime(Path, path, v.eventId)
        end)
    end
end

function Class:changeTime(startDate, endDate)
    local startDate = convertToTime(startDate / 1000)
    local endDate = convertToTime(endDate / 1000)
    local date = startDate.month .. "月" .. startDate.day .. "日-" .. endDate.month .. "月" .. endDate.day .. "日"
    return date
end

function Class:showP2(index)
    UI.enable(self.node, "P2", true)
    UI.button(self.node, "P2/BtnClose", function()
        UI.enable(self.node, "P2", false)
    end)

    for i, event in ipairs(config.rushLoop) do
        if event.eventId == self.rankType[index].eventId then
            log(event.eventId)
            UI.showHint(event.name .. "已结束");
        end
    end

    UI.button(self.node, "P2/BtnEnter", function()
        self:showP3(self.index)
        local Path = self.node:Find("P3/CountDown")
        local path = self.node:Find("P3/countDown")
        self:upDateTime(Path, path, self.rankType[index].eventId)
    end)

    message:send("C2S_ReqRushRankThreePlayer", { eventId = self.rankType[index].eventId }, function(ret)
        log(ret)
        for i = 1, 3 do
            local player = {
                name = "暂无玩家",
                score = 0,
            }
            if ret.threePlayer[i] then
                UI.enableOne(self.node, "P2/Active/Player" .. i .. "/Head", 0)
                player.name = ret.threePlayer[i].name
                player.score = goldFormat(ret.threePlayer[i].score)
                local child = self.node:Find("P2/Active/Player" .. i .. "/Head/player")

                UI.draw(child, ret.threePlayer[i])
                if ret.threePlayer[i].curCloth > 0 then
                    UI.sprite(child, "level", "KingCloth", ret.threePlayer[i].curCloth)
                else
                    UI.sprite(child, "level", "Body", ret.threePlayer[i].level)
                end

            else
                UI.enableOne(self.node, "P2/Active/Player" .. i .. "/Head", 1)
            end
            UI.draw(self.node, "P2/Active/Player" .. i, player)
        end
    end)

    local rankInfo = self.rankType[index]
    local rushTypeInfo = {
        Active = rankInfo.eventId,
        eventId = rankInfo.eventId,
        date = self:changeTime(rankInfo.startDate, rankInfo.endDate),
    }
    if rankInfo.eventId > 5 then
        rushTypeInfo.Active = 201
    end
    UI.draw(self.node, "P2", rushTypeInfo)

    if rankInfo.eventId < 5 then
        UI.enable(self.node, "P2/Bottom/GetName", true)
        UI.draw(self.node, "P2/Bottom/GetName", { KingName = rankInfo.eventId })
    else
        UI.enable(self.node, "P2/Bottom/GetName", false)
    end

    UI.draw(self.firstRewardNode, Tools.getOneEventItems(self:getEvent(rankInfo.eventId)[1]))
end

function Class:getEvent(index)
    if index == 1 then
        return config.event1
    elseif index == 2 then
        return config.event2
    elseif index == 3 then
        return config.event3
    elseif index == 4 then
        return config.event4
    elseif index == 201 then
        return config.event201
    elseif index == 202 then
        return config.event202
    elseif index == 203 then
        return config.event203
    elseif index == 204 then
        return config.event204
    elseif index == 205 then
        return config.event205
    elseif index == 206 then
        return config.event206
    elseif index == 207 then
        return config.event207
    elseif index == 208 then
        return config.event208
    elseif index == 209 then
        return config.event209
    end
end

function Class:getTipStr(index)
    local eventDes = { }
    eventDes[1] = "势力涨幅"
    eventDes[2] = "亲密涨幅"
    eventDes[3] = "权威涨幅"
    eventDes[4] = "联盟经验涨幅"
    eventDes[201] = "银两消耗"
    eventDes[202] = "兵力消耗"
    eventDes[203] = "关卡突破"
    eventDes[204] = "国子监修行"
    eventDes[205] = "培养子嗣"
    eventDes[206] = "召唤宠幸"
    eventDes[207] = "子嗣联姻"
    eventDes[208] = "寻访次数"

    local eventCfg = self:getEvent(index)
    local maxRank = "前" .. eventCfg[#eventCfg].endRank .. "名"
    local eventStr = index == 4 and "联盟内" or ""
    local str = "活动期间，" .. eventDes[index] ..
            "排行 " .. UI.colorStr(maxRank, ColorStr.yellow) ..
            " 的" .. eventStr .. "玩家可领取丰厚奖励"

    return str
end

function Class:showP3(index)

    UI.enable(self.node, "P3", true)
    UI.button(self.node, "P3/BtnClose", function()
        UI.enable(self.node, "P3", false)
    end)

    UI.button(self.node, "P3/BtnRank", function()
        self:showRank(self.index)
    end)

    local eventId = self.rankType[index].eventId
    local rushTypeInfo = {
        Active = self.rankType[index].eventId,
        eventId = self.rankType[index].eventId,
        date = self:changeTime(self.rankType[index].startDate, self.rankType[index].endDate),
        Tips = Tools.getEventTips(eventId),
    }
    if self.rankType[index].eventId > 5 then
        rushTypeInfo.Active = 201
    end
    UI.draw(self.node, "P3", rushTypeInfo)

    local itemNode = eventId == 4 and UI.child(self.node, "P3/P/s/V/C") or UI.child(self.node, "P3/P/S/V/C")
    UI.enableOne(self.node, "P3/P", eventId == 4 and 1 or 0)

    local Items = Tools.getEventAllItems(self:getEvent(self.rankType[index].eventId))

    UI.cloneChild(itemNode, #Items)

    for i, v in ipairs(Items) do
        local child = UI.child(itemNode, i - 1)

        local itemsNode = UI.child(child, "Item")

        UI.cloneChild(itemsNode, #v)

        for j, item in ipairs(v) do
            local itemNode = UI.child(itemsNode, j - 1)
            UI.draw(itemNode, item)
        end

        if i == 1 and eventId < 5 then
            UI.enable(child, "title", true)
            UI.draw(child, "title", { KingName = eventId })
        else
            UI.enable(child, "title", false)
        end

        UI.draw(child, "BG", { rank = v.rank })
    end

    if eventId == 4 then
        local Items2 = Tools.getEventAllItems(self:getEvent(self.rankType[index].eventId), 2)
        log(Items2)
        for i, v in ipairs(Items2) do
            local child = UI.child(itemNode, i - 1)
            local itemsNode = UI.child(child, "Item2")
            UI.cloneChild(itemsNode, #v)
            for j, item in ipairs(v) do
                local itemNode = UI.child(itemsNode, j - 1)
                log(item)
                UI.draw(itemNode, item)
            end
        end
    end
    self:getRoleInfo(eventId, 3)

    UI.refreshSVC(itemNode)
end

function Class:getRoleInfo(eventId, index)

    message:send("C2S_ReqMyRushRank", { eventId = eventId }, function(ret)
        local role = {
            rank = ret.rank > 0 and ret.rank or (eventId == 4 and (ret.name == "" and "未入盟" or "未上榜") or "未上榜"),
            tips = "还未到达领奖时间",
            value = ret.value,
            name = eventId == 4 and (ret.name == "" and "未入盟" or ret.name) or client.user.name,
            RankValue = eventId,
        }
        if index == 3 then
            UI.clearGray(self.node, "P3/BtnReward")

            if ret.gotten then
                UI.enableOne(self.node, "P3/BtnReward", 1)
                UI.enable(self.node, "P3/Bottom/tips", false)
            else
                UI.enableOne(self.node, "P3/BtnReward", 0)
                UI.enableOne(self.node, "P3/BtnReward/BtnGet", 1)
                UI.enable(self.node, "P3/Bottom/tips", true)
                if ret.canGet then
                    if ret.rank > 0 then
                        role.tips = "再接再厉！"
                        UI.enableOne(self.node, "P3/BtnReward/BtnGet", 0)
                        UI.button(self.node, "P3/BtnReward/BtnGet/Get", function()
                            message:send("C2S_ReqGetRushReward", { eventId = eventId }, function(ret)
                                local rank = ret.rank

                                if eventId == 4 and not ret.isUnityMaster then
                                    ItemTools.showItemsResult(Tools.getEventAllItems(self:getEvent(eventId), 2, rank))
                                else
                                    ItemTools.showItemsResult(Tools.getEventAllItems(self:getEvent(eventId), 1, rank))
                                end

                                UI.enableOne(self.node, "P3/BtnReward", 1)
                                UI.enable(self.node, "P3/Bottom/tips", false)
                            end)
                        end)
                    else
                        UI.button(self.node, "P3/BtnReward/BtnGet/Get", nil)
                        role.tips = "很遗憾！未获得奖励"
                        UI.setGray(self.node, "P3/BtnReward")
                    end
                else
                    UI.setGray(self.node, "P3/BtnReward")
                    role.tips = "还未到达领奖时间"
                end
            end
            UI.enableOne(self.node, "P3/Bottom/Rank", eventId == 4 and 1 or 0)
            UI.draw(self.node, "P3/Bottom", role)
        else
            UI.enableAll(self.node, "Rank/Bottom", true)
            UI.enableOne(self.node, "Rank/Bottom/Name", eventId == 4 and 1 or 0)
            UI.enableOne(self.node, "Rank/Bottom/Rank", eventId == 4 and 1 or 0)
            if eventId == 4 then
                role.rank = "\t " .. role.rank
                role.name = "\t " .. role.name
            end
            UI.draw(self.node, "Rank/Bottom", role)
        end
    end)
end

function Class:upDateTime(Path, path, eventId)
    message:send("C2S_ReqGetCountDown", { eventId = eventId }, function(ret)
        log(ret.countDown)

        if ret.countDown > 0 then
            UI.enable(Path, true)
            UI.enable(path, true)
            UI.txtUpdateTime(path, ret.countDown / 1000, function()
                log(self)
                UI.desObj(path, CS.TxtTime);
                for i, event in ipairs(config.rushLoop) do
                    if event.eventId == eventId then
                        UI.showHint(event.name .. "已结束");
                    end
                end
                self:showP1()
            end)
        else
            UI.text(path, ret.countDown < 0 and "活动未开始" or "活动已结束")
        end
    end)
end

function Class:showRank(index)
    UI.button(self.node, "Rank/BtnClose", function()
        UI.enable(self.node, "Rank", false)
    end)
    local eventId = self.rankType[index].eventId
    UI.enableOne(self.node, "Rank/BG/Rank/Name", eventId == 4 and 1 or 0)
    message:send("C2S_ReqRushRankTopPlayer", { eventId = eventId }, function(ret)
        UI.enable(self.node, "Rank", true)
        if #ret.topPlayer > 0 then
            UI.enableOne(self.node, "Rank/P", 0)
            UI.draw(self.rankNode, ret.topPlayer)
        else
            UI.enableOne(self.node, "Rank/P", 1)
        end
    end)
    self:getRoleInfo(eventId)
    UI.refreshSVC(self.rankNode)

end

return Class