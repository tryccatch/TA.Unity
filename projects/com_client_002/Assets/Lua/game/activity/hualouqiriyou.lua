local Class = {
    res = "UI/hualouqiriyou"
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()
    self.hasClose = false
    UI.button(self.node, "BtnClose", function()
        self:closePage()
    end)

    local heroNode = UI.showNode(self.node, "Page/page2/Anim", "Anim/hero22")
    UI.playAnim(heroNode, "idle")

    local wifeNode = UI.showNode(self.node, "Page/page7/Anim", "Anim/wife4")
    UI.playAnim(wifeNode, "idle")

    self.itemsNode = self.node:Find("Bag")
    self.itemNode = self.node:Find("Bag/item")

    message:send("C2S_ReqSevenSignInfo", {}, function(ret)
        if self.hasClose then
            return
        end
        self.ret = ret
        self:showItemPage(7, ret)
        local count = 0
        for i = 1, 7 do
            count = count + 1
            if ret.day[i].shouldSign then
                self:showItemPage(i, ret)
                return
            end
        end

        if count == 7 then
            for i = 1, 7 do
                if ret.day[i].nextDaySign then
                    self:showItemPage(i, ret)
                    return
                end
            end
        end
    end)

    for i = 1, 7 do
        UI.button(self.node, "Day/Day" .. i .. "/BtnSign", function()
            self:showItemPage(i, self.ret)
        end)
    end


end

function Class:showItemPage(index, ret)
    UI.enableOne(self.node, "Page", index - 1);
    for i = 1, 7 do
        UI.enable(self.node, "Day/Day" .. i .. "/Select", false)
        if ret.day[i].signed then
            UI.enable(self.node, "Day/Day" .. i .. "/BtnSign/Signed", true)
        end
    end

    UI.enable(self.node, "Day/Day" .. index .. "/Select", true)

    --if #ret.day[index].item > 5 then
    --    self:cloneItem(10)
    --else
    --    self:cloneItem(5)
    --end
    local items = Tools.getOneEventItems(config.eventSevenMap[index])
    UI.cloneChild(self.itemsNode, #items, 2, self.itemNode)

    for i, v in ipairs(items) do
        local child = UI.child(self.itemsNode, i + 1)
        UI.enableAll(child, true)
        UI.draw(child, v)
    end

    if ret.day[index].signed then
        UI.enableOne(self.itemsNode, "Reward", 2)
    else
        UI.enableOne(self.itemsNode, "Reward", 0)
        if ret.day[index].canSign then
            UI.enable(self.itemsNode, "Reward/BtnGet/BtnLight", true)
            UI.button(self.itemsNode, "Reward/BtnGet", function()
                self:signSelectDay(index)
            end)
        else
            UI.enableOne(self.itemsNode, "Reward", 1)
            UI.setGray(self.itemsNode, "Reward/Btn")
            UI.enable(self.itemsNode, "Reward/BtnGet/BtnLight", false)
        end
    end

    if ret.day[index].nextDaySign then
        UI.enable(self.itemsNode, "Reward/nextSign", true)
    else
        UI.enable(self.itemsNode, "Reward/nextSign", false)
    end


end
function Class:signSelectDay(index)
    message:send("C2S_ReqSevenSign", { index = index }, function(ret)
        if self.hasClose then
            return
        end
        log(index)
        self.ret = ret
        self:showItemPage(index, ret)

        ItemTools.showItemsResult(Tools.getOneEventItems(config.eventSevenMap[index]))
        if index == 2 then
            Story.show({ heroID = 22, endFun = function()
                self:showItemPage(index, ret)
            end
            })
        end
        if index == 7 then
            Story.show({ wifeID = 4, endFun = function()
                self:showItemPage(index, ret)
            end
            })
        end
    end)
end

function Class:cloneItem(count)
    UI.cloneChild(self.itemsNode, count, 2, self.itemNode)
    for i = 1, count do
        local child = UI.child(self.itemsNode, i + 1)
        UI.enableAll(child, false)
    end
end

return Class