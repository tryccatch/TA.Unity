local Class = {
    res = "ui/workhouse",
}

function Class:init()
    local animNode = UI.showNode(self.node, "BG/Anim", "Anim/wifeUndress20")
    UI.playAnim(animNode, "idle")

    UI.setLocalScale(UI.child(self.node, "Top/head"), 0.91, 0.85, 1)

    self.chatNode = self.node:Find("Chat/Text")

    local anim1 = UI.child(self.node, "Page/Ack/Anim1", true)
    local anim2 = UI.child(self.node, "Page/Ack/Anim2", true)
    self.animPos = { anim1.localPosition, anim2.localPosition }
    self.animAngles = { anim1.localEulerAngles, anim2.localEulerAngles }

    UI.enableAll(self.node, "Page/Ack", false)

    message:send("C2S_ReqWorkInfo", {}, function(res)
        self.info = res
        self:button()
        self:showBase()
        self:showPolitics(true)
    end)
end

function Class:button()
    for i = 1, 2 do
        UI.button(self.node, "Page/Ack/DealPage/S" .. i .. "/Select", function()
            UI.enable(self.node, "Page/Ack/DealPage/S" .. i, false)
            self:showSelectDetails(i)
        end)
    end

    UI.button(self.node, "Page/Ack/WaitPage/BtnUseItem", function()
        ItemTools.used(3, { minCount = 1, maxCount = self.info.energy.maxValue }, function()
            self:showPop()
            message:send("C2S_ReqUseItem", {}, function(res)
                self.info.energy = res
                self:showPolitics()
            end)
        end)
    end)

    UI.button(self.node, "BtnGold", function()
        ComTools.openRecharge()
    end)

    UI.button(self.node, "Top/head", function()
        UI.openPage(UIPageName.PlayerAttribute)
        UI.close(self)
    end)

    UI.button(self.node, "BtnClose", function()
        UI.close(self)
    end)
end

function Class:showBase()
    local info = self.info
    info.head = 1
    info.gold = client.user.gold
    UI.draw(self.node, "Top", info)
    self:checkLen(UI.child(self.node, "Top/money"))
    self:checkLen(UI.child(self.node, "Top/food"))
    self:checkLen(UI.child(self.node, "Top/soldier"))
    self:checkLen(UI.child(self.node, "Top/gold"))
    self:showSlider()
end

function Class:checkLen(node)
    local value = UI.getValue(node)
    if string.len(value) > 12 then
        UI.text(node, "999999999999+")
    end
end

function Class:showSlider()
    local data = { level = client.user.level < 18 and "/" or "已满级",
                   curExp = client.user.level < 18 and client.user.levelExp or " ",
                   nextExp = client.user.level < 18 and config.levelMap[client.user.level + 1].score or " " }
    UI.draw(self.node, "Top", data)
    if client.user.level < 18 then
        local cfg = config.levelMap[client.user.level + 1]
        UI.slider(self.node, "Top/Slider", { minValue = 0, value = client.user.levelExp, maxValue = cfg.score })
    else
        UI.slider(self.node, "Top/Slider", { value = 1, maxValue = 1 })
    end
    UI.showLevelUpEffect(UI.child(self.node, "Top"))
end

function Class:showPolitics(init)
    local energy = self.info.energy

    UI.text(self.node, "times", "政务" .. energy.value .. "/" .. energy.maxValue)
    UI.enable(self.node, "Chat", true)
    local node = nil
    UI.enable(self.node, "Page/countDown", energy.value ~= energy.maxValue)
    if energy.value > 0 then
        UI.enableOne(self.node, "Page/Ack", 0)
        UI.enableAll(self.node, "Page/Ack/DealPage", true)
        node = UI.child(self.node, "Page/Ack/DealPage")

        local politics = self.info.politics
        local reward = politics.reward
        local cfg = config.politicsMap[politics.id]
        UI.showTextByTypeWriter(self.chatNode, cfg.description, 10)

        politics.option1 = cfg.option1
        politics.option2 = cfg.option2
        politics.value1 = config.itemMap[reward[1].id].name .. "+" .. reward[1].count
        politics.value2 = config.itemMap[reward[2].id].name .. "+" .. reward[2].count
        UI.draw(self.node, "Page/Ack/DealPage", politics)
    else
        UI.enableOne(self.node, "Page/Ack", 1)
        node = UI.child(self.node, "Page/Ack/WaitPage")

        UI.text(self.node, "Page/Ack/WaitPage/count", energy.count)
        UI.showTextByTypeWriter(self.chatNode, "禀告大人，暂无政务需要处理", 10)
    end

    if not init then
        UI.tweenList(UI.child(self.node, "Page"), {
            {
                time = 1,
                type = "alphaAll",
                value = 1,
                waitTime = 0.24,
            },
            {
                fun = function()
                    UI.enable(self.node, "guide", false)
                    log("work")
                end
            }
        })
        --local timeNode = UI.child(self.node, "Page/countDown")
        --UI.tweenList(timeNode, {
        --    {
        --        time = 1,
        --        --waitTime = 1,
        --        type = "alphaAll",
        --        value = 1,
        --    } })
    else
        UI.enable(self.node, "guide", false)
    end
    if energy.value < energy.maxValue then
        self:upDateTime()
    end
