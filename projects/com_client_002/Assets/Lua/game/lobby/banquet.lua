local Class = {
    res = "ui/yanhui",
}

local freshTime = 600

function Class:init()
    CS.Sound.PlayMusic("music/feast")
    self.hasClose = false
    UI.enableAll(self.node, false)
    UI.enable(self.node, "main", true)

    self:showMan()

    local button = {
        main = {
            btnBack = function()
                self.hasClose = true
                UI.close(self)
            end,
            btnEnterMy = function()
                self:clickEnter()
            end,
            btnMsg = function()
                self:clickMsg()
            end,
            btnBonus = function()
                self:clickBonus()
            end,
            btnTopList = function()
                self:clickTopList()
            end,
            bottom = {
                btnJion = function()
                    self:clickJion()
                end
            }
        }
    }

    UI.draw(self.node, button)

    self:backLobby()

    UI.addUpdate(self.node, function()
        self:update()
    end)
end

function Class:update()

    if self.nextUpdateBanquetTime ~= nil then

        self.nextUpdateBanquetTime = self.nextUpdateBanquetTime - CS.UnityEngine.Time.deltaTime

        if self.nextUpdateBanquetTime <= 0 then

            self.nextUpdateBanquetTime = nil

            if not self.banquetInfo then
                return
            end

            if self.banquetInfo.id <= 0 then
                return
            end

            message:send("C2S_updateBanquetDetal", { id = self.banquetInfo.id, index = #self.banquetInfo.comeInfo }, function(ret)
                if self.hasClose then
                    return
                end
                if not UI.isVisual(self.node, "house") then
                    return
                end

                if self.nextUpdateBanquetTime ~= nil then
                    return
                end

                if #ret.comeInfo > 0 then
                    for _, v in ipairs(ret.comeInfo) do
                        table.insert(self.banquetInfo.comeInfo, v)
                    end
                    self.banquetInfo.score = ret.score
                    self:disBanquet()
                end

                if ret.isEnd then
                    self.nextUpdateBanquetTime = nil

                    if not ret.endBanquet then
                        UI.enable(self.node, "house", false)
                        self:backLobby()
                        return
                    end

                    self:showEnd(ret.endBanquet, function()
                        UI.enable(self.node, "house", false)
                        self:backLobby()
                    end)
                else
                    self.nextUpdateBanquetTime = freshTime
                end
            end, true)
        end
    end

    -- 参加宴会的动画
    local pos = 1
    while pos <= #self.man do
        local man = self.man[pos]

        local off = man.move[1]

        if not off.x then
            off.x = 0
        end

        if not off.y then
            off.y = 0
        end

        local moveDis = man.speed * CS.UnityEngine.Time.deltaTime

        local base = math.sqrt(off.x * off.x + off.y * off.y)

        if moveDis > base then
            moveDis = base
        end

        local offX = off.x * moveDis / base
        local offY = off.y * moveDis / base

        off.x = off.x - offX
        off.y = off.y - offY
        man.move[1] = off

        UI.setLocalOffset(man.node, offX, offY)

        if moveDis == base then
            table.remove(man.move, 1)

            if #man.move == 2 then
                local index = math.random(1, 2)

                if man.move[1].x < 0 then
                    index = index + 2
                end

                local node = self.waiters[index]
                UI.enable(node, true)
                UI.tweenList(node, {
                    {
                        scale = 1.5,
                        alphaAll = 1,
                        time = 0.2,
                    },
                    {
                        time = 2,
                    },
                    {
                        scale = 1,
                        alphaAll = 0,
                        time = 0.2,
                    },
                })
            end
        end

        if #man.move == 0 then

            UI.tweenList(man.node, {
                {
                    alpha = 0,
                    time = 0.5,
                },
                {
                    type = "delete"
                }
            })

            table.remove(self.man, pos)
        else
            pos = pos + 1
        end
    end
end

function Class:showMan()

    if not self.waiters then
        self.waiters = {}
        self.man = {}
        for i = 1, 4 do
            self.waiters[i] = UI.child(self.node, "main/background/waiter" .. i .. "/hint")
        end
    end

    local node = UI.child(self.node, "main/background/man")

    local man = CS.UIAPI.Clone(node)
    local x = (math.random() - 0.5) * 200
    UI.setLocalPosition(man, x, nil, nil)
    table.insert(self.man, {
        node = man,
        speed = 30,
        move = {
            {
                y = 650,
            },
            {
                y = 50,
                x = -x,
            },
            {
                y = 150,
            }
        },
    })

    local time = 5 + math.random() * 5
    UI.delay(self.node, time, function()
        self:showMan()
    end)
end

function Class:showInfo()
    local node = UI.child(self.node, "main")
    UI.enable(node, true)

    local info = self.info

    local other = {}

    for i, v in ipairs(info.other) do
        local data = {
            supper = v.supper,
            name = v.name,
            mouse = (v.state == 2),
        }
        if v.state == 1 then
            data.icon = {
                self = {
                    level = client.user.level,
                    head = client.user.head,
                }
            }
        else
            data.icon = false
        end
        data.click = function()
            message:send("C2S_getBanquetDetal", { id = v.id }, function(ret)
                if self.hasClose then
                    return
                end
                if ret.id == 0 then
                    UI.showHint("此宴会已经结束")
                    return
                end
                self.banquetInfo = nil
                self:disBanquet(ret)
            end)
        end
        other[i] = data
    end

    local datas = {
        bottom = {
            countText = info.canGoCount .. "/" .. info.goMaxCount,
        },
        other = other,
    }

    UI.draw(node, datas)

    if info.endBanquet ~= nil then
        self:showEnd(info.endBanquet)
        info.endBanquet = nil
    end
end

function Class:showEnd(endBanquet, backFun)
    CS.UnityEngine.PlayerPrefs.SetInt("hasMakeBanquet", 0)
    self.info.hasSelf = false

    local child = UI.child(self.node, "result")
    UI.enable(child, true)

    local guests = {}
    for i, score in ipairs(endBanquet.scores) do

        guests[i] = {}

        guests[i].name = endBanquet.names[i]
        if score >= 0 then
            guests[i].score = "<color=#01FF00>+" .. score .. "</color>"
        else
            guests[i].score = score
        end
    end

    local datas = {
        top = {
            type1 = not endBanquet.supper,
            type2 = endBanquet.supper,
            score1 = endBanquet.score,
            score2 = endBanquet.score,
            hint = "共有" .. endBanquet.goCount1 .. "名玩家赴宴",
        },
        guests = guests,
        btnBack = function()
            if backFun then
                backFun()
            end
            UI.enable(child, false)
        end,
    }

    UI.draw(child, datas)
end

function Class:backLobby()
    self.inRoom = false

    local id = 0
    if CS.UnityEngine.PlayerPrefs.GetInt("hasMakeBanquet", 0) > 0 then
        id = client.user.id
    end

    message:send("C2S_getBanquetInfo", { lastId = id }, function(ret)
        if self.hasClose then
            return
        end
        if self.inRoom then
            return
        end

        self.delayBackLobbyTimer = UI.delay(self.node, 5, function()
            self.delayBackLobbyTimer = nil
            if UI.check(self.node) then
                self:backLobby()
            end
        end)

        if (id > 0) and (not ret.hasSelf) then
            CS.UnityEngine.PlayerPrefs.SetInt("hasMakeBanquet", 0)
        end

        self.info = ret
        self:showInfo()
    end)

end

function Class:clickEnter()

    if self.info.hasSelf then

        message:send("C2S_getBanquetDetal", { id = client.user.id }, function(ret)
            if self.hasClose then
                return
            end
            if ret.id == 0 then
                self.info.hasSelf = false
                self:clickEnter()
                return
            end
            self.banquetInfo = nil
            self:disBanquet(ret)
        end)

        return
    end

    local node = UI.child(self.node, "maker")
    UI.enable(node, true)

    local items = self.info.item

    local checkPublic = true
    local datas = {
        btnBack = function()
            UI.enable(node, false)
        end,
        banquet1 = {
            id1 = items[1].id,
            need1 = UI.formatCountText(items[1].count, items[1].need),
            id2 = items[2].id,
            need2 = UI.formatCountText(items[2].count, items[2].need),
            btnMake = function()
                self:makeBanquet(false, checkPublic)
            end,
            checkPublic = checkPublic,
            btnCheck = function()
                checkPublic = not checkPublic
                UI.enable(node, "banquet1/checkPublic", checkPublic)
            end,
        },
        banquet2 = {
            id1 = items[3].id,
            need1 = UI.formatCountText(items[3].count, items[3].need),
            id2 = items[4].id,
            need2 = UI.formatCountText(items[4].count, items[4].need),
            btnMake = function()
                self:makeBanquet(true, true)
            end,
        },
    }

    UI.draw(node, datas)

    local datas = {
        banquet1 = {
            id1 = function()
                UI.showItemInfo(items[1].id)
            end,
            id2 = function()
                UI.showItemInfo(items[2].id)
            end,
        },
        banquet2 = {
            id1 = function()
                UI.showItemInfo(items[3].id)
            end,
            id2 = function()
                UI.showItemInfo(items[4].id)
            end,
        },
    }
    UI.draw(node, datas)
end

function Class:makeBanquet(supper, share)
    local items = self.info.item

    local i = 1
    if supper then
        i = 3
    end
    if items[i].count < items[i].need or items[i + 1].count < items[i + 1].need then
        UI.showHint("材料不够！")
        return
    end

    message:send("C2S_makeBanquet", { supper = supper, share = share }, function(ret)
        if self.hasClose then
            return
        end
        if ret.success then

            CS.UnityEngine.PlayerPrefs.SetInt("hasMakeBanquet", 1)

            self.info.hasSelf = true
            self:disBanquet(ret.info)
            UI.enable(self.node, "maker", false)

            local node = UI.child(self.node, "makeOk")
            UI.enable(node, true)
            UI.text(node, "idText", "玩家编号" .. ret.info.id)

            UI.delay(node, 10, function()
                UI.enable(node, false)
            end)

            UI.button(node, function()
                UI.enable(node, false)
            end)
        else
            UI.showHint(ret.error)
        end
    end)
end

function Class:clickMsg()
    local node = UI.child(self.node, "his")
    UI.enable(node, true)

    local selTab = function(n)

        UI.enable(node, "Tab1/selected", n == 1)
        UI.enable(node, "Tab2/selected", n == 2)

        UI.enable(node, "his", n == 1)
        UI.enable(node, "enemy", n == 2)
    end

    UI.draw(node, {
        Tab1 = function()
            selTab(1)
        end,
        Tab2 = function()
            selTab(2)
        end,
        btnBack = function()
            UI.enable(node, false)
        end,
    })
    selTab(1)

    message:send("C2S_getBanquetHis", {}, function(ret)
        if self.hasClose then
            return
        end
        for i, v in ipairs(ret.his) do
            v.hint = "你举办了"

            if v.supper then
                v.hint = v.hint .. "官宴，"
            else
                v.hint = v.hint .. "家宴，"
            end

            v.hint = v.hint .. "共<color=#00FF00>" .. v.count1 .. "人" .. "</color>赴宴，"
            v.hint = v.hint .. "其中<color=#FF2900>" .. v.count2 .. "人" .. "</color>前来捣乱"
        end

        table.sort(ret.his, function(a, b)
            return a.time > b.time
        end)

        table.sort(ret.enemy, function(a, b)
            return a.time > b.time
        end)

        UI.draw(node, ret)
    end)
end

function Class:clickBonus()


    message:send("C2S_getBanquetBonusInfo", {}, function(ret)
        if self.hasClose then
            return
        end
        self:drawBonus(ret)

    end)
end

function Class:drawBonus(info)
    if info == nil then
        info = self.bonusInfo
    end
    self.bonusInfo = info

    local node = UI.child(self.node, "bonus")
    UI.enable(node, true)

    local delayId = UI.delay(node, info.refreshLastTime, function()
        message:send("C2S_getBanquetBonusInfo", {}, function(ret)
            if self.hasClose then
                return
            end
            self:drawBonus(ret)
        end)
    end)

    log(_s(info))

    info.countInfo = info.refreshCount .. "/" .. info.refreshAllCount
    info.gold = client.user.gold
    info.btnRefresh = function()
        message:send("C2S_refreshBanquetBonusInfo", {}, function(ret)
            if self.hasClose then
                return
            end
            if ret.success then
                log(_s(ret.info))
                UI.stopDelay(node, delayId)
                log(_s(ret.info))
                UI.showHint("刷新成功！")
                log(_s(ret.info))
                self:drawBonus(ret.info)
            else
                UI.showHint(ret.error)
            end
        end)
    end

    for i, v in ipairs(info.bonus) do
        v.btn = function()
            message:send("C2S_getBonus", { id = v.id, index = i - 1 }, function(ret)
                if self.hasClose then
                    return
                end
                if ret.success then
                    v.count = v.count - 1
                    info.score = info.score - v.score
                    self:drawBonus(info)

                    local results = {
                        {
                            type = "item",
                            item = {
                                id = v.id,
                            },
                            value = 1,
                        }
                    }
                    ItemTools.onItemResultDis(results)
                else
                    UI.showHint(ret.error)
                end
            end)
        end
    end

    info.btnClose = function()
        UI.enable(node, false)
    end
    UI.draw(node, info)

    local bonusNode = UI.child(self.node, "bonus/bonus/V/C")
    for i, v in ipairs(info.bonus) do
        local child = UI.child(bonusNode, i - 1)
        if v.count == 0 then
            UI.setGray(child)
        else
            UI.clearGray(child)
        end

        UI.button(bonusNode:GetChild(i - 1), "id/Image", function()
            UI.showItemInfo(v.id)
        end)
    end
end

function Class:clickTopList()
    local node = UI.child(self.node, "toplist")
    UI.enable(node, true)

    message:send("C2S_getBanquetTopList", {}, function(ret)
        if self.hasClose then
            return
        end
        for k, v in ipairs(ret.infos) do
            v.index = k
        end

        ret.me = {
            topIndex = "未上榜",
            score = ret.myScore,
        }

        ret.btnBack = function()
            UI.enable(node, false)
        end

        if ret.myPos > 0 then
            ret.me.topIndex = ret.myPos
        end

        UI.draw(node, ret)
    end)
end

function Class:clickJion()
    local node = UI.child(self.node, "findBanguet")
    UI.enable(node, true)

    local doFind = function()
        local id = UI.getValue(node, "bg/inputId")
        message:send("C2S_findBanquet", { id = id }, function(ret)
            if self.hasClose then
                return
            end
            if ret.success then


                local infoNode = UI.child(node, "bg/info")
                UI.enable(infoNode, true)

                local max = 10
                if ret.info.supper then
                    max = 50
                end

                ret.info.count = ret.info.count .. "/" .. max
                ret.info.btn = function()
                    message:send("C2S_getBanquetDetal", { id = id }, function(ret)
                        if self.hasClose then
                            return
                        end
                        if ret.id == 0 then
                            UI.showHint("此宴会已经结束")
                            return
                        end
                        self.banquetInfo = nil
                        self:disBanquet(ret)
                        UI.enable(node, false)
                    end)
                end
                UI.draw(infoNode, ret.info)
            else
                UI.showHint("宴会不存在")
            end
        end)
    end

    local datas = {
        bg = {
            btnFind = doFind,
            info = false,
            btnClose = function()
                UI.enable(node, false)
            end,
        }
    }
    UI.draw(node, datas)
end

function Class:disBanquet(info)
    log(info)
    local first = (not self.banquetInfo)

    if not info then
        info = self.banquetInfo
    end

    if info.id <= 0 then
        return
    end

    self.nextUpdateBanquetTime = freshTime

    self.banquetInfo = info
    self.inRoom = true
    if self.delayBackLobbyTimer then
        UI.stopDelay(self.node, self.delayBackLobbyTimer)
        self.delayBackLobbyTimer = nil
    end

    local node = UI.child(self.node, "house")
    UI.enable(node, true)

    local findSelf = false
    for i, v in ipairs(info.comeInfo) do
        if v.id == client.user.id then
            findSelf = true
        end
    end

    canDown = (info.id ~= client.user.id) and (not findSelf)

    local seats = {
    }

    local count = 10
    if info.supper then
        count = 50
    end

    for i = 1, count do
        seats[i] = {
            id = 0,
            icon = false,
            name = false,
            canDown = canDown,
            mouse = false,
            click = false,
        }

        if canDown then
            local pos = i
            seats[i].click = function()
                self:clickSitDown(pos)
            end
        end
    end

    log(_s(info.comeInfo))
    if first then
        UI.setLocalPosition(UI.child(node, "seats/C"), nil, 0, nil)
    end

    local hasCount = 0
    local mySeat = 0
    for _, v in ipairs(info.comeInfo) do

        local data = seats[v.pos + 1]

        if data.id == 0 then
            hasCount = hasCount + 1
        end

        data.id = v.id
        if v.type == 0 then
            data.mouse = true
        end

        data.canDown = false

        if v.id == client.user.id then
            if v.type == 0 then
                local pos = v.pos + 1
                data.click = function()
                    self:clickSitDown(pos)
                end
            else
                data.click = function()
                    ComTools.showPlayerInfo(data.id, false)
                end
            end
        else
            data.click = function()
                ComTools.showPlayerInfo(data.id, false)
            end
            mySeat = v.pos
        end

        if v.id == client.user.id then
            data.name = {
                Text = "<color=#01FF00>" .. v.name .. "</color>",
            }
        else
            data.name = {
                Text = v.name,
            }
        end
        data.icon = {
            self = {
                level = v.level,
                head = v.head,
            }
        }
    end

    local msgList = {}
    for i, v in ipairs(info.comeInfo) do
        local cfg = config.dinnerGoMap[v.type]
        if v.type == 0 then
            cfg = config.dinnerGoMap[4]
        end
        msgList[i] = {
            name = v.name,
        }

        if cfg.gold > 0 then
            msgList[i].icon = 1000
            msgList[i].count = cfg.gold
        else
            msgList[i].icon = cfg.item[1]
            msgList[i].count = "x" .. cfg.item[2]
        end

        if cfg.point > 0 then
            msgList[i].score = "+" .. cfg.point
        else
            msgList[i].score = "<color=#FF2F15>-" .. cfg.pointDown .. "</color>"
        end
    end

    local datas = {
        btnBack = function()
            self.nextUpdateBanquetTime = nil
            UI.enable(node, false)
            self:backLobby()
        end,
        info = {
            id = info.id,
            score = info.score,
            lastTime = info.lastTime,
            count = hasCount .. "/" .. info.maxCount,
            name = info.name,
        },
        supper = info.supper,
        normal = (not info.supper),
        seats = {
            C = seats,
        },
        msgList = msgList,
    }

    info.seats = seats

    UI.draw(node, datas)

    if not first then
        return
    end

    for _, v in ipairs(info.comeInfo) do
        if v.id == client.user.id then
            local seatsNode = UI.child(node, "seats/C")
            local child = UI.child(seatsNode, v.pos)

            UI.delay(self.node, 0.1, function()
                local y = -child.localPosition.y - 300
                UI.tweenList(seatsNode, {
                    {
                        position = { y = y },
                        time = 1
                    }
                })
            end)

            break
        end
    end
end

function Class:clickSitDown(pos)
    local info = self.banquetInfo
    local findSelf = false
    for i, v in ipairs(info.seats) do
        if v.id == client.user.id then
            findSelf = true
        end
    end

    local node = nil
    local datas = nil

    if findSelf then
        node = UI.child(self.node, "goBanquetOne")
        datas = {
            value = UI.formatCountText(self.info.goCount2, 1),
            btn = function()
                self:goBanquet(0, pos)
            end
        }
    else
        node = UI.child(self.node, "goBanquet")
        datas = {
            gold = client.user.gold,
            types = {
                {
                    btn = function()
                        self:goBanquet(1, pos)
                    end
                },
                {
                    btn = function()
                        self:goBanquet(2, pos)
                    end
                },
                {
                    count = UI.formatCountText(self.info.goCount1, 1),
                    btn = function()
                        self:goBanquet(3, pos)
                    end
                },
                {
                    count = UI.formatCountText(self.info.goCount2, 1),
                    btn = function()
                        self:goBanquet(0, pos)
                    end
                },
            }
        }
    end

    if not node then
        return
    end

    UI.enable(node, true)
    UI.draw(node, datas)
    UI.button(node, "btnBack", function()
        UI.enable(node, false)
    end)
end

function Class:goBanquet(type, pos)
    message:send("C2S_sitDown", { type = type, pos = pos - 1, id = self.banquetInfo.id }, function(ret)
        if self.hasClose then
            return
        end
        if ret.success then
            -- update info
            if type == 0 then
                self.info.goCount2 = self.info.goCount2 - 1
            end

            if type == 3 then
                self.info.goCount1 = self.info.goCount1 - 1
            end

            UI.enable(self.node, "goBanquet", false)
            UI.enable(self.node, "goBanquetOne", false)

            --self.banquetInfo.seats[pos] = ret.info
            --self:disBanquet()
            self.nextUpdateBanquetTime = 0

            local node = UI.child(self.node, "comeInfo")
            UI.enable(node, true)
            UI.button(node, function()
                UI.enable(node, false)
            end)

            local txt
            local hint
            if type == 0 then
                txt = "主人分数-10000"
                hint = "给我滚出去"
            else
                hint = "多谢大家来捧场"
            end

            if type == 1 then
                txt = "宴会分数+1000"
            end

            if type == 2 then
                txt = "宴会分数+5000"
            end

            if type == 3 then
                txt = "宴会分数+10000"
            end

            UI.draw(node, {
                hostName = self.banquetInfo.name,
                scoreInfo = txt,
                hint = hint,
            })

            HeroTools.setHeadTemp(self.banquetInfo.head, self.banquetInfo.level, self.banquetInfo.cloth)
            HeroTools.showAnim(node, "root", 1)
            HeroTools.clearHeadTemp()

        else
            UI.showHint(ret.error)
        end
    end)
end

return Class