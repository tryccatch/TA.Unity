local Class = {
    res = "UI/tower"
}


function Class:init()

    UI.enableAll(self.node,false)

    self.backFuns = {}



    local main  = {
        bk = {
            monster = false,
            name = false,
        },

        title = {
            btnBack =  function()
                self:onBack()
            end,
            btnHelp = function()
                showHelp("tower")
            end,
        },

        infoOppo = {
            btn = function() self:fight() end ,
            gift = "",
            count = "",
            canCount = "",
        },

        info = {
            name = client.user.name,
            level = "",
            btnTop = function()
                self:showAllTop()
            end,
        }
    }

    UI.button(self.node, "battle/btnHelp",function()
        showHelp("tower")
    end)

    self.main = main

    UI.enable(self.node,"main", true)
    self:drawMain()
    message:send("C2S_BattleLevelInfo", {}, function(ret)
        self:showHallInfo(ret)
    end)
end

function Class:addCount()
    ItemTools.used(52,1,function()
        message:send("C2S_BattleLevelInfo", {}, function(ret)
            self:showHallInfo(ret)
        end)
    end)
end

function Class:updateNotices()
    self.noticeTime = self.noticeTime - CS.UnityEngine.Time.deltaTime
    if self.noticeTime <= 0 then

        message:send("C2S_BattleLevelUpdateNotice", {id=self.noticeGetTime}, function(ret)
            local last = nil
            for i,v in ipairs(ret.notice) do
                if v.time > self.noticeGetTime then

                    local text = "麾下"

                    if v.heroId <= 1 then
                        text = text .. "<color=#FFE486>主角</color>"
                    else
                        text = text .. "<color=#FFE486>" .. HeroTools.getName(v.heroId) .. "</color>"
                    end

                    text = text .. "击败了" .. v.oppoName

                    if v.isAll then
                        text = text .. "全部"
                    end

                    text = text .. "<color=#FFE486>" .. v.count .. "个</color>豪杰"

                    self.noticeGetTime = v.time
                    last = v
                    v.text = text
                    v.btn = function()
                        self:fight(v.userId)
                    end,
                    table.insert(self.notices,1,v)
                end
            end
            if last then
                local text = "麾下"

                if last.heroId <= 1 then
                    text = text .. "主角"
                else
                    text = text .. HeroTools.getName(last.heroId)
                end

                text = text .. "击败了" .. last.oppoName

                if last.isAll then
                    text = text .. "全部"
                end

                text = text .. last.count .. "个豪杰"

                UI.draw(self.node,"main/btnNotice", {
                    name = last.name,
                    hint = text,
                })
            end

            if self.noticeEnable then
                self:showNotices()
            end
        end,true)

        self.noticeTime = 3
    end
end

function Class:showNotices()
    local node = UI.child(self.node,"noticeTop")
    UI.enable(node,true);
    UI.draw(node,"S/V/C", self.notices)

    if not self.noticeEnable then
        UI.tweenList(node,{
            {
                offset = {y = -1280}
            },
            {
                offset = {y = 0},
                time = 0.5,
            }
        })
    end
    self.noticeEnable = true

    UI.button(node,"btnBack", function()
        self.noticeEnable = false
        UI.enable(node,false)
    end)
end

