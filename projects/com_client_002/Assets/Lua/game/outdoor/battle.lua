local Class = {
    res = "UI/zhengzhan"
}

function Class:init()
    UI.enable(self.node, false)
    message:send("C2S_getBattleInfo", {}, function(ret)
        UI.enable(self.node, true)
        UI.enable(self.node, "level", true)
        self.info = ret
        self:showLevel()
    end)

    UI.enableAll(self.node, false)
    UI.enable(self.node, "background", true)

    UI.addUpdate(self, function()
        self:update()
    end)

    UI.button(self.node, "level/BtnBack", function()
        UI.close(self)
    end)

    UI.button(self.node, "level/btnHelp", function()
        showHelp("battle")
    end)

    UI.button(self.node, "level/head", function()
        UI.openPage(UIPageName.PlayerAttribute)
        UI.close(self)
    end)
end

function Class:onFront()
    local levelNode = UI.child(self.node, "level")
    UI.showLevelUpEffect(levelNode)
end

function Class:showLevel()

    CS.Sound.PlayMusic("music/story")

    self.battleALll = false

    local node = UI.child(self.node, "level")

    local info = self.info

    if info.levelNextExp > 0 then
        info.canLevelUp = info.levelExp > info.levelNextExp

        local value = info.levelExp
        if value > info.levelNextExp then
            value = info.levelNextExp
        end
        log(_s({ maxValue = info.levelNextExp, value = value }))
        UI.slider(node, "levelP", { maxValue = info.levelNextExp, value = value })
    else
        info.canLevelUp = false
        UI.slider(node, "levelP", { maxValue = 1, value = 1 })
    end

    info.allValue = client.user.allValue
    info.level = client.user.level
    info.head = 1

    info.strength = info.self.strength
    info.soldier = info.self.soldier

    -- log(_s(info))
    UI.draw(node, info)
    if info.levelNextExp == 0 then
        UI.enable(node, "levelNextExp", false)
        UI.enable(node, "levelExp", false)
        UI.text(node, "Label", "您已满级")
    end

    local head = UI.child(node, "head")
    local headChild = head:GetChild(0)
    if headChild then
        headChild.localPosition = CS.UnityEngine.Vector3(1.9, -10.2, 0)
    end

    local levelNode = UI.child(node, "Level")
    for i = 1, 7 do
        local child = UI.child(levelNode, i - 1)
        UI.enable(child, i <= self.info.gameIndex)

        if i == info.gameIndex then
            UI.playAnim(child)
            UI.button(child, function()
                if i >= 7 then
                    self:showBossBattle()
                else
                    local storyId = CS.UnityEngine.PlayerPrefs.GetInt("storyId", 0)
                    if storyId ~= info.storyId then
                        storyId = info.storyId
                        CS.UnityEngine.PlayerPrefs.SetInt("storyId", storyId)

                        Story.show({
                            storyID = storyId,
                            endFun = function()
                                self:showBattle()
                            end
                        })
                    else
                        self:showBattle()
                    end

                end
            end)
            UI.clearGray(child)
        else
            UI.stopAnim(child)
            UI.button(child, nil)
            UI.setGray(child)
        end

        if i == 7 then
            local data = {
                name = self.info.other.name,
                head = self.info.other.head,
            }
            log(_s(data))
            UI.draw(child, data)
        end
    end

    UI.rawImage(node, "StroyImage", "storyback" .. self.info.background)
end

function Class:showBossHero()
    if self.bossInfo.curSelectIndex then
        local v = self.bossInfo.heroes[self.bossInfo.curSelectIndex]
        HeroTools.showAnim(self.node, "boss/anim", v.id)
        UI.enable(self.node, "boss/NoOne", false)
    else
        UI.enable(self.node, "boss/NoOne", true)
    end
end

