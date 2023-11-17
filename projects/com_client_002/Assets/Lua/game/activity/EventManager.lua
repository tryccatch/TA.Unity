local Class = {
    res = "ui/EventManager"
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init(index)
    --if not index then
    --    index = 0
    --end
    UI.enable(self.node, false)
    UI.enableAll(self.node, "Page", false)

    self:showRedDot()
    self:showBtn()
    --self:showAnim()
    --self:showPage(index)
    if index then
        self:showPage(index)
    else
        self.index = 0
    end
end

function Class:showBtn()
    UI.button(self.node, "BtnClose", function()
        self:closePage()
    end)
end

function Class:countDown()
    message:send("C2S_ReqCountDown", {}, function(ret)
        if self.hasClose then
            return
        end
        self.overTime = ret.countDown
        if UI.check(self.node) then
            UI.CountDown(self.node, "countDown", ret.countDown / 1000, function()
                local index = self.index
                self.index = 0
                self.event402Info = nil
                self.overTime = nil
                self:showRedDot()
                self:showPage(index)
            end, 3, false)
        end
    end, true)
end

function Class:showRedDot()
    message:send("C2S_TreasureHouseInfo", {}, function(ret)
        log(ret)
        if self.hasClose then
            return
        end

        if #ret.btn < 1 then
            self:closePage()
            return
        end

        UI.enable(self.node, true)

        if self.index == 0 then
            local temp = config["treasureHouse"][ret.btn[1].id]

            self:showPage(temp.type, ret.btn[1].key)
        end

        local btnNode = UI.child(self.node, "Bottom/S/V/C")
        UI.cloneChild(btnNode, #ret.btn)
        for i, v in ipairs(ret.btn) do
            local child = UI.child(btnNode, i - 1)
            local cfg = config["treasureHouse"][v.id]
            UI.enable(child, "redDot", v.redDot)

            UI.draw(child, cfg)

            if cfg.type == 1 then
                local event = config["event401"][v.key]
                event.btnName = (event.hero > 0 and event.hero + 100) or (event.wife > 0 and event.wife + 200)
                UI.draw(child, event)
            end

            UI.button(child, function()
                self:showPage(cfg.type, v.key)
            end)
        end

        if #ret.btn > 4 then
            local S = UI.component2(UI.child(self.node, "Bottom/S"), typeof(CS.UnityEngine.RectTransform))
            local C = UI.component2(btnNode, typeof(CS.UnityEngine.RectTransform))

            local rect = UI.component2(UI.child(self.node, "Bottom/S/V/C"), typeof(CS.UnityEngine.RectTransform))
            local width = 150 * #ret.btn - 30
            CS.UIAPI.ScrollRectFun(S, function(value)
                UI.enable(self.node, "Bottom/L", rect.anchoredPosition.x < -30)
                UI.enable(self.node, "Bottom/R", rect.anchoredPosition.x > 150 * 4 - 30 - width)
            end)
            UI.child(self.node, "Bottom/S").gameObject:GetComponent(typeof(CS.UnityEngine.UI.ScrollRect)).horizontal = S.rect.width < width
        end
    end)
end

function Class:setVisual(bool)
    local text = UI.child(self.node, "countDown").gameObject:GetComponent(typeof(CS.UnityEngine.UI.Text))
    if text then
        text.enabled = bool
        UI.enable(self.node, "countDown/Text", bool)
    end
end

function Class:showPage(index, key)
    local pageNode = UI.child(self.node, "Page")

    --local showNode = UI.child(self.node, "Page/Event40" .. index)
    --if not UI.child(pageNode, index).gameObject.activeSelf then
    --    UI.enableAll(pageNode)

    if not UI.child(pageNode, index).gameObject.activeSelf then
        UI.enableOne(self.node, "Page", index)
    end

    if (self.index and index == self.index) and (self.key and key == self.key) then
        return
    end

    self:setVisual(false)

    --if not self.overTime then
    --    self:countDown()
    --end
    self.play = true

    if index == 0 then
        self:showEvent402()
    elseif index == 1 then
        --UI.enableAll(self.node, "Page/Event401/Msg/Info/Item", false)
        self:showEvent401(key)
    elseif index == 3 then
        self:showEvent403()
    else
        UI.showHint("看啥！还没写！！！")
    end

    self.index = index
    self.key = key
end

function Class:showEffect(node, value)
    if UI.check(node) then
        local effect = node:Find("effect")
        if value then
            if not effect then
                UI.showNode(node, "Effect/itemEffect").name = "effect"
            else
                UI.enable(effect, true)
            end
        else
            if effect then
                UI.enable(effect, false)
            end
        end
    end
end

function Class:changeTime(startDate, endDate)
    local startDate = convertToTime(startDate / 1000)
    local endDate = convertToTime(endDate / 1000)
    local date = startDate.month .. "月" .. startDate.day .. "日-" .. endDate.month .. "月" .. endDate.day .. "日"
    return date
end

function Class:showEvent401(key)
    local node = UI.child(self.node, "Page/Event401")
    local cfg = config["event401"][key]
    local show = function()
        UI.CountDown(node, "Msg/countDown", (self.event401Info[key].endDate / 1000) - os.time(), function()
            self:closePage()
        end)

        local data = {}
        if self.play then
            local child = UI.child(node, "Msg/Anim/pos")
            child = UI.child(child, 0, true)
            if child then
                UI.close(child)
            end
        end

        local pos = UI.child(node, "Msg/Anim/pos")
        if cfg.hero > 0 then
            UI.setLocalPosition(pos, cfg.posX, cfg.posY)
            local heroCfg = config.hero[cfg.hero]
            data.name = cfg.hero + 100
            data.specialty = heroCfg.specialty
            data.grows = heroCfg.allGrows
            if self.play then
                local animNode = UI.showNode(node, "Msg/Anim/pos", "Anim/hero" .. cfg.hero)
                animNode.name = "anim"
                UI.playAnim(animNode, "idle")
                self.play = false
            end
        elseif cfg.wife > 0 then
            UI.setLocalPosition(pos, cfg.posX, cfg.posY)
            local wifeCfg = config.wife[cfg.wife]
            data.name = cfg.wife + 200
            data.specialty = 3
            data.grows = wifeCfg.beauty
            if self.play then
                local animNode = UI.showNode(node, "Msg/Anim/pos", "Anim/wife" .. cfg.wife)
                animNode.name = "anim"
                UI.playAnim(animNode, "idle")
                self.play = false
            end
        end

        local items = {}

        if cfg.hero > 0 then
            local item = { id = 0,
                --qua = config.heroMap[cfg.hero].quality,
                           hero = cfg.hero,
                           wife = false,
                           icon = false,
                           count = false,
                           gotten = self.event401Info[key].state > 0,
                           fun = function()
                               UI.showHeroInfo(cfg.hero)
                           end }
            table.insert(items, item)
        end

        if cfg.wife > 0 then
            local item = { id = 0,
                --qua = config.wifeMap[cfg.wife].quality,
                --           qua = 5,
                           hero = false,
                           wife = config.wifeMap[cfg.wife].head,
                           icon = false,
                           count = false,
                           gotten = self.event401Info[key].state > 0,
                           fun = function()
                               UI.showWifeInfo(cfg.wife)
                           end }
            table.insert(items, item)
        end

        if #cfg.itemID % 2 == 0 then
            local count = #cfg.itemID / 2
            for i = 1, count do
                local item = { id = cfg.itemID[2 * i - 1],
                               wife = false,
                               hero = false,
                    --qua = config.itemMap[cfg.itemID[2 * i - 1]].quality,
                               icon = config.itemMap[cfg.itemID[2 * i - 1]].icon,
                               count = cfg.itemID[2 * i],
                               gotten = self.event401Info[key].state > 0,
                               fun = function()
                                   UI.showItemInfo(cfg.itemID[2 * i - 1])
                               end }
                table.insert(items, item)
            end
        end

        local py = config.payMap[cfg.payID].price
        data.Info = { --[[date = self:changeTime(self.event401Info[key].startDate, self.event401Info[key].endDate),]]
            S = { V = { C = items } },
            Btn = { Over = self.event401Info[key].state > 0,
                    Buy = self.event401Info[key].state <= 0 and
                            { redDot = self.event401Info[key].state == 0,
                              Text = self.event401Info[key].state < 0 and Tools.showChannelValue(py) or "可领取" } } }

        UI.draw(node, "Msg", data)

        --local itemsNode = UI.child(node, "Msg/Info/Item")
        --for i = 0, #items - 1 do
        --    self:showEffect(UI.child(itemsNode, i), self.event401Info[key].state <= 0)
        --end

        UI.child(node, "Msg/name"):GetComponent(typeof(CS.UnityEngine.UI.Image)):SetNativeSize()

        UI.refreshSVC(node, "Msg/Info", true, true)

        UI.button(node, "Msg/Info/Btn/Buy", function()
            if self.event401Info[key].state < 0 then
                ComTools.charge(config.payMap[cfg.payID], "event401", key, function()
                    self.event401Info[key] = nil
                    self:showEvent401(key)
                    self:showRedDot()
                end)
            elseif self.event401Info[key].state == 0 then
                message:send("C2S_Event401Receive", { key = key }, function(ret)
                    if self.hasClose then
                        return
                    end
                    if ret.code == "ok" then
                        if ret.hero > 0 then
                            Story.show({ heroID = ret.hero, endFun = function()
                                if ret.wife > 0 then
                                    Story.show({ wifeId = ret.wife, endFun = function()
                                        ItemTools.showItemsResult(items)
                                    end })
                                else
                                    ItemTools.showItemsResult(items)
                                end
                            end })
                        elseif ret.wife > 0 then
                            Story.show({ wifeId = ret.wife, endFun = function()
                                ItemTools.showItemsResult(items)
                            end })
                        else
                            ItemTools.showItemsResult(items)
                        end
                    else
                        UI.showHint("领取失败")
                    end
                    self.event401Info[key] = nil
                    self:showEvent401(key)
                    self:showRedDot()
                end)
            end
        end)
    end

    if self.event401Info and self.event401Info[key] then
        show()
    else
        if self.event401Info == nil then
            self.event401Info = {}
        end
        message:send("C2S_Event401Open", { key = key }, function(ret)
            if self.hasClose then
                return
            end
            table.insert(self.event401Info, key, ret)
            show()
        end)
    end
    log(self.event401Info)
end

function Class:showEvent402()
    local node = UI.child(self.node, "Page/Event402")
    local cfg = config["event402"]

    local show = function()
        local itemsNode = UI.child(node, "S/V/C")
        UI.cloneChild(itemsNode, #cfg)

        for i, v in ipairs(self.event402Info) do
            local child = UI.child(itemsNode, i - 1)
            local items = {}

            for i = 1, #cfg[v.id].item, 2 do
                local item = { id = cfg[v.id].item[i],
                               icon = config.itemMap[cfg[v.id].item[i]].icon,
                               count = cfg[v.id].item[i + 1],
                               fun = function()
                                   UI.showItemInfo(cfg[v.id].item[i])
                               end }
                table.insert(items, item)
            end

            UI.button(child, "Btn/Buy", function()
                if cfg[v.id].price > 0 then
                    ComTools.charge(cfg[v.id], "event402", v.id, function()
                        message:send("C2S_Event402Open", {}, function(ret)
                            if self.hasClose then
                                return
                            end
                            if ret.item[v.id].gotten > v.gotten then
                                ItemTools.showItemsResult(items)
                            else
                                UI.showHint("充值失败")
                            end
                            self.event402Info = ret.item
                            self:showEvent402()
                        end)
                    end)
                else
                    message:send("C2S_Event402Receive", { id = v.id }, function(ret)
                        if self.hasClose then
                            return
                        end
                        if ret.code == "ok" then
                            ItemTools.showItemsResult(items)
                        else
                            UI.showHint("领取失败")
                        end
                        self.event402Info = nil
                        self:showEvent402()
                        self:showRedDot()
                    end)
                end
            end)

            local info = {
                Name = { name = cfg[v.id].name },
                limited = cfg[v.id].limited > 0 and (v.count > 0 and v.count) or false,
                Item = items,
                Btn = { Over = cfg[v.id].limited > 0 and v.count <= 0,
                        Buy = (cfg[v.id].limited <= 0 or v.count > 0) and
                                { Text = cfg[v.id].price > 0 and Tools.showChannelValue(cfg[v.id].price) or "免费",
                                  redDot = cfg[v.id].price <= 0
                                } or false }
            }
            UI.draw(child, info)
            local Item = UI.child(child, "Item")
            for i = 0, #items - 1 do
                self:showEffect(UI.child(Item, i), true)
            end

            UI.refreshSVC(child, "Name", true, true)
        end
    end

    if self.event402Info then
        show()
    else
        message:send("C2S_Event402Open", {}, function(ret)
            if self.hasClose then
                return
            end
            self.event402Info = ret.item
            show()
        end)
    end
end

function Class:showEvent403()
    local node = UI.child(self.node, "Page/Event403")
    local cfg = config["event403"]

    local show = function()
        local itemsNode = UI.child(node, "S/V/C")
        UI.cloneChild(itemsNode, #cfg)
        if self.event403Info.Countdown > 0 then
            UI.CountDown(node, "Top/Mask/CountDown", math.ceil(self.event403Info.Countdown), function()
                self:closePage()
            end, 1, true)
        else
            self:closePage()
        end

        local Info = {}
        local war = { level = "LV" .. 0,
                      count = 0,
                      hero = 0,
                      wife = 0,
                      oneKey = false,
                      slider = { value = 0,
                                 maxValue = cfg[1].num } }

        for i, v in ipairs(cfg) do
            local state = self:getEvent403State(i)

            if self.event403Info.warExp >= v.num then
                if cfg[i + 1] then
                    war.slider.maxValue = cfg[i + 1].num - v.num
                end
                war.slider.value = self.event403Info.warExp - v.num
                war.level = "LV" .. v.id
                if (not state.free) or (self.event403Info.hasBuy and (not state.gold)) then
                    war.oneKey = true
                end
            end

            if v.hero > 0 then
                war.hero = v.hero
            end

            if v.wife > 0 then
                war.wife = v.wife
            end

            local child = UI.child(itemsNode, i - 1)
            local item0 = { id = 0,
                            qua = nil,
                            hero = nil,
                            wife = nil,
                            icon = nil,
                            count = nil,
                            node = UI.child(child, "Item/item0"),
                            gotten = state.free,
                            fun = nil }
            if v.type == 1 then
                if v.hero > 0 then
                    item0.qua = config.heroMap[v.hero].quality
                    item0.hero = v.hero
                    item0.fun = function()
                        UI.showHeroInfo(v.hero)
                    end
                elseif v.wife > 0 then
                    item0.qua = 5
                    item0.wife = v.wife
                    item0.fun = function()
                        UI.showWifeInfo(v.wife)
                    end
                else
                    UI.showHint("第" .. i .. "行配置不合理")
                end
            else
                item0.id = config.itemMap[v.item0[1]].id
                item0.qua = config.itemMap[v.item0[1]].quality
                item0.icon = config.itemMap[v.item0[1]].icon
                item0.count = v.item0[2]
                item0.fun = function()
                    UI.showItemInfo(v.item0[1])
                end
            end
            local item1 = { id = 0,
                            qua = nil,
                            hero = nil,
                            wife = nil,
                            icon = nil,
                            count = nil,
                            node = UI.child(child, "Item/item1"),
                            gotten = state.gold,
                            fun = nil }
            local item2 = { id = 0,
                            qua = nil,
                            hero = nil,
                            wife = nil,
                            icon = nil,
                            count = nil,
                            node = UI.child(child, "Item/item2"),
                            gotten = state.gold,
                            fun = nil }
            if v.type == 2 then
                if v.hero > 0 then
                    item1.qua = config.heroMap[v.hero].quality
                    item1.hero = v.hero
                    item1.fun = function()
                        UI.showHeroInfo(v.hero)
                    end
                elseif v.wife > 0 then
                    item1.qua = 5
                    item1.wife = v.wife
                    item1.fun = function()
                        UI.showWifeInfo(v.wife)
                    end
                else
                    UI.showHint("第" .. i .. "行配置不合理")
                end
                item2.id = config.itemMap[v.item[1]].id
                item2.qua = config.itemMap[v.item[1]].quality
                item2.icon = config.itemMap[v.item[1]].icon
                item2.count = v.item[2]
                item2.fun = function()
                    UI.showItemInfo(v.item[1])
                end
            else
                item1.id = config.itemMap[v.item[1]].id
                item1.qua = config.itemMap[v.item[1]].quality
                item1.icon = config.itemMap[v.item[1]].icon
                item1.count = v.item[2]
                item1.fun = function()
                    UI.showItemInfo(v.item[1])
                end
                item2.id = config.itemMap[v.item[3]].id
                item2.qua = config.itemMap[v.item[3]].quality
                item2.icon = config.itemMap[v.item[3]].icon
                item2.count = v.item[4]
                item2.fun = function()
                    UI.showItemInfo(v.item[3])
                end
            end

            local info = { Item = { Level = { level = v.id },
                                    item0 = item0,
                                    item1 = item1,
                                    item2 = item2 },
                           Btn = { Over = state.free and state.gold,
                                   Buy = (not state.gold) and
                                           { Text = ((not state.free) and "领取") or ((not state.gold) and "继续领取"),
                                             redDot = self.event403Info.warExp >= v.num and (not state.free or (self.event403Info.hasBuy and not state.gold)),
                                             fun = function()
                                                 if state.free and not self.event403Info.hasBuy then
                                                     UI.showHint("需要开通皇家战令")
                                                     return
                                                 end

                                                 if self.event403Info.warExp >= v.num then
                                                     message:send("C2S_Event403Receive", { id = v.id }, function(ret)
                                                         if self.hasClose then
                                                             return
                                                         end
                                                         log(ret)
                                                         if ret.code == "ok" then
                                                             if ret.hero > 0 then
                                                                 Story.show({ heroID = ret.hero, endFun = function()
                                                                     if ret.wife > 0 then
                                                                         Story.show({ wifeId = ret.wife, endFun = function()
                                                                             ItemTools.showItemsResult(ret.items)
                                                                         end })
                                                                     else
                                                                         ItemTools.showItemsResult(ret.items)
                                                                     end
                                                                 end })
                                                             elseif ret.wife > 0 then
                                                                 Story.show({ wifeId = ret.wife, endFun = function()
                                                                     ItemTools.showItemsResult(ret.items)
                                                                 end })
                                                             else
                                                                 ItemTools.showItemsResult(ret.items)
                                                             end
                                                         else
                                                             UI.showHint("领取失败")
                                                         end
                                                         self.event403Info = nil
                                                         self:showEvent403()
                                                         self:showRedDot()
                                                     end)
                                                 else
                                                     UI.showHint("经验不足")
                                                 end
                                             end
                                           } } }
            table.insert(Info, info)
            if self.event403Info.warExp >= v.num then
                UI.clearGray(child, "Btn/Buy")
            else
                UI.setGray(child, "Btn/Buy")
            end
            self:showEffect(item0.node, not state.free)
            self:showEffect(item1.node, not state.gold)
            self:showEffect(item2.node, not state.gold)
        end
        UI.draw(itemsNode, Info)

        local Top = { PayWay = { Over = self.event403Info.hasBuy,
                                 Text = "开通皇家战令获得更多奖励",
                                 Btn = (not self.event403Info.hasBuy) and {
                                     Buy = function()
                                         ComTools.charge(config["pay"][15], "recharge", 15, function()
                                             self.event403Info = nil
                                             self:showEvent403()
                                         end)
                                     end,
                                     Text = Tools.showChannelValue(1000) } },
                      OneKey = { Over = self.event403Info.hasBuy,
                          --(not self.event403Info.hasBuy) and
                                 Buy = function()
                                     if war.oneKey then
                                         message:send("C2S_Event403Receive", { id = 0 }, function(ret)
                                             if self.hasClose then
                                                 return
                                             end
                                             if ret.code == "ok" then
                                                 if ret.hero > 0 then
                                                     Story.show({ heroID = ret.hero, endFun = function()
                                                         if ret.wife > 0 then
                                                             Story.show({ wifeId = ret.wife, endFun = function()
                                                                 ItemTools.showItemsResult(ret.items)
                                                             end })
                                                         else
                                                             ItemTools.showItemsResult(ret.items)
                                                         end
                                                     end })
                                                 elseif ret.wife > 0 then
                                                     Story.show({ wifeId = ret.wife, endFun = function()
                                                         ItemTools.showItemsResult(ret.items)
                                                     end })
                                                 else
                                                     ItemTools.showItemsResult(ret.items)
                                                 end
                                             else
                                                 UI.showHint("领取失败")
                                             end
                                             self.event403Info = nil
                                             self:showEvent403()
                                             self:showRedDot()
                                         end)
                                     else
                                         UI.showHint("暂无奖励领取")
                                     end
                                 end },
                      Level = { Text = war.level },
                      NumCom = (self.event403Info.warExp >= cfg[#cfg].num and "max") or war.slider.value .. "/" .. war.slider.maxValue,
                      help = function()
                          local node = UI.showNode("Base/help")

                          UI.button(node, "BG/BtnBack", function()
                              UI.close(node)
                          end)
                          UI.text(node, "BG/S/V/C", Tools.getHelp("warmakes"))
                      end }
        if self.event403Info.warExp >= cfg[#cfg].num then
            war.slider.value = cfg[#cfg].num
        end
        UI.slider(node, "Top/slider", war.slider)
        log(war)

        local pos = UI.child(node, "Top/Anim/pos")
        local data = {}
        if war.hero > 0 then
            --UI.setLocalPosition(pos, cfg.pos[1], cfg.pos[2])
            local heroCfg = config.hero[war.hero]
            Top.name = war.hero + 100
            Top.grows = heroCfg.allGrows
            Top.charm = false
            if self.play then
                local animNode = UI.showNode(pos, "Anim/hero" .. war.hero)
                animNode.name = "anim"
                UI.playAnim(animNode, "idle")
                self.play = false
            end
        elseif war.wife > 0 then
            --UI.setLocalPosition(pos, cfg.pos[1], cfg.pos[2])
            local wifeCfg = config.wife[war.wife]
            Top.name = war.wife + 200
            Top.charm = wifeCfg.beauty
            Top.grows = false
            if self.play then
                local animNode = UI.showNode(pos, "Anim/wife" .. war.wife)
                animNode.name = "anim"
                UI.playAnim(animNode, "idle")
                self.play = false
            end
        end
        UI.draw(node, "Top", Top)
    end

    if self.event403Info then
        show()
    else
        message:send("C2S_Event403Open", {}, function(ret)
            if self.hasClose then
                return
            end
            log(ret)
            self.event403Info = ret
            show()
        end)
    end
end

function Class:getEvent403State(index)
    if self.event403Info then
        for i, v in ipairs(self.event403Info.states) do
            if i == index then
                return v
            end
        end
    end
    return false
end

return Class