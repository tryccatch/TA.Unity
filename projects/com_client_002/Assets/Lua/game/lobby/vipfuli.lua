local Class = {
    res = "ui/vipfuli"
}
-- 福利脚本
function Class:init()
    self.vipIndex = 1;
    self.hwPos = {
        [2] = -200,
        [3] = -200,
        [4] = 220,
        [5] = -200,
        [6] = 220,
        [7] = -200,
        [8] = 220,
        [9] = -220,
        [10] = 220,
        [11] = -200,
        [12] = -220
    }

    UI.button(self.node, "btnClose", function()
        UI.close(self);
    end);
    self:OnOpen();

end
-- 打开页面
function Class:OnOpen()
    local vipCfg = {}
    for i = 2, #config.vip do
        local temp = config.vip[i];
        local x = i - 1;
        temp.viplevel = x;
        temp.btnVIP = function()
            if self.vipIndex == x then
                return ;
            end
            UI.enable(self.node, "bg/page_1", x == 1);
            UI.enable(self.node, "bg/page_2", x ~= 1);
            self.vipIndex = x;
            --log(self.vipIndex);
            if x > 1 then
                self:SetPage2();
            end
            self:SetItems(self.vipIndex);
            UI.image(self.node, "Rward/vip", "VipFuliJiangliUI", self.vipIndex);
            UI.child(self.node, "Rward/vip"):GetComponent(typeof(CS.UnityEngine.UI.Image)):SetNativeSize();
        end
        table.insert(vipCfg, temp);
    end
    UI.draw(self.node, "bottomPin/VIPBtnGroup/Viewport/Content", vipCfg);
    UI.enable(self.node, "bg/page_1", true);
    UI.enable(self.node, "bg/page_2", false);
    self:SetItems(1);
end
-- 设置page2页面
function Class:SetPage2()
    local vipCfg = cloneTable(config.vip[self.vipIndex + 1])
    local temp = {};
    temp.price = vipCfg.pay / 100;
    temp.vip = self.vipIndex;
    self:DesObj();
    if vipCfg.heroID > 0 then
        local heroCfg = config.hero[vipCfg.heroID]
        temp.name = vipCfg.heroID
        temp.specialty = heroCfg.specialty;
        temp.attr = heroCfg.allGrows;
        local heroAni = UI.showNode(self.node, "bg/page_2/aniNode", "Anim/hero" .. temp.name);
        UI.playAnim(heroAni, "idle");
        UI.setLocalPosition(heroAni, nil, self.hwPos[self.vipIndex]);
    else
        temp.name = vipCfg.wifeID;
        temp.specialty = 3;
        temp.attr = config.wife[vipCfg.wifeID].beauty;
        local wifeAni = UI.showNode(self.node, "bg/page_2/aniNode", "Anim/wife" .. temp.name);
        UI.playAnim(wifeAni, "idle")
        UI.setLocalPosition(wifeAni, nil, self.hwPos[self.vipIndex]);
    end
    UI.draw(self.node, "bg/page_2", temp);
    log(vipCfg.pay)
    UI.image(self.node, "bg/page_2/ui/Num", "rechargeNum", config.vip[self.vipIndex + 1].pay);
    log(vipCfg.pay)

end

-- 设置奖励物品
function Class:SetItems(index, isGetItem)
    if isGetItem == nil then
        isGetItem = 0;
    end
    local tempNode = UI.child(self.node, "Rward/Items/V/C");
    message:send("C2S_VIPFuli_Items", {
        vipLevel = index,
        isGetItem = isGetItem
    }, function(args)
        if args.code == "fail" then
            UI.showHint("VIP等级不足 请充值");
            UI.show("game.lobby.recharge");
        elseif args.code == "error_nogold" then
            UI.showHint("元宝不足")
        end

        UI.draw(tempNode, args.items);

        UI.image(self.node, "Rward/vip", "VipFuliJiangliUI", (args.state == 2 or 3) and self.vipIndex or 0);
        UI.child(self.node, "Rward/vip"):GetComponent(typeof(CS.UnityEngine.UI.Image)):SetNativeSize();

        for i = 1, #args.items do
            UI.button(tempNode, i - 1, function()
                UI.showItemInfo(args.items[i].itemID);
            end)
        end
        local btn = UI.child(self.node, "Rward/btn");
        local received = UI.child(self.node, "Rward/received");
        UI.enableAll(btn, false);
        UI.enable(received, false);
        UI.enable(btn, true);

        UI.button(btn, function()
            -- 充值 领取  购买专属礼包 领取专属礼包
            self:SetItems(self.vipIndex, 1);
        end)

        if args.state == 0 then
            UI.enable(btn, "gold", true);
            UI.text(btn, "gold", "充 值");
            UI.button(btn, function()
                -- 跳转页面
                ComTools.openRecharge();
            end)
        elseif args.state == 1 then
            UI.enable(btn, "gold", true);
            UI.enable(btn, "receive", true);
            UI.text(btn, "gold", "领 取");
        elseif args.state == 2 then
            UI.enableAll(btn, true);
            UI.enable(btn, "receive", false);
            UI.enable(btn, "gold", false);
            UI.text(btn, "buy/gold", args.gold);
        elseif args.state == 3 then
            UI.enable(btn, false);
            UI.enable(received, true);
        end
        if args.itemR == 1 then
            local temp1 = {}
            for i = 1, #config.vip[self.vipIndex + 1].itemID, 2 do
                local temp = {};
                temp.id = config.vip[self.vipIndex + 1].itemID[i];
                temp.count = config.vip[self.vipIndex + 1].itemID[i + 1]
                table.insert(temp1, temp);
            end
            ItemTools.addItemsDis(temp1);
        elseif args.itemR == 2 then
            local temp1 = {}
            for i = 1, #config.vip[self.vipIndex + 1].itemOnlyID, 2 do
                local temp = {};
                temp.id = config.vip[self.vipIndex + 1].itemOnlyID[i];
                temp.count = config.vip[self.vipIndex + 1].itemOnlyID[i + 1];
                table.insert(temp1, temp);
            end
            ItemTools.addItemsDis(temp1);
        end
        -- 显示豪杰或妻子
        if args.heroID > 0 then
            Story.show({
                heroID = args.heroID
            })
        end
        if args.wifeID > 0 then
            Story.show({
                wifeID = args.wifeID
            })
        end
        -- 小红点显示功能
        local vipBtnNode = UI.child(self.node, "bottomPin/VIPBtnGroup/Viewport/Content");
        for i = 1, #args.unRead do
            local temp = UI.child(vipBtnNode, i - 1);
            UI.enable(temp, "unread", args.unRead[i])
            ;
        end
    end)
end
-- 删除动画
function Class:DesObj()
    for i = 1, UI.child(self.node, "bg/page_2/aniNode").childCount do
        local temp = UI.child(self.node, "bg/page_2/aniNode");
        UI.close(UI.child(temp, i - 1));
    end
end

function Class:onFront()

    if self.vipIndex > 1 then
        self:SetPage2();
    end
    self:SetItems(self.vipIndex);

end

return Class;
