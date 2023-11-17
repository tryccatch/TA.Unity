local Class = {
    res = "ui/hdEmpress"
}
-- 活动 调教女皇
function Class:init()
    self.selected = {};
    -- 跑马灯相关属性
    self.speedInfo = {
        runId = 1,
        startId = 1, -- 默认为1，应该为1 - 14
        speedId = 5,
        speed = true,
        speedTime = 0.03,
        stopDelayId = 0,
        turns = 0,
        stopId = 0,
        running = false,
        add = 3, --减速个数
    }
    self.msgNode = self.node:Find("Top/MsgNode")
    self.cylinderNode = self.node:Find("Bottom/draw/cylinder")
    self.signNode = self.node:Find("Bottom/draw/cylinder/sign")
    UI.button(self.node, "Top/btnClose", function()
        UI.close(self)
    end);
    self:C2S_HD_EOnopen();
    UI.enable(self.node, "Mask", false);
    -- 奖励消息
    self:C2S_HD_EMsg();
    UI.button(self.node, "Bottom/btnQiuqian", function()
        UI.enable(self.node, "Mask", true);
        self:C2S_HD_EQiuqian();
    end)
    UI.button(self.node, "Bottom/btnQiuqianTen", function()
        UI.enable(self.node, "Mask", true);
        self:C2S_HD_EQiuqian(1);
    end)
    UI.button(self.node, "Bottom/btnAddGold", function()
        ComTools.openRecharge();
    end)
    UI.button(self.node, "GetAwardItem/btnBack", function()
        UI.enable(self.node, "GetAwardItem", false);
    end)

    UI.button(self.node, "Top/exchange", function()
        self:C2S_HD_EEO()
    end)

    UI.button(self.node, "Exchange/BtnClose", function()
        UI.enable(self.node, "Exchange", false)
    end)

    UI.enable(self.node, "Exchange", false)

    self.times = 1
    self.time = 0
end
-- 调教女皇打开页面
function Class:C2S_HD_EOnopen()
    self.selected = nil;
    self.selected = {};
    message:send("C2S_HD_EOnopen", {}, function(args)
        UI.text(self.node, "Top/top", args.top);
        UI.draw(self.node, "Bottom", args);
        UI.draw(self.node, "Bottom/prizeGroup", args.items);
        local prizeGroup = UI.child(self.node, "Bottom/prizeGroup");
        self:ShowItem(args.items, prizeGroup);
        for i = 1, #args.items do
            local itemNode = UI.child(prizeGroup, i - 1);
            local temp = UI.child(itemNode, "selected");
            table.insert(self.selected, temp);
        end
    end)
end
-- 推送消息
function Class:C2S_HD_EMsg()
    message:send("C2S_HD_EMsg", {}, function(args)
        for i, v in ipairs(args.msgInfo) do
            args.msgInfo[i].text = v.userName .. UI.colorStr(" 获得 ", ColorStr.get) .. UI.colorStr(args.msgInfo[i].item, ColorQua[args.msgInfo[i].qua])
        end

        UI.draw(self.node, "Top/MsgNode", args.msgInfo);
    end)
    UI.delay(self.node, 5, function()
        if self.speedInfo.running then
            return
        end
        self:C2S_HD_EMsg()
    end);
end
--- 求签
---@param qqtype any 求签类型 0：单抽 1：十连抽
function Class:C2S_HD_EQiuqian(qqtype)
    if qqtype == nil then
        qqtype = 0;
    end
    message:send("C2S_HD_EQiuqian", {
        qiuqianType = qqtype
    }, function(args)
        if args.code == "ok" then
            log(args.items)
            table.sort(args.items, function(a, b)
                return a.qua > b.qua
            end)
            self:drawAck(1)
            self:setSpeedId();
            self.speedInfo.stopId = args.items[1].id;
            self.count = self:getRunCount()
            self.speedInfo.stopDelayId = self:RunLight(args.items);
        elseif args.code == "error_noGold" then
            UI.showHint("元宝不足，可前往充值获取");
            UI.enable(self.node, "Mask", false);
        end
        UI.text(self.node, "Bottom/gold", client.user.gold);
    end)