function Class:showHis()
    local node = UI.child(self.node,"his")
    UI.enable(node,true);

    local curTab = 1
    local showTab = function(n)
        curTab = n
        for i = 1, 3 do
            UI.enable(node,"tab" .. i .. "/select" ,i == n)
            UI.enable(node,"page_"..i,i==n)
        end
    end

    message:send("C2S_BattleLevelLog", {}, function(ret)

        for i,v in ipairs(ret.logs) do
            v.valueText = "(权威值：" .. v.value .. ")"
            local name = v.name
            if v.heroId > 1 then
                name = HeroTools.getName(v.heroId)
            end
            v.info = "率领门下<color=#F8E6AF>" .. name .. "</color>前来论战，战胜了我方<color=#FF2900>" .. v.count .. "</color>名大将"
        end

        for i,v in ipairs(ret.enemys) do

            v.icon = {
                head = v.head,
                level = v.level,
            }

            v.btn = function()
                self:fight(v.id)
            end
        end

        local data = {
            base = {
              btnBack = function()
                  UI.enable(node,false)
              end
            },
            tab1 = function()
                showTab(1)
            end,
            tab2 = function()
                showTab(2)
            end,
            tab3 = function()
                showTab(3)
            end,

            page_1 = ret.logs,
            page_2 = ret.enemys,
            page_3 = {
                btnFind = function()
                    local id = UI.getValue(node,"page_3/Input")

                    message:send("C2S_BattleLevelFind",{id=id},function(ret)
                        if ret.success then
                            ret.body = ret.level
                            ret.btnGo = function()
                                self:fight(id,true)
                            end
                            UI.draw(node,"page_3/opponent",ret)
                            UI.enable(node,"page_3/opponent",true)
                        else
                            UI.showHint("没有找到对手")
                        end
                    end)
                end,
                opponent = false,
            }
        }

        UI.draw(node,data)
        showTab(curTab)
    end)

    showTab(1)
end

function Class:fight()

    if self.info.hasGame then

        message:send("C2S_BattleLevelGoInfo",{},function(ret)
            self.info.hasGame = true
            self.info.self = ret.self

            if self.heroes then
                for i,v in ipairs(self.heroes) do
                    if v.id == self.info.heroId then
                        self.selectHero = v
                        break
                    end
                end
            end

            self:drawBattleInfo(ret)
        end)
        return
    end

    if not self.heroes then
        message:send("C2S_BattleLevelHeroes", {}, function(ret)

            table.sort(ret.heroes,function(a,b)
                if a.attribue == b.attribue then
                    return a.id > b.id
                end

                return a.attribue > b.attribue
            end)

            self.heroes = ret.heroes
            self:fight()
        end)
        return
    end

    local usedCount = 0
    for i,v in ipairs(self.heroes) do
        if v.state == 1 then
            usedCount = usedCount + 1
        end
    end

    local maxCount = client.user.level
    if maxCount > #self.heroes then
        maxCount = #self.heroes
    end
    local count = maxCount - usedCount


    local node = UI.child(self.node,"selectHero")

    local heros = {}

    for i,v in ipairs(self.heroes) do
        heros[i] = {
            id = v.id,
            name = v.name,
            grows = v.grows,
            attribue = v.attribue,
            lvl = "LV." .. v.level,
            done = v.state == 1,
        }

        if v.state == 1 then
            heros[i].btn = false
        else
            heros[i].btn = function()
                if usedCount >= maxCount then
                    UI.msgBox("该关卡今日已无剩余豪杰出战次数")
                else
                    self.selectHero = v
                    self:doFight(v.id)
                end
            end
        end
    end


    table.sort(heros,function(a,b)
        if a.done and (not b.done) then
            return false
        elseif b.done and (not a.done) then
            return true
        else
            return a.attribue > b.attribue
        end
    end)

    local data = {
        bg = {
            btnBack = function()
                UI.enable(node,false)
            end,
        },
        heros = heros,
        itemHint = "当前关卡出战豪杰数量：" .. count .. "/" .. maxCount,
    }
    UI.enable(node,true)
    UI.draw(node,data)
end

function Class:doFight(heroId)
    message:send("C2S_BattleLevelFight",{heroId=heroId},function(ret)
        if ret.success then
            UI.enableAll(self.node,false)
            UI.enable(self.node,"main", true)

            self.notShop = false
            self.opponent = ret.opponent

            self:drawBattleInfo(ret.info)
        else
            UI.showHint(ret.error)
        end
    end)
end

