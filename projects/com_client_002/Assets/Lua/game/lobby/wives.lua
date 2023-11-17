local Class = {
    res = "UI/qunfangyuan"
}

function Class:init()
    self.hasClose = false
    CS.Sound.PlayMusic("music/harem")
    CS.Sound.Play("effect/wifeSystem")

    UI.enableOne(self.node, 0)

    local node = UI.child(self.node, "Main")
    UI.enable(node, "Left", false)
    UI.enable(node, "Right", false)
    UI.enable(node, "Time", false)
    UI.enable(node, "Girl/Icon", false)

    UI.button(node, "Help", function()
        showHelp("wifehall")
    end)

    message:send("C2S_wives", {}, function(ret)
        if self.hasClose then
            return
        end
        self.value = ret.value
        self.maxValue = ret.maxValue
        self.wives = ret.unlockedGirls
        self.lockedWives = ret.lockedGirls
        self.curIndex = 1
        self.items = ret.items
        self:showCurWife()

        if #self.lockedWives > 0 then
            UI.button(self.node, "Main/BtnListNot", function()
                self:ShowListNot()
            end)
            UI.enable(self.node, "Main/BtnListNot", true)
        end

        self.updateTime = 0
        UI.addUpdate(self.node, function()

            if self.value > 0 then
                return
            end

            if self.updateTime < 0 then
                return
            end

            UI.enable(node, "Time", true)

            self.updateTime = self.updateTime - CS.UnityEngine.Time.deltaTime

            local node = UI.child(self.node, "Main")
            local value = math.floor(self.updateTime)
            local s = value % 60
            local m = math.modf((value - s) / 60)

            if self.updateTime < 0 then
                message:send("C2S_updateWifeTime", {}, function(ret)
                    if self.hasClose then
                        return
                    end
                    if ret.value == 0 then
                        self.updateTime = ret.nextGetSecond
                    else
                        UI.enable(node, "Time", false)
                        self.updateTime = 0
                    end
                    self.value = ret.value
                    self:showCurWife()

                end, true)
            else
                if m < 10 then
                    m = "0" .. m
                end
                if s < 10 then
                    s = "0" .. s
                end
                UI.text(node, "Time", "00:" .. m .. ":" .. s)

            end
        end)

    end)

    UI.button(self.node, "Main/BtnBack", function()
        self.hasClose = true
        UI.close(self)
    end)

    UI.enable(self.node, "Main/BtnListNot", false)

    UI.button(self.node, "Main/Girl", function()
        self:showDetail()
    end)

    UI.button(self.node, "Main/BtnRecovery", function()
        ItemTools.used(4, 1, function(ret)
            for i, v in ipairs(ret.result) do
                if v.type == "energy" then
                    self.value = self.maxValue
                    self.updateTime = 0
                    UI.enable(node, "Time", false)
                    self:showCurWife()
                end
            end
        end)
    end)

end

function Class:showDetail()
    if self.curIndex <= #self.wives then
        local wife = self.wives[self.curIndex]

        if wife.childrenCount then
            self:showDetailFun(wife)
        else
            message:send("C2S_wifeDetail", { id = wife.id }, function(ret)
                if self.hasClose then
                    return
                end
                mergeTable(wife, ret)
                self:showDetailFun(wife)
            end)
        end
    end
end

