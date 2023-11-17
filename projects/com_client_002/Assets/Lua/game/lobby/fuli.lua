local Class = {
    res = "ui/fuli"
}

function Class:getFirstChargeConfig(index)
    local data = {}
    local count = 1;
    for i = 1, #config["pay"] do
        if config["pay"][i].firstCharge == 1 then
            data[count] = config["pay"][i]
            count = count + 1
        end
    end
    return data[index]
end
-- 福利脚本
function Class:init(index)
    UI.enableAll(self.node, false);
    local bottomBtn = UI.child(self.node, "BottomBtns");
    local page = UI.child(self.node, "page");
    -- 动画相关
    local ani1 = UI.showNode(self.node, "page/monthCard/aniNode", "Anim/wife6");
    UI.playAnim(ani1, "idle")
    local ani2 = UI.showNode(self.node, "page/yearCard/aniNode", "Anim/wife10");
    UI.playAnim(ani2, "idle")
    local ani3 = UI.showNode(self.node, "page/shuochong/aniNode", "Anim/hero27");
    UI.setScale(ani3, 80, 80, 1);
    UI.playAnim(ani3, "idle")
    local ani4 = UI.showNode(self.node, "page/guanqun/aniNode", "Anim/wife1");
    UI.playAnim(ani4, "idle")
    -- 活动物品特效添加
    self:AddItemEffect();
    UI.button(self.node, "btnClose", function()
        local node = UI.child(self.node, "BottomBtns/btnMiracle")
        RedDot.unregisterBtn(node, RedDot.SystemID.GodShow)
        UI.close(self);
    end)
    UI.button(self.node, "page/qiandao/btnNode/btnQiandao", function()
        -- 签到
        self:C2S_FL_QDReceive();
    end)
    local shouChongBtn = UI.child(page, "shuochong/btnGroup");
    for i = 1, 4 do
        UI.button(shouChongBtn, tostring(i), function()
            -- 首充按钮 1-4 对应不同
            ComTools.charge(self:getFirstChargeConfig(i),"firstCharge", i - 1, function()
                self:C2S_FL_FirstChargeOOP();
            end)
        end)
    end
    UI.button(shouChongBtn, "btnReceive", function()
        self:C2S_FL_FirstChargeOOP(1);
    end)
    self:drawFun();
    if index == 0 then
        -- 签到入口
        self:C2S_FL_qiandao();
    elseif index == 1 then
        -- 月卡入口
        self:showPage(1);
        self:C2S_FL_McOOP();
    elseif index == 2 then
        -- 年卡入口
        self:showPage(2);
        self:C2S_FL_YcOOP();
    elseif index == 4 then
        -- 首充入口
        self:showPage(4);
        self:C2S_FL_FirstChargeOOP();
    end
    self:C2S_FL_UnRead();
    local node = UI.child(self.node, "BottomBtns/btnMiracle")
    RedDot.registerBtn(node, RedDot.SystemID.GodShow, true, -12.6, -12.6)
end

function Class:drawFun()
    local bottomBtn = UI.child(self.node, "BottomBtns");
    local fun = {
        btnQiandao = function()
            -- 签到
            if self.curIndex == 0 then
                return
            end
            self:C2S_FL_qiandao();
        end,
        btnMonthCard = function()
            if self.curIndex == 1 then
                return
            end
            self:showPage(1);
            self:C2S_FL_McOOP();
        end,
        btnYearCard = function()
            -- 年卡
            if self.curIndex == 2 then
                return
            end
            self:showPage(2);
            self:C2S_FL_YcOOP();
        end,
        btnMiracle = function()
            -- 神迹
            if self.curIndex == 3 then
                return
            end
            self:showPage(3);
            self:C2S_FL_Miracle();
        end,
        btnFrist = function()
            -- 首充
            if self.curIndex == 4 then
                return
            end
            self:showPage(4);
            self:C2S_FL_FirstChargeOOP();
        end,
        btnGuanqun = function()
            -- 官群
            if self.curIndex == 5 then
                return
            end
            self:showPage(5);
            self:openUrl()
        end
    }
    UI.draw(bottomBtn, fun);
    return fun;
