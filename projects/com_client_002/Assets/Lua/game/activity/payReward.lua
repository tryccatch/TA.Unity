local Class = {
    res = "UI/PayReward"
}

function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()

    UI.button(self.node, "BtnClose", function()
        self:addRedDot(false)
        UI.close(self)
    end)
    UI.enableAll(self.node, false)

    --人民币100||平台币10
    local channel = Tools.getChannelMap()
    self.rate = channel.getGold
    self.type = channel.name
    self.pos = channel.pos

    self.rewardNode = self.node:Find("S/V/C")
    self.tipsNode = self.node:Find("Page/page1/today/tips")

    message:send("C2S_ReqPayRewardInfo", {}, function(ret)

        if ret.countDown > 0 then
            UI.txtUpdateTime(self.node, "BG/countDown", ret.countDown, function()
                UI.desObj(self.node, "BG/countDown", CS.TxtTime);
                UI.showHint("充值奖励已结束");
                UI.close(self);
            end)

            UI.enableAll(self.node, true)
            local startDate = convertToTime(ret.startDate);
            local endDate = convertToTime(ret.endDate - 1);
            local strDate = startDate.month .. "月" .. startDate.day .. "日-" .. endDate.month .. "月" .. endDate.day .. "日";

            self.dateInfo = {
                date = strDate;
                todayPay = self.pos > 0 and goldFormatNotDot(ret.todayPay) .. self.type or self.type .. goldFormatNotDot(ret.todayPay)
            }

            self.daiType = ret.daiType
            self.allType = ret.allType
            self.dayType = ret.dayType

            self.daiType.Pay = ret.todayPay
            self.allType.Pay = ret.allPay
            self.dayType.Pay = ret.payDay

            UI.draw(self.node, "BG", self.dateInfo)
            self:showPage(1)
        else
            UI.showHint("充值奖励已结束");
            UI.close(self);
        end

    end)

    for i = 1, 3 do
        UI.button(self.node, "Btn/Btn_" .. i, function()
            self:showPage(i)
        end)
    end
    self:addRedDot(true)
end

function Class:addRedDot(add)
    local btnTotalCharge = UI.child(self.node, "Btn/Btn_2")
    local btnDailyCharge = UI.child(self.node, "Btn/Btn_1")
    local btnTotalDayCharge = UI.child(self.node, "Btn/Btn_3")
    if add then
        RedDot.registerBtn(btnTotalCharge, RedDot.SystemID.TotalChargeReward)
        RedDot.registerBtn(btnDailyCharge, RedDot.SystemID.DailyChargeReward)
        RedDot.registerBtn(btnTotalDayCharge, RedDot.SystemID.TotalDayChargeReward)
    else
        RedDot.unregisterBtn(btnTotalCharge, RedDot.SystemID.TotalChargeReward)
        RedDot.unregisterBtn(btnDailyCharge, RedDot.SystemID.DailyChargeReward)
        RedDot.unregisterBtn(btnTotalDayCharge, RedDot.SystemID.TotalDayChargeReward)
    end
end

function Class:showPage(index)
    local oldIndex = self.curIndex
    self.curIndex = index

    for i = 1, 3 do
        UI.enable(self.node, "Btn/Btn_" .. i .. "/Select", false)
    end
    UI.enable(self.node, "Btn/Btn_" .. index .. "/Select", true)
    UI.enableOne(self.node, "Page", index - 1)
    UI.draw(self.node, "Page/page" .. index, self.dateInfo)

    if index == 1 then
        --local x = string.len(self.dateInfo.todayPay)
        --UI.setLocalPosition(self.tipsNode, 145 + 15 * (x - 6), 0, 0)
        self:showRewardInfo(self.daiType)
    elseif index == 2 then
        self:showRewardInfo(self.allType)
    else
        self:showRewardInfo(self.dayType)
    end
    UI.refreshSVC(self.rewardNode, oldIndex ~= index)
end

function Class:showRewardInfo(typeInfo)


    UI.cloneChild(self.rewardNode, #typeInfo)
    for i, v in ipairs(self:sortReward(typeInfo)) do

        local child = UI.child(self.rewardNode, i - 1)
        local cfg = config.eventPayMap[v.id]
        local items = Tools.getOneEventItems(cfg)

        UI.text(child, "des", string.gsub(cfg.description, "money", Tools.showChannelValue(cfg.num)))

        UI.cloneChild(child, #items, 3, UI.child(child, 3))
        for j, itemInfo in ipairs(items) do
            local item = UI.child(child, j + 2)
            UI.draw(item, itemInfo)
        end

        if self.curIndex == 3 then
            UI.progress(child, "process", typeInfo.Pay / cfg.num)
            UI.text(child, "process/value", "" .. typeInfo.Pay .. "/" .. cfg.num)
        else
            UI.progress(child, "process", typeInfo.Pay / ((cfg.num / self.rate)))
            UI.text(child, "process/value", "" .. goldFormatNotDot(typeInfo.Pay) .. "/" .. math.floor((cfg.num / self.rate)))
        end

        local aim = self.curIndex < 3 and (cfg.num / self.rate) or cfg.num

        if v.gotten then
            UI.enableOne(child, "Btn", 2)
            log("已领取")
        else
            if typeInfo.Pay < aim then
                UI.enableOne(child, "Btn", 0)
                UI.button(child, "Btn/Pay", function()
                    ComTools.openRecharge()
                end)
            else
                UI.enableOne(child, "Btn", 1)
                UI.button(child, "Btn/Get", function()
                    message:send("C2S_ReqGetPayReward", { id = v.id }, function(ret)
                        self.daiType = ret.daiType
                        self.allType = ret.allType
                        self.dayType = ret.dayType

                        self.daiType.Pay = ret.todayPay
                        self.allType.Pay = ret.allPay
                        self.dayType.Pay = ret.payDay

                        ItemTools.showItemsResult(items)

                        self:showPage(self.curIndex)
                        UI.refreshSVC(self.rewardNode, nil, true, true)
                    end)
                end)
            end
        end
    end
end

function Class:sortReward(reward)
    local tb = {}
    local count = 0
    for i, v in ipairs(reward) do
        if v.gotten then
            table.insert(tb, #tb + 1, v)
            count = count + 1
        else
            table.insert(tb, i - count, v)
        end
    end
    return tb
end

function Class:onFront()
    message:send("C2S_ReqPayRewardInfo", {}, function(ret)

        self.daiType = ret.daiType
        self.allType = ret.allType
        self.dayType = ret.dayType

        self.daiType.Pay = ret.todayPay
        self.allType.Pay = ret.allPay
        self.dayType.Pay = ret.payDay

        self.dateInfo.todayPay = self.pos > 0 and goldFormatNotDot(ret.todayPay) .. self.type or self.type .. goldFormatNotDot(ret.todayPay)

        self:showPage(self.curIndex)
    end)
end

return Class