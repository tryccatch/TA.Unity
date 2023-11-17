local Class = {
    res = "ui/shop",
}

function Class:closePage(root)
    if (self.index and self.index == 2) or root then
        self.hasClose = true
        if self.hasClose then
            UI.close(self)
        end
    end
end

function Class:addRedDot(addOrRemove)
    local btnVip = UI.child(self.node, "Btn/3")
    if addOrRemove then
        RedDot.registerBtn(btnVip, RedDot.SystemID.ShopVipCanBuy, true)
    else
        RedDot.unregisterBtn(btnVip, RedDot.SystemID.ShopVipCanBuy)
    end
end

function Class:init(index)
    self.hasClose = false
    UI.button(self.node, "BtnBack", function()
        self:addRedDot(false)
        self:closePage(true)
    end)
    UI.enableAll(self.node, false)
    self.singleNode = self.node:Find("Page/P1/V/C")
    self.superNode = self.node:Find("Page/P2/V/C")
    self.vipNode = self.node:Find("Page/P3/V/C")

    UI.button(self.node, "Gold/BtnAdd", function()
        ComTools.openRecharge()
    end)

    if index == nil then
        index = 1;
    else
        self.index = index
    end
    --if client.user.level < 3 and index == 2 then
    --    index = 1
    --    UI.showHint("势力优惠礼包已结束")
    --end


    message:send("C2S_ReqShopItemInfo", {}, function(ret)
        if self.hasClose then
            return
        end
        if #ret.superItem == 0 and index == 2 then
            UI.showHint("势力优惠礼包已结束")
            self:closePage(true)
        else
            self:timeAck(ret.countDown)
        end
        UI.enableAll(self.node, true)
        self.singleItem = ret.singleItem
        self.superItem = ret.superItem
        self.vipItem = ret.vipItem
        self.vipLevel = client.user.vip
        self.gold = client.user.gold
        UI.enable(self.node, "Btn/2", #self.superItem > 0)
        --self.curIndex = index
        self:showPage(index)
    end)

    for i = 1, 3 do
        UI.button(self.node, "Btn/" .. i, function()
            if not UI.child(self.node, "Page/P" .. i).gameObject.activeSelf then
                self:showPage(i)
            end
        end)
    end

    self:addRedDot(true)
end

function Class:timeAck(value)
    if value > 0 then
        UI.txtUpdateTime(self.node, "Time", value / 1000, function()
            UI.enable(self.node, "Btn/2", false)
            UI.showHint("势力优惠礼包已结束")
            local node = UI.child(self.node, "Page/P2", true)
            if node.gameObject.activeSelf then
                self:showP1()
            end
        end)
    end
end
function Class:showPage(index)

    self.oldIndex = self.curIndex
    self.curIndex = index
    self:showSelect(index, self.oldIndex ~= index)
    UI.text(self.node, "Gold/gold", goldFormat(self.gold))
    UI.text(self.node, "Vip/vipLevel", self.vipLevel)

    if index == 1 then
        self:showP1(index)
        UI.refreshSVC(self.singleNode, self.oldIndex ~= index)
    elseif index == 2 then
        self:showP2(index)
        UI.refreshSVC(self.superNode, self.oldIndex ~= index)
    else
        self:showP3(index)
        UI.refreshSVC(self.vipNode, self.oldIndex ~= index)
    end
end

function Class:showP1(index)
    UI.cloneChild(self.singleNode, #self.singleItem)
    for i, v in ipairs(self:sortItems(self.singleItem)) do
        local child = UI.child(self.singleNode, i - 1)
        UI.enableAll(child, "Item", true)
        self:showEffect(child:Find("Item"), self.oldIndex ~= index)

        local item = {
            icon = config.itemMap[v.itemId].icon,
            name = config.itemMap[v.itemId].name,
            des = config.itemMap[v.itemId].description,
            goldPrice = v.goldPrice,
            limited = v.nowCount ~= 0 and "限购数：" .. v.nowCount or "",
            --count = 1,
        }
        UI.draw(child, "Item", item)

        UI.button(child, "Item", function()
            UI.showItemInfo(v.itemId)
        end)

        if v.limited ~= 0 and v.nowCount == 0 then
            UI.enableOne(child, "Btn", 0)
        else
            UI.enableOne(child, "Btn", 1)
            UI.button(child, "Btn/Buy", function()
                self:showBuyResult(v, 1)
            end)
        end
    end
end

function Class:showP2(index)
    UI.cloneChild(self.superNode, #self.superItem)
    for i, v in ipairs(self:sortItems(self.superItem)) do
        local child = UI.child(self.superNode, i - 1)

        local shop = {
            Name = { name = config.itemMap[v.itemId].name },
            GoldPrice = { goldPrice = v.goldPrice },
            limited = v.nowCount ~= 0 and "限购数：" .. v.nowCount or "",
        }

        UI.draw(child, shop)
        UI.cloneChild(child, #v.childItemId, 7, child:Find("Item"))
        for k, id in ipairs(v.childItemId) do
            local childItem = UI.child(child, k + 6)
            self:showEffect(childItem, self.oldIndex ~= index)

            local item = {
                icon = config.itemMap[id].icon,
                name = config.itemMap[id].name,
                count = v.count[k],
            }
            UI.draw(childItem, item)

            UI.button(childItem, function()
                UI.showItemInfo(id)
            end)
        end

        if v.limited ~= 0 and v.nowCount == 0 then
            UI.enableOne(child, "Btn", 0)
        else
            UI.enableOne(child, "Btn", 1)
            UI.button(child, "Btn/Buy", function()
                self:showBuyResult(v, 2)
            end)
        end
    end
    UI.refreshSVC(self.superNode, nil, true, true)
end

function Class:showP3(index)
    UI.cloneChild(self.vipNode, #self.vipItem)
    for i, v in ipairs(self:sortItems(self.vipItem)) do
        local child = UI.child(self.vipNode, i - 1)
        self:showEffect(child:Find("Item"), self.oldIndex ~= index)

        local item = {
            icon = config.itemMap[v.itemId].icon,
            name = config.itemMap[v.itemId].name,
            des = config.itemMap[v.itemId].description,
            goldPrice = v.goldPrice,
            limited = v.nowCount ~= 0 and "限购数：" .. v.nowCount or "",
            vipLevel = v.vipLevel,
        }
        UI.draw(child, "Item", item)

        UI.button(child, "Item", function()
            UI.showItemInfo(v.itemId)
        end)

        if v.limited ~= 0 and v.nowCount == 0 then
            UI.enableOne(child, "Btn", 0)
        else
            UI.enableOne(child, "Btn", 1)
            UI.button(child, "Btn/Buy", function()
                if self.vipLevel >= v.vipLevel then
                    self:showBuyResult(v, 4)
                else
                    UI.showHint("vip" .. v.vipLevel .. "可购买")
                end
            end)
        end
    end
end

function Class:showBuyResult(shop, type)
    if shop.nowCount > 0 or shop.limited == 0 then
        if self.gold >= shop.goldPrice then
            message:send("C2S_ReqBuyItem", { type = type, id = shop.id }, function(ret)
                if self.hasClose then
                    return
                end
                if ret.code == "ok" then
                    self.gold = ret.gold
                    self.count = ret.limited
                    self:showPage(self.curIndex)
                    if type == 2 then
                        local time = 0
                        for k, id in ipairs(shop.childItemId) do
                            UI.delay(self.node, time, function()
                                ItemTools.showItemResult({ icon = config.itemMap[id].icon,
                                                           name = config.itemMap[id].name,
                                                           count = shop.count[k], })
                            end)
                            time = time + 0.5
                        end
                    else
                        ItemTools.showItemResult({ icon = config.itemMap[shop.itemId].icon,
                                                   name = config.itemMap[shop.itemId].name,
                                                   count = 1 })
                    end
                elseif ret.code == "noEvent" then
                    UI.showHint("势力优惠礼包已结束")
                    self:closePage(true)
                else
                    UI.showHint("购买失败")
                end
            end)
        else
            self:showTips()
        end
    else
        UI.showHint("购买数量已用完")
    end
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

function Class:showEffect(node, value)
    if value then
        if node:Find("effect") == nil then
            UI.showNode(node, "Effect/itemEffect").name = "effect"
        end
    end
end

function Class:showSelect(index, value)
    if value then
        UI.enableOne(self.node, "Page", index - 1)
    end
    for i = 1, 3 do
        UI.enable(self.node, "Btn/" .. i .. "/Selected", false)
    end
    UI.enable(self.node, "Btn/" .. index .. "/Selected", true)
end

function Class:sortItems(items)

    local newItems = {}
    local count = 0
    for i, v in ipairs(items) do
        if v.limited > 0 then
            if self.count and self.oldIndex == self.curIndex then
                v.nowCount = self.count[i]
            end
            if v.nowCount == 0 then
                table.insert(newItems, #newItems + 1, v)
                count = count + 1
            else
                table.insert(newItems, i - count, v)
            end
        else
            table.insert(newItems, i - count, v)
        end
    end

    return newItems
end

function Class:onFront()
    self.gold = client.user.gold
    self.vipLevel = client.user.vip
    self:showPage(self.curIndex)
end

return Class