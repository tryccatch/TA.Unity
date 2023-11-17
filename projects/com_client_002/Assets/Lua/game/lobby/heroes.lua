local Class = {
    res = "ui/Heroes",
}
--local ret
function Class:init()
    self.hasClose = false
    CS.Sound.PlayMusic("music/herosoft")
    CS.Sound.Play("effect/heroSystem")

    UI.button(self.node, "BtnBack", function()
        self.hasClose = true
        UI.close(self)
    end)
    self.heroesNode = self.node:Find("HeroList/Viewport/Content")
    UI.enableAll(self.heroesNode, false)

    --log(_s(self))

    self:showTable(1)

    for i = 1, 4 do
        local n = i
        UI.button(self.node, "Btn_" .. i, function()
            self:showTable(n);
        end)
    end

    self.upSuccess = 0
    self.money = client.user.money
    self.heroDetail = {}

    message:send("C2S_heroList", {}, function(ret)
        if self.hasClose then
            return
        end
        self.heroes = ret.heroes
        self.growsItemCount = ret.growsItemCount
        --log(ret)
        UI.cloneChild(self.heroesNode, #self.heroes)
        for i, _ in ipairs(self.heroes) do
            local child = UI.child(self.heroesNode, i - 1)
            UI.button(child, function()
                local index = UI.getChildIndex(child)
                self:showHero(index + 1)
            end)
        end

        self:showTable(1)
    end)
end

function Class:showHero(index, keepPage)

    self.showHeroIndex = index

    local heroBase = self.heroes[index]

    local show = function()
        CS.Sound.PlayOne("voice/heroVoice" .. heroBase.id)

        if not self.heroDetailNode then
            self.heroDetailNode = UI.showNode("UI/HeroesDetails")

            local btnFun = function()
                if self.upSuccess > 0 then
                    message:send("C2S_heroRedDot", {}, function(ret)
                        if self.hasClose then
                            return
                        end
                        self:showTable(-1)
                        log(self.heroes)
                        for i, v in ipairs(self.heroes) do
                            v.red = ret.heroes[i].red
                        end
                        self:showTable()
                        log(self.heroes)
                    end)
                end
            end

            UI.button(self.heroDetailNode, "Top/BtnBack", function()
                UI.enable(self.heroDetailNode, false)
                btnFun()
                self:showTable()
                --log(self.heroes)
            end)
            UI.button(self.heroDetailNode, "Middle/BtnLeft", function()
                if self.showHeroIndex > 1 then
                    self:showHero(self.showHeroIndex - 1, true)
                else
                    self:showHero(#self.heroes, true)
                end
            end)

            UI.button(self.heroDetailNode, "Middle/BtnRight", function()
                if self.showHeroIndex < #self.heroes then
                    self:showHero(self.showHeroIndex + 1, true)
                else
                    self:showHero(1, true)
                end
            end)

            for i = 1, 3 do
                local n = i
                UI.button(self.heroDetailNode, "Bottom/Btns/Btn_" .. i, function()
                    self:showDetailPage(n)
                end)
            end


        else
            UI.enable(self.heroDetailNode, true)
            local node = UI.child(self.heroDetailNode, "Anim")
            if node then
                UI.close(node:GetChild(0))
            end
        end

        HeroTools.showAnim(self.heroDetailNode, "Anim", heroBase.id)

        UI.enable(self.heroDetailNode, "Bottom/Btns/Btn_3", heroBase.id ~= 1)
        if heroBase.id == 1 then
            local node = UI.child(self.heroDetailNode, "Bottom/panel_3")
            if node.gameObject.activeSelf then
                self:showDetailPage(1)
            end
        end

        if not keepPage then
            self:showDetailPage(1)
        end
    end

    -- --log(self.heroDetailNode)
    --if heroBase.id == 1 then
    --    local res = "me"..client.user.level
    --    local node = UI.showNode(self.heroDetailNode,"Anim","Anim/"..res)
    --    UI.playAnim(node,"idle")
    --    UI.setLocalPosition(node,0,-300,0)
    --
    --    UI.changAnimSlot(node,res,"191",""..client.user.head)
    --else
    --    local node = UI.showNode(self.heroDetailNode,"Anim","Anim/hero"..heroBase.id)
    --    UI.playAnim(node,"idle")
    --end
    show()

    if self.heroDetail[heroBase.id] then
        --show()
        self:showDetail(heroBase, self.heroDetail[heroBase.id])
    else
        self:showDetail(heroBase)
        message:send("C2S_heroDetail", { id = heroBase.id }, function(ret)
            if self.hasClose then
                return
            end
            self.heroDetail[heroBase.id] = ret
            --show()
            self:showDetail(heroBase, self.heroDetail[heroBase.id])
        end)
    end

end

function Class:showDetail(heroBase, heroDetail, showUpEx)
    local node = self.heroDetailNode

    if not showUpEx then
        UI.enable(node, "UpEx", false)
    end

    --log(heroBase)

    local showStatus = function(maxLevel)
        local cfg = config.promotion
        for i, v in ipairs(cfg) do
            if maxLevel == v.limit then
                UI.enable(node, "Middle/Status", i - 1 > 0)
                if i - 1 > 0 then
                    --log(i)
                    UI.draw(node, "Middle/Status", { status = i - 1 })
                    break
                end
            end
        end
    end

    UI.text(node, "Middle/ImgName/TextName", heroBase.name)
    UI.text(node, "Bottom/panel_1/Rank/TextRank", "等级：" .. heroBase.level)
    UI.text(node, "Middle/ImgName/TextName", heroBase.name)

    UI.text(node, "Middle/ImgAttribute/TextAttribute", heroBase.allAttribute)

    UI.enableOne(node, "Middle/ImgAttribute/Type", heroBase.specialty)

    UI.text(node, "Bottom/panel_1/Rank/TextGold", goldFormat(client.user.money))
    UI.text(node, "Bottom/panel_1/ImgCapacity/TextAll", heroBase.allGrows)

    local texts = {
        "武力资质 ",
        "智力资质 ",
        "魅力资质 ",
        "政治资质 ",
    }

    if not heroDetail then
        for i = 1, 4 do
            UI.text(node, "Bottom/panel_1/ImgAttribute/Text" .. i, "")
            UI.text(node, "Bottom/panel_1/ImgCapacity/Text" .. i, texts[i])
        end
        UI.text(node, "Bottom/panel_1/ImgCapacity/TextAll", "")
        UI.text(node, "Bottom/panel_1/Rank/TextRankValue", "")
        UI.text(node, "Bottom/panel_1/Rank/TextRankGold", "")
        UI.progress(node, "Bottom/panel_1/Rank/SliderRank", 0)
        UI.enable(node, "Middle/Status", false)

        if heroBase.level >= 350 then
            UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUpEx", false)
            UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp", false)
            UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp10", false)
        else
            UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUpEx", false)
            UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp", false)
            UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp10", true)
        end

        return
    end

    if heroBase.level >= heroDetail.maxLevel or heroDetail.levelExp == 0 then
        UI.progress(node, "Bottom/panel_1/Rank/SliderRank", 1)
        UI.text(node, "Bottom/panel_1/Rank/TextRankValue", "最大")
        UI.text(node, "Bottom/panel_1/Rank/TextRankGold", "")
    else
        UI.progress(node, "Bottom/panel_1/Rank/SliderRank", heroDetail.exp / heroDetail.levelExp)
        UI.text(node, "Bottom/panel_1/Rank/TextRankValue", "" .. goldFormat(heroDetail.exp) .. "/" .. goldFormat(heroDetail.levelExp))
        UI.text(node, "Bottom/panel_1/Rank/TextRankGold", goldFormat(heroDetail.levelMoney))
    end

    showStatus(heroDetail.maxLevel)

    for i = 1, 4 do
        UI.text(node, "Bottom/panel_1/ImgAttribute/Text" .. i, goldFormat(heroDetail.attributes[i]))
    end

    local allValue = 0
    local allGrows = 0
    for i = 1, 4 do
        UI.text(node, "Bottom/panel_1/ImgCapacity/Text" .. i, texts[i] .. heroDetail.grows[i])
        allGrows = allGrows + heroDetail.grows[i]
        allValue = allValue + heroDetail.attributes[i]
    end
    heroBase.allGrows = allGrows
    heroBase.allAttribute = allValue
    UI.text(node, "Bottom/panel_1/ImgCapacity/TextAll", heroBase.allGrows)
    UI.text(node, "Middle/ImgAttribute/TextAttribute", heroBase.allAttribute)

    local showButtons = function()
        if heroBase.level >= heroDetail.maxLevel then
            if heroBase.level >= 350 then
                UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUpEx", false)
                UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp", false)
                UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp10", false)
            else
                UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUpEx", true)
                UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp", false)
                UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp10", true)
            end
        else
            UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp", true)
            UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp10", true)
            UI.enable(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUpEx", false)
        end
    end

    UI.button(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUpEx", function()
        message:send("C2S_getHeroTopLevelInfo", { id = heroBase.id }, function(ret)
            if self.hasClose then
                return
            end
            self:showUpTop(ret, heroBase, heroDetail)
        end)
    end)

    local updateAck = function(data)


        --log(data)
        if #data.datas == 0 then

            if data.startExp == -1 then
                UI.showHint("已经达到最大等级")
                return
            end

            local node = UI.show("UI/tishi")

            UI.draw(node, {
                btnClose = function()
                    UI.close(node)
                end,
                btnSearch1 = function()
                    UI.openPage(UIPageName.Shop)
                end,
                btnSearch2 = function()
                    UI.openPage(UIPageName.Industry)
                end,
                btnSearch3 = function()
                    UI.openPage(UIPageName.WareHouse)
                end,
            })

            return
        end

        local base = 0
        local levelExp = data.datas[1].levelExp

        local endExp = data.endExp
        local i = 2
        while i < #data.datas do
            endExp = endExp - data.datas[i].levelExp
            i = i + 1
        end

        local time = (endExp - data.startExp) / levelExp * 0.5 + 0.1
        --log(time)
        if time > 0.3 then
            time = 0.3
        end

        local lastValue = 0
        local maxValue = endExp - data.startExp

        self.stopLastFun = function()
            self.lastFun(maxValue)
        end
        --log("lE", levelExp)
        self.lastFun = function(value)
            local exp = value + data.startExp - base
            if (levelExp ~= 0) and (exp >= levelExp) then

                for step = 1, #data.datas - 1 do
                    for i = 1, 4 do
                        heroDetail.attributes[i] = heroDetail.attributes[i] + data.datas[step].addAttributes[i]
                        heroBase.allAttribute = heroBase.allAttribute + data.datas[step].addAttributes[i]
                    end
                    heroBase.level = heroBase.level + 1
                end

                local i = 2
                while i < #data.datas do
                    self.money = self.money - data.datas[i].levelExp
                    i = i + 1
                end

                for i = 1, 4 do
                    UI.text(node, "Bottom/panel_1/ImgAttribute/Text" .. i, goldFormat(heroDetail.attributes[i]))
                end

                UI.text(node, "Middle/ImgAttribute/TextAttribute", heroBase.allAttribute)

                step = #data.datas
                levelExp = data.datas[step].levelExp
                base = data.datas[1].levelExp
                UI.text(node, "Bottom/panel_1/Rank/TextRankGold", goldFormat(data.datas[step].levelExp))
                UI.text(node, "Bottom/panel_1/Rank/TextRank", "等级：" .. heroBase.level)

                CS.Sound.Play("effect/uplevel")
                UI.playEffect(self.node, "eft_03")
            end

            self.money = self.money + lastValue - value
            --client.user.money = self.money
            UI.text(node, "Bottom/panel_1/Rank/TextGold", goldFormat(client.user.money))

            lastValue = value

            exp = value + data.startExp - base

            heroDetail.levelMoney = levelExp - exp
            heroDetail.exp = exp
            heroDetail.levelExp = levelExp

            if heroBase.level >= heroDetail.maxLevel or heroDetail.levelExp == 0 then
                UI.text(node, "Bottom/panel_1/Rank/TextRankValue", "最大")
                UI.progress(node, "Bottom/panel_1/Rank/SliderRank", 1)
                UI.text(node, "Bottom/panel_1/Rank/TextRankGold", "")
            else
                UI.text(node, "Bottom/panel_1/Rank/TextRankValue", "" .. goldFormat(exp) .. "/" .. goldFormat(levelExp))
                UI.progress(node, "Bottom/panel_1/Rank/SliderRank", exp / levelExp)
                UI.text(node, "Bottom/panel_1/Rank/TextRankGold", goldFormat(heroDetail.levelMoney))
            end

            showButtons()
        end

        UI.addProccessUpdate(self.node, maxValue, time, self.lastFun, true)
    end

    showButtons()

    UI.button(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp", function()
        if heroBase.level >= heroDetail.maxLevel then
            UI.showHint("已经达到最大等级")
            return
        end
        message:send("C2S_upHeroLevel", { id = heroBase.id, count = 1 }, function(ret)
            if self.hasClose then
                return
            end
            updateAck(ret)
        end)
    end)

    UI.button(self.heroDetailNode, "Bottom/panel_1/Rank/BtnUp10", function()
        if heroBase.level >= heroDetail.maxLevel then
            UI.showHint("已经达到最大等级")
            return
        end
        message:send("C2S_upHeroLevel", { id = heroBase.id, count = 10 }, function(ret)
            if self.hasClose then
                return
            end
            updateAck(ret)
        end)
    end)

    --log(_s(heroDetail))
    -- 显示技能
    local panel2 = UI.child(self.heroDetailNode, "Bottom/panel_2")
    local skillListNode = UI.child(panel2, "S/V/C")

    UI.text(panel2, "Text", "技能经验：" .. heroDetail.skillExp)

    UI.cloneChild(skillListNode, #heroDetail.skills)
    local showRedDot = function()
        local count = 0
        for i, v in ipairs(heroDetail.skills) do
            local child = UI.child(skillListNode, i - 1)
            UI.enable(child, "Exp", v.level < 100)
            UI.enableOne(child, "BtnUpgrade", v.level < 100 and 0 or 1)
            UI.enable(child, "BtnUpgrade/Btn/red", heroDetail.skillExp >= v.levelExp)
            if heroDetail.skillExp >= v.levelExp and v.level < 100 then
                count = count + 1
            end
        end
        UI.enable(self.heroDetailNode, "Bottom/Btns/skill", count > 0)
        return count > 0
    end
    showRedDot()
    for i, v in ipairs(heroDetail.skills) do
        local skill = v
        local child = UI.child(skillListNode, i - 1)
        UI.text(child, "Name", skill.name .. " Lv." .. skill.level)
        UI.text(child, "Hint", skill.hint)
        UI.text(child, "Exp", "需要" .. skill.levelExp .. "经验")
        UI.sprite(child, "Icon", "SkillIcon", "heroSkill_" .. skill.pic)
        UI.button(child, "BtnUpgrade/Btn", function()
            if heroDetail.skillExp < skill.levelExp then
                UI.showHint("经验不够")
                return
            end
            message:send("C2S_upHeroSkillLevel", { id = heroBase.id, skillId = skill.id }, function(ret)
                if self.hasClose then
                    return
                end
                if ret.usedExp <= 0 then
                    --暂时先在客服端判断
                    return
                end
                skill.hint = ret.hint
                skill.levelExp = ret.levelExp
                skill.level = skill.level + 1
                heroDetail.skillExp = heroDetail.skillExp - ret.usedExp
                UI.text(child, "Hint", skill.hint)
                UI.text(child, "Exp", "需要" .. skill.levelExp .. "经验")
                UI.text(child, "Name", skill.name .. " Lv." .. skill.level)

                UI.text(panel2, "Text", "技能经验：" .. heroDetail.skillExp)

                CS.Sound.Play("effect/upskill")
                self.upSuccess = 1
                showRedDot()
            end)
        end)
    end

    -- 显示技能
    local panel3 = UI.child(self.heroDetailNode, "Bottom/panel_3")
    local linksNode = UI.child(panel3, "S/V/C")

    UI.cloneChild(linksNode, #heroDetail.linkHeros)
    for i, v in ipairs(heroDetail.linkHeros) do
        local child = UI.child(linksNode, i - 1)
        UI.text(child, "Name", v.name)
        UI.text(child, "Hint", v.hint)

        local linkHeroNode = UI.child(child, "Links")
        UI.cloneChild(linkHeroNode, #v.ids)
        for i, id in ipairs(v.ids) do
            local heroNode = UI.child(linkHeroNode, i - 1)
            HeroTools.setCHeadSprite(heroNode, id)
            UI.text(heroNode, "Name", v.names[i])
            UI.enable(heroNode, "Locked", not v.has[i])
            if v.has[i] then
                UI.clearGray(heroNode)
            else
                UI.setGray(heroNode)
            end
        end
    end

    local growsCanUp = 0
    for i = 1, 4 do
        local path = "Bottom/panel_1/ImgCapacity/Btn" .. i
        UI.button(self.heroDetailNode, path, function()
            self:showUpGrows(i, heroBase, heroDetail)
        end)

        local red = false
        if heroDetail.grows[i] < 500 and (heroDetail.growsExp >= heroDetail.growsNeedExp[i]
                or self.growsItemCount[i] >= heroDetail.growsNeedCount[i]) then
            red = true;
            growsCanUp = growsCanUp + 1
        end
        --log(i,heroDetail.growsExp,heroDetail.growsNeedExp[i],self.growsItemCount[i],heroDetail.growsNeedCount[i])
        UI.enable(self.heroDetailNode, path .. "/red", red)
    end
    UI.enable(self.heroDetailNode, "Bottom/Btns/red", growsCanUp > 0)
    heroBase.red = growsCanUp > 0 or showRedDot()
end

function Class:showUpGrows(n, heroBase, heroDetail)


    local node = UI.child(self.heroDetailNode, "UpEx")
    UI.enable(node, true)
    UI.enable(node, "page1", false)
    UI.enable(node, "page2", true)

    UI.button(node, "BtnBack", function()
        UI.enable(self.heroDetailNode, "UpEx", false)
    end)

    local values = {}
    local itemIds = { 9, 10, 11, 12 }
    values.itemId = itemIds[n]
    values.itemName = config.itemMap[itemIds[n]].name
    local showUpGroupNode = function()

        local node = UI.child(self.heroDetailNode, "UpEx/page2")

        values.countPerText = values.countPer and ("" .. (values.countPer / 100) .. "%") or ""
        --log(self.growsItemCount)
        --log(heroDetail.growsNeedCount)
        values.countText = "(" .. self.growsItemCount[n] .. "/" .. heroDetail.growsNeedCount[n] .. ")"

        values.expPerText = values.expPer and ("" .. (values.expPer / 100) .. "%") or ""
        values.expText = "(" .. heroDetail.growsExp .. "/" .. heroDetail.growsNeedExp[n] .. ")"

        values.grows = heroDetail.grows[n]
        values.value = goldFormat(heroDetail.attributes[n])
        UI.enable()
        if heroDetail.grows[n] >= 500 then
            values.nextGrows = "已满级"
            values.nextValue = "已满级"
        else
            values.nextGrows = heroDetail.grows[n] + 1
            if values.nextValue and IsNum(values.nextValue) then
                values.nextValue = goldFormat(values.nextValue)
            else
                values.nextValue = ""
            end
        end

        for i = 1, 2 do
            UI.enableOne(node, "BtnUp" .. i, heroDetail.grows[n] >= 500 and 1 or 0)
        end

        --log(values)
        UI.draw(node, values)

        UI.replaceImage(node, "WuImage", "Images/I" .. n)

        for i = 1, 4 do
            UI.replaceImage(node, "WuLi" .. i, "Images/T" .. n)
        end
    end

    local node = UI.child(self.heroDetailNode, "UpEx/page2")
    for i = 1, 2 do
        UI.button(node, "BtnUp" .. i .. "/Btn", function()
            message:send("C2S_updateHeroGrows", { id = heroBase.id, type = n - 1, usedExp = (i == 1) }, function(ret)
                if self.hasClose then
                    return
                end
                self.upSuccess = 1
                if ret.levelUp then
                    heroDetail.growsExp = ret.growsExp
                    heroDetail.growsNeedExp[n] = ret.growsNeedExp
                    heroDetail.growsNeedCount[n] = ret.growsNeedCount
                    heroDetail.attributes[n] = ret.attributes

                    values.expPer = ret.expPer
                    values.countPer = ret.countPer
                    values.nextValue = ret.nextValue

                    heroDetail.grows[n] = heroDetail.grows[n] + 1

                    UI.showHint("升级成功！")

                    CS.Sound.Play("effect/upskill")

                    UI.playEffect(self.node, "eft_03")

                else
                    if ret.success then
                        CS.Sound.Play("effect/upskillfail")
                    end
                end

                if ret.success then
                    values.growsExp = ret.growsExp
                    self.growsItemCount[n] = ret.itemCount
                end

                if ret.error and ret.error ~= "" then
                    UI.showHint(ret.error)
                end

                self:showDetail(heroBase, heroDetail, true)
                showUpGroupNode()
            end)
        end)
    end

    showUpGroupNode()

    message:send("C2S_getUpdateHeroGrowsInfo", { id = heroBase.id, type = n - 1 }, function(ret)
        --log(ret)
        if self.hasClose then
            return
        end
        mergeTable(values, ret)

        showUpGroupNode()
    end)
end

function Class:showUpTop(datas, heroBase, heroDetail)
    local node = UI.child(self.heroDetailNode, "UpEx")

    UI.enable(node, true)

    UI.enable(node, "page1", true)
    UI.enable(node, "page2", false)

    UI.draw(node, "page1", datas)

    local btns = {}
    for i, v in ipairs(datas.items) do
        btns[i] = function()
            UI.showItemInfo(v.id)
        end
    end

    UI.draw(node, "page1/items", btns)

    UI.button(node, "BtnBack", function()
        UI.enable(node, false)
    end)

    UI.button(node, "page1/BtnUp", function()
        message:send("C2S_updateHeroTopLevel", { id = heroBase.id }, function(ret)
            if self.hasClose then
                return
            end
            if ret.success then
                for i = 1, 3 do
                    datas.items[i].count = datas.items[i].count - 1
                end
                UI.button(node, "page1/BtnUp")
                UI.draw(node, "page1", datas)

                local effectNode = UI.child(node, "page1/effect")
                UI.tweenList(effectNode, {
                    {
                        shake = 10,
                        time = 1,
                    },
                    {
                        fun = function()
                            CS.Sound.Play("effect/investiture")
                            UI.playEffect(effectNode, "eft_05")
                        end
                    }
                })
                UI.delay(self.node, 2, function()
                    UI.showHint("提拔成功")
                    heroDetail.maxLevel = datas.nextLevelTop
                    for i, value in ipairs(datas.attributes) do
                        heroDetail.attributes[i] = heroDetail.attributes[i] + value
                        heroBase.allAttribute = heroBase.allAttribute + value
                    end
                    self:showDetail(heroBase, heroDetail)
                    UI.enable(node, false)
                end)
            else
                UI.msgBox("材料不够")
            end
        end)
    end)
end

function Class:showDetailPage(n)
    for i = 1, 3 do
        UI.enable(self.heroDetailNode, "Bottom/Btns/Btn_" .. i .. "/Selected", i == n)
        UI.enable(self.heroDetailNode, "Bottom/panel_" .. i, i == n)
    end
end

function Class:showTable(n)

    if not n then
        n = self.curTable
    end

    if n ~= -1 then
        self.curTable = n

        for i = 1, 4 do
            UI.enable(self.node, "Btn_" .. i .. "/Selected", i == n)
        end
    end

    if self.heroes then
        local fun
        if n == -1 then
            fun = function(a, b)
                return a.id < b.id
            end
        end

        if n == 1 then
            fun = function(a, b)
                if a.level == b.level then
                    if a.quality == b.quality then
                        return a.id < b.id
                    end
                    return a.quality > b.quality
                end
                return a.level > b.level
            end
        end

        if n == 2 then
            fun = function(a, b)
                if a.quality == b.quality then
                    if a.level == b.level then
                        return a.id < b.id
                    end
                    return a.level > b.level
                end
                return a.quality > b.quality
            end
        end

        if n == 3 then
            fun = function(a, b)
                if a.allGrows == b.allGrows then
                    if a.quality == b.quality then
                        if a.level == b.level then
                            return a.id < b.id
                        end
                        return a.level > b.level
                    end
                    return a.quality > b.quality
                end
                return a.allGrows > b.allGrows
            end
        end

        if n == 4 then
            fun = function(a, b)
                if a.allAttribute == b.allAttribute then
                    if a.allGrows == b.allGrows then
                        if a.quality == b.quality then
                            if a.level == b.level then
                                return a.id < b.id
                            end
                            return a.level > b.level
                        end
                        return a.quality > b.quality
                    end
                    return a.allGrows > b.allGrows
                end
                return a.allAttribute > b.allAttribute
            end
        end

        table.sort(self.heroes, fun)

        local mySelf = nil
        local myIndex = function()
            for i, v in ipairs(self.heroes) do
                if v.id == 1 then
                    mySelf = self.heroes[i]
                    return i
                end
            end
        end
        table.remove(self.heroes, myIndex())
        table.insert(self.heroes, 1, mySelf)

        for i, v in ipairs(self.heroes) do
            local child = UI.child(self.heroesNode, i - 1)
            -- --log(child.name)
            UI.text(child, "Name", v.name)
            UI.text(child, "Level", v.level)
            UI.enable(child, "red", v.red)
            UI.sprite(child, "quality", "HeroValueBack", v.quality)
            HeroTools.setHeadSprite(child, "Head", v.id)
        end
    end
end

function Class:onClose()
    UI.close(self.heroDetailNode)
end

function Class:onFront()
    local node = self.heroDetailNode
    if (UI.check(node)) then
        UI.text(node, "Bottom/panel_1/Rank/TextGold", goldFormat(client.user.money))
    end
end

return Class