end

function Class:showSelectDetails(type)
    message:send("C2S_ReqSelect", { type = type }, function(res)
        if res.code == "ok" then
            local reward = self.info.politics.reward

            ItemTools.showItemResultById(reward[type].id, reward[type].count)
            self.info.energy.value = self.info.energy.value - 1
            self:showSelectAck(type)

            self.info.politics = res.politics
        else
            UI.showHint("出错了")
            message:send("C2S_ReqWorkInfo", {}, function(res)
                self.info = res
                self:showBase()
                self:showPolitics(true)
            end)
        end
    end)
end

function Class:showTextByScroll(node, startValue, count, time)
    local fullStr = "999999999999+"

    if string.len(startValue) > 12 then
        UI.text(node, fullStr)
        return
    end

    local times = 60
    local add = math.floor(count / times)
    for i = 1, times do
        UI.delay(node, (time / times) * i, function()
            local value = startValue + count - (times - i) * add
            if string.len(value) > 12 then
                UI.text(node, fullStr)
                return
            else
                UI.text(node, value)
            end
        end)
    end
end

function Class:showSelectAck(type)
    self:showPop()
    local textNode = nil
    local oldValue = 0
    local reward = self.info.politics.reward[type]
    if reward.id == 1000 then
        oldValue = self.info.money
        textNode = UI.child(self.node, "Top/money")
        self.info.money = self.info.money + reward.count
    elseif reward.id == 2000 then
        oldValue = self.info.food
        textNode = UI.child(self.node, "Top/food")
        self.info.food = self.info.food + reward.count
    elseif reward.id == 3000 then
        oldValue = self.info.soldier
        textNode = UI.child(self.node, "Top/soldier")
        self.info.soldier = self.info.soldier + reward.count
    elseif reward.id == 4000 then
        self:showSlider()
    end

    if textNode then
        self:showTextByScroll(textNode, oldValue, reward.count, 0.5)
    end

    UI.text(self.node, "times", "政务" .. self.info.energy.value .. "/" .. self.info.energy.maxValue)
    UI.enable(self.node, "Chat", false)

    UI.enableOne(self.node, "Page/Ack", type + 1)

    local node = UI.child(self.node, "Page/Ack/Anim" .. type)

    local pos = self.animPos[type]
    local angles = self.animAngles[type]
    node.localPosition = pos
    node.localEulerAngles = angles

    local offX = 200
    local RotaZ = 300
    if type == 2 then
        offX = -200
        RotaZ = -300
    end
    UI.tweenList(node, {
        {
            time = 0.1,
            waitTime = 0,
            type = "alphaAll",
            value = 1,
        },
        {
            time = 0,
            waitTime = 0,
            type = "scale",
            value = 1,
        },
        {
            time = 1,
            waitTime = 0,
            type = "scale",
            value = 0.7,
        },
        {
            time = 1,
            waitTime = 0,
            rotation = {
                x = 0,
                y = 0,
                z = RotaZ,
            }
        },
        {
            time = 1,
            waitTime = 1,
            type = "offset",
            pos = {
                x = offX,
                y = 210,
                z = 0,
            }
        },
        {
            time = 0.5,
            waitTime = 1,
            type = "alphaAll",
            value = 0,
        },
        {
            time = 0,
            fun = function()
                node.localPosition = pos
                node.localEulerAngles = angles
                self:showPolitics()
            end,
        }
    })
end

function Class:upDateTime()
    message:send("C2S_ReqUpdate", {}, function(res)
        log(res)
        self.info.energy = res
        UI.CountDown(self.node, "Page/countDown", res.countDown, function()
            if res.value == 0 then
                self:showPop()
            end
            if res.value > res.maxValue then
                self.info.energy.value = self.info.energy.value + 1
            end
            self:showPolitics()
        end, 3, res.value == 0)
    end, true)
end

function Class:showPop()
    UI.enable(self.node, "guide", true)
    UI.tweenList(UI.child(self.node, "Page", true), {
        {
            time = 0,
            type = "alphaAll",
            value = 0,
        } })
end

function Class:onFront()
    self:showBase()
end

return Class