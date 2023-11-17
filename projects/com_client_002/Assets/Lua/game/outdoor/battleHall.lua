local Class = {
    res = "UI/yizhengting"
}


function Class:init()

    CS.Sound.PlayMusic("music/governmentfight")

    UI.button(self.node, "battle/btnHelp",function()
        showHelp("waterbattle")
    end)

    UI.enableAll(self.node,false)

    self.backFuns = {}

    local main  = {
        doing = false,
        hint = false,
        heroId = false,
        hintTime = false,
        hintNormal = false,
        hint = false,
        btnBack =  function()
            self:onBack()
        end,
        btnHelp = function()
            showHelp("waterbattle")
        end,
        btnHero = function()
            self:showTop6Heroes()
        end,
        btnDayTop = function()
            self:showDayTop()
        end,
        btnTop = function()
            self:showAllTop()
        end,
        btnHis = function()
            self:showHis()
        end,
        btnNotice = function()
            self:showNotices()
        end,
        btnAddCount = false,
    }

    self.notices = {}
    self.main = main

    UI.enable(self.node,"main", true)
    self:drawMain()

    message:send("C2S_battleHallInfo", {}, function(ret)
        self:showHallInfo(ret)
    end)

    self.noticeTime = 0
    self.noticeGetTime = 0
    UI.addUpdate(self.node,function()
        self:updateNotices()

        if self.freshTime then
            self.freshTime =  self.freshTime - CS.UnityEngine.Time.deltaTime
            local needRefresh = self.freshTime <= 0
            if needRefresh then
                for i=1,self.node.childCount-1 do
                    local node = UI.child(self,i)
                    if node.activeSelf then
                        needRefresh = false
                        break
                    end
                end
            end

            if needRefresh then
                self.freshTime = nil
                 message:send("C2S_battleHallInfo", {}, function(ret)
                    self:showHallInfo(ret)
                end)
            end
        end
    end)
end

function Class:addCount()
    ItemTools.used(52,1,function()
        message:send("C2S_battleHallInfo", {}, function(ret)
            self:showHallInfo(ret)
        end)
    end)
end

