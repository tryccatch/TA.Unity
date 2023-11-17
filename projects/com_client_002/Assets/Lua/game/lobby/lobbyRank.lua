local Class = {
    res = "ui/lobbyRank"
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()
    self.hasClose = false

    UI.button(self.node, "BtnClose", function()
        self:closePage()
    end)

    self.BtnNode = self.node:Find("Btn")
    self.rankNode = self.node:Find("S/V/C")
    self.RankNode = self.node:Find("Rank")
    self.BottomNode = self.node:Find("Bottom")
    self.visitNode = self.node:Find("Visit")

    message:send("C2S_ReqLobbyRankInfo", {}, function(ret)
        if self.hasClose then
            return
        end
        self.rankInfo = ret
        UI.enableAll(self.node, true)

        self:showSelectRank(1)
    end)

    for i = 1, 3 do
        UI.button(self.BtnNode, "Btn_" .. i, function()
            self:showSelectRank(i)
        end)
    end

end

function Class:showSelectRank(index)

    self:showSelectBtn(index)
    UI.enableAll(self.RankNode, true)
    UI.enableOne(self.RankNode, "Value", index - 1)
    UI.enableOne(self.BottomNode, "Value", index - 1)
    UI.enable(self.RankNode, "Level", index < 3)
    UI.enable(self.node, "Visit", false)

    local myRank = {
        rank = "未上榜";
        value = self:showValue(self.rankInfo.myRank, index);
    }

    UI.cloneChild(self.rankNode, #self.rankInfo.players[index].player)

    for i, v in ipairs(self.rankInfo.players[index].player) do
        local child = UI.child(self.rankNode, i - 1)
        UI.enableAll(child, true)
        UI.enableOne(child, "Rank", i < 4 and i or 0)
        UI.enable(child, "Level", index < 3)

        local rankInfo = {
            Name = { name = v.name },
            Level = index < 3 and { level = index < 3 and v.level or nil } or nil,
            Value = { value = self:showValue(v, index) },
        }

        if i == 1 then
            rankInfo.Name.name = "<color=#ED7D31>" .. v.name .. "</color>"
        elseif i == 2 then
            rankInfo.Name.name = "<color=#ef19e2>" .. v.name .. "</color>"
        elseif i == 3 then
            rankInfo.Name.name = "<color=#00b0f0>" .. v.name .. "</color>"
        end

        if i > 3 then
            UI.text(child, "Rank/n/rank", i)
        end

        if v.id == client.user.id then
            rankInfo.Name.name = "<color=#eab72b>" .. v.name .. "</color>"
            myRank.rank = i
            --if index == 1 then
            --    myRank.value = v.value
            --elseif index == 2 then
            --    myRank.value = v.intimacy
            --else
            --    myRank.value = v.gameLevel
            --end
        end

        UI.draw(child, rankInfo)

        UI.button(child, "Name/name", function()
            ComTools.showPlayerInfo(v.id, false)
        end)
    end
    UI.refreshSVC(self.rankNode)

    if #self.rankInfo.players[index].player > 0 then
        if self.rankInfo.visited[index] then
            UI.setGray(self.BottomNode, "BtnVisit")
            UI.button(self.BottomNode, "BtnVisit", function()
                UI.showHint("已无可膜拜次数")
            end)
        else
            UI.clearGray(self.BottomNode, "BtnVisit")
            UI.button(self.BottomNode, "BtnVisit", function()
                self:showVisitResult(index)
            end)
        end
    else
        UI.setGray(self.BottomNode, "BtnVisit")
        UI.desObj(self.BottomNode, "BtnVisit", CS.UnityEngine.UI.Button)
        --UI.button(self.BottomNode, "BtnVisit", function()
        --    UI.showHint("当前无玩家可以膜拜")
        --end)
    end

    UI.draw(self.BottomNode, myRank)
end

function Class:showVisitResult(index)
    message:send("C2S_ReqRankVisited", { index = index }, function(ret)
        if self.hasClose then
            return
        end
        self.rankInfo.visited[index] = ret.visited[index]
        UI.enable(self.visitNode, true)
        ret.Anim = 1

        HeroTools.setHeadTemp(ret.head, ret.level, ret.curCloth)
        UI.draw(self.visitNode, ret)
        HeroTools.clearHeadTemp()

        CS.Sound.Play(ret.head > 5 and "voice/rankGirl" or "voice/rankBoy")

        ItemTools.showItemResultById(5000, ret.visitGold)

        UI.button(self.visitNode, function()
            self:showSelectRank(index)
        end)
    end)
end

function Class:showValue(v, index)
    if index == 1 then
        return goldFormat(v.value)
    elseif index == 2 then
        return v.intimacy
    else
        return v.gameLevel
    end
end

function Class:showSelectBtn(index)
    for i = 1, 3 do
        UI.enable(self.BtnNode, "Btn_" .. i .. "/Select", false)
    end
    UI.enable(self.BtnNode, "Btn_" .. index .. "/Select", true)
end

return Class