end
-- 显示页面
function Class:openUrl()
    UI.button(self.node, "page/guanqun/btnAddQunTg", function()
        CS.UnityEngine.Application.OpenURL("https://t.me/joinchat/Otb6Ahr_amvPO5zwUlgelA")
    end)
    UI.button(self.node, "page/guanqun/btnAddQunTd", function()
        CS.UnityEngine.Application.OpenURL("https://lynnconway.me/lywhy")
    end)
end

function Class:showPage(index)
    if self.firstOpen == nil then
        UI.enableAll(self.node, true)
        self.firstOpen = "hasOpen"
    end
    self.curIndex = index
    UI.enableOne(self.node, "page", index)
end
-- 活动物品特效添加
function Class:AddItemEffect()
    -- 添加签到物品特效
    for i = 1, 4 do
        local temp = UI.child(self.node, "page/qiandao/btnNode/btnDay" .. i);
        local efNode = UI.showNode(temp, "Effect/itemEffect");
        efNode.name = "ef";
    end

    -- 添加月卡物品特效
    UI.showNode(self.node, "page/monthCard/Reward/btnDay", "Effect/itemEffect").name = "ef";
    UI.showNode(self.node, "page/monthCard/Reward/btnWeek1", "Effect/itemEffect").name = "ef";
    UI.showNode(self.node, "page/monthCard/Reward/btnWeek2", "Effect/itemEffect").name = "ef";

    -- 添加年卡物品特效
    for i = 1, 4 do
        local temp = UI.child(self.node, "page/yearCard/Reward/btnWeek" .. i);
        UI.showNode(temp, "Effect/itemEffect").name = "ef";
    end

    local temp1 = UI.child(self.node, "page/shuochong/ItemGroup")
    -- 添加首充物品特效
    for i = 0, 4 do
        local temp = UI.child(temp1, i);
        UI.showNode(temp, "Effect/itemEffect").name = "ef";
    end
end
-- 福利签到页面打开
function Class:C2S_FL_qiandao()
    local tempNode = UI.child(self.node, "page/qiandao/btnNode");
    message:send("C2S_FL_qiandao", {}, function(args)
        self:showPage(0)
        UI.draw(tempNode, args);
        if args.isQiandao then
            -- 领取过了
            UI.enable(tempNode, "btnQiandao", false);
            UI.enable(tempNode, "received", true);
        else
            UI.enable(tempNode, "btnQiandao", true);
            UI.enable(tempNode, "received", false);
        end
        for i = 1, #args.items do
            local temp = UI.child(tempNode, "btnDay" .. i);
            UI.draw(temp, args.items[i]);
            UI.button(temp, function()
                -- 物品详细信息按钮
                UI.showItemInfo(args.items[i].itemID);
            end)
            if args.items[i].received then
                UI.enable(temp, "received", args.items[i].received)
                UI.enable(temp, "ef", false);
            end
        end

        self:C2S_FL_UnRead();
    end)
end
-- 福利签到
function Class:C2S_FL_QDReceive()
    message:send("C2S_FL_QDReceive", {}, function(args)
        if args.code == "ok" then
            local info = {};
            for i = 1, #args.items do
                local temp = {
                    id = args.items[i].itemID,
                    itemIcon = args.items[i].itemIcon,
                    count = args.items[i].itemNum
                }
                table.insert(info, temp);
            end
            ItemTools.showItemsResult(info);
        elseif args.code == "fail" then
            UI.showHint("签到错误");
        end
        self:C2S_FL_qiandao();
    end)
