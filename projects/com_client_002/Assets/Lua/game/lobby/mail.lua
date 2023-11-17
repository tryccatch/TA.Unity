local Class = {
    res = "ui/email",
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()
    self.hasClose = false

    UI.enable(self.node, "Detail", false)
    UI.enable(self.node, "emails", false)
    UI.enable(self.node, "noEmail", false)
    self:updateEmailList()
    UI.button(self.node, "BtnBack", function()
        self:closePage()
    end)

    UI.button(self.node, "Detail/sure", function()
        UI.enable(self.node, "Detail", false)
        self:updateEmailList()
    end)
    -- local fresh = false
    -- UI.dragBottom(emailNode,function()  
    --     log("dragBottom")     
    --     if fresh then
    --         return
    --     end

    --     fresh = true
    --     UI.addFresh(emailNode)
    --     message:send("C2S_getEmail",{},function(ret)
    --         UI.delFresh(emailNode)
    --         UI.drawAppend(emailNode,self.info.emails,ret.emails) 
    --         fresh = false
    --     end)
    -- end)

    UI.enable(self.node, "Detail", false)
end

function Class:updateEmailList()
    local emailNode = UI.child(self.node, "emails/V/C")

    message:send("C2S_getEmail", {}, function(ret)
        if self.hasClose then
            return
        end
        ret.noEmail = #ret.emails == 0

        UI.enable(self.node, "emails", true)
        self.info = ret
        UI.draw(self.node, self.info)

        for i = 1, #ret.emails do
            local child = emailNode:GetChild(i - 1)
            if ret.emails[i].hasRead then
                UI.setGray(child, "hasItem")
                UI.setGray(child, "background")
            else
                UI.clearGray(child, "hasItem")
                UI.clearGray(child, "background")
            end
        end

        for i, v in ipairs(ret.emails) do
            local child = UI.child(emailNode, i - 1)
            UI.button(child, function()
                message:send("C2S_getEmailDetail", { id = v.id, time = v.time }, function(ret)
                    if self.hasClose then
                        return
                    end
                    mergeTable(v, ret)
                    if not v.hasItem then
                        v.hasRead = true
                        UI.draw(self.node, self.info)
                    end
                    self:showDetail(v)
                end)
            end)
        end
    end)
end

function Class:showDetail(data)
    local node = UI.child(self.node, "Detail")
    UI.enable(node, true)

    UI.button(node, "BtnBack", function()
        UI.enable(node, false)
        self:updateEmailList()
    end)

    data.canGot = data.hasItem and (not data.hasRead)
    data.hasGot = data.hasItem and data.hasRead

    UI.button(node, "canGot", function()
        message:send("C2S_gotEmailItems", { id = data.id, time = data.time }, function(ret)
            if self.hasClose then
                return
            end
            if ret.success then
                data.canGot = false
                data.hasGot = true
                data.hasRead = true

                UI.draw(node, data)
                UI.draw(self.node, self.info)

                UI.setGray(node, "list/items/V/C")
                ItemTools.addItemsDis(data.items)
                self:updateEmailList()
            end
        end)
    end)

    local itemsNode = UI.child(node, "list/items/V/C")
    UI.cloneChild(itemsNode, #data.items)
    for i, v in ipairs(data.items) do
        local cfg = config.itemMap[v.id]
        local child = UI.child(itemsNode, i - 1)

        v.count = goldFormatNotDot(v.count)
        v.icon = cfg.icon
        UI.button(child, function()
            local itemNode = UI.show("Base/ItemInfo")
            UI.text(itemNode, "name", cfg.name)
            UI.text(itemNode, "des", cfg.description)
            UI.image(itemNode, "icon", "Item", cfg.icon)
            UI.button(itemNode, "BtnClose", function()
                UI.close(itemNode)
            end)
        end)
        UI.text(child, "count", v.count)
        UI.image(child, "icon", "Item", cfg.icon)
    end

    UI.draw(node, data)
    if data.canGot then
        UI.clearGray(node, "list/items/V/C")
    else
        UI.setGray(node, "list/items/V/C")
    end

    UI.enable(node, "list/items", data.hasItem)
    UI.enable(node, "sure", not data.hasItem)

    local rectTransform = UI.component(node, "text", typeof(CS.UnityEngine.RectTransform))
    if rectTransform then
        local width = 236
        if not data.hasItem then
            width = 350
        end
        rectTransform.sizeDelta = CS.UnityEngine.Vector2(544, width)
    end
end

return Class