end

function Class:drawAck(index)
    local cylinder = UI.child(self.node, "Bottom/draw/cylinder").gameObject:GetComponent(typeof(CS.SAnim))
    local sign = UI.child(self.node, "Bottom/draw/cylinder/sign").gameObject:GetComponent(typeof(CS.SAnim))
    cylinder.gameObject:SetActive(true)
    sign.gameObject:SetActive(true)

    if index == 1 then
        cylinder:Play()
        sign:Play()
    else
        cylinder:Stop()
        cylinder:Reset()
        sign:Stop()
        sign:Reset()
    end
end

function Class:showSign()
    local random = math.random(0, 3)
    local sign = UI.child(self.signNode, random)
    local pos = sign.localPosition
    local angles = sign.localEulerAngles
    local rotaZ = 0
    if angles.z > 180 then
        rotaZ = 360 - angles.z
    else
        rotaZ = -(angles.z)
    end

    UI.tweenList(self.cylinderNode, {
        {
            time = 0.3,
            type = "offset",
            pos = {
                x = 0,
                y = 30,
                z = 0,
            }
        },
        {
            time = 0,
            UI.tweenList(sign, {
                {
                    time = 0.3,
                    type = "offset",
                    pos = {
                        x = 0,
                        y = 240,
                        z = 0,
                    }
                },
                {
                    fun = function()
                        sign.transform.parent = self.cylinderNode
                    end
                },
                {
                    time = 1.5,
                    rotation = {
                        x = 0,
                        y = 0,
                        z = rotaZ,
                    },
                    type = "offset",
                    pos = {
                        x = -pos.x,
                        y = -240,
                        z = 0,
                    }
                },
                {
                    time = 0.1,
                    waitTime = 1,
                    type = "scale",
                    value = 1.8,
                },
                {
                    fun = function()
                        sign.transform.parent = self.signNode
                    end
                },
                {
                    fun = function()
                        sign.localPosition = pos
                        sign.localEulerAngles = angles
                    end
                },
                {
                    time = 0,
                    type = "scale",
                    value = 1.25,
                },

            })
        },
        {
            time = 0.3,
            type = "offset",
            pos = {
                x = 0,
                y = -30,
                z = 0,
            }
        },
    })
end

function Class:getRunCount()
    local turns = 0
    local startId = self.speedInfo.startId
    local stopId = self.speedInfo.stopId
    local runId = self.speedInfo.runId
    local run = function()
        startId = startId + 1
        if startId > 14 then
            startId = 1
        end
        if startId == runId then
            turns = turns + 1
        end
    end

    for i = 1, 14 * 4 do
        run()
        if turns > 1 and startId == stopId then
            log(i)
            return i
        end
    end
end