function Class:showDayTop()
    local node = UI.child(self.node,"dayTopList")
    UI.enable(node,true);

    message:send("C2S_BattleLevelDayTop", {}, function(ret)

        local gitfIndex = 1
        local index= "未上榜"
        for i,v in ipairs(ret.datas) do
            if v.id == client.user.id then
                index = i
            end

            local cfg = config.waterBattleRank[gitfIndex]
            if cfg.endRank < i then
                gitfIndex = gitfIndex + 1
                cfg = config.waterBattleRank[gitfIndex]
            end

            v.index = i
            v.giftId = cfg.item[1]
            v.giftCount = "X" .. cfg.item[2]

            v.clickItem = function()
                UI.showItemInfo(v.giftId)
            end
        end

        local data = {
            noOne = #ret.datas == 0,
            bg = {
                btnBack = function()
                    UI.enable(node,false)
                end,
            },
            info = {
                name = ret.self.name,
                score = ret.self.score,
                index = index,
            },
            datas = ret.datas,
        }

        UI.draw(node,data)
    end)
end


function Class:showAllTop()
    local node = UI.child(self.node,"topList")
    UI.enable(node,true);

    message:send("C2S_BattleLevelAllTop", {}, function(ret)


        local index= "未上榜"
        for i,v in ipairs(ret.datas) do
            if v.id == client.user.id then
                index = i
            end
            v.index = i

            v.scoreDis = {
                score = self:getScoreText(v.score),
                scoreEx = self:getScoreRoundText(v.score),
            }
        end

        local myScore = ""
        local round = ""
        if ret.self.score > 0 then
            round = self:getScoreRoundText(ret.self.score)
            myScore = self:getScoreText(ret.self.score)
            if round then
                round = "(" .. round .. ")"
            else
                round = ""
            end
        end

        local data = {
            noOne = #ret.datas == 0,
            bg = {
                btnBack = function()
                    UI.enable(node,false)
                end,
            },
            info = {
                name = ret.self.name,
                score = myScore,
                index = index,
                round = round,
            },
            datas = ret.datas,
        }

        UI.draw(node,data)
    end)
end

function Class:getScoreText(score)
    local level = score % #config.tower
    if level == 0 then
       level = #config.tower
    end

    local cfg = config.tower[level]
    big = cfg.big

    local n = 0

    while(cfg ~= nil) do
        if cfg.big == big then
            n = n + 1
        else
            break
        end
        cfg = config.tower[cfg.id-1]
    end

    return "第" .. big .. "关" .. "第" .. n .. "门"
end