function Class:showBossBattle()
    message:send("C2S_getBossInfo", {}, function(ret)
        print("ret code:", ret.code)
        if ret.code == 1 then
            UI.showHint("暂无更多关卡！")
            return
        end

        UI.enable(self.node, "level", false)
        local node = UI.child(self.node, "boss")

        --UI.rawImage(node,"BKImage","storyback2")

        UI.enable(node, true)
        UI.enableAll(node, false)
        UI.button(node, "BtnBack", function()
            UI.enable(self.node, "level", true)
            UI.enable(node, false)
        end)

        UI.button(node, "heroes/BtnBack", function()
            UI.enable(node, "heroes", false)
            self:showBossHero()
        end)

        self.bossInfo = ret
        self.bossInfo.hpText = "" .. self.bossInfo.hp .. "/" .. self.bossInfo.maxHP
        self:sortHeroes()

        UI.slider(node, "hp", { maxValue = self.bossInfo.maxHP })

        UI.button(node, "heroStrength/Change", function()
            self:showHeroList()
        end)

        UI.button(node, "BtnBattle", function()
            if not self.bossInfo.curSelectIndex then
                UI.showHint("无豪杰出战")
            else
                UI.enable(node, "BtnBattle", false)

                local hero = self.bossInfo.heroes[self.bossInfo.curSelectIndex]
                message:send("C2S_fightingBoss", { heroId = hero.id }, function(ret)
                    log("+++++++++++++++++++++++++++++++++")
                    log(ret)
                    self.battleRet = ret
                    self.bossInfo.hp = self.bossInfo.hp - ret.lostHP
                    self.bossInfo.hpText = "" .. self.bossInfo.hp .. "/" .. self.bossInfo.maxHP

                    hero.canBattle = false
                    hero.selected = false

                    CS.Sound.PlayOne("effect/fight")
                    local bossNode = UI.child(node, "head")
                    UI.tweenList(bossNode, {
                        {
                            time = 0.5
                        },
                        {
                            scale = 1.3,
                            time = 0.05
                        },
                        {
                            scale = 0.9,
                            time = 0.05
                        },
                        {
                            scale = 1.2,
                            time = 0.05
                        },
                        {
                            scale = 0.9,
                            time = 0.05
                        },
                    })

                    local heroNode = UI.child(node, "anim")
                    heroNode = UI.child(heroNode, 0)
                    UI.tweenList(heroNode, {
                        {
                            scale = 80,
                            time = 0.1
                        },
                        {
                            scale = 150,
                            time = 0.1
                        },
                        {
                            offset = {
                                x = 0,
                                y = 1000,
                                z = 0,
                            },
                            scale = 100,
                            time = 0.2
                        },
                        {
                            fun = function()
                                UI.draw(node, self.bossInfo)
                                ComTools.disDamage(node, { y = -300 }, ret.lostHP, false)
                            end,
                            scale = 30,
                            time = 0.2
                        },
                        {
                            type = "delete",
                        },
                    })

                    local heroNode = UI.child(node, "anim")
                    heroNode = UI.child(heroNode, 0)

                    UI.delay(self.node, 1.5, function()
                        --UI.draw(node,self.bossInfo)  
                        log(_s(self.battleRet))
                        if self.battleRet.info then
                            local winNode = UI.child(self.node, "win")
                            UI.enable(winNode, true)

                            log(_s(self.battleRet))
                            UI.draw(winNode, self.battleRet)

                            UI.button(winNode, function()
                                UI.enable(winNode, false)

                                self.info = self.battleRet.info
                                UI.enable(self.node, "level", true)
                                UI.enable(self.node, "boss", false)

                                if self.battleRet.wifeId < 0 then
                                    UI.ShowCatchPrisoner(-self.battleRet.wifeId, function()
                                        if self.battleRet.wifeId == -1 then
                                            UI.close(self)
                                            UI.show("game.other.guide", 4)
                                            return
                                        end
                                        self:showLevel()
                                    end)
                                elseif self.battleRet.heroId > 0 or self.battleRet.wifeId > 0 then
                                    Story.show({
                                        heroID = self.battleRet.heroId,
                                        wifeID = self.battleRet.wifeId,
                                        endFun = function()
                                            self:showLevel()
                                            if self.battleRet.wifeId == 2 then
                                                UI.close(self)
                                                UI.show("game.other.guide", 2)
                                                return
                                            end
                                        end
                                    })
                                else
                                    self:showLevel()
                                end
                            end)
                        else
                            UI.enable(node, "BtnBattle", true)

                            self.bossInfo.curSelectIndex = nil
                            self.bossInfo.heroStrength = 0
                            for i, v in ipairs(self.bossInfo.heroes) do
                                if v.canBattle then
                                    v.selected = true
                                    self.bossInfo.curSelectIndex = i
                                    self.bossInfo.heroStrength = goldFormat(v.strength)
                                    break
                                end
                            end

                            self:showBossHero()

                            UI.draw(node, self.bossInfo)
                        end
                    end)
                end)
            end
        end)
        UI.draw(node, self.bossInfo)
        UI.enableAll(node, true)
        UI.enable(node, "heroes", false)
        self:showBossHero()
    end)