function Class:showDetailFun(wife)
    CS.Sound.PlayOne("voice/wifeVoice" .. wife.id)

    local node = UI.child(self.node, "Room")
    UI.enable(node, true)

    UI.button(node, "Help", function()
        showHelp("wifedetails")
    end)

    UI.button(node, "BtnBack", function()
        UI.enable(node, false)
        CS.Sound.PlayOne("")
    end)

    self.supperMake = (wife.unlockMakeValue <= 0)
    UI.enable(node, "BtnState1", self.supperMake)
    UI.enable(node, "BtnState2", false)

    UI.button(node, "BtnState1", function()
        self.supperMake = not self.supperMake
        UI.showHint("宠幸下奴家就知道了")
        UI.enable(node, "BtnState1", self.supperMake)
        UI.enable(node, "BtnState2", not self.supperMake)
    end)
    UI.button(node, "BtnState2", function()
        self.supperMake = not self.supperMake
        UI.showHint("宠幸下奴家就知道了")
        UI.enable(node, "BtnState1", self.supperMake)
        UI.enable(node, "BtnState2", not self.supperMake)
    end)

    UI.text(node, "Name/Text", wife.name)
    UI.text(node, "Charm", wife.charm)
    UI.text(node, "Intimacy", wife.intimacy)

    UI.text(node, "ChildrenCount", wife.childrenCount)
    UI.text(node, "Hint/Text", wife.hint)

    UI.rawImage(node, "Background/Icon", "wife/wifeFull" .. wife.id)

    UI.text(node, "UnlockValue/Text", "解锁新姿势所需亲密度：" .. wife.unlockMakeValue)
    UI.enable(node, "UnlockValue", wife.unlockMakeValue > 0)

    UI.button(node, "BtnMake", function()
        local node = UI.showNode("Base/chongxing")

        UI.text(node, "Gold/Value", goldFormat(client.user.gold))
        UI.text(node, "UsedValue", wife.needGold)

        UI.button(node, "BtnYes", function()
            if wife.needGold > client.user.gold then
                UI.showHint("元宝不够！")
                return
            end
            UI.close(node)
            message:send("C2S_makeOne", { id = wife.id, supper = true, x = self.supperMake }, function(ret)
                if self.hasClose then
                    return
                end
                self:showMake(wife, ret)
            end)
        end)

        UI.button(node, "BtnNo", function()
            UI.close(node)
        end)
    end)

    UI.button(node, "BtnSkill", function()
        message:send("C2S_wifeSkill", { id = wife.id }, function(ret)
            if self.hasClose then
                return
            end
            mergeTable(wife, ret)
            self:showSkill(wife)
        end)
    end)

    local itemNode = UI.child(self.node, "Items")
    UI.button(node, "BtnGift", function()
        UI.enable(itemNode, true)
        UI.text(itemNode, "Text/Charm/Value", wife.charm)
        UI.text(itemNode, "Text/Intimacy/Value", wife.intimacy)
    end)

    UI.button(itemNode, "BtnBack", function()
        UI.enable(itemNode, false)
    end)

    local itemDatasNode = UI.child(itemNode, "Datas")

    UI.cloneChild(itemDatasNode, #self.items)
    for i, v in ipairs(self.items) do
        local child = UI.child(itemDatasNode, i - 1)

        local disFun = function()
            UI.text(itemNode, "Text/Charm/Value", wife.charm)
            UI.text(itemNode, "Text/Intimacy/Value", wife.intimacy)

            UI.text(node, "Charm", wife.charm)
            UI.text(node, "Intimacy", wife.intimacy)

            UI.text(child, "Count", v.count)
            UI.text(child, "Name", v.name)
            UI.text(child, "Hint", v.hint)

            UI.image(child, "Icon", "Item", "item" .. config.itemMap[v.id].icon)

            if (not self.supperMake) and wife.unlockMakeValue <= 0 and (not UI.child(node, "BtnState2").gameObject.activeSelf) then
                self.supperMake = true
                UI.enable(node, "BtnState1", self.supperMake)
            end
        end

        UI.button(child, "Btn", function()
            if i == 1 or i == 2 then
                if wife.intimacy >= 500 then
                    UI.showHint("亲密度已满")
                    return
                end
            else
                if wife.charm >= 500 then
                    UI.showHint("魅力已满")
                    return
                end
            end
            self:usedItem(wife, v, disFun)
        end)

        disFun()
    end
end

function Class:showSkill(wife)
    local node = UI.child(self.node, "Skill")

    UI.enable(node, true)
    UI.button(node, "BtnBack", function()
        UI.enable(node, false)
    end)

    local selectedIndex = 1
    local selectedFun = function(n)
        selectedIndex = n
        for i = 1, 2 do
            UI.enable(node, "tab_" .. i .. "/Selected", i == selectedIndex)
            UI.enable(node, "page_" .. i, i == selectedIndex)
        end
    end

    for i = 1, 2 do
        UI.button(node, "tab_" .. i, function()
            if selectedIndex ~= i then
                selectedFun(i)
            end
        end)
    end
    selectedFun(1)

    UI.text(node, "page_1/Skill/Value", wife.skillExp)

    local skillListNode = UI.child(node, "page_1/S/V/C")

    UI.cloneChild(skillListNode, #wife.skills)
    for i, data in ipairs(wife.skills) do
        local child = UI.child(skillListNode, i - 1)

        local showFun = function(v)
            UI.text(child, "Text", v.name)
            UI.text(child, "CurHint", v.curHint)
            UI.text(child, "NextHint", v.nextHint)
            log(v)
            UI.text(child, "Level", "Lv." .. v.level)

            if v.upLevelExp > 0 then
                UI.enable(child, "NextHint", true)
                UI.enable(child, "NeedExp", true)
                UI.text(child, "NeedExp", "需要" .. v.upLevelExp .. "经验")
            else
                UI.enable(child, "NextHint", false)
            end

            UI.enable(child, "Max", v.upLevelExp <= 0)
            UI.enable(child, "NeedExp", v.unlockIntimacy <= wife.intimacy and v.upLevelExp > 0)
            UI.text(child, "Mask/Unlock/Value", v.unlockIntimacy)
            UI.enable(child, "Mask", v.unlockIntimacy > wife.intimacy)
            UI.enable(child, "BtnUp", v.unlockIntimacy <= wife.intimacy and v.upLevelExp > 0)

            UI.text(node, "page_1/Skill/Value", wife.skillExp)
        end

        UI.button(child, "BtnUp", function()
            message:send("C2S_updateSkill", { id = wife.id, skillId = data.id }, function(ret)
                if self.hasClose then
                    return
                end
                if ret.error == "" then
                    UI.showHint("升级成功!")
                    wife.skillExp = ret.skillExp
                    showFun(ret.data)
                else
                    UI.showHint(ret.error)
                end
            end)
        end)

        showFun(data)
    end

    local skillListNode = UI.child(node, "page_2/S/V/C")

    UI.cloneChild(skillListNode, #wife.linkHeros)
    for i, v in ipairs(wife.linkHeros) do
        local child = UI.child(skillListNode, i - 1)

        UI.text(child, "Name", v.name)
        UI.text(child, "Link/Name", v.linkName)

        for n = 1, 4 do
            if v.hints[n] then
                UI.text(child, "Text" .. n, v.hints[n])
            else
                UI.text(child, "Text" .. n, "")
            end
        end

        if v.has then
            UI.enable(child, "Mask", false)
            UI.enable(child, "Link", true)
            UI.text(child, "Link/Name", v.linkName)
        else
            UI.enable(child, "Mask", true)
            UI.enable(child, "Link", false)
            UI.text(child, "Mask/Link/Name", v.linkName)
        end
    end


end

function Class:usedItem(wife, item, disFun)

    if item.count <= 0 then
        UI.showHint("没有库存")
        return
    end

    message:send("C2S_usedItem", { id = item.id, count = 1, des = wife.id }, function(ret)
        if self.hasClose then
            return
        end
        if ret.error == "" then
            item.count = item.count - 1

            for _, v in pairs(ret.result) do
                if v.type == "intimate" then
                    wife.intimacy = wife.intimacy + v.value
                    if wife.intimacy >= config.wifeConfigureMap[wife.id].wifeIntimateNum then
                        wife.unlockMakeValue = 0
                    end
                    UI.text(self.node, "Main/Girl/Value/Intimacy", wife.intimacy)
                    UI.showHint("增加亲密度" .. v.value)
                end

                if v.type == "beauty" then
                    wife.charm = wife.charm + v.value
                    UI.text(self.node, "Main/Girl/Value/Charm", wife.charm)
                    UI.showHint("增加魅力" .. v.value)
                end
            end

            disFun()
        else
            UI.showHint(ret.error)
        end
    end)
end

function Class:ShowListNot()
    local node = UI.child(self.node, "NotGotList")
    UI.enable(node, true)

    UI.button(node, "BtnBack", function()
        UI.enable(node, false)
    end)

    local wNode = UI.child(node, "S/V/C")

    UI.cloneChild(wNode, #self.lockedWives)

    for i, v in ipairs(self.lockedWives) do
        local child = UI.child(wNode, i - 1)

        UI.rawImage(child, "Icon", "wife/wife_half_" .. v.id)
        UI.text(child, "Name/Text", v.name)
        UI.text(child, "Unlock/Text", v.lockHint)
        UI.text(child, "Text", v.hint)
    end
end

function Class:showCurWife()
    local girlNode = UI.child(self.node, "Main/Girl")
    if not girlNode.gameObject.activeSelf then
        log("girl is enable")
        UI.enable(girlNode, true)
    else
        log("girl is active")
    end

    local node = UI.child(self.node, "Main")

    if self.curIndex <= #self.wives then
        local wife = self.wives[self.curIndex]

        UI.text(node, "Girl/Name/Text", wife.name)
        UI.text(node, "Girl/Value/Intimacy", wife.intimacy)
        UI.text(node, "Girl/Value/Charm", wife.charm)

        UI.rawImage(node, "Girl/Icon", "wife/wife_half_" .. wife.id)
        UI.enable(node, "Girl/Icon", true)
    end

    --log("cur wife",self.curIndex)

    UI.button(node, "Right", function()
        if self.curIndex < #self.wives then
            self.curIndex = self.curIndex + 1
            self:showCurWife()
        end
    end)

    UI.button(node, "Left", function()
        if self.curIndex > 1 then
            self.curIndex = self.curIndex - 1
            self:showCurWife()
        end
    end)

    UI.enable(node, "Left", self.curIndex > 1)
    UI.enable(node, "Right", self.curIndex < #self.wives)

    UI.enable(node, "BtnRandom", self.value > 0)
    UI.enable(node, "BtnRecovery", self.value <= 0)
    UI.text(node, "Value/Text", "" .. self.value .. "/" .. self.maxValue)

    UI.button(node, "BtnRandom", function()
        if self.value <= 0 then
            return
        end

        UI.showMask()

        self.value = self.value - 1

        if (self.randomList == nil) or (#self.randomList == 0) then
            local list = {}
            for i = 1, #self.wives do
                list[i] = i
            end

            for i = 1, #self.wives do
                local next = math.random(1, #self.wives)

                local temp = list[i]
                list[i] = list[next]
                list[next] = temp
            end

            self.randomList = list
        end

        local lastIndex = self.curIndex
        self.curIndex = table.remove(self.randomList)

        local offsetX = 650
        local animNode1 = UI.child(self.node, "Main/Girl")
        local animNode2
        if lastIndex ~= self.curIndex then
            animNode2 = UI.clone(animNode1)
            if self.curIndex < lastIndex then
                offsetX = -offsetX
            end
        end

        self:showCurWife()

        if animNode2 then
            UI.tweenList(animNode1, {
                {
                    offset = { x = offsetX },
                },
                {
                    offset = { x = -offsetX },
                    time = 1,
                }
            })

            UI.tweenList(animNode2, {
                {
                    offset = { x = -offsetX },
                    time = 1,
                },
                {
                    fun = function()
                        UI.close(animNode2)
                    end
                }
            })

        end

        local child = UI.child(node, "Girl/Icon")
        UI.tweenList(child, {
            { type = "scale", value = 1.1, time = 0.5 },
            { type = "scale", value = 0.9, time = 0.5 },
            { type = "scale", value = 1, time = 0.5 },
        })

        local wife = self.wives[self.curIndex]


        -- 有引导 不生娃
        local notChild = CS.UnityEngine.GameObject.Find("Canvas/Mask/guide") ~= nil

        message:send("C2S_makeOne", { id = wife.id, supper = false, notChild = notChild }, function(ret)
            if self.hasClose then
                return
            end
            UI.delay(self.node, 2, function()
                UI.closeMask()
                self:showMake(wife, ret)
            end)
        end)
    end)

end

function Class:getIndex(id)
    local wife = nil
    for i, v in ipairs(self.wives) do
        if v.id == id then
            return i
        end
    end
    return 1
end

function Class:showMake(wife, data)
    wife.needGold = data.needGold

    local node = UI.child(self.node, "RoomMake")
    local btnSkip = UI.child(node, "Background/Btn3")
    UI.enable(node, true)
    UI.button(node, nil)
    UI.enable(btnSkip, false)
    UI.text(node, "Name/Text", wife.name)
    UI.text(node, "Hint/Text", data.hint)
    UI.text(node, "UnlockValue/Text", "解锁新姿势所需亲密度：" .. data.unlockMakeValue)
    UI.enable(node, "UnlockValue", data.unlockMakeValue > 0)

    UI.setLocalScale(UI.child(node, "Background/Icon", true), 0.9, 0.9, 0)
    UI.setLocalPosition(UI.child(node, "Background/Icon"), 0, -620, nil)

    --UI.rawImage(node, "Background/Icon", "wife/wifeFull" .. wife.id)

    local time = 1.5

    local disAdd = {}

    if data.addSkillExp > 0 then

        if data.addSkillExp > wife.charm * 3 then
            for i = 1, 5 do
                disAdd[#disAdd + 1] = {
                    type = "skillExp",
                    value = data.addSkillExp / 5,
                }
            end
        else
            disAdd[#disAdd + 1] = {
                type = "skillExp",
                value = data.addSkillExp,
            }
        end
    end

    if data.addIntimate > 0 then

        disAdd[#disAdd + 1] = {
            type = "intimate",
            value = data.addIntimate,
        }

        wife.intimacy = wife.intimacy + data.addIntimate
        if wife.intimacy >= config.wifeConfigureMap[wife.id].wifeIntimateNum then
            wife.unlockMakeValue = 0
        end
        self:showDetailFun(wife)
        UI.text(self.node, "Room/Intimacy", wife.intimacy)
        UI.text(self.node, "Main/Girl/Value/Intimacy", wife.intimacy)
    end

    local hasSexData = true

    local child = UI.child(node, "Background/Icon")
    child = UI.child(child, 0, true)
    if child then
        UI.close(child)
    end

    local nextAck = function()
        ItemTools.onItemResultDis(disAdd, self.node)
        if data.childSex > 0 then

            -- 孩子数加一
            if wife.childrenCount then
                wife.childrenCount = wife.childrenCount + 1
                UI.text(self.node, "Room/ChildrenCount", wife.childrenCount)
            end

            --UI.button(node, function()
            --    UI.enable(node, false)
            --end)

            local node = UI.child(self.node, "shengzi")
            UI.enable(node, true)

            UI.enableOne(node, "Type", data.childSex - 1)

            UI.text(node, "Value/Text", UI.colorStr(data.childValueText, ColorQua[data.childValue]))

            UI.button(node, "BtnNo", function()
                UI.enable(node, false)
            end)

            UI.button(node, "BtnYes", function()
                UI.openPage(UIPageName.School)
                self.hasClose = true
                UI.close(self)
            end)

            if data.childSex == 1 then
                CS.Sound.Play("effect/birthBoy")
            else
                CS.Sound.Play("effect/birthGirl")
            end
        end
    end

    if hasSexData and data.x then

        UI.setLocalScale(UI.child(node, "Background/Icon"), 1, 1, 0)
        UI.setLocalPosition(UI.child(node, "Background/Icon"), 0, -620, nil)
        local animNode = UI.showNode(node, "Background/Icon", "Anim/Love")

        UI.playAnim(animNode, "idle")

        UI.setLocalPosition(animNode, 0, 640, 0)

        local ack = function()
            UI.button(node, nil)
            UI.enable(btnSkip, false)
            UI.close(animNode)
            CS.Sound.PlayOne("voice/wifeUndressVoice" .. wife.id)
            if wife.id == 17 then
                UI.setLocalScale(UI.child(node, "Background/Icon"), 1.15, 1.15, 0)
            elseif wife.id == 18 then
                UI.setLocalScale(UI.child(node, "Background/Icon"), 1.07, 1.07, 0)
            end
            if wife.id == 19 then
                UI.setLocalPosition(UI.child(node, "Background/Icon"), -10, -620, nil)
            elseif wife.id == 21 then
                UI.setLocalPosition(UI.child(node, "Background/Icon"), -150, -915, nil)
            else
                UI.setLocalPosition(UI.child(node, "Background/Icon"), 0, -620, nil)
            end
            animNode = UI.showNode(node, "Background/Icon", "Anim/wifeIntimateNum" .. wife.id)
            UI.playAnim(animNode, "idle")
            UI.enable(btnSkip, true)
            UI.button(btnSkip, function()
                UI.enable(node, false)
                CS.Sound.PlayOne("")
            end)
        end

        local delayId = UI.delay(self.node, 5, function()
            ack()
        end)

        time = time + 5

        local nextDelayId = UI.delay(self.node, time, function()
            CS.Sound.PlayOne("")
            nextAck()
        end)
        UI.button(node, function()
            UI.stopDelay(self.node, delayId)
            UI.stopDelay(self.node, nextDelayId)
            ack()
            nextAck()
        end)
    else
        if wife.id == 17 then
            UI.setLocalScale(UI.child(node, "Background/Icon"), 1, 1, 0)
        elseif wife.id == 18 then
            UI.setLocalScale(UI.child(node, "Background/Icon"), 1.1, 1.1, 0)
        end
        local animNode = UI.showNode(node, "Background/Icon", "Anim/wifeUndress" .. wife.id)
        UI.playAnim(animNode, "idle")

        CS.Sound.PlayOne("voice/wifeUndressVoice" .. wife.id)
        UI.delay(self.node, time, function()
            nextAck()
        end)
        UI.enable(btnSkip, true)
        UI.button(btnSkip, function()
            UI.enable(node, false)
            CS.Sound.PlayOne("")
        end)
    end
end

return Class