function Class:getScoreRoundText(score)
    if score <= #config.tower then
        return false
    end

    return ""..math.floor(score/#config.tower).."转"
end

function Class:showTop6Heroes()
    local node = UI.child(self.node,"heros")
    UI.enable(node,true);

    message:send("C2S_BattleLevelTop6", {}, function(ret)
        local heros = {}

        for i,v in ipairs(ret.heroes) do
            heros[i] = {
                id = v.id,
                name = v.name,
                grows = v.grows,
                attribue = v.attribue,
                lvl = "LV." .. v.level,
                yes = v.state == 1,
                no = v.state == 0,
            }
        end

        local data = {
            bg = {
                btnBack = function()
                    UI.enable(node,false)
                end,
            },
            heros = heros,
        }

        UI.draw(node,data)
    end)
end

function Class:showHallInfo(ret)

    UI.enableAll(self.node,false)
    UI.enable(self.node,"main", true)

    self.info = ret

    local main = self.main
    self.opponent = ret.opponent

    main.level = "第" .. ret.bigLevel .. "关"
    main.meng = "第" .. ret.smallLevel  .. "门"

    main.infoOppo = {
        count = ret.oppoCount .. "名",
        canCount = "<color=#F8E6AF>可出战豪杰：</color>" .. ret.canCount .. "/" .. ret.maxCount
    }

    if ret.maxBigLevel <= 0 then
        main.info = {
            level =  "没有战绩"
        }
    else
        local zhuan = self:getScoreRoundText(ret.maxBigLevel)
        local txt = self:getScoreText(ret.maxBigLevel)

        if zhuan then
            txt = txt .. " " .. zhuan
        end

        main.info = {
            level =  txt
        }
    end

    main.monster = ret.opponent.head
    main.name = {
        Text = ret.opponent.name
    }

    local gift = ""

    local cfg = self:findCfg(self.info.bigLevel,self.info.smallLevel)
    log(cfg)
    log(self.info.bigLevel,self.info.smallLevel)
    for i=1,#cfg.item,2 do
        if gift ~= "" then
            gift = gift .. ","
        end
        gift = gift .. config.itemMap[cfg.item[i]].name
    end
    main.infoOppo.gift = gift

    local gameLevel = {}

    for i=1,ret.levelCount do
        gameLevel[i] = {
            done = i < ret.smallLevel,
            endNode = i == ret.levelCount,
        }
    end

    main.gameLevel = gameLevel

    log(main)
    self:drawMain()
end

function Class:addBackFun(fun)
    table.insert(self.backFuns,fun)
end

function Class:onBack()

    if #self.backFuns > 0 then
        local n = #self.backFuns
        self.backFuns[n]()
        table.remove(self.backFuns,n)
    else
        UI.close(self)
    end
end

function Class:showOpponent()
    log("showOpponent")
    local node = UI.child(self.node,"dialog")
    UI.enable(node,true)

    local data = {
        btnYes = function()
            message:send("C2S_BattleLevelGoInfo",{},function(ret)
                UI.enable(node,false)
                self.info.hasGame = true
                self.info.self = ret.self

                self:drawBattleInfo(ret)
            end)
        end,
        btnNo = function()
            UI.enable(node,false)
        end,
    }

    HeroTools.setHeadTemp(self.opponent.head,self.opponent.level,self.opponent.cloth)
    UI.draw(node,data)
    HeroTools.clearHeadTemp()


    local tempLevel = self.opponent.level
    local tempHead = self.opponent.head

    client.user.level = self.opponent.level
    client.user.head = self.opponent.head

    data = {
        btnYes = {
            Text = "战斗",
        },
        text = "你确定要挑战玩家<color=#F8E6AF>" .. self.opponent.name ..  "</color>",
        id = 1,
    }

    UI.draw(node,data)

    self.opponent.level = tempLevel
    self.opponent.head = tempHead
end

function Class:drawMain()
    UI.draw(self.node,"main",self.main)
end

function Class:showTips()
    local tipNode = UI.showNode("Base/MsgShop")
    UI.button(tipNode, "BtnYes", function()
        UI.close(tipNode)
        ComTools.openRecharge()
    end)
    UI.button(tipNode, "BtnClose", function()
        UI.close(tipNode)
    end)
end

function Class:drawBattleInfo(info)

    if not info then
        info = self.battleInfo
    end

    self.battleInfo = info

    local node = UI.child(self.node,"battle")
    UI.enable(node,true)

    UI.slider(node, "info/hp",{
        maxValue = info.maxHp,
        hp = info.hp,
    })

    local continue = false
    if info.opAllCount > info.opLiveCount then
        continue = {
            index = info.opAllCount - info.opLiveCount
        }
    end


    while #info.heros < 3 do
        table.insert(info.heros,false)
    end

    for i,v in ipairs(info.heros) do

        if type(v) == "table" then
            v.btn = function()

                 if not self.notShop then
                    if info.selectedItem == 0 then
                        UI.msgBox("你确认要放弃购买属性?",function()
                             message:send("C2S_BattleLevelGo",{selected=i},function(ret)
                                self:showBattle(ret,v)
                             end)
                        end,function() end)
                        return
                    end
                 end

                message:send("C2S_BattleLevelGo",{selected=i},function(ret)
                    self:showBattle(ret,v)
                end)
            end
        end
    end

    local data = {
        anim = info.self.id,
    }
    UI.draw(node,data)

    local data = {
        bk  = {
          name = self.opponent.name,
          count = "大臣数量：" .. info.opLiveCount .. "/" .. info.opAllCount
        },
        continue = continue,
        heros = info.heros,
        info = {
            name = client.user.name,
            heroName = info.self.name,
            heroLevel = "等级：" .. info.self.level,
            heroGrows = "资质：" .. info.self.grows,
            addSkill = (info.addSkill/100) .. "%",
            addAttack = (info.addAttack/100) .. "%",
            hp = info.hp,
            hpText = info.hp .. "/" .. info.maxHp,
        },
        btnBack =  function()
            if self.buyingBuffBack then
                self.buyingBuffBack()
            else
                UI.enable(node,false)
                self:showBackHero()
            end
        end,
    }



    UI.enable(node,"heros",true)
    UI.enable(node,"buff",false)


    data.heros.btn = function()
        UI.enable(node,"heros",false)
        UI.enable(node,"buff",true)

        local backFun = function()
            UI.enable(node,"heros",true)
            UI.enable(node,"buff",false)
            self.buyingBuffBack = nil
        end
        self.buyingBuffBack = backFun


        local items = {}

        local buff = {
            btnGiveUp = backFun,
            btnBack = backFun,
            items = items,
            gold = client.user.gold,
            value = info.itemValue,
            check = {
                selected = self.notShop == true
            },
        }



        for i,v in ipairs(info.items) do
            local cfg = config.waterBattleBuffMap[v]

            items[i] = {}

            if cfg.type == 1 then
                items[i].icon = "xl"
                items[i].hint = "回血" .. (cfg.add / 100) .. "%"
            end

            if cfg.type == 2 then
                items[i].icon = "gj"
                items[i].hint = "攻击加成" .. (cfg.add / 100) .. "%"
            end

            if cfg.type == 3 then
                items[i].icon = "jn"
                items[i].hint = "暴击加成" .. (cfg.add / 100) .. "%"
            end

            if  cfg.type == 0 then
                items[i].icon = items[i].icon .. "3"
            else
                items[i].icon = items[i].icon .. cfg.type
            end

            if info.selectedItem == 0 then
                items[i].buy = function()

                    if cfg.coin == 0 then
                        if buff.gold < cfg.gold then
                            --UI.msgBox("元宝不够")
                            self:showTips()
                            return
                        end
                    else
                        if buff.value < cfg.coin then
                            UI.msgBox("代币不够")
                            return
                        end
                    end

                    message:send("C2S_BattleLevelBuyItem", {selected=i}, function()

                        for n=1,3 do
                            items[n].buy = false
                        end
                        items[i].get = true

                        info.selectedItem = i

                        if cfg.coin == 0 then
                            buff.gold =  buff.gold - cfg.gold
                        else
                            buff.value =  buff.value - cfg.coin
                            info.itemValue = info.itemValue - cfg.coin
                        end

                        UI.draw(node,"buff",buff)

                        if cfg.type == 2 then
                            info.addAttack = info.addAttack + cfg.add
                        end

                        if cfg.type == 3 then
                            info.addSkill = info.addSkill + cfg.add
                        end

                        if cfg.type == 1 then
                            info.hp = info.hp  + (info.maxHp * cfg.add / 10000)
                            if info.hp > info.maxHp then
                                info.hp = info.maxHp
                            else
                                info.hp = math.floor(info.hp)
                            end
                        end

                        local infoData = {
                            addSkill = (info.addSkill/100) .. "%",
                            addAttack = (info.addAttack/100) .. "%",
                            hp = info.hp,
                            hpText = info.hp .. "/" .. info.maxHp,
                        }
                        UI.draw(node,"info",infoData)

                        backFun()
                    end)
                end
                items[i].get = false
            else
                items[i].buy = false
                items[i].get = info.selectedItem == i
            end

            if cfg.coin == 0 then
                items[i].type1 = false
                items[i].type2 = true
                items[i].value = cfg.gold
            else
                items[i].type1 = true
                items[i].type2 = false
                items[i].value = cfg.coin
            end
        end

        log(buff)

        UI.draw(node,"buff",buff)

        UI.button(node,"buff/check", function()
            self.notShop = not self.notShop
            UI.enable(node,"buff/check/selected",self.notShop)
        end)
    end


    HeroTools.setHeadTemp(self.opponent.head,self.opponent.level,self.opponent.cloth)
    UI.draw(node,data)
    HeroTools.clearHeadTemp()

    if not self.notShop then
        if info.selectedItem == 0 then
            data.heros.btn()
        end
    end

    if self.battleInfo.selectedHero > 0 then
        message:send("C2S_BattleLevelGo",{selected=self.battleInfo.selectedHero},function(ret)
            self:showBattle(ret,info.heros[self.battleInfo.selectedHero])
            self.battleInfo.selectedHero = 0
        end)
    end
end

function Class:showBattle(ret,hero)

    self.battleHallGo = ret

    local node = UI.child(self.node,"doing")
    UI.enable(node,true)

    self.doing_node = UI.clone(node)
    self.doing_node.parent = node
    node = self.doing_node

    local child = UI.child(node,"other/id")
    UI.setLocalScale(child,0.7,0.7, 1)

    self.opponentMaxHp = ret.hp

    local data = {
        self = {
            id = self.battleInfo.self.id,
            hpPer =self.battleInfo.hp .. "/" .. self.battleInfo.maxHp,
            hp = {maxValue = self.battleInfo.maxHp,value=self.battleInfo.hp},
            name = self.battleInfo.self.name,
            level = "等级：" .. self.battleInfo.self.level,
            grows = "资质：" .. self.battleInfo.self.grows,
            hint = self:randomHint(1),
        },
        btnSkip = function()
            if self.battleHallGo.timer then
                UI.stopDelay(self.node,self.battleHallGo.timer)
                self.battleHallGo.timer = nil
                self:endBattleStep(true)
            end
        end,
    }

    self.battleInfo.otherHp = ret.hp

    log(self.battleInfo)

    UI.enable(node,true)
    UI.draw(node,data)

    local data = {
        other = {
            id = hero.id,
            hp = {value=ret.hp,maxValue= ret.hp},
            hpPer = ret.hp .. "/" .. ret.hp,
            name = hero.name,
            level = "等级：" .. hero.level,
            grows = "资质：" .. hero.grows,
            hint = self:randomHint(2),
        }
    }
    HeroTools.setHeadTemp(self.opponent.head,self.opponent.level,self.opponent.cloth)
    UI.draw(node,data)
    HeroTools.clearHeadTemp()

    local anim = {
        {
            alphaAll = 1,
            time = 0,
        },
        {
            time = 1.5,
        } ,
        {
            alphaAll = 0,
            time = 0.2,
        }
    }

    UI.tweenList(node,"other/hint",anim)
    UI.tweenList(node,"self/hint",anim)

    self.battleHallGo.step = 0
    self.battleHallGo.timer = UI.delay(self.node,0.1,function()
        self:nextBattleStep()
    end)

    --for i=1,20 do
    --    self.battleHallGo.attacks[i] = 123
    --    self.battleHallGo.cirts[i] = true
    --end
end

function Class:randomHint(index)
    local n = math.random(1,10)
    if index > 1 then
        n = n + 10
    end
    return config.waterBattleWordMap[n].content
end

function Class:endBattleStep(skip)

    if skip then
        local step = self.battleHallGo.step + 1
        while step <= #self.battleHallGo.attacks do
            if step % 2 == 1 then
                self.battleInfo.otherHp = self.battleInfo.otherHp - self.battleHallGo.attacks[step]
            else
                self.battleInfo.hp = self.battleInfo.hp - self.battleHallGo.attacks[step]
            end
            step = step + 1
        end

        if self.battleInfo.otherHp < 0 then
            self.battleInfo.otherHp = 0
        end

        if self.battleInfo.hp < 0 then
            self.battleInfo.hp = 0
        end

        local hpOhterPer =   self.battleInfo.otherHp .. "/" .. self.opponentMaxHp
        local hpPer =   self.battleInfo.hp .."/" .. self.battleInfo.maxHp

        local node = self.doing_node
        if node then
            UI.draw(node, {
                other = {
                    hpPer = hpOhterPer,
                    hp = self.battleInfo.otherHp,
                },
                self = {
                    hpPer = hpPer,
                    hp = self.battleInfo.hp,
                },
            })
        end
    end

    self.battleHallGo.step = #self.battleHallGo.attacks + 1

    log(self.battleHallGo)
    if self.battleHallGo.win then
        CS.Sound.Play("effect/win")

        UI.enable(self.node,"continuedWin",true)

        local data  = {
            continueWin = self.battleHallGo.nextInfo.continueWin,
        }

        if data.continueWin % 3 == 0 then
            data.hint = false
            data.gift = true
        else
            data.hint = {
                count = 3 - (data.continueWin % 3)
            }
            data.gift = false
        end

        UI.draw(self.node,"continuedWin",data)

        local open = function(i,index,selected)
            local cfg

            if selected then
                cfg = config.waterBattleRewardMap[self.battleHallGo.selectId]
            else
                cfg = config.waterBattleReward[index]
            end

            local item  = false
            local hint = false

            if cfg.type == 1 then
                hint = "资质经验："
            end

            if cfg.type == 2 then
                hint = "技能经验："
            end

            local hintValue

            if cfg.type == 3 then
                item = cfg.num
                hint = "获得物品<color=#F8E6AF>" .. config.itemMap[item].name .. "</color>"
                hintValue = "X" .. cfg.num
            else
                hint =  hint .. cfg.num
                hintValue = hint
                hint = "你的豪杰<color=#F8E6AF>" .. self.battleInfo.self.name .. "</color>获得<color=#01FF00>" .. hint .. "</color>"
            end

            local dis = {
                type1 = cfg.type == 1,
                type2 = cfg.type == 2,
                type3 = item,
                value = hintValue,
            }

            UI.tweenList(self.node,"continuedWinGift/S"..i,{
                {
                    rotation = {y=90},
                    time = 0.3,
                },
                {
                    rotation = {y=90},
                    time = 0.3,
                    fun = function()
                        local child = UI.child(self.node,"continuedWinGift/gift"..i)
                        CS.UIAPI.TweenRotation(child, CS.UnityEngine.Vector3(0, 90, 0), 0.3);

                        UI.draw(child, dis)
                        UI.enable(child,true)

                        if selected then
                            UI.draw(self.node, "continuedWinGift",{
                                hint = hint,
                                click = function()
                                    UI.enable(self.node, "continuedWinGift", false)
                                    self:nextBattle()
                                end,
                            })
                        end
                    end,
                },
            })

        end

        UI.button(self.node,"continuedWin", function()
            UI.close(self.doing_node)
            self.doing_node = nil
            UI.enable(self.node,"doing",false)

            UI.enable(self.node,"continuedWin",false)
            self:nextBattle()
        end)
    else
        CS.Sound.Play("effect/fail")

        UI.enable(self.node,"lost",true)
        UI.button(self.node,"lost", function()
            UI.close(self.doing_node)
            self.doing_node = nil
            UI.enable(self.node,"doing",false)

            UI.enable(self.node,"lost",false)
            self:showBackHero()
            if self.selectHero then
                self.selectHero.state = 1
            end
        end)
    end
end

function Class:nextBattle()
    if self.battleHallGo.nextInfo.opLiveCount == 0 then
        self:showWin()
    else
        self:drawBattleInfo(self.battleHallGo.nextInfo)
    end
end

function Class:showBackHero()
    UI.enable(self.node,"battle",false)
    message:send("C2S_BattleLevelInfo",{},function(ret)
        self:showHallInfo(ret)
    end)
end


function Class:showWin()
    local node = UI.child(self.node,"win")
    UI.enable(node,true)

    local data = {
        btnOk = function()
            UI.enable(self.node,"battle",false)
            message:send("C2S_BattleLevelInfo",{},function(ret)
                self:showHallInfo(ret)
            end)
        end
    }

    local cfg = self:findCfg(self.info.bigLevel,self.info.smallLevel)

    data.items = {}
    for i=1,#cfg.item,2 do
        local item = {
            id = cfg.item[i],
            count = cfg.item[i+1],
        }
        table.insert(data.items,item)
    end

    log(self.info.levelCount,self.info.smallLevel)

    if self.info.levelCount == self.info.smallLevel then

        if self.heroes then
            for i,v in ipairs(self.heroes) do
                v.state = 0
            end
        end

        data.line1 = {
            Index1 = "第" .. self.info.bigLevel .. "关",
        }
--         if self:findCfg(self.info.bigLevel+1,1) then
--             data.line2 = {
--                 Index1 =  "第" .. (self.info.bigLevel+1) .. "关 第1门",
--             }
--         else
--             data.line2 = {
--                 Index1 =  "第" .. 1 .. "关 第1门",
--             }
--         end
        data.line2 = false
        data.line3 = false
        data.bg = {
            Title = {
                Text = "通关成功"
            }
        }
    else
        data.line1 = false
        data.line2 = false
        data.line3 = {
            Index1 =  "第" .. self.info.bigLevel .. "关 第" ..self.info.smallLevel .. "门"
        }
        data.bg = {
            Title = {
                Text = "破门成功"
            }
        }
    end

    UI.draw(node,data)
end

function Class:findCfg(big,small)
    for _,v in ipairs(config.tower) do
        if v.big == big then
            small = small - 1
            if small == 0 then
                return v
            end
        end
    end
    return nil
end

function Class:nextBattleStep()

    if self.battleHallGo.step > #self.battleHallGo.attacks then
        return
    end

    local step = self.battleHallGo.step + 1
    self.battleHallGo.step = step

    if self.battleHallGo.step > #self.battleHallGo.attacks then
        self:endBattleStep()
        return
    end

    local node = self.doing_node

    if node == nil then
        return
    end

    UI.enable(node,true)

    local desNode
    local hp

    local srcAnimPath = "id"
    local desAnimPath = "id"

    local srcNode
    local offX = 60
    local per
    if step % 2 == 1 then
        hp = self.battleInfo.otherHp - self.battleHallGo.attacks[step]
        if hp < 0 then
            hp = 0
        end
        self.battleInfo.otherHp = hp
        desNode = UI.child(node,"other")
        srcNode = UI.child(node,"self")

        per =  hp .. "/" .. self.opponentMaxHp
    else
        hp = self.battleInfo.hp - self.battleHallGo.attacks[step]
        if hp < 0 then
            hp = 0
        end
        self.battleInfo.hp = hp
        desNode = UI.child(node,"self")
        srcNode = UI.child(node,"other")
        offX = -offX

        per =  hp .. "/" .. self.battleInfo.maxHp
    end

    local dHp = self.battleHallGo.attacks[step]
    local dCirt = self.battleHallGo.cirts[step]

    CS.Sound.Play("effect/fight")

    UI.tweenList(UI.child(srcNode,srcAnimPath),{
        {
            addScale = 1.2,
            time = 0.2,
        },
        {
            addScale = 1/1.2,
            time = 0.2,
        },
        {
            fun = function()
                UI.tweenList(UI.child(desNode,desAnimPath),{
                    {
                        addScale = 0.9,
                        offset = {
                            x = offX,
                        },
                        time = 0.2,
                        fun = function()
                            if self.battleHallGo.step > #self.battleHallGo.attacks then
                                 UI.tweenList(UI.child(desNode,desAnimPath),{
                                    {
                                        addScale = 1/0.9,
                                        offset = {
                                            x = -offX,
                                        },
                                        time = 0,
                                    },
                                 })
                                return
                            end
                            UI.draw(desNode, {
                                hp = hp,
                                hpPer = per,
                            })
                            UI.playEffect(desNode,"id","strike", 0.3)

                            ComTools.disDamage(UI.child(desNode,"id"), { y = -200 },dHp,dCirt)
                        end,
                    },
                    {
                        addScale = 1/0.9,
                        offset = {
                            x = -offX,
                        },
                        time = 0.2,
                    },
                    {
                        fun = function()
                            if self.battleHallGo.step > #self.battleHallGo.attacks then
                                return
                            end
                            self.battleHallGo.timer = UI.delay(self.node,0.5,function()
                                if self.battleHallGo.step > #self.battleHallGo.attacks then
                                    return
                                end
                                self:nextBattleStep()
                            end)
                        end
                    }
                })
            end,
        }
    })



end




return Class