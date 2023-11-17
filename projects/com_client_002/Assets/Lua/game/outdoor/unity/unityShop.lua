local cls = {
    res = "ui/unity_shop"
}

function cls:close()
    self.controller:close(self.controller.Pages.Shop)
end

function cls:init(params)
    self.controller = params.controller
    UI.button(self.node, "BtnClose", function()
        self:close()
    end)
    self.itemNode = self.node:Find("BG/S/V/C")
    UI.enableAll(self.node, false)

    message:send("C2S_ReqUnityShopInfo", {}, function(ret)
        if ret.code == "ok" then
            UI.enableAll(self.node, true)
            self.info = ret
            self:showShopInfo()
        else
            UI.showHint("联盟不存在!")
            self:close()
        end
    end)
end

function cls:showShopInfo()
    UI.text(self.node, "devote", self.info.devote)
    UI.cloneChild(self.itemNode, #self.info.item)
    for i, v in ipairs(self.info.item) do
        local child = UI.child(self.itemNode, i - 1)

        UI.enableAll(child, true)

        local cfg = config.allianceShopMap[i]

        local showItem = function()
            if self.info.level < cfg.level then
                UI.enable(child, "Lock", true)
                UI.text(child, "Lock/unityLevel", "联盟" .. cfg.level .. "级解锁购买")
            else
                UI.enable(child, "Lock", false)
            end

            local data = {
                icon = config.itemMap[v.id].icon,
                name = config.itemMap[v.id].name,
                limit = v.limit,
                devoteCost = cfg.devoteCost .. "贡献",
                fun = function()
                    UI.showItemInfo(v.id)
                end
            }

            UI.draw(child, "Item", data)

            if v.limit > 0 then
                UI.clearGray(child, "BtnBuy")
                UI.text(child, "BtnBuy/Text", "购 买")

            else
                UI.setGray(child, "BtnBuy")
                UI.text(child, "BtnBuy/Text", "售 馨")
                UI.button(child, "BtnBuy", function()
                    UI.showHint("今日购买次数使用完")
                end)
            end
        end

        showItem()

        UI.button(child, "BtnBuy", function()
            if self.info.devote < cfg.devoteCost then
                UI.showHint("个人贡献不足")
            else
                message:send("C2S_ReqBuyUnityItem", { id = i }, function(ret)
                    if ret.code == "ok" then
                        ItemTools.showItemResultById(v.id)
                        self.info.item[i].limit = self.info.item[i].limit - 1
                        self.info.devote = self.info.devote - cfg.devoteCost
                        UI.text(self.node, "devote", self.info.devote)
                        showItem()
                    elseif ret.code == "noDevote" then
                        UI.showHint("个人贡献不足")
                    elseif ret.code == "noLevel" then
                        UI.showHint("联盟等级不足")
                        showItem()
                    elseif ret.code == "noLimit" then
                        self.info.item[i].limit = 0
                        UI.showHint("今日购买次数使用完")
                        showItem()
                    elseif ret.code == "noUnity" then
                        UI.showHint("联盟不存在!")
                        self:close()
                    end
                end)
            end
        end)
    end
end

return cls