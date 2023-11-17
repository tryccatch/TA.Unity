local Class = {
    res = "ui/Industry",
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()
    self.hasClose = false

    self.valueNode = UI.child(self.node, "Main/Type/Value")
    self.typeNode = UI.child(self.node, "Main/Type")
    self.oneKeyNode = UI.child(self.node, "Main/Bottom/CheckOne")
    self.heroesNode = UI.child(self.node, "Hero/S/V/C")
    self.curHeroNode = UI.child(self.node, "Hero/CurHero/node")
    self.icon = {}
    self.count = {}
    self.point = {}

    self.fullStr = "999999999999+"
    UI.enableOne(self.node, 0)

    message:send("C2S_ReqIndustryInfo", {}, function(ret)
        if self.hasClose then
            return
        end
        self.type = ret.type
        self:showMain()
        self:button()
    end)
end

function Class:button()
    UI.button(self.node, "Main/BtnHelp", function()
        self:showHelp()
    end)
    UI.button(self.node, "Main/BtnClose", function()
        self:closePage()
    end)
    UI.button(self.node, "Hero/BtnBack", function()
        UI.enable(self.node, "Hero", false)
    end)

    for i = 1, 5 do
        UI.button(self.node, "Hero/Btn/" .. i, function()
            self:showHero(i)
        end)
    end

    for i = 1, 3 do
        UI.button(self.node, "Main/Type/" .. i .. "/Btn/collect", function()
            self:collectAck(i)
        end)

        UI.button(self.node, "Main/Type/" .. i .. "/Btn/wait", function()
            log("道具" .. i)
            ItemTools.used(8, { minCount = 1, maxCount = self.type[i].times.maxValue }, function(ret)
                self:update(i)
            end, i)
        end)
    end

    UI.button(self.oneKeyNode, "Box", function()
        CS.UnityEngine.PlayerPrefs.SetInt("industryOneKey", CS.UnityEngine.PlayerPrefs.GetInt("industryOneKey", 0) > 0 and 0 or 1)
        UI.enable(self.oneKeyNode, "Box/Check", CS.UnityEngine.PlayerPrefs.GetInt("industryOneKey", 0) > 0)
    end)
end

function Class:showMain()
    local node = UI.child(self.node, "Main")
    for i, v in ipairs(self.type) do
        local valueChild = UI.child(self.valueNode, i - 1)

        self.icon[i] = UI.child(valueChild, 0)
        self.count[i] = UI.child(valueChild, 1)
        self.point[i] = UI.child(valueChild, 2)

        UI.text(self.count[i], self:checkLen(v.count))
        UI.enable(self.count[i], true)

        self.type[i].node = UI.child(self.typeNode, i - 1)

        self.type[i].cost = v.base + v.hero
        UI.draw(self.type[i].node, "Reward", self.type[i])

        self:countDown(i)

        local Head = UI.child(self.type[i].node, "Line/Head")
        UI.cloneChild(Head, #v.heroId)

        for j, k in ipairs(v.heroId) do
            local child = UI.child(Head, j - 1)
            if k > 0 then
                UI.enableOne(child, 2)
                UI.draw(child, { head = k })

                if k == 1 then
                    UI.setLocalScale(child:Find("head"), 0.8, 0.71, 0.8)
                else
                    UI.setLocalScale(child:Find("head"), 1, 1, 1)
                end

            else
                if client.user.level >= j and (i == 1 or client.user.level ~= 1) then
                    UI.enableOne(child, 1)
                else
                    UI.enableOne(child, 0)
                end
            end

            UI.button(child, function()
                if client.user.level >= j and (i == 1 or client.user.level ~= 1) then
                    UI.enable(self.node, "Hero", true)
                    self.seatIndex = 5 * (i - 1) + j
                    self.curHeroId = k
                    self:showHero(i)
                else
                    UI.showHint(config.levelMap[j > 2 and j or 2].name .. "解锁槽位")
                end
            end)
        end

        UI.enableOne(self.oneKeyNode, client.user.level > 3 and 0 or 1)
        if client.user.level > 3 then
            UI.enable(self.oneKeyNode, "Box/Check", CS.UnityEngine.PlayerPrefs.GetInt("industryOneKey", 0) > 0)
        end
    end
    log(self)
end

function Class:collectAck(index)
    local count = 1

    if index == 3 then
        if self.type[3].cost > self.type[2].count then
            UI.showHint("粮草不足")
            return
        end
    end

    if client.user.level > 3 and CS.UnityEngine.PlayerPrefs.GetInt("industryOneKey", 0) > 0 then
        if index == 3 then
            count = self.type[3].cost * self.type[3].times.value > self.type[2].count and
                    math.floor(self.type[2].count / self.type[3].cost) or
                    self.type[3].times.value
        else
            count = self.type[index].times.value
        end
    end

    local addAnim = function(ten)
        math.randomseed(tostring(os.time()):reverse():sub(1, 7))
        local times = 3
        if self.type[3].cost * count > 20000 then
            times = string.len(self.type[3].cost * count) + math.random(1, 3)
        else
            times = math.random(5, 10)
        end

        if ten then
            times = times + 10
        end

        for i = 1, times do
            local posX = math.random(200 - 210 * index, 800 - 210 * index)
            local posY = math.random(140 - 360 * index, 200 - 360 * index)
            --log(posX .. "+" .. posY)
            local add = UI.clone(self.icon[index])
            add.parent = self.point[index]
            add.name = i
            UI.setLocalScale(add, 1, 1, 0)
            UI.setLocalPosition(add, posX, posY, 0)
            UI.delay(self.node, 0.1, function()
                UI.tweenList(add, {
                    {
                        type = "offset",
                        pos = {
                            x = -posX,
                            y = -posY - index * 360 + 240,
                            z = 0,
                        },
                        time = i * (1 / times),
                    },
                    {
                        type = "offset",
                        pos = {
                            x = 0,
                            y = index * 360 - 240,
                            z = 0,
                        },
                        time = i * (1 / times),
                    },
                    {
                        time = 0,
                        fun = function()
                            if IsNum(UI.getValueInt(self.count[index])) and UI.getValueInt(self.count[index]) < self.type[index].count then
                                UI.text(self.count[index], UI.getValueInt(self.count[index]) + math.floor(self.type[index].cost / times))
                            end
                            if index == 3 then
                                if IsNum(UI.getValueInt(self.count[2])) and UI.getValueInt(self.count[2]) > self.type[2].count then
                                    UI.text(self.count[2], UI.getValueInt(self.count[2]) - math.floor(self.type[3].cost / times))
                                end
                            end
                        end
                    },
                    {
                        type = "delete",
                    }
                })

                if i == times then
                    for j = 1, count do
                        UI.delay(self.node, 2 + 0.1 * (index + j - count), function()
                            local valueNode = UI.clone(self.count[index])
                            valueNode.name = "addValue"
                            UI.setLocalPosition(valueNode, nil, -60, 0)
                            local Value = "+" .. self.type[index].cost
                            UI.text(valueNode, "<color=white>" .. Value .. "</color>")
                            local node = UI.clone(self.icon[index])
                            node.parent = valueNode
                            node.name = j
                            UI.setLocalScale(node, 1, 1, 0)
                            UI.setLocalPosition(node, -13 * string.len(Value), 0, 0)
                            UI.tweenList(valueNode, {
                                {
                                    type = "offset",
                                    pos = {
                                        x = 0,
                                        y = 90,
                                        z = 0,
                                    },
                                    time = 0.3,
                                },
                                {
                                    time = 0,
                                    fun = function()
                                        if j == count then
                                            if IsNum(UI.getValueInt(self.count[index])) then
                                                UI.text(self.count[index], self.type[index].count)
                                            end
                                            if index == 3 then
                                                if string.len(self.type[2].count) <= 12 then
                                                    UI.text(self.count[2], self.type[2].count)
                                                end
                                                if IsNum(UI.getValueInt(self.count[2])) and UI.getValueInt(self.count[2]) > self.type[2].count then
                                                    UI.text(self.count[2], self.type[2].count)
                                                end
                                            end
                                        end
                                    end
                                },
                                {
                                    type = "delete"
                                }
                            })
                        end)
                    end
                end
            end)
        end
    end

    message:send("C2S_ReqUseIndustry", { index = index, count = count }, function(ret)
        if self.hasClose then
            return
        end
        if ret.code == "ok" then
            CS.Sound.Play("effect/collect")
            if index == 3 then
                self.type[3].count = self.type[3].count + self.type[3].cost * count
                self.type[2].count = self.type[2].count - self.type[3].cost * count
            else
                self.type[index].count = self.type[index].count + self.type[index].cost * count
            end
            addAnim()
            self.type[index].times = ret.times
            self:countDown(index)
        elseif ret.code == "ten" then
            log("------10------")
            CS.Sound.Play("effect/collect")
            if index == 3 then
                self.type[3].count = self.type[3].count + self.type[3].cost * 10
                self.type[2].count = self.type[2].count - self.type[3].cost
            else
                self.type[index].count = self.type[index].count + self.type[index].cost * 10
            end
            addAnim(true)
        end
        self.type[index].times = ret.times
        self:countDown(index)
    end)
end

function Class:checkLen(value)
    return string.len(value) > 12 and self.fullStr or value
end

function Class:countDown(index)
    local show = function()
        UI.text(self.type[index].node, "energy", self.type[index].times.value .. "/" .. self.type[index].times.maxValue)
        UI.enable(self.type[index].node, "energy", self.type[index].times.value > 0)
        UI.enableOne(self.type[index].node, "Btn", self.type[index].times.value > 0 and 0 or 1)
    end
    show()

    if self.type[index].times.value == self.type[index].times.maxValue then
        UI.enable(self.type[index].node, "countDown", false)
        return
    else
        UI.enable(self.type[index].node, "countDown", true)
    end

    UI.CountDown(self.type[index].node, "countDown", self.type[index].times.countDown, function()
        self.type[index].times.value = self.type[index].times.value + 1
        if self.type[index].times.value < self.type[index].times.maxValue then
            self:update(index)
        else
            show()
        end
    end, 2, self.type[index].times.value == 0)
end

function Class:update(index)
    message:send("C2S_ReqIndustryUpdate", { index = index }, function(ret)
        if self.hasClose then
            return
        end
        log(index)
        log(ret)
        self.type[index].times = ret.times
        self:countDown(index)
    end)
end

function Class:showHero(index)
    local node = UI.child(self.node, "Hero")

    for i = 1, 5 do
        UI.enable(node, "Btn/" .. i .. "/select", i == index)
    end

    message:send("C2S_ReqIndustryHeroList", {}, function(ret)
        if self.hasClose then
            return
        end
        self.heroes = ret.heroes
        log(ret)
        self:showTable(index)
    end)
end

function Class:showTable(n)
    local heroes = {}

    UI.enable(self.curHeroNode, self.curHeroId > 0)

    for i, v in ipairs(self.heroes) do
        if v.id == self.curHeroId then
            UI.draw(self.node, "Hero/CurHero/node", v)
            if v.id == 1 then
                UI.setLocalScale(self.curHeroNode:Find("head"), 1.12, 1.03, 0.8)
            else
                UI.setLocalScale(self.curHeroNode:Find("head"), 1, 0.94, 1)
            end
            UI.enableOne(self.curHeroNode, "state", v.workSta)
        else
            table.insert(heroes, v)
        end
    end

    if heroes then
        local fun

        if n == 1 then
            fun = function(a, b)
                if a.wisdom == b.wisdom then
                    return a.id < b.id
                end
                return a.wisdom > b.wisdom
            end
        end

        if n == 2 then
            fun = function(a, b)
                if a.politics == b.politics then
                    return a.id < b.id
                end
                return a.politics > b.politics
            end
        end

        if n == 3 then
            fun = function(a, b)
                if a.charm == b.charm then
                    return a.id < b.id
                end
                return a.charm > b.charm
            end
        end

        if n == 4 then
            fun = function(a, b)
                if a.strength == b.strength then
                    return a.id < b.id
                end
                return a.strength > b.strength
            end
        end

        if n == 5 then
            fun = function(a, b)
                if a.level == b.level then
                    return a.id < b.id
                end
                return a.level > b.level
            end
        end

        table.sort(heroes, fun)

        local heroesState = {}
        local count = 0

        for i, v in ipairs(heroes) do
            if v.workSta == 0 then
                table.insert(heroesState, i - count, v)
            else
                table.insert(heroesState, #heroesState + 1, v)
                count = count + 1
            end
        end

        UI.cloneChild(self.heroesNode, #heroes)
        for i, v in ipairs(heroesState) do
            local child = UI.child(self.heroesNode, i - 1)

            UI.draw(child, v)
            UI.enableOne(child, "state", v.workSta)
            if v.id == 1 then
                UI.setLocalScale(child:Find("head"), 1.12, 1.03, 0.8)
            else
                UI.setLocalScale(child:Find("head"), 1, 0.94, 1)
            end
            UI.button(child, "btn", function()
                if v.workSta == 0 then
                    self:setHero(v.id)
                else
                    local type = { "商业", "农业", "征兵" }
                    funYes = function()
                        self:setHero(v.id)
                    end
                    funNo = function()
                        self:showTable(n)
                    end
                    UI.msgBoxTitle("提示", "该豪杰正在经营" .. type[v.workSta] .. "，是否确定现在替换？", funYes, funNo)
                end
            end)
        end
    end
end

function Class:setHero(id)
    message:send("C2S_ReqSetIndustryHero", { seatId = self.seatIndex, heroId = id }, function(ret)
        if self.hasClose then
            return
        end
        message:send("C2S_ReqIndustryInfo", {}, function(ret)
            if self.hasClose then
                return
            end
            UI.enable(self.node, "Hero", false)
            self.type = ret.type
            self:showMain()
        end)
    end)
end

function Class:showHelp()
    showHelp("manage")
end

return Class