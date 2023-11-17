local Class = {
    res = "UI/HdPunish"
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()
    self.hasClose = false

    UI.button(self.node, "check/BtnClose", function()
        self:closePage()
    end)

    UI.button(self.node, "check/Help", function()
        showHelp("femalethief")
    end)

    self.itemNode = self.node:Find("check/P3")
    self.checkBtnNode = self.node:Find("check/P3/Bottom/S/V/C")
    self.heroesNode = self.node:Find("battle/hero/S/V/C")
    self.hpNode = self.node:Find("battle/fight/hp")
    self.bossNode = self.node:Find("battle/fight/head")

    message:send("C2S_ReqHdPunishInfo", {}, function(ret)
        if self.hasClose then
            return
        end
        UI.enableOne(self.node, 0)
        self.boss = ret.boss
        self.heroes = ret.heroes
        local myRoadCfg = config.myRoadConfig[1]
        local heroCfg = config.heroMap[myRoadCfg.hero]
        self.superHero = {
            id = heroCfg.id,
            icon = heroCfg.id,
            name = HeroTools.getName(heroCfg.id),
            des = heroCfg.description,
            getHero = ret.heroReward
        }
        for i, v in ipairs(self.boss) do
            if v.remove == false then
                self.checkIndex = i
                self:showCheckP2(self.checkIndex)
                return
            end
        end
        self.checkIndex = 10
        self:showCheckP2(self.checkIndex)
    end)

    UI.button(self.node, "battle/fight/BtnBack", function()
        self:showCheckP2(self.checkIndex)
    end)

    UI.cloneChild(self.checkBtnNode, 10)

    local rect = UI.component2(self.checkBtnNode, typeof(CS.UnityEngine.RectTransform))
    log(rect.sizeDelta.x)

    --local width = rect.rect.width / 10

    log(rect.rect.width)

    UI.enable(self.node, "check/P3/Bottom/L", rect.anchoredPosition.x < -30)

    UI.button(self.node, "check/P3/Bottom/L", function()
        UI.setLocalOffset(self.checkBtnNode, 143, 0, 0)
    end)

    UI.button(self.node, "check/P3/Bottom/R", function()
        UI.setLocalOffset(self.checkBtnNode, -143, 0, 0)
    end)

    local S = UI.child(self.node, "check/P3/Bottom/S")

    CS.UIAPI.ScrollRectFun(S, function(value)

        UI.enable(self.node, "check/P3/Bottom/L", rect.anchoredPosition.x < -30)
        UI.enable(self.node, "check/P3/Bottom/R", rect.anchoredPosition.x > -780)

    end)
end

function Class:showCheckP1()
    HeroTools.setHeadSprite(self.node, "check/P1/HK/Head", self.superHero.icon)
    UI.button(self.node, "check/P1/HK/Head", function()
        self:showSuperHero(self.superHero)
    end)
    local count = 0
    for i, v in ipairs(self.boss) do
        if v.remove then
            count = count + 1
        end
    end
    UI.progress(self.node, "check/P1/Process", count / 10)
    UI.text(self.node, "check/P1/Process/Value", "" .. count .. "/10")

    UI.clearGray(self.node, "check/P1/SuperHero/BtnGet")

    if self.superHero.getHero then
        UI.enableOne(self.node, "check/P1/SuperHero", 1)
        UI.button(self.node, "check/P1/SuperHero/BtnGet", function()
            UI.enableOne(self.node, "check/P1/SuperHero", 1)
        end)
    else
        UI.enableOne(self.node, "check/P1/SuperHero", 0)
        if count == 10 then
            UI.button(self.node, "check/P1/SuperHero/BtnGet", function()
                message:send("C2S_ReqGetHero", {}, function(ret)
                    if self.hasClose then
                        return
                    end
                    if ret.code == "ok" then
                        self.superHero.getHero = true
                        Story.show({ heroID = self.superHero.id, endFun = function()
                            self:showCheckP2(self.checkIndex)
                        end
                        })
                    elseif ret.code == "hasHero" then
                        self.superHero.getHero = true
                        UI.showHint("您已获得该豪杰")
                    else
                        UI.showHint("领取失败")
                    end

                end)
            end)
        else
            UI.setGray(self.node, "check/P1/SuperHero/BtnGet")
        end
    end
end

function Class:showCheckP2(index)
    UI.enable(self.node, "battle", false)
    self:showCheckP1()
    UI.cloneChild(self.checkBtnNode, #self.boss)
    for i, v in ipairs(self.boss) do
        local child = UI.child(self.checkBtnNode, i - 1)
        local cfg = config.myRoadMap[index]
        self.boss[i].maxHP = cfg.life
        self.boss[i].name = cfg.name
        self.boss[i].pic = cfg.pic
        self.boss[i].id = cfg.id
        local data = {
            select = index == i,
            num = i,
            YCC = v.remove,
        }
        UI.draw(child, data)
        if i == index then
            local boss = {
                head = cfg.pic,
                num = index,
                name = cfg.name,
                YCC = v.remove,
            }
            UI.draw(self.node, "check/P2", boss)

            local items = {}
            for j = 1, #cfg.item, 2 do
                local itemCfg = config.item[cfg.item[j]]
                local item = {
                    id = itemCfg.id,
                    icon = itemCfg.icon,
                    count = cfg.item[j + 1],
                    fun = function()
                        UI.showItemInfo(itemCfg.id)
                    end,
                }
                table.insert(items, item)
            end

            UI.cloneChild(self.itemNode, #items, 3, UI.child(self.itemNode, 3))

            for j, item in ipairs(items) do
                local itemNode = UI.child(self.itemNode, 2 + j)
                UI.draw(itemNode, item)

                if self.oldIndex ~= index then
                    if itemNode:Find("effect") == nil then
                        UI.showNode(itemNode, nil, "Effect/itemEffect").name = "effect"
                    end
                end
            end

            if v.reward then
                UI.enableOne(self.itemNode, "Btn", 2)
            else
                if v.remove then
                    UI.enableOne(self.itemNode, "Btn", 1)
                    UI.button(self.itemNode, "Btn/Reward", function()
                        message:send("C2S_ReqGetBossReward", { index = i }, function(ret)
                            if self.hasClose then
                                return
                            end
                            self.boss = ret.boss
                            ItemTools.showItemsResult(items)
                            self:showCheckP2(i)
                        end)
                    end)
                else
                    UI.enableOne(self.itemNode, "Btn", 0)
                    UI.button(self.itemNode, "Btn/Challenge", function()
                        if i == 1 then
                            self:ReqPunishBoss(self.boss[i])
                        else
                            if self.boss[i - 1].remove then
                                self:ReqPunishBoss(self.boss[i])
                            else
                                UI.showHint("需要通关上一个关卡！")
                            end
                        end
                    end)
                end
            end
        end

        UI.enable(child, "RedTips", v.remove and not v.reward)

        UI.button(child, function()
            self.checkIndex = i
            self:showCheckP2(self.checkIndex)
        end)
    end
    self.oldIndex = index
end

function Class:AutoSelectHero()
    table.sort(self.heroes, function(a, b)
        if a.strength == b.strength then
            return a.id < b.id
        end
        return a.strength > b.strength
    end)

    for i, v in ipairs(self.heroes) do
        if v.fighting == false then
            self.curHero = v
            return
        else
            self.curHero = nil
        end
    end
end

function Class:ReqPunishBoss(boss)
    self.curBoss = boss
    log(boss)
    message:send("C2S_ReqPunishBoss", {}, function(ret)
        if self.hasClose then
            return
        end
        self.BossHP = self.curBoss.maxHP
        self.heroes = ret.heroes
        self:AutoSelectHero()
        self:showBattle()
    end)
end

function Class:showBattle()
    UI.enable(self.node, "battle", true)
    UI.enableOne(self.node, "battle", 0)

    self.battleInfo = {
        name = self.curBoss.name,
        head = self.curBoss.pic,
        hpText = "血量：" .. self.BossHP,
        Anim = self.curHero.id,
        strength = goldFormat(self.curHero.strength),
        --hp = self.BossHP,
    }

    UI.draw(self.node, "battle/fight", self.battleInfo)
    UI.progress(self.node, "battle/fight/hp", self.BossHP / self.curBoss.maxHP)
    if self.curHero == nil then
        self:showCheckP2(self.boss.id)
    end

    UI.button(self.node, "battle/fight/BtnBattle", function()
        UI.showMask()
        CS.Sound.Play("effect/fight")
        UI.enable(self.node, "battle/fight/BtnBack", false)
        UI.enable(self.node, "battle/fight/BtnBattle", false)
        message:send("C2S_ReqBattle", { bossId = self.curBoss.id, heroId = self.curHero.id }, function(ret)
            if self.hasClose then
                return
            end
            self.heroes = ret.heroes
            self.BossHP = ret.bossHP
            self.battleInfo.hpText = "血量：" .. ret.bossHP
            local bossNode = UI.child(self.node, "battle/fight/head")

            local heroNode = UI.child(self.node, "battle/fight/Anim")
            heroNode = UI.child(heroNode, 0)
            UI.tweenList(heroNode, {
                {
                    scale = 80,
                    time = 0.1
                },
                --{
                --    scale = 150,
                --    time = 0.1
                --},
                {
                    offset = {
                        x = 0,
                        y = 1200,
                        z = 0,
                    },
                    scale = 60,
                    time = 0.2
                },
                {
                    fun = function()
                        UI.tweenList(bossNode, {
                            {
                                offset = {
                                    x = 30,
                                    y = 60,
                                    z = 0,
                                },
                                time = 0.05
                            },
                            {
                                fun = function()
                                    UI.progress(self.node, "battle/fight/hp", self.BossHP / self.curBoss.maxHP)
                                    UI.draw(self.node, "battle/fight", self.battleInfo)
                                    --UI.enable(self.node, "battle/fight/Anim", false)
                                    ComTools.disDamage(UI.child(self.node, "battle/fight/SSS"), { y = -360 }, ret.lostHP, false)
                                    UI.playEffect(bossNode, "", "strike", 0.3)
                                end,
                                time = 0.1,
                            },
                            {
                                offset = {
                                    x = -30,
                                    y = -60,
                                    z = 0,
                                },
                                time = 0.05
                            },
                        })
                    end
                },
                {
                    offset = {
                        x = 0,
                        y = -1200,
                        z = 0,
                    },
                    scale = 100,
                    time = 0.1
                },
                --{
                --    type = "delete",
                --},
            })
            --local heroNode = UI.child(self.node, "battle/fight/Anim")
            --heroNode = UI.child(heroNode, 0)

            UI.delay(self.node, 2, function()
                UI.enable(self.node, "battle/fight/BtnBattle", true)
                UI.enable(self.node, "battle/fight/Anim", true)
                UI.enable(self.node, "battle/fight/BtnBack", true)
                UI.closeMask()
                if ret.bossHP <= 0 then
                    CS.Sound.Play("effect/celebrate")
                    UI.enableOne(self.node, "battle", 2)
                    UI.button(self.node, "battle/win", function()
                        message:send("C2S_ReqHdPunishInfo", {}, function(ret)
                            if self.hasClose then
                                return
                            end
                            self.boss = ret.boss
                            self:showCheckP2((self.curBoss.id < 10) and (self.curBoss.id + 1) or (self.curBoss.id))
                        end)
                    end)
                else
                    self:AutoSelectHero()
                    if self.curHero then
                        self:showBattle()
                    else
                        CS.Sound.Play("effect/fail")
                        UI.enableOne(self.node, "battle", 3)
                        UI.button(self.node, "battle/lost", function()
                            self:showCheckP2(self.curBoss.id)
                        end)
                    end
                end
            end)
        end, true)
    end)

    UI.button(self.node, "battle/fight/heroStrength/BtnChange", function()
        self:showHeroInfo()
    end)
end

function Class:sortHero(heroes)
    local newItems = {}
    local count = 0

    table.sort(heroes, function(a, b)

        if a.strength == b.strength then
            return a.id < b.id
        end
        return a.strength > b.strength

    end)

    for i, v in ipairs(heroes) do
        if v.id == self.curHero.id then
            table.insert(newItems, 1, v)
        else
            if v.fighting then
                table.insert(newItems, #newItems + 1, v)
                count = count + 1
            else
                table.insert(newItems, i - count, v)
            end
        end
    end

    return newItems
end

function Class:showHeroInfo()
    UI.enableOne(self.node, "battle", 1)
    table.sort(self.heroes, function(a, b)

        if a.strength == b.strength then
            return a.id < b.id
        end
        return a.strength > b.strength

    end)

    UI.cloneChild(self.heroesNode, #self.heroes)
    for i, v in ipairs(self:sortHero(self.heroes)) do
        local child = UI.child(self.heroesNode, i - 1)
        v.name = HeroTools.getName(v.id)
        UI.draw(child, "hero", v)
        HeroTools.setCHeadSprite(child, "hero/head", v.id)

        UI.enableAll(child, "Btn", false)
        if v.id == self.curHero.id then
            UI.enableOne(child, "Btn", 2)
        else
            if v.fighting then
                UI.enableOne(child, "Btn", 1)
                UI.setGray(child, "Btn/BtnY")
            else
                UI.enableOne(child, "Btn", 0)
                UI.button(child, "Btn/BtnC", function()
                    self.curHero = v
                    self:showBattle()
                end)
            end
        end
    end

    UI.button(self.node, "battle/hero/BtnClose", function()
        self:showBattle()
    end)
    UI.refreshSVC(self.heroesNode)
end

function Class:showSuperHero(hero)
    local heroNode = UI.show("Base/ItemInfo")
    HeroTools.setHeadSprite(heroNode, "icon", hero.icon)
    UI.text(heroNode, "name", hero.name)
    UI.text(heroNode, "des", hero.des)
    UI.button(heroNode, "BtnClose", function()
        UI.close(heroNode)
    end)
end

return Class