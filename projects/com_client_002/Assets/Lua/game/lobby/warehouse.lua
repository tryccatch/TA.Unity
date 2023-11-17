local Class = {
    res = "UI/warehouse"
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()
    self.hasClose = false

    UI.enable(self.node, "SelectHero", false)
    UI.enable(self.node, "HeroResult", false)
    UI.enable(self.node, "Rename", false)
    UI.enable(self.node, "Maker", false)

    UI.button(self.node, "Base/BtnBack", function()
        self:closePage()
    end)

    local tabNode = UI.child(self.node, "Tab")

    local page = 0
    local selectPage = function(value)
        if page == value then
            return
        end
        page = value

        for i = 1, 3 do
            local child = UI.child(tabNode, i - 1)
            UI.enable(child, "Image", page == i)
            UI.enable(self.node, "Page/Page" .. i, page == i)
        end
    end

    for i = 1, 3 do
        UI.button(tabNode, i - 1, function()
            selectPage(i)
        end)
    end

    selectPage(1)

    self:showSelectedItem(nil)

    message:send("C2S_getWareHousetems", {}, function(ret)
        if self.hasClose then
            return
        end
        self.datas = ret
        self:sortItem(self.datas.items)
        self:show()

        local selectdNode = UI.child(self.node, "Page/Page3/Node/selected")
        local clothNode = UI.child(self.node, "Page/Page3/Node")
        local infoNode = UI.child(self.node, "Page/Page3/Info")
        local data = {}

        local hasClothes = { false, false, false, false }

        for i, v in ipairs(ret.clothes) do
            hasClothes[v.id - 80] = true
        end

        for i, v in ipairs(hasClothes) do
            data[i] = {
                body = i,
                head = client.user.head,
                name = config.royal[i].name,
                used = client.user.curCloth == i,
            }

            local child = UI.child(clothNode, i - 1)

            if not v then
                UI.setGray(child)
            end

            UI.button(child, function()
                UI.enableAll(infoNode, true)
                UI.enable(selectdNode, true)
                selectdNode.localPosition = child.localPosition

                local cfg = config.itemMap[i + 80]

                local info = {
                    btnUsed = false,
                    btnRemove = false,
                    path = cfg.description,
                    time = "未获得",
                }

                if v then
                    info.time = "到下次" .. data[i].name .. "产生之前"
                end

                info.btnUsed = function()
                    if v and client.user.curCloth ~= i then
                        if client.user.curCloth > 0 then
                            data[client.user.curCloth].used = false
                        end

                        data[i].used = true
                        UI.draw(clothNode, data)

                        info.btnUsed = false
                        info.btnRemove = true
                        UI.draw(infoNode, info)
                        UI.enable(selectdNode, true)

                        message:send("C2S_setCurCloth", { index = i })

                    end
                end

                info.btnRemove = function()
                    if v and client.user.curCloth == i then
                        if client.user.curCloth > 0 then
                            data[client.user.curCloth].used = false
                        end
                        info.btnUsed = true
                        info.btnRemove = false
                        data.used = false
                        UI.draw(clothNode, data)
                        UI.draw(infoNode, info)
                        UI.enable(selectdNode, true)
                        message:send("C2S_setCurCloth", { index = 0 })
                    end
                end

                UI.draw(infoNode, info)

                UI.enable(infoNode, "btnUsed", v and client.user.curCloth ~= i)
                UI.enable(infoNode, "btnRemove", v and client.user.curCloth == i)
            end)
        end

        UI.draw(clothNode, data)

        UI.enableAll(infoNode, false)
        UI.enable(selectdNode, false)

    end)

end

function Class:sortItem(datas)
    local fun = function(a, b)
        return a.id < b.id
    end
    table.sort(datas, fun)
end

function Class:show()
    local itemsNode = UI.child(self.node, "Page/Page1/S/V/C")
    if itemsNode.childCount <= 1 then
        if self.selectedItemNode then
            self.selectedItemNode.parent = UI.child(self.node, "Page/Page1")
            UI.enable(self.selectedItemNode, false)
            self.selectedItemNode = nil
        end
    end

    UI.cloneChild(itemsNode, #self.datas.items)

    for i, v in ipairs(self.datas.items) do
        local cfg = config.itemMap[v.id]
        local child = UI.child(itemsNode, i - 1)
        local count = v.count > 999 and "999+" or v.count
        UI.text(child, "Count", count)
        UI.image(child, "Icon", "Item", "item" .. cfg.icon)

        if self.selectedItem and v.id == self.selectedItem.id then
            self:showSelectedItem(i, v)
        end

        UI.button(child, function()
            self:showSelectedItem(i, v)
        end)
    end

    UI.enable(self.node, "Page/Page1/noInfo", #self.datas.items == 0)

    local itemsNode = UI.child(self.node, "Page/Page2")

    for i = 1, 5 do
        local child = UI.child(itemsNode, i - 1)

        for n = 1, 3 do
            local index = (i - 1) * 3 + n
            local data = self.datas.promotion[index]
            local cfg = config.itemMap[data.item.id]

            local childItem = UI.child(child, "Node" .. n)
            UI.image(childItem, "Icon", "Item", "item" .. cfg.icon)

            if data.item.count <= 0 then
                UI.text(childItem, "Count", "")
                UI.setGray(childItem)
                UI.clearGray(childItem, "Btn")
            else
                UI.text(childItem, "Count", data.item.count)
                UI.clearGray(childItem)
            end

            if data.upNeedCount > 0 then
                UI.button(childItem, "Btn", function()
                    self:showMaker(data)
                end)
            else
                UI.enable(childItem, "Btn", false)
            end

            UI.button(childItem, "Icon", function()
                UI.showItemInfo(data.item.id)
            end)
        end
    end
end

function Class:showMaker(data)
    local node = UI.child(self.node, "Maker")

    UI.enable(node, true)

    UI.button(node, "BtnBack", function()
        UI.enable(node, false)
    end)

    local cfg = config.itemMap[data.item.id]

    UI.text(node, "Name", cfg.name)
    UI.text(node, "Hint", cfg.description)

    UI.image(node, "Item1/Image", "Item", "item" .. data.item.id)

    for _, v in ipairs(self.datas.promotion) do
        if v.item.id == data.upFromItemId then
            UI.image(node, "Item2/Image", "Item", "item" .. v.item.id)
            UI.text(node, "Need", v.item.count .. "/" .. data.upNeedCount)
        end
    end

    UI.button(node, "BtnMake", function()
        message:send("C2S_makeItem", { id = data.item.id }, function(ret)
            if self.hasClose then
                return
            end
            if ret.succeed then

                for _, v in ipairs(self.datas.promotion) do
                    if v.item.id == data.upFromItemId then
                        v.item.count = v.item.count - data.upNeedCount
                    end
                end

                data.item.count = data.item.count + 1

                self:show()
                UI.showHint("合成成功")
                UI.enable(node, false)
            else
                UI.showHint("材料不够")
            end
        end)
    end)
end

local nameLimitMax = 8
local nameLimitMin = 2

function Class:showSelectedItem(index, item)
    self.selectedItem = item

    if not self.selectedItemNode then
        self.selectedItemNode = UI.child(self.node, "Page/Page1/Selected")
    end
    local itemInfo = UI.child(self.node, "Page/Page1/Info")

    if not item then
        UI.enableAll(itemInfo, false)
        UI.enable(self.selectedItemNode, false)
        return
    end

    UI.enable(self.selectedItemNode, true)
    local itemsNode = UI.child(self.node, "Page/Page1/S/V/C")
    self.selectedItemNode.parent = UI.child(itemsNode, index - 1)
    UI.setLocalPosition(self.selectedItemNode, 0, 0, 0)

    UI.enableAll(itemInfo, true)

    local cfg = config.itemMap[item.id]
    local name = "<color=#" .. ColorQua[cfg.quality] .. ">" .. cfg.name .. "</color>"
    UI.text(itemInfo, "Count", item.count)
    UI.text(itemInfo, "Name", name)
    UI.text(itemInfo, "Hint", cfg.description)
    UI.image(itemInfo, "Image/Icon", "Item", "item" .. cfg.icon)

    UI.enable(itemInfo, "BtnUsed", item.canUsed)
    if item.canUsed then
        UI.button(itemInfo, "BtnUsed", function()

            if item.type == 18 then
                UI.enable(self.node, "Rename", true)
                UI.text(self.node, "Rename/Name", "")

                local input = UI.component(self.node, "Rename/Name", typeof(CS.UnityEngine.UI.InputField))
                if input then
                    input.onValueChanged:AddListener(function(value)
                        local v = Tools.removeSymbolInString(value)
                        local len = Tools.getStrLenAsOne(v)
                        if len > nameLimitMax then
                            v = Tools.subStringAsOne(v, nameLimitMax)
                        end
                        input.text = v
                    end)
                end

                UI.button(self.node, "Rename/BtnNo", function()
                    UI.enable(self.node, "Rename", false)
                end)
                UI.button(self.node, "Rename/BtnClose", function()
                    UI.enable(self.node, "Rename", false)
                end)
                UI.button(self.node, "Rename/BtnYes", function()
                    self:rename(item)
                end)
                return
            end

            if item.type == 20 then
                self:usedItem(item.id, 1, function()
                    UI.show("game.other.createPlayer", "changeFace")
                end)
                return
            end

            if item.effectType > 0 then
                self:selectedHero(item, function(heroId)
                    if item.count == 0 then
                        UI.showHint("物品已经使用完")
                    elseif item.count >= 5 then
                        self:showUsedItem(item, heroId)
                    else
                        self:usedItem(item.id, 1, heroId)
                    end
                end)
            else
                if item.count >= 5 then
                    self:showUsedItem(item)
                else
                    self:usedItem(item.id, 1)
                end
            end
        end)
    end
end

function Class:rename(item)
    local name = UI.getValue(self.node, "Rename/Name")
    local result, a, sensitiveWord = Tools.sensitiveCheck(name)
    if result then
        UI.showHint("名字内包含敏感字符")
        return
    end

    if Tools.getStrLenAsOne(name) < nameLimitMin then
        UI.showHint("请输入2-8个字符")
        return
    end
    message:send("C2S_rename", { name = name }, function(ret)
        if self.hasClose then
            return
        end
        if ret.succeed then
            client.user.name = name
            UI.enable(self.node, "Rename", false)

            UI.msgBox("修改名字成功")

            item.count = item.count - 1

            if item.count <= 0 then
                for i, v in ipairs(self.datas.items) do
                    if v.id == item.id then
                        table.remove(self.datas.items, i)
                        self:showSelectedItem(nil)
                        break
                    end
                end
            end
            self:show()
        else
            UI.msgBox(ret.error)
        end
    end)
end

function Class:selectedHero(item, fun)
    if self.itemHeros then
        self:showSelectedHero(item, fun)
    else
        message:send("C2S_itemHeros", {}, function(ret)
            if self.hasClose then
                return
            end
            self.itemHeros = ret.heros
            self:showSelectedHero(item, fun)
        end)
    end
end

function Class:showSelectedHero(item, fun)
    local node = UI.child(self.node, "SelectHero")
    UI.enable(node, item.count > 0)
    if item.count <= 0 then
        return
    end

    local cfg = config.itemMap[item.id]

    UI.text(node, "Item/Name", cfg.name)
    UI.text(node, "Item/Count", item.count)

    UI.button(node, "BtnBack", function()
        UI.enable(node, false)
    end)

    local nodeHeros = UI.child(node, "S/V/C")

    UI.cloneChild(nodeHeros, #self.itemHeros)
    table.sort(self.itemHeros, function(a, b)
        if a.level == b.level then
            return a.id < b.id
        end
        return a.level > b.level
    end)
    for i, v in ipairs(self.itemHeros) do
        local child = UI.child(nodeHeros, i - 1)

        local cfg = config.heroMap[v.id]
        local heroName = cfg.name
        if v.id == 1 then
            heroName = client.user.name
        end

        UI.text(child, "name", heroName)
        UI.text(child, "level", v.level)
        UI.text(child, "allAttribute", v.allAttribute)

        HeroTools.setCHeadSprite(child, "icon", v.id)

        local typeName = HeroTools.getSpecialtyName(v.specialty)

        UI.text(child, "type", typeName)

        if fun then
            UI.button(child, "BtnUse", function()
                fun(v.id)
            end)
        end
    end
end

function Class:updateHeroAttr(id, value)
    if self.itemHeros then
        for _, v in ipairs(self.itemHeros) do
            if v.id == id then
                v.allAttribute = v.allAttribute + value
            end
        end
    end
end

function Class:showUsedItem(ret, heroId)
    local node = UI.showNode("Base/UsedItem1")

    local cfg = config.itemMap[ret.id]

    UI.text(node, "Name", cfg.name)
    UI.text(node, "Hint", cfg.description)

    UI.image(node, "Icon", "Item", "item" .. cfg.icon)

    local count = 1
    local maxCount = ret.count > 99 and 99 or ret.count
    local showCount = function()
        UI.text(node, "Count", count .. "/" .. maxCount)
    end

    UI.button(node, "BtnClose", function()
        UI.close(node)
    end)

    local onChangeValue = function(value)
        count = value
        showCount()
    end

    UI.slider(node, "usedCount", { minValue = 1, maxValue = maxCount, value = 1, fun = onChangeValue })

    UI.button(node, "BtnYes", function()
        self:usedItem(ret.id, count, heroId, function()
            UI.close(node)
            --[[            maxCount = maxCount - count
                        maxCount = ret.count > 99 and 99 or ret.count
                        if maxCount > 0 then
                            log(ret.count)
                            UI.text(node, "Count", "1/" .. maxCount)
                            UI.slider(node, "usedCount", { minValue = 1, maxValue = maxCount, value = 1, fun = onChangeValue })
                        else
                            UI.close(node)
                        end]]
        end)
    end)

    UI.button(node, "BtnAdd", function()
        UI.slider(node, "usedCount", { value = count + 1 })
    end)

    UI.button(node, "BtnDec", function()
        UI.slider(node, "usedCount", { value = count - 1 })
    end)

    showCount()
end

function Class:usedItem(id, count, heroId, fun)
    local msg = { id = id, count = count }

    if type(heroId) == "function" then
        fun = heroId
        heroId = nil
    end

    local heroInfo = nil
    if heroId then
        msg.des = heroId
        for _, hero in ipairs(self.itemHeros) do
            if hero.id == heroId then
                heroInfo = hero
            end
        end
    end

    message:send("C2S_usedItem", msg, function(ret)
        if self.hasClose then
            return
        end
        log("++++++++++++++++++++++++++")
        log(ret)
        if ret.succeed then
            local hasHero = false
            for i, v in ipairs(ret.result) do
                if v.hero ~= nil then
                    hasHero = true

                    local node = UI.child(self.node, "HeroResult")
                    local str = "共使用" .. count .. "个"
                    if v.type == "skillEXP" then
                        str = str .. "技能经验书"
                    else
                        str = str .. "资质经验书"
                    end

                    UI.text(node, 0, str)

                    break
                end
            end

            if hasHero then
                local node = UI.child(self.node, "HeroResult")
                UI.enable(node, true)
                UI.button(node, function()
                    UI.enable(node, false)
                end)
                local node = UI.child(node, "S/V/C")
                table.sort(ret.result, function(a, b)
                    return a.hero.id < b.hero.id
                end)
                UI.cloneChild(node, #ret.result)
                for i, v in ipairs(ret.result) do
                    local child = UI.child(node, i - 1)
                    UI.text(child, "Name", v.hero.name)
                    HeroTools.setHeadSprite(child, "Icon", v.hero.id)
                    if v.hero.id == 1 then
                        local meHead = UI.child(child, "Icon/the_me_node", true)
                        if meHead then
                            local trans = UI.component2(meHead, typeof(CS.UnityEngine.RectTransform))
                            if trans then
                                trans.sizeDelta = CS.UnityEngine.Vector2(160, 218)
                            end
                        end
                    end
                    local str = "+" .. v.value
                    if v.type == "skillEXP" then
                        str = "技能经验" .. str
                    else
                        str = "资质经验" .. str
                    end
                    UI.text(child, "Value", str)
                end
            else
                for i, v in ipairs(ret.result) do
                    if v.type == "politics" or v.type == "charm" or v.type == "wisdom" or v.type == "strength" then
                        if heroInfo then
                            heroInfo.allAttribute = heroInfo.allAttribute + v.value
                        end
                    end
                end
            end

            for i, v in ipairs(self.datas.items) do
                if v.id == id then
                    v.count = v.count - count

                    if v.count <= 0 then
                        table.remove(self.datas.items, i)
                        self:showSelectedItem(nil)

                        if heroId then
                            --UI.enable(self.node,"SelectHero",false)
                            self:showSelectedHero(v)
                        end
                    else
                        --self:showSelectedItem(i, self.selectedItem)
                        if heroId then
                            self:showSelectedHero(v)
                        end
                    end
                    self:show()
                    break
                end
            end

            local needUpdate = false
            for _, r in ipairs(ret.result) do
                if r.type == "item" then
                    local found = false
                    for i, v in ipairs(self.datas.items) do
                        if v.id == r.item.id then
                            v.count = v.count + r.value
                            found = true
                            break
                        end
                    end

                    if r.item.type == 9 then
                        for i, v in ipairs(self.datas.promotion) do
                            if v.item.id == r.item.id then
                                v.item.count = v.item.count + r.value
                                found = true
                                break
                            end
                        end
                    end

                    if not found then
                        r.item.count = r.item.count + r.value-1
                        table.insert(self.datas.items, r.item)
                        self:sortItem(self.datas.items)
                    end
                    needUpdate = true
                end
            end

            if self:checkIsPrisonerItem(id) then
                Story.show({
                    storyID = config.itemMap[id].story,
                    endFun = function()
                        UI.ShowCatchPrisoner(config.itemMap[id].prisoner);
                    end
                })
                needUpdate = true
            end

            if needUpdate then
                self:show()
            end

            ItemTools.onItemResult(ret.result)
            ItemTools.onItemResultDis(ret.result, nil, heroInfo)
            if fun then
                fun()
            end
        else
            for i, v in ipairs(ret.result) do
                if v.type == "prisoner" then
                    UI.showHint("您已获得该犯人")
                    for i, v in ipairs(self.datas.items) do
                        if v.id == id then
                            v.count = v.count - count

                            if v.count <= 0 then
                                table.remove(self.datas.items, i)
                                self:showSelectedItem(nil)

                                if heroId then
                                    --UI.enable(self.node,"SelectHero",false)
                                    self:showSelectedHero(v)
                                end
                            else
                                self:showSelectedItem(i, self.selectedItem)
                                if heroId then
                                    self:showSelectedHero(v)
                                end
                            end
                            self:show()
                            break
                        end
                    end
                    break ;
                end
            end
        end
    end)
end

function Class:checkIsPrisonerItem(id)
    local cfg = config.itemMap[id]
    if cfg.type == 57 then
        return true
    end
    --local n1 = id >= 110 and id <= 120
    --local n2 = id >= 140 and id <= 152
    --return n1 or n2
end

return Class