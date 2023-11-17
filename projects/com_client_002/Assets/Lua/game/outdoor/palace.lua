local Class = {
    res = "UI/Palace"
}

local contentLimit = 30

function Class:init()
    UI.enableAll(self.node, false)
    UI.button(self.node, "house/BtnClose", function()
        UI.close(self)
    end)
    self.listNode = self.node:Find("kingHistory/Rank/S/V/C")
    self.AnimNode = self.node:Find("house/King/curKing/Anim")
    self.animNode = self.node:Find("playerInfo/anim")
    message:send("C2S_ReqPalaceInfo", {}, function(ret)
        self.playerInfo = ret.playerInfo
        self.kingList = ret.kingList

        self.curIndex = 1

        self.gold = ret.gold
        self.level = ret.level
        self.getGold = ret.getGold

        self:showKingInfo(1)
    end)

    for i = 1, 4 do
        UI.button(self.node, "house/BtnKing/King" .. i, function()
            if self.curIndex ~= i then
                self:showKingInfo(i)
            end
        end)
    end
end

function Class:showKingInfo(index)
    UI.enableOne(self.node, 0)
    --UI.enableAll(self.node, "house", true)
    self.curIndex = index
    for i = 1, 4 do
        UI.setGray(self.node, "house/BtnKing/King" .. i)
    end
    UI.clearGray(self.node, "house/BtnKing/King" .. index)

    if self.getGold then
        UI.enableOne(self.node, "house/Bottom/BtnHello", 1)
    else
        UI.enableOne(self.node, "house/Bottom/BtnHello", 0)
        UI.button(self.node, "house/Bottom/BtnHello/Hello", function()
            message:send("C2S_ReqPalaceGetGold", {}, function(ret)
                self.getGold = ret.getGold
                ItemTools.showItemResultById(5000, ret.gold)
                self:showKingInfo(index)
            end)
        end)
    end

    if self.playerInfo[index].id == 0 then
        UI.enableOne(self.node, "house/King", 1)
        UI.enableAll(self.node, "house/chat", false)
        UI.enableAll(self.node, "house/Bottom/King", false)
    else
        UI.enableOne(self.node, "house/King", 0)

        self.playerKingInfo = {
            name = self.playerInfo[index].name,
            level = self.playerInfo[index].vipLevel,
        }
        UI.enableOne(self.node, "house/chat", index - 1)
        --UI.enable(self.node, "house/Bottom/King/", true)
        UI.draw(self.node, "house/Bottom/King", self.playerKingInfo)
        UI.text(self.node, "house/chat/" .. index .. "/Text", self.playerInfo[index].kingWord)
        UI.refreshSVC(self.node, "house/Bottom/King", nil, true)
        if self.delayId then
            UI.stopDelay(self.node, self.delayId)
        end

        self.delayId = UI.delay(self.node, 5, function()
            UI.enable(self.node, "house/chat/" .. index, false)
        end)

        UI.showPlayerAnim(self.AnimNode, "wang", index, self.playerInfo[index].head)

        UI.button(self.node, "house/King/curKing", function()
            self:showPlayerInfo(index)
        end)

    end

    local kingPower = { "武成王势力", "玲珑王亲密", "文慧王议政", "靖贤王联盟" }
    self.bottom = {
        des = kingPower[index] .. "冲榜第一获得,每日请安可获得俸禄",
        level = "我的官职：<color=#FA8872>" .. self.level .. "</color>",
        gold = "俸禄：<color=#FA8872>" .. self.gold .. "</color>",
    }
    UI.draw(self.node, "house/Bottom", self.bottom)

    UI.draw(self.node, "house", { kingName = index })

    UI.button(self.node, "house/BtnHistory", function()
        self:showKingList(index)
    end)

    if self.playerInfo[index].id == client.user.id then
        UI.enable(self.node, "house/BtnPerson", true)
        UI.button(self.node, "house/BtnPerson", function()
            self:setKingWord(index)
        end)
    else
        UI.enable(self.node, "house/BtnPerson", false)
    end


end