function Class:updateNotices()
    self.noticeTime = self.noticeTime - CS.UnityEngine.Time.deltaTime
    if self.noticeTime <= 0 then

        message:send("C2S_battleHallUpdateNotice", {id=self.noticeGetTime}, function(ret)
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

                    if v.userId == client.user.id then
                        v.btn = false
                    else
                        v.btn = function()
                            self:fight(v.userId)
                        end
                    end

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
                offset = {y = 1280},
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

    message:send("C2S_battleHallLog", {}, function(ret)

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

        UI.enable(node,"page_1/NoData",#ret.logs == 0)
        UI.enable(node,"page_2/NoData",#ret.enemys == 0)

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

                    id = tonumber(id)
                    if type(id) ~= "number" then
                        UI.showHint("无效输入")
                        return
                    end

                    if id < 10000000 then
                        UI.showHint("id位数太短")
                        return
                    end

                    message:send("C2S_battleHallFind",{id=id},function(ret)
                        if ret.success then
                            ret.body = ret.level
                            ret.btnGo = function()
                                self:fight(id,true)
                            end

                            ret.hero = 1
                            HeroTools.setHeadTemp(ret.head,ret.level,ret.cloth)
                            UI.draw(node,"page_3/opponent",ret)
                            HeroTools.clearHeadTemp()

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

function Class:fight(id,supper)

    local type = 1
    if supper then
        type = 2
    end


    if type == 1 then
        if self.info.item1 <= 0 then
            UI.showHint("没有挑战书")
            return
        end
    else
        if self.info.item2 <= 0 then
            UI.showHint("没有追击令")
            return
        end
    end


    -- if not self.heroes then
    if true then
        message:send("C2S_battleHallHeroes", {type=type}, function(ret)

            table.sort(ret.heroes,function(a,b)

                if a.state == 1 then
                    return false
                end

                if b.state == 1 then
                    return true
                end

                if a.attribue == b.attribue then
                    return a.id > b.id
                end

                return a.attribue > b.attribue
            end)

            self.heroes = ret.heroes
            self:fightFun(id,type)
        end)
        return
    end

    self:fightFun(id,type)
end


function Class:fightFun(id,type)
    local node = UI.child(self.node,"selectHero")

    local heros = {}

    local btnText = "挑战"
    local itemHint
    if type == 1 then
        itemHint = "挑战书" .. self.info.item1
    else
        btnText = "追击"
        itemHint = "追击令" .. self.info.item2
    end

    for i,v in ipairs(self.heroes) do
        heros[i] = {
            id = v.id,
            name = v.name,
            grows = v.grows,
            attribue = v.attribue,
            lvl = "LV." .. v.level,
            btnText = btnText,
            state = (v.state == 1),
        }
        if v.state == 1 then
            heros[i].btn = false
        else
            heros[i].btn = function()
                 self:doFight(id,v.id,type)
            end
        end
    end

    local data = {
        itemHint = itemHint,
        bg = {
            btnBack = function()
                UI.enable(node,false)
            end,
        },
        heros = heros,
    }
    UI.enable(node,true)
    UI.draw(node,data)
end

function Class:doFight(id,heroId,type)
    log(id,heroId,type)

    local dofun = function()
        message:send("C2S_battleHallFight",{oppoId=id,heroId=heroId,type=type},function(ret)
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

    local itemId = 50
    if type == 1 then
        itemId = 50
    else
        itemId = 51
    end
    ItemTools.usedItemHit(itemId, dofun)
end

function Class:showDayTop()
    local node = UI.child(self.node,"dayTopList")
    UI.enable(node,true);

    message:send("C2S_battleHallDayTop", {}, function(ret)

        local gitfIndex = 1
        local index= "未上榜"
        for i,v in ipairs(ret.datas) do
            if v.id == client.user.id then
                index = i
                v.name = "<color=#45EA2B>" .. v.name .. "</color>"
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

    message:send("C2S_battleHallAllTop", {}, function(ret)

        local datas = ret.datas


        local index= "未上榜"
        for i,v in ipairs(datas) do
            if v.id == client.user.id then
                index = i
                v.name = "<color=#45EA2B>" .. v.name .. "</color>"
            end
            v.index = i
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
            datas = datas,
        }

        UI.draw(node,data)
    end)
end

function Class:showTop6Heroes()
    local node = UI.child(self.node,"heros")
    UI.enable(node,true);

    message:send("C2S_battleHallTop6", {}, function(ret)
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

    main.doing = ret.hasGame

    if ret.heroId > 0 then
        main.heroId = ret.heroId
        main.lastTime = false
    else
        main.heroId = false
        main.lastTime = ret.lastTime
    end

    main.hintTime = false
    main.hintNormal = false
    main.hint = false
    main.btnAddCount = false
    main.clickHero = false

    log(ret)

    self.freshTime = nil
    if not ret.hasGame then
        if ret.heroId > 0 then
            main.hint = {
                text = "<color=#FA8872>" ..  HeroTools.getName(ret.heroId) .. "</color>愿助大人一臂之力"
            }
            main.clickHero = function()
                self:showOpponent()
            end
        else
            if ret.lastTime <= 0 then
                if ret.canBuy then
                    main.hintNormal = {
                        Text = "今日议政次数已完，可使用议政令x1增加1次议政"
                    }
                    main.btnAddCount = function()
                        self:addCount()
                    end
                else
                    main.hintNormal = {
                        Text = "今日议政次数已完，请明日再来"
                    }
                end
            else
                main.hintTime = {
                    lastTime = ret.lastTime,
                }
                self.freshTime = ret.lastTime
            end
        end
    else
        main.lastHint = false
        main.clickHero = function()
            message:send("C2S_battleHallGoInfo",{},function(ret)
                self.notShop = false
                self:drawBattleInfo(ret)
            end)
        end
    end

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
            message:send("C2S_battleHallGoInfo",{},function(ret)
                UI.enable(node,false)
                self.info.hasGame = true
                self:drawBattleInfo(ret)
            end)
        end,
        btnNo = function()
            UI.enable(node,false)
        end,
    }

    UI.draw(node,data)




    data = {
        btnYes = {
            Text = "战斗",
        },
        text = "你确定要挑战玩家<color=#F8E6AF>" .. self.opponent.name ..  "</color>",
        id = 1,
    }

    HeroTools.setHeadTemp(self.opponent.head,self.opponent.level,self.opponent.cloth)
    UI.draw(node,data)
    HeroTools.clearHeadTemp()

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

    UI.slider(ui, "info/hp",{
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


    self.selectedHeroDone = false

    for i,v in ipairs(info.heros) do

        if type(v) == "table" then
            v.btn = function()
                if self.selectedHeroDone then
                    return
                end

                if not self.notShop then
                    if info.selectedItem == 0 then
                        UI.msgBox("你确认要放弃购买属性?",function()
                             message:send("C2S_battleHallGo",{selected=i},function(ret)
                                self:showBattle(ret,v)
                             end)
                        end,function() end)
                        return
                    end
                 end

                self.selectedHeroDone = true
                message:send("C2S_battleHallGo",{selected=i},function(ret)
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
          name = self.opponent.name .. " (权威：" .. self.opponent.value .. ")",
          count = "大臣数量：" .. info.opLiveCount .. "/" .. info.opAllCount
        },
        continue = continue,
        heros = info.heros,
        info = {
            name = client.user.name .. " (权威：" .. info.value .. ")",
            heroName = info.self.name,
            heroLevel = "等级：" .. info.self.level,
            heroGrows = "资质：" .. info.self.grows,
            addSkill = (info.addSkill/100) .. "%",
            addAttack = (info.addAttack/100) .. "%",
            hp = info.hp/info.maxHp,
            hpText = info.hp .. "/" .. info.maxHp,
        },
        btnBack =  function()
            if self.buyingBuffBack then
                self.buyingBuffBack()
            else
                message:send("C2S_battleHallInfo",{},function(ret)
                    UI.enable(node,false)
                    self:showHallInfo(ret)
                end)
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
                items[i].hint = "技能加成" .. (cfg.add / 100) .. "%"
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

                    message:send("C2S_battleHallBuyItem", {selected=i}, function()

                        info.selectedItem = i

                        for n=1,3 do
                            items[n].buy = false
                        end
                        items[i].get = true


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
                            hp = info.hp/info.maxHp,
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

end

function Class:showBattle(ret,hero)

    self.battleHallGo = ret
    self.opponentMaxHp = ret.hp

    local node = UI.child(self.node,"doing")
    UI.enable(node,true)

    self.doing_node = UI.clone(node)
    self.doing_node.parent = node
    node = self.doing_node

    local data = {

        other = {
            id = hero.id,
            hp = {value=ret.hp,maxValue= ret.hp},
            hpPer = ret.hp .. "/" .. ret.hp,
            name = hero.name,
            level = "等级：" .. hero.level,
            grows = "资质：" .. hero.grows,
            hint = self:randomHint(2),
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

    HeroTools.setHeadTemp(self.opponent.head,self.opponent.level,self.opponent.cloth)
    UI.draw(node,data)
    HeroTools.clearHeadTemp()

    local data = {
        self = {
            id = self.battleInfo.self.id,
            hp = { maxValue = self.battleInfo.maxHp, value = self.battleInfo.hp },
            hpPer =self.battleInfo.hp .. "/" .. self.battleInfo.maxHp,
            name = self.battleInfo.self.name,
            level = "等级：" .. self.battleInfo.self.level,
            grows = "资质：" .. self.battleInfo.self.grows,
            hint = self:randomHint(1),
        }
    }
    UI.draw(node,data)



    if not self.delayIndex then
        self.delayIndex = 0
    end
    self.delayIndex = self.delayIndex + 1
    local n = self.delayIndex

    UI.setAlpha(node,"other/hint",1)
    UI.setAlpha(node,"other/hint/hint",1)
    UI.setAlpha(node,"self/hint",1)
    UI.setAlpha(node,"self/hint/hint",1)

    UI.delay(self.node,1.5,function()
        if self.delayIndex == n then
            local anim = {
                {
                    alphaAll = 0,
                    time = 0.2,
                },
            }
            UI.tweenList(node,"other/hint",anim)
            UI.tweenList(node,"self/hint",anim)
        end
    end)



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

        if self.battleInfo.hp < 0 then
            self.battleInfo.hp = 0
        end

         if self.battleInfo.otherHp < 0 then
             self.battleInfo.otherHp = 0
         end

        local hpOhterPer =   self.battleInfo.otherHp .. "/" .. self.opponentMaxHp
        local hpPer =   self.battleInfo.hp .."/" .. self.battleInfo.maxHp

        local node = self.doing_node
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

    self.battleHallGo.step = #self.battleHallGo.attacks + 1

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

        local open = function(i,index,selected,giftNode)
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
                hintValue = "X1"
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

            UI.tweenList(giftNode,"S"..i,{
                {
                    rotation = {y=90},
                    time = 0.3,
                },
                {
                    rotation = {y=90},
                    time = 0.3,
                    fun = function()
                        local child = UI.child(giftNode,"gift"..i)
                        CS.UIAPI.TweenRotation(child, CS.UnityEngine.Vector3(0, 90, 0), 0.3);

                        UI.draw(child, dis)
                        UI.enable(child,true)

                        if selected then
                            UI.draw(giftNode, {
                                hint = hint,
                                click = function()
                                    print("close continuedWinGift...")
                                    UI.close(giftNode)
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

            if self.battleHallGo.selectId > 0 then
                local clicked
                local giftNode = UI.clone(UI.child(self.node,"continuedWinGift"))
                UI.enable(giftNode,true)
                local data = {
                    hint =  false,
                    click = false,
                }

                for i = 1, 6 do
                    local path = "S"..i
                    local pathGift = "gift"..i
                    local child = UI.child(giftNode,path)
                    UI.child(giftNode,pathGift).localPosition = child.localPosition
                    child.localEulerAngles = CS.UnityEngine.Vector3(0,0,0)

                    local childGift = UI.child(giftNode,pathGift)
                    childGift.localEulerAngles = CS.UnityEngine.Vector3(0,-90,0)

                    data[pathGift] = false
                    data[path] = function()

                        if clicked then
                            return
                        end
                        clicked = true

                        open(i,0,true,giftNode)

                        UI.delay(giftNode,0.5, function()
                            for j=1,6 do
                                if j ~= i then
                                    local n = math.random(1,#config.waterBattleReward)
                                     open(j,n,false,giftNode)
                                end
                            end
                        end)
                    end
                end

                UI.draw(giftNode, data)
            else
                self:nextBattle()
            end
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
        end)
    end
end

function Class:nextBattle()
    if self.battleHallGo.nextInfo.opLiveCount == 0 then
        self:showBackHero()
    else
        self:drawBattleInfo(self.battleHallGo.nextInfo)
    end
end

function Class:showBackHero()

    local node = UI.child(self.node,"dialog")
    UI.enable(node,true)

    local data = {
        btnYes = function()
            UI.enable(self.node,"battle",false)
            message:send("C2S_battleHallInfo",{},function(ret)
                self:showHallInfo(ret)
            end)
        end,
    }

    UI.draw(node,data)

    local text

    if self.battleHallGo.nextInfo.opLiveCount == 0 then
        text = "属下不辱使命，将<color=#F8E6AF>" .. self.battleInfo.opName .. "</color>麾下豪杰全部击败！"
    else
        local info = self.battleHallGo.nextInfo
        if info.opAllCount == info.opLiveCount then
            text = "<color=#F8E6AF>" .. self.battleInfo.opName .. "</color>过于强大，望大人休养生息后再来一战！"
        else
            text = "属下虽然无法敌过<color=#F8E6AF>" .. self.battleInfo.opName .. "</color>所有豪杰，但也有小胜一二。"
        end
    end

    data = {
        btnYes = {
            Text = "返回",
        },
        btnNo = false,
        text = text,
        id = self.battleInfo.self.id,
    }

    UI.draw(node,data)
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

    CS.Sound.Play("effect/fight")

    local node = self.doing_node
    if node == nil then
        return
    end

    local desNode
    local hp
    local per

    local srcNode
    local offX = 60
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

    UI.tweenList(UI.child(srcNode,"id/_animNode"),{
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
                UI.tweenList(UI.child(desNode,"id/_animNode"),{
                    {
                        addScale = 0.9,
                        offset = {
                            x = offX,
                        },
                        time = 0.2,
                        fun = function()

                            if self.battleHallGo.step > #self.battleHallGo.attacks then
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