local Class = {
    res = "ui/recharge"
}

function Class:init(openType)
    self:C2S_RechargeOO()

    self.rate = Tools.getChannelMap().getGold

    UI.enable(self.node, "Top/Info/GK", client.isGK == true)
    UI.enable(self.node, "Top/Info/H365", client.isH365 == true)
    UI.enable(self.node, "Top/Info/JGG", client.isJGG == true)

    UI.text(self.node, "Top/vip", client.user.vip)
    UI.text(self.node, "Top/gold", goldFormat(client.user.gold))

    UI.toggle(self.node, "Top/TG/pay", function()
        message:send("C2S_ISOpenFristRecharge", {}, function(args)
            if args.frist then
                UI.openPage(UIPageName.FirstCharge)
            else
                UI.enableOne(self.node, "Bottom", 0)
            end
        end)
    end)

    UI.toggle(self.node, "Top/TG/vip", function()
        UI.enableOne(self.node, "Bottom", 1)
    end)

    if openType == nil or openType == 0 then
        UI.SetToggleIsOn(self.node, "Top/TG/pay")
    else
        UI.SetToggleIsOn(self.node, "Top/TG/vip")
    end

    UI.button(self.node, "BtnClose", function()
        UI.close(self);
    end)
    self:SetVipTxt()
end

function Class:C2S_RechargeOO()
    message:send("C2S_RechargeOO", {}, function(args)
        UI.enable(self.node, "Top/Info", args.vipNextLevel ~= 0)
        UI.progress(self.node, "Top/slider", args.vipNextLevel == 0 and 1 or args.vipExp / args.vipNextExp)
        --[[        UI.text(self.node, "Top/vipExp", args.vipNextLevel == 0
                        and UI.colorStr("已满级", ColorStr.green)
                        or math.floor(args.vipExp / self.rate) * 10 .. "/" .. math.floor(args.vipNextExp / self.rate) * 10)]]
        UI.text(self.node, "Top/vipExp", args.vipNextLevel == 0
                and UI.colorStr("已满级", ColorStr.green)
                or math.floor(args.vipExp) / 10 .. "/" .. math.floor(args.vipNextExp) / 10)
        UI.text(self.node, "Top/Info/vipNextLevel", "VIP" .. args.vipNextLevel)
        UI.text(self.node, "Top/Info/nextVipMoney", math.floor((args.vipNextExp - args.vipExp) / self.rate))
        UI.text(self.node, "Top/gold", goldFormat(client.user.gold))
        UI.text(self.node, "Top/vip", args.vip)

        self.isFirstCharge = args.isFirstCharge
        UI.refreshSVC(self.node, "Top/Info", true, true)
        self:SetRecharge()
    end)
end
-- 设置VIPTxt
function Class:SetVipTxt()
    local vipNode = UI.child(self.node, "Bottom/s/V/C")
    local cfg = config.vip

    UI.draw(vipNode, cfg)

    for i, v in ipairs(cfg) do
        local child = UI.child(vipNode, i - 1)

        UI.text(child, "vip", v.id)
        local str = UI.getValue(child, "Text")
        v.tempA = Tools.showChannelValue(v.pay)
        v.tempB = v.brith / 100

        str = UI.gsub(str, v)

        if cfg.id == 9 then
            str = str .. "\n解锁姻缘祠赐婚功能"
        end

        UI.text(child, "Text", str)
    end

    UI.refreshSVC(vipNode)

    local posY = 0

    for i = 1, #cfg do
        local child = UI.child(vipNode, i - 1)
        if i - 1 < client.user.vip then
            posY = posY + UI.component2(child, typeof(CS.UnityEngine.RectTransform)).sizeDelta.y
        else
            UI.setLocalPosition(vipNode, nil, posY, 0)
            break
        end
    end
end

function Class:getFirstChargeConfig(index)
    local data = {}
    local count = 1;
    for i = 1, #config["pay"] do
        if config["pay"][i].firstDouble == 1 then
            data[count] = config["pay"][i]
            count = count + 1
            if count > 8 then
                break
            end
        end
    end
    return data[index]
end

-- 设置充值
function Class:SetRecharge()
    local payNode = UI.child(self.node, "Bottom/S/V/C")

    local cfg = {}

    local count = 0
    for i, v in ipairs(config.pay) do
        if v.firstDouble > 0 then
            table.insert(cfg, v)
            count = count + 1
            if count >= 8 then
                break
            end
        end
    end

    UI.draw(payNode, cfg)

    for i, v in ipairs(cfg) do
        local child = UI.child(payNode, i - 1)

        v.pay = Tools.showChannelValue(v.price)
        v.first = self.isFirstCharge[i]
        v.fun = function()
            ComTools.charge(self:getFirstChargeConfig(i), "recharge", i, function()
                self:C2S_RechargeOO();
            end)
        end

        UI.draw(child, v)
    end
end

function Class:onFront()
    UI.SetToggleIsOn(self.node, "Top/TG/vip")
    self:C2S_RechargeOO()
end
return Class