end

function Class:sortHeroes()
    table.sort(self.bossInfo.heroes, function(a, b)
        if a.canBattle and not b.canBattle then
            return true
        elseif not a.canBattle and b.canBattle then
            return false
        else
            if a.strength == b.strength then
                return a.id < b.id
            else
                return a.strength > b.strength
            end
        end

    end)

    self.bossInfo.heroStrength = 0
    for i, v in ipairs(self.bossInfo.heroes) do
        if v.canBattle and (not self.bossInfo.curSelectIndex) then
            v.selected = true
            self.bossInfo.curSelectIndex = i
            self.bossInfo.heroStrength = goldFormat(v.strength)
        else
            v.selected = false
        end
    end
end

function Class:showHeroList()
    self:sortHeroes()
    local node = UI.child(self.node, "boss")
    UI.enable(node, "heroes", true)
    local heroSVC = UI.child(node, "heroes/S/V/C")
    UI.cloneChild(heroSVC, #self.bossInfo.heroes)
    for i, v in ipairs(self.bossInfo.heroes) do
        local child = UI.child(heroSVC, i - 1)
        UI.button(child, "canBattle", function()
            if self.bossInfo.curSelectIndex then
                self.bossInfo.heroes[self.bossInfo.curSelectIndex].selected = false
            end
            v.selected = true
            self.bossInfo.curSelectIndex = i
            self.bossInfo.heroStrength = goldFormat(v.strength)
            UI.draw(node, self.bossInfo)
            --self:showHeroList()
        end)

        -- 10000 代表征战类型
        UI.button(child, "canRelive", function()
            ItemTools.used(7, 1, function(ret)
                v.canRelive = false
                v.canBattle = true
                UI.draw(node, self.bossInfo)
                UI.clearGray(child, "id")
            end, v.id + 10000)
        end)

        UI.draw(child, v)
        if not v.canBattle then
            UI.setGray(child, "id")
        else
            UI.clearGray(child, "id")
        end
    end
end

function Class:showBattle()
    UI.enable(self.node, "level", false)

    CS.Sound.PlayMusic("music/storyfight", true, 0.5)

    local info = self.info
    log(_s(info))

    UI.enable(self.node, "fighting/btn", true)

    local node = UI.child(self.node, "fighting")
    local btnNode = UI.child(node, "btn")
    UI.enable(node, true)

    UI.button(btnNode, "BtnBack", function()
        UI.enable(node, false)
        UI.enable(self.node, "level", true)
        self:showLevel()
    end)

    UI.slider(node, "other/soldierP", { maxValue = info.other.soldierMax })
    UI.slider(node, "self/soldierP", { maxValue = info.self.soldierMax })

    info.other.soldierP = info.other.soldier
    info.self.soldierP = info.self.soldier

    local info = self.info
    UI.draw(node, info)

    UI.draw(node, "self", { head = 1 })

    local levelNode = UI.child(node, "Level")
    UI.cloneChild(levelNode, info.gameStepMax)
    for i = 1, info.gameStepMax do
        local child = UI.child(levelNode, i - 1)
        UI.enable(child, 0, i < info.gameStep)
    end

    UI.tweenList(node, "other/speech", {
        {
            alphaAll = 0,
        },
        {
            alphaAll = 1,
            time = 0.5,
        },
        {
            time = 3,
        },
        {
            alphaAll = 0,
            time = 0.5,
        },
    })

    UI.button(btnNode, "BtnStart", function()
        UI.enable(node, "btn", false)
        message:send("C2S_fighting", {}, function(ret)
            self:startBattle(ret)
        end)
    end)

    if client.user.vip >= 6 then
        UI.enable(btnNode, "LvlHint", false)
        UI.button(btnNode, "BtnFighting", function()
            UI.enable(node, "btn", false)
            self.battleALll = true
            message:send("C2S_fighting", {}, function(ret)
                self:startBattle(ret)
            end)
        end)
    else
        UI.setGray(btnNode, "BtnFighting")
    end

    self:initBattle()

end

function Class:initBattle()

    if self.actors then
        for _, actor in pairs(self.actors) do
            UI.close(actor.node)
        end
    end

    local info = self.info

    self.allBattleTime = 1
    self.battleTime = -0.5
    self.inBattle = false
    self.actors = {}

    self.team = {}

    local count = 0
    self:createActor(1, count, info.self.leaderId)
    count = count + 1
    for i, v in ipairs(info.self.soldierCount) do
        for n = 1, v do
            self:createActor(1, count, info.self.soldierId[i])
            count = count + 1
        end
    end

    self.team[1] = {
        hp = info.self.soldier,
        damageHp = 0,
        count = count,
        dieCount = 0,
    }

    local count = 0
    self:createActor(2, count, info.other.leaderId)
    count = count + 1
    for i, v in ipairs(info.other.soldierCount) do
        for n = 1, v do
            self:createActor(2, count, info.other.soldierId[i])
            count = count + 1
        end
    end

    self.team[2] = {
        hp = info.other.soldier,
        damageHp = 0,
        count = count,
        dieCount = 0,
    }

    -- for i,v in ipairs(self.team) do
    --     for n=1,v.count do
    --         self:createActor(i,n,1)
    --     end
    -- end

end

function Class:startBattle(ret)

    -- 没有士兵
    if ret.lostCountSelf == 0 and ret.lostCountOther == 0 then
        UI.enable(self.node, "fighting/btn", true)
        UI.msgBox("没有士兵，无法战斗")
        return
    end

    CS.Sound.Play("effect/fight")

    self.battleRet = ret

    self.team[1].damageHp = ret.lostCountSelf
    self.team[2].damageHp = ret.lostCountOther

    for i, v in ipairs(self.team) do
        local needDieCount = math.ceil(v.count * v.damageHp / v.hp)

        if needDieCount >= v.count then
            if v.damageHp < v.hp then
                needDieCount = v.count - 1
            else
                needDieCount = v.count
            end
        end

        v.needDieCount = needDieCount
    end

    self.inBattle = true
end

function Class:update()
    if self.inBattle then
        self:updateBattle()
        self:sortActorDis()
    end
end

function Class:isBattle()
    for i, v in ipairs(self.team) do
        if v.dieCount ~= v.needDieCount then
            return false
        end
    end

    return true
end

function Class:updateBattle()

    self.battleTime = self.battleTime + CS.UnityEngine.Time.deltaTime

    for _, actor in ipairs(self.actors) do
        actor.frameInDamage = false
    end

    for _, actor in ipairs(self.actors) do
        self:updateActor(actor)
    end

    local soldiers = {}
    for i, v in ipairs(self.team) do
        local t = self.battleTime
        if t > self.allBattleTime then
            t = self.allBattleTime
        end

        local needDieCount = math.ceil(v.needDieCount * t / self.allBattleTime)

        local actors = {}
        for teamIndex, actor in ipairs(self.actors) do
            if actor.team == i and actor.isAlive then
                -- and actor.frameInDamage then
                if actor.isTeamLeader then
                    if needDieCount >= v.count then
                        table.insert(actors, actor)
                    end
                else
                    table.insert(actors, actor)
                end
            end
        end

        table.sort(actors, function(a, b)
            local va = a.damageHp
            if a.isTeamLeader then
                va = 0
            end

            local vb = b.damageHp
            if b.isTeamLeader then
                vb = 0
            end

            return va > vb
        end)

        needDieCount = needDieCount - v.dieCount
        while #actors > 0 and needDieCount > 0 do
            local actor = table.remove(actors, 1)
            needDieCount = needDieCount - 1
            v.dieCount = v.dieCount + 1

            self:actorDie(actor)
        end

        local info = {}
        --local soldier = v.hp * (v.count - v.dieCount) / v.count
        local soldier = math.ceil(v.hp - v.damageHp * self.allBattleTime * t);
        --soldier = math.ceil(soldier)
        soldiers[i] = soldier
        if i == 1 then
            if self.info.self.soldierMax < soldier then
                soldier = self.info.self.soldierMax
            end
            info.self = {
                soldier = soldier,
                soldierP = soldier,
            }
        else
            if v.hp < soldier then
                soldier = v.hp
            end
            info.other = {
                soldier = soldier,
                soldierP = soldier,
            }
        end

        local node = UI.child(self.node, "fighting")
        UI.draw(node, info)
    end

    --self.team[1] = {
    --    hp = info.self.soldier,
    --    damageHp = 0,
    --    count = count,
    --    dieCount = 0,
    --}


    local endGame = false
    --for _, v in ipairs(self.team) do
    --    if v.dieCount >= v.count then
    --        endGame = true
    --    end
    --end

    for i = 1, #soldiers do
        if soldiers[i] == 0 then
            endGame = true
            break ;
        end
    end

    if endGame then

        if self.endBattle then
            return
        end

        self.endBattle = true

        UI.delay(self.node, 0.5, function()
            if self.battleRet.info then
                local winNode = UI.child(self.node, "win")
                UI.enable(winNode, true)

                log(_s(self.battleRet))
                UI.draw(winNode, self.battleRet)

                local doWin = function()
                    UI.enable(winNode, false)

                    if self.info.gameIndex ~= self.battleRet.info.gameIndex then
                        self.info = self.battleRet.info
                        UI.enable(self.node, "level", true)
                        UI.enable(self.node, "fighting", false)
                        self:showLevel()
                    else
                        self.info = self.battleRet.info
                        self:showBattle()

                        if self.battleALll then
                            UI.enable(self.node, "fighting/btn", false)
                            message:send("C2S_fighting", {}, function(ret)
                                self:startBattle(ret)
                            end)
                        else
                            UI.enable(self.node, "fighting/btn", true)
                        end
                    end
                end

                if self.battleALll then
                    UI.button(winNode, nil)
                    UI.delay(winNode, 2, function()
                        doWin()
                    end)
                else
                    UI.button(winNode, function()
                        doWin()
                    end)
                end
            else
                UI.enable(self.node, "lost")
                UI.button(self.node, "lost/BtnIndustry", function()
                    UI.close(self)
                    UI.openPage(UIPageName.Industry)
                end)
                UI.button(self.node, "lost/BtnShop", function()
                    UI.openPage(UIPageName.Shop)
                    UI.close(self)
                end)
            end
        end)
    else
        self.endBattle = false
    end

end

function Class:sortActorDis()
    local node = UI.child(self.node, "fighting/bg")
    local datas = {}
    for i = 1, node.childCount do
        datas[i] = {
            i = i,
            node = UI.child(node, i - 1)
        }
    end

    table.sort(datas, function(a, b)
        if a.node.position.y == b.node.position.y then
            return a.i < b.i
        end
        return a.node.position.y > b.node.position.y
    end)

    local needChange = false
    for i, v in ipairs(datas) do
        if v.i ~= i then
            needChange = true
            break
        end
    end

    if needChange then
        for _, v in ipairs(datas) do
            v.node.parent = nil
        end

        for _, v in ipairs(datas) do
            v.node.parent = node
        end
    end
end

function Class:createActor(team, pos, type)

    local scale = 1.6
    local lineCount = 8

    local cfg = config.sceneSoldierConfigureMap[type]

    local actor = {
        team = team,
        isAlive = true,
        damage = 1,
        damageHp = 0,
        speed = cfg.moveSpeed * (math.random() + 0.5),
        attackDis = cfg.attackRange * scale * 50 / 100,
    }

    local posY = 1 + ((pos - 1) % lineCount)
    local posX = (pos - posY) / lineCount

    local x = 80 + (posX + 1) * 70 * scale
    local y = -50 - (posY - lineCount / 2) * 50 * scale

    if pos == 0 then
        x = 80
        y = -100
    end

    if team == 1 then
        x = -x
    end

    local node = UI.child(self.node, "fighting/bg")

    actor.node = UI.showNode(node, "FrameAnim/npc" .. type)
    if team == 2 then
        UI.setRotation(actor.node, 0, 180, 0)
    end

    UI.setLocalPosition(actor.node, x, y, 0)
    UI.setLocalScale(actor.node, scale, scale, 0)
    UI.playAnim(actor.node, "idle")
    actor.isTeamLeader = (pos == 0)
    table.insert(self.actors, actor)
end

function Class:updateActor(actor)

    if actor.isAlive then
        if actor.isAttacking then
            self:actorUpateAttack(actor)
            return
        end

        local des = self:actorFindDes(actor)
        if des then
            if self:actorDistance(actor, des) <= actor.attackDis then
                self:actorAttack(actor, des)
            else
                self:actorMoveTo(actor, des)
            end
        else
            self:actorStop(actor)
        end
    else
        -- log("die....")
        self:actorUpateDie(actor)
    end
end

function Class:actorUpateDie(actor)
    if actor.node then
        if UI.isEndAnim(actor.node) then
            UI.close(actor.node)
            actor.node = nil
        end
    end
end

function Class:actorUpateAttack(actor)

    if UI.getAnimFrame(actor.node) > 2 then
        if not actor.attacked then
            actor.attacked = true
            actor.damageHp = actor.damageHp + actor.damage;
            actor.frameInDamage = true
        end
    end

    if UI.isEndAnim(actor.node) then
        actor.isAttacking = false
        self:actorStop(actor)
    end
end

function Class:actorFindDes(actor)
    if actor.des and actor.des.isAlive then
        return actor.des
    end

    local ret = nil
    local dis = 10000000
    for _, des in ipairs(self.actors) do
        if des.team ~= actor.team and des.isAlive then
            local tempDis = CS.API.Distance2D(actor.node.localPosition, des.node.localPosition) + math.random(1, 200)
            if tempDis < dis then
                ret = des
                dis = tempDis
            end
        end
    end

    return ret
end

function Class:actorAttack(actor, des)
    UI.playAnim(actor.node, "attack", true)
    actor.isAttacking = true
    actor.attacked = false;
    actor.des = des
end

function Class:actorDistance(actor, des)
    return CS.API.Distance2D(actor.node.localPosition, des.node.localPosition)
end

function Class:actorMoveTo(actor, des)
    CS.API.MoveTo2D(actor.node, des.node, actor.speed)
    UI.playAnim(actor.node, "run")
    actor.des = des
end

function Class:actorStop(actor, des)
    UI.playAnim(actor.node, "idle")
end

function Class:actorDie(actor)
    if actor.isAlive then
        actor.isAlive = false
        UI.playAnim(actor.node, "die")
    end
end

return Class