-- 跑马灯
function Class:RunLight(awardItems)
    self.speedInfo.running = true;
    UI.enable(self.selected[self.speedInfo.startId], false);
    self.speedInfo.startId = self.speedInfo.startId + 1;
    if self.speedInfo.startId > 14 then
        self.speedInfo.startId = 1;
    end
    if self.speedInfo.runId == self.speedInfo.startId then
        self.speedInfo.turns = self.speedInfo.turns + 1;
    end

    UI.enable(self.selected[self.speedInfo.startId], true);
    if self.speedInfo.stopId == self.speedInfo.startId and (self.speedInfo.turns > 1) then
        -- 显示 中奖物品
        -- todo 播放抽签结束动画
        log(self.times)
        self.speedInfo.runId = self.speedInfo.stopId
        self.time = 0
        self.times = 1
        self:drawAck(0)
        self.speedInfo.running = false;
        self:showSign()
        UI.delay(self.node, 2.2, function()
            self:C2S_HD_EMsg();
            UI.enable(self.node, "GetAwardItem", true);
            UI.enable(self.node, "Mask", false);
            local btnBack = UI.child(self.node, "GetAwardItem/btnBack")
            UI.draw(self.node, "GetAwardItem/bg/Itembg", awardItems);
            local prizeGroup = UI.child(self.node, "GetAwardItem/bg/Itembg");
            self:ShowItem(awardItems, prizeGroup, true);
            if #awardItems == 1 then
                UI.setLocalPosition(btnBack, nil, 0, nil);
            else
                UI.setLocalPosition(btnBack, nil, -210, nil);
            end

            for i = 1, #awardItems do
                if awardItems[i].hero > 0 then
                    Story.show({
                        heroID = awardItems[i].hero,
                        endFun = function()
                            self:C2S_HD_EOnopen();
                        end
                    })
                end
                if awardItems[i].wife > 0 then
                    Story.show({
                        wifeID = awardItems[i].wife,
                        endFun = function()
                            self:C2S_HD_EOnopen();
                        end
                    })
                end
            end
        end)
        return
    end

    if self.speedInfo.turns < 1 then
        self.speedInfo.speedTime = self.speedInfo.speedTime - 0.001
    end
    if self.count - self.times <= 6 then
        self.speedInfo.speedTime = self.speedInfo.speedTime + 0.03
    end
    self.time = self.time + self.speedInfo.speedTime
    --log(self.speedInfo.speedTime)
    --log(self.time)

    return UI.delay(self.node, self.speedInfo.speedTime, function()
        self.times = self.times + 1
        self:RunLight(awardItems)
    end)
end
function Class:setSpeedId()
    self.speedInfo.speedId = self.speedInfo.startId + 4;
    if self.speedInfo.speedId > 14 then
        self.speedInfo.speedId = self.speedInfo.speedId - 14;
    end
    self.speedInfo.speed = true;
    self.speedInfo.speedTime = 0.03;
    self.speedInfo.stopDelayId = 0;
    self.speedInfo.stopId = 0;
    self.speedInfo.turns = 0;
end
--- 显示物品信息
---@param awardItems any 物品信息
---@param node any 哪个节点下面
function Class:ShowItem(awardItems, node, refresh)
    log(awardItems)
    for i = 1, #awardItems do
        local temp = awardItems[i];
        local itemNode = UI.child(node, i - 1);
        UI.enable(itemNode, "ef", temp.qua == 5);
        UI.enable(itemNode, "itemIcon", temp.item > 0);
        UI.enable(itemNode, "hero", temp.hero > 0);
        UI.enable(itemNode, "wife", temp.wife > 0);
        if temp.hero > 0 or temp.wife > 0 then
            UI.enable(itemNode, "num", false);
        else
            UI.enable(itemNode, "num", true);
        end

        if not refresh then
            UI.enable(itemNode, "jipin", temp.qua == 5);
        end

        if refresh and (temp.item > 0 and config.itemMap[temp.item].type == 57) then
            self:C2S_HD_EOnopen()
        end

        UI.image(itemNode, "qua", "HDEQua", tostring(temp.qua));
        UI.button(itemNode, "qua", function()
            if temp.hero > 0 then
                UI.showHeroInfo(temp.hero);
            elseif temp.wife > 0 then
                UI.showWifeInfo(temp.wife);
            elseif temp.item > 0 then
                UI.showItemInfo(temp.item);
            end
        end)
    end
end