end
-- 月卡界面打开
function Class:C2S_FL_McOOP()
    local tempNode = UI.child(self.node, "page/monthCard");
    message:send("C2S_FL_McOOP", {}, function(args)
        log(args)
        if args.monthCardDay > 0 then
            UI.enable(tempNode, "btnReceive/unread", not args.isRMD)
            UI.text(tempNode, "isBuy/day", args.monthCardDay);

            if args.isRMD then
                UI.enable(tempNode, "btnReceive", false);
                UI.enable(tempNode, "isBuy", true);
                UI.enable(tempNode, "isBuy/received", true);
            else
                UI.text(tempNode, "btnReceive/Text", "领 取");
                UI.button(self.node, "page/monthCard/btnReceive", function()
                    -- 点击领取奖励
                    self:C2S_FL_McR();
                end)
                UI.enable(tempNode, "isBuy", true);
                UI.enable(tempNode, "isBuy/received", false);
                --UI.text(tempNode, "isBuy/day", args.monthCardDay);
            end
            if args.weekDay > 0 and args.items[2].received then
                UI.enable(tempNode, "Reward/ui/received", false);
                UI.enable(tempNode, "Reward/ui/weekDay", true);
                UI.text(tempNode, "Reward/ui/weekDay", args.weekDay);
            else
                UI.enable(tempNode, "Reward/ui/received", true);
                UI.enable(tempNode, "Reward/ui/weekDay", false);
            end
        else
            UI.enable(tempNode, "btnReceive/unread", false)
            UI.enable(tempNode, "btnReceive", true);
            UI.enable(tempNode, "isBuy", false);
            UI.text(tempNode, "btnReceive/Text", "HoneyP200");
            UI.button(self.node, "page/monthCard/btnReceive", function()
                -- 点击月卡充值
                ComTools.charge(config.cardMonthMap[1],"monthCard", 2000, function()
                    self:C2S_FL_McOOP();
                end)
            end)
        end
        -- 显示可领取物品
        UI.draw(tempNode, "Reward/btnDay", args.items[1]);
        UI.enable(tempNode, "Reward/btnDay/received", args.items[1].received);
        UI.enable(tempNode, "Reward/btnDay/ef", not args.items[1].received);
        UI.button(tempNode, "Reward/btnDay", function()
            UI.showItemInfo(args.items[1].itemID);
        end)
        UI.draw(tempNode, "Reward/btnWeek1", args.items[2]);
        UI.enable(tempNode, "Reward/btnWeek1/received", args.items[2].received);
        UI.enable(tempNode, "Reward/btnWeek1/ef", not args.items[2].received);
        UI.button(tempNode, "Reward/btnWeek1", function()
            UI.showItemInfo(args.items[2].itemID);
        end)
        UI.draw(tempNode, "Reward/btnWeek2", args.items[3]);
        UI.enable(tempNode, "Reward/btnWeek2/received", args.items[3].received);
        UI.enable(tempNode, "Reward/btnWeek2/ef", not args.items[3].received);
        UI.button(tempNode, "Reward/btnWeek2", function()
            UI.showItemInfo(args.items[3].itemID);
        end)
        self:C2S_FL_UnRead();
    end)
end

-- 领取月卡奖励
function Class:C2S_FL_McR()
    message:send("C2S_FL_McR", {}, function(args)
        if args.code == "ok" then
            local info = {};
            for i = 1, #args.items do
                local temp = {
                    id = args.items[i].itemID,
                    itemIcon = args.items[i].itemIcon,
                    count = args.items[i].itemNum
                }
                table.insert(info, temp);
            end
            ItemTools.addItemsDis(info);
        elseif args.code == "fail" then
            UI.showHint("签到错误");
        end
        self:C2S_FL_McOOP();
    end)
end