function Class:showKingList(index)
    UI.enable(self.node, "kingHistory", true)

    UI.button(self.node, "kingHistory/BtnClose", function()
        UI.enableOne(self.node, 0)
    end)

    UI.enable(self.node, "kingHistory/BtnL", index ~= 1)
    UI.enable(self.node, "kingHistory/BtnR", index ~= 4)

    UI.button(self.node, "kingHistory/BtnL", function()
        self:showKingList(index - 1)
    end)
    UI.button(self.node, "kingHistory/BtnR", function()
        self:showKingList(index + 1)
    end)

    UI.draw(self.node, "kingHistory/King", { name = index })

    UI.cloneChild(self.listNode, #self.playerInfo[index].player)

    if #self.playerInfo[index].player > 0 then
        UI.enable(self.node, "kingHistory/Empty", false)
        for i, v in ipairs(self.playerInfo[index].player) do
            local child = UI.child(self.listNode, i - 1)
            local getDate = convertToTime(v.date / 1000);
            local Date = getDate.year .. "-" .. getDate.month .. "-" .. getDate.day .. " " .. getDate.hour .. ":" .. getDate.minute .. ":" .. getDate.second;
            self.player = {
                rank = v.rank,
                name = v.name,
                date = Date,
            }
            UI.draw(child, self.player)
        end
    else
        UI.enable(self.node, "kingHistory/Empty", true)
    end

end

function Class:showPlayerInfo(index)
    UI.enable(self.node, "playerInfo", true)

    UI.button(self.node, "playerInfo/BtnClose", function()
        UI.enableOne(self.node, 0)
    end)

    self.PlayerInfo = {
        head = self.playerInfo[index].head,
        cloth = self.playerInfo[index].cloth,
        kingName = self.playerInfo[index].kingName,
        name = self.playerInfo[index].name,
        vipLevel = self.playerInfo[index].vipLevel,
        id = "编号：" .. self.playerInfo[index].id,
        allValue = self.playerInfo[index].allValue,
        strength = "武力：<color=#F8E6AF>" .. self.playerInfo[index].attributes[1] .. "</color>",
        wisdom = "智力：<color=#F8E6AF>" .. self.playerInfo[index].attributes[2] .. "</color>",
        charm = "魅力：<color=#F8E6AF>" .. self.playerInfo[index].attributes[3] .. "</color>",
        politics = "政治：<color=#F8E6AF>" .. self.playerInfo[index].attributes[4] .. "</color>",
        level = "官品：<color=#F8E6AF>" .. self.playerInfo[index].level .. "</color>",
        intimacy = "亲密：<color=#F8E6AF>" .. self.playerInfo[index].intimacy .. "</color>",
        score = "政绩：<color=#F8E6AF>" .. self.playerInfo[index].score .. "</color>",
        check = "关卡：<color=#F8E6AF>" .. self.playerInfo[index].check .. "</color>",
        anim = 1,
    }
    HeroTools.setHeadTemp(self.playerInfo[index].head, self.playerInfo[index].level, index)
    UI.draw(self.node, "playerInfo", self.PlayerInfo)
    HeroTools.clearHeadTemp()

    --UI.showPlayerAnim(self.animNode, "wang", index, self.playerInfo[index].head)

end

function Class:setKingWord(index)
    UI.enable(self.node, "personWord", true)
    UI.setValue(self.node, "personWord/InputWord", "")
    UI.button(self.node, "personWord/BtnClose", function()
        UI.enableOne(self.node, 0)
    end)

    local InputField = UI.component(self.node, "personWord/InputWord", typeof(CS.UnityEngine.UI.InputField))
    InputField.text = ""

    InputField.onValueChanged:AddListener(function(value)

        local hasSensitive, result = Tools.sensitiveCheck(value)

        local len = Tools.getStrLen(result)

        if len > contentLimit then
            result = Tools.subString(result, contentLimit)
        end

        InputField.text = result

    end)

    UI.button(self.node, "personWord/BtnSure", function()
        local InputWord = UI.getValue(self.node, "personWord/InputWord")

        local can, str1, str2 = Tools.sensitiveCheck(InputWord)
        local len = Tools.getStrLen(InputWord)

        if len <= contentLimit then
            if can then
                UI.showHint("含有敏感文字，请重新输入")
            else
                message:send("C2S_ReqSetPersonWord", { index = index, word = InputWord }, function(ret)
                    self.playerInfo = ret.playerInfo
                    self:showKingInfo(self.curIndex)
                end)
            end
        else
            UI.showHint("请输入30字符以内的个性宣言")
        end
        UI.setValue(self.node, "personWord/InputWord", "")
    end)

    UI.button(self.node, "personWord/BtnCancel", function()
        UI.enableOne(self.node, 0)
    end)

end

return Class