function Class:C2S_HD_EEO(type)
    message:send("C2S_HD_EEO", {}, function(ret)
        UI.enable(self.node, "Exchange", true)
        UI.enable(self.node, "Exchange/Btn/btn1/select", true)
        UI.text(self.node, "Exchange/score", ret.score)
        self.changeState = ret.state
        local SVC = UI.child(self.node, "Exchange/S/V/C")

        local show = function(type)
            local Info = self:sortChange(self:getExCfg(type))

            UI.cloneChild(SVC, #Info)
            log(Info)
            for i, v in ipairs(Info) do
                local child = UI.child(SVC, i - 1)
                if type == 1 then
                    UI.image(child, "head/icon", "HeroHead", v.icon)
                elseif type == 2 then
                    UI.image(child, "head/icon", "WifeHead", v.icon)
                else
                    UI.image(child, "head/icon", "Item", v.icon)
                end
                UI.draw(child, v)
            end
            UI.refreshSVC(SVC, type ~= self.type)
            self.type = type
        end

        if type then
            show(type)
        else
            show(1)
        end

        for i = 1, 3 do
            UI.button(self.node, "Exchange/Btn/btn" .. i, function()
                for j = 1, 3 do
                    UI.enable(self.node, "Exchange/Btn/btn" .. j .. "/select", false)
                end
                UI.enable(self.node, "Exchange/Btn/btn" .. i .. "/select", true)
                show(i)
            end)
        end
    end)
end

function Class:getExCfg(type)
    local cfg = config["lotteryShop"]
    local Info = {}

    local iCfg = {}
    if type == 1 then
        iCfg = config["hero"]
    elseif type == 2 then
        iCfg = config["wife"]
    else
        iCfg = config["item"]
    end
    for i, v in ipairs(cfg) do
        if v.type == type then
            local id = v.shopID
            local qua = 5
            if type == 3 then
                --id = config["item"][v.shopID].prisoner
                qua = config["item"][v.shopID].quality
            end

            if iCfg[id] == nil or (type == 3 and iCfg[id].type ~= 57) then
                UI.showHint("别特么乱配表")
            else
                local info = { icon = type == 3 and iCfg[id].icon or iCfg[id].head,
                               head = { qua = iCfg[id].quality and iCfg[id].quality or qua, fun = function()
                                   if type == 1 then
                                       UI.showHeroInfo(id)
                                   elseif type == 2 then
                                       UI.showWifeInfo(id)
                                   else
                                       UI.showItemInfo(id)
                                   end
                               end },
                               name = iCfg[id].name,
                               score = v.price,
                               state = { btnEX = self:getChangeState(id) == false
                                       and function()
                                   self:C2S_HD_EEC(i)
                               end, State = self:getChangeState(id) } }
                table.insert(Info, info)
            end
        end
    end

    return Info
end

function Class:sortChange(original)
    local Info = {}
    local count = 0
    for i, v in ipairs(original) do
        if v.state.State then
            table.insert(Info, #Info + 1, v)
            count = count + 1
        else
            table.insert(Info, i - count, v)
        end
    end
    return Info
end

function Class:getChangeState(id)
    if self.changeState then
        for i, v in ipairs(self.changeState) do
            if v.id == id then
                return v.have
            end
        end
    end
end

function Class:C2S_HD_EEC(id)
    message:send("C2S_HD_EEC", { id = id }, function(ret)
        local cfg = config["lotteryShop"][id]

        log(cfg)

        if ret.code == "ok" then
            if cfg.type == 1 then
                Story.show({
                    heroID = cfg.shopID,
                    endFun = function()
                        self:C2S_HD_EEO(cfg.type)
                    end
                })
            elseif cfg.type == 2 then
                Story.show({
                    wifeID = cfg.shopID,
                    endFun = function()
                        self:C2S_HD_EEO(cfg.type)
                    end
                })
            else
                Story.show({
                    storyID = config["item"][cfg.shopID].story,
                    endFun = function()
                        self:C2S_HD_EEO(cfg.type)
                    end
                })
            end
        elseif ret.code == "error_noGold" then
            UI.showHint("积分不足，参与调教女皇可获得积分")
        elseif ret.code == "gotten" then
            UI.showHint("已拥有")
        else

        end
    end)
end

return Class