-- 年卡界面打开
function Class:C2S_FL_YcOOP()
    local tempNode = UI.child(self.node, "page/yearCard");
    message:send("C2S_FL_YcOOP", {}, function(args)
        if args.yearCardDay > 0 then
            if args.items[1].received then
                UI.enable(tempNode, "btnReceive", false);
                UI.enable(tempNode, "isBuy", true);
                UI.enable(tempNode, "isBuy/received", true);
            else
                UI.enable(tempNode, "btnReceive/unread", true)
                UI.text(tempNode, "btnReceive/Text", "领取");
                UI.button(tempNode, "btnReceive", function()
                    -- 点击领取奖励
                    self:C2S_FL_YcR();
                end)
                UI.enable(tempNode, "isBuy", true);
                UI.enable(tempNode, "isBuy/received", false);
            end
            if args.weekDay > 0 and args.items[2].received then
                UI.enable(tempNode, "Reward/ui/received", false);
                UI.enable(tempNode, "Reward/ui/weekDay", true);
                UI.text(tempNode, "Reward/ui/weekDay", args.weekDay);
            else
                UI.enable(tempNode, "Reward/ui/received", true);
                UI.enable(tempNode, "Reward/ui/weekDay", false);
            end
            UI.text(tempNode, "isBuy/day", args.yearCardDay);
        else
            UI.enable(tempNode, "btnReceive/unread", false)
            UI.enable(tempNode, "btnReceive", true);
            UI.enable(tempNode, "isBuy", false);
            UI.text(tempNode, "btnReceive/Text", "HoneyP" .. math.floor(args.RMB * 10));
            UI.button(tempNode, "btnReceive", function()
                -- 点击年卡充值
                ComTools.charge(config.cardMonthMap[1],"yearCard", 2000, function()
                    self:C2S_FLBYCCallBack();
                    self:C2S_FL_YcOOP();
                end)
            end)
        end
        -- 显示可领取物品
        for i = 1, #args.items do
            UI.draw(tempNode, "Reward/btnWeek" .. i, args.items[i]);
            UI.enable(tempNode, "Reward/btnWeek" .. i .. "/received", args.items[i].received);
            UI.enable(tempNode, "Reward/btnWeek" .. i .. "/ef", not args.items[i].received);
            UI.button(tempNode, "Reward/btnWeek" .. i, function()
                UI.showItemInfo(args.items[i].itemID);
            end)
        end
        self:C2S_FL_UnRead();
    end)
end

-- 领取年卡奖励
function Class:C2S_FL_YcR()
    message:send("C2S_FL_YcR", {}, function(args)
        if args.code == "ok" then
            local info = {};
            for i = 1, #args.items do
                local temp = {
                    id = args.items[i].itemID,
                    itemIcon = args.items[i].itemIcon,
                    count = args.items[i].itemNum
                }
                table.insert(info, temp);
            end
            ItemTools.addItemsDis(info);
        elseif args.code == "fail" then
            UI.showHint("签到错误");
        end
        self:C2S_FL_YcOOP();
    end)
end

-- 小红点功能
function Class:C2S_FL_UnRead()
    message:send("C2S_FL_UnRead", {}, function(args)
        self.redDot = args
        local unreadNode = UI.child(self.node, "BottomBtns/unReadNode");
        UI.enableAll(unreadNode, false);
        for i = 1, #args.unread do
            local temp = UI.child(unreadNode, i - 1);
            UI.enable(temp, args.unread[i]);
        end
    end)
end
-- 首充界面
function Class:C2S_FL_FirstChargeOOP(msgType)
    if msgType == nil then
        msgType = 0;
    end
    message:send("C2S_FL_FirstCharge", {
        msgType = msgType
    }, function(args)
        local btnGroup = UI.child(self.node, "page/shuochong/btnGroup");
        local itemGroup = UI.child(self.node, "page/shuochong/ItemGroup");
        for i = 1, 4 do
            UI.enable(btnGroup, tostring(i), args.firstCharge == 0);
        end
        for i = 0, 4 do
            local temp = UI.child(itemGroup, tonumber(i));
            UI.button(temp, function()
                -- 物品信息
                UI.showItemInfo(args.items[i + 1].itemID);
            end);
            UI.draw(temp, args.items[i + 1]);
            UI.enable(temp, "received", args.firstCharge == 2);
            UI.enable(temp, "ef", args.firstCharge ~= 2);
        end
        UI.enable(btnGroup, "received", args.firstCharge == 2);
        UI.enable(btnGroup, "btnReceive", args.firstCharge == 1);
        if args.heroID > 0 then
            Story.show({
                heroID = args.heroID,
                endFun = function()
                    self:C2S_FL_FirstChargeOOP();
                end
            })
        end
    end)
end
-- 神迹打开页面
function Class:C2S_FL_Miracle()
    message:send("C2S_FL_Miracle", {}, function(args)
        for i = 1, #args.str do
            UI.text(self.node, "page/miracle/txtNode/str" .. i, args.str[i]);
        end
        self:C2S_FL_UnRead();
    end)
end

function Class:C2S_FLBYCCallBack()
    message:send("C2S_FLBYCCallBack", {}, function(args)
        if args.wifeID > 0 then
            Story.show({
                wifeID = args.wifeID,
            })
        end
    end)
end

return Class
