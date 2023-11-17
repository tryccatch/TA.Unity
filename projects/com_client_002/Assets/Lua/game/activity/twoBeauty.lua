local Class = {
    res = "ui/twoBeauty"
}
-- 绝代双骄脚本
function Class:closePage()
    self.hasClose = true
    if self.hasClose then
        UI.close(self)
    end
end

function Class:init()
    self.hasClose = false

    UI.enableAll(self.node, false)
    self:C2S_HD_TbOnopen();
    self.bTwoBeauty = true;
    UI.button(self.node, "bg/btnClose", function()
        self:closePage()
    end)

    UI.button(self.node, "MsgBox/BtnBack", function()
        UI.enable(self.node, "MsgBox", false)
    end)

    -- 绝代双骄按钮  
    UI.button(self.node, "TopBtn/btnTwoBeauty", function()
        -- 打开绝代双骄页面
        if not self.bTwoBeauty then
            self:C2S_HD_TwoBeauty();
            self.bTwoBeauty = true;
        end

    end)
    -- 道具按钮
    UI.button(self.node, "TopBtn/btnProps", function()
        -- 打开道具页面
        if self.bTwoBeauty then
            self:C2S_HD_TbProps();
            self.bTwoBeauty = false;
        end
    end)
    self:C2S_HD_TwoBeauty();
    --self:showAnim()
end

-- 打开绝代双骄页面  获取时间
function Class:C2S_HD_TbOnopen()
    message:send("C2S_HD_TbOnopen", {}, function(args)
        if self.hasClose then
            return
        end
        UI.enableAll(self.node, true)
        UI.enable(self.node, "MsgBox", false)
        UI.enable(self.node, "Props", false);

        if args.Countdown > 0 then
            UI.txtUpdateTime(self.node, "bg/Countdown", args.Countdown, function()
                -- 倒计时为0  活动结束 飘字提示 关闭页面  入口消失
                UI.showHint("绝代双骄已结束");
                self:closePage()
            end)
            -- 用秒转换时间
            local startDate = convertToTime(args.startDate);
            local endDate = convertToTime(args.endDate);
            local strDate = startDate.month .. "月" .. startDate.day .. "日-" ..
                    endDate.month .. "月" .. endDate.day .. "日";
            UI.text(self.node, "bg/Date", strDate)
        else
            UI.showHint("绝代双骄已结束");
            self:closePage()
        end
    end)
end

-- 重置页面
function Class:ResetHome()
    UI.enable(self.node, "Home", false);
    UI.enable(self.node, "Props", false);
    UI.enable(self.node, "MsgBox", false);
    UI.enable(self.node, "TopBtn/btnTwoBeauty/selected", false);
    UI.enable(self.node, "TopBtn/btnProps/selected", false);
end

function Class:showAnim()
    local item = UI.child(self.node, "Home/BeautysGroup/Viewport/Content");
    local cfg = config.event17
    UI.cloneChild(item, #cfg)
    for i, v in ipairs(cfg) do
        local temp = UI.child(item, i - 1);
        if UI.child(temp, "heroAnim").childCount <= 0 then
            local heroAni = UI.showNode(temp, "heroAnim", "Anim/" .. "hero" .. v.heroID);
            local wifeAni = UI.showNode(temp, "wifeAnim", "Anim/" .. "wife" .. v.hongyanID);
            UI.playAnim(heroAni, "idle")
            UI.playAnim(wifeAni, "idle")
        end
    end
end

--- 发送消息  获取绝代双骄状态  并显示
function Class:C2S_HD_TwoBeauty()
    self:ResetHome();
    self:showAnim()
    UI.enable(self.node, "TopBtn/btnTwoBeauty/selected", true);
    local item = UI.child(self.node, "Home/BeautysGroup/Viewport/Content");
    message:send("C2S_HD_TwoBeauty", {}, function(args)
        if self.hasClose then
            return
        end
        if #args.info > 0 and args ~= nil then
            UI.enable(self.node, "Home", true);
            UI.draw(item, args.info);
            for i = 1, #args.info do
                local temp = UI.child(item, i - 1);
                -- 根据是否拥有显示可兑换  
                UI.enableAll(temp, "Node", false);
                if args.info[i].haved then
                    UI.enable(temp, "Node/uiHaved", true);
                else
                    UI.enable(temp, "Node/btnZhaomu", true);
                    UI.draw(temp, "Node/btnZhaomu", args.info[i]);
                    UI.text(temp, "Node/btnZhaomu/itemNum", args.info[i].itemCount .. "/" .. args.info[i].itemSub)
                    UI.button(temp, "Node/btnZhaomu", function()
                        -- 招募豪杰与妻子
                        local msgbox = UI.child(self.node, "MsgBox");
                        local temp = args.info[i];
                        UI.enable(msgbox, true);
                        UI.draw(msgbox, temp);
                        UI.image(msgbox, "itemID", "Item", temp.itemID);
                        UI.text(msgbox, "Title", "招募豪杰");
                        UI.text(msgbox, "tip",
                                "是否使用" .. config.item[73].name .. "X" .. temp.itemSub .. "招募豪杰");
                        UI.button(msgbox, "BtnNo", function()
                            UI.enable(msgbox, false);
                        end)
                        UI.button(msgbox, "BtnBack", function()
                            UI.enable(msgbox, false);
                        end)
                        UI.button(msgbox, "BtnYes", function()
                            -- 点击确定，招募豪杰
                            self:C2S_HD_TbRedeemHongyan(temp);
                        end)
                        UI.button(msgbox, "itemID", function()
                            UI.showItemInfo(73)
                        end)
                    end)
                end
                -- 显示豪杰与妻子  龙骨动画
                if UI.child(temp, "heroAnim").childCount <= 0 then
                    local heroAni = UI.showNode(temp, "heroAnim", "Anim/" .. args.info[i].heroName);
                    local wifeAni = UI.showNode(temp, "wifeAnim", "Anim/" .. args.info[i].wifeName);
                    UI.playAnim(heroAni, "idle")
                    UI.playAnim(wifeAni, "idle")
                end
            end
        end
    end)
end
-- 打开道具界面
function Class:C2S_HD_TbProps()
    self:ResetHome();
    UI.enable(self.node, "TopBtn/btnProps/selected", true);
    local item = UI.child(self.node, "Props/PropGroup/Viewport/Content");
    message:send("C2S_HD_TbProps", {}, function(args)
        if self.hasClose then
            return
        end
        if #args.info > 0 and args.info ~= nil then
            UI.enable(self.node, "Props", true);
            UI.draw(item, args.info);
            for i = 1, #args.info do
                local temp = UI.child(item, i - 1);
                -- 根据是否拥有显示可兑换  
                UI.enableAll(temp, "Node", false);
                UI.image(temp, "ShopItemID", "Item", config.item[args.info[i].ShopItemID].icon);
                UI.enable(temp, "ShopItemID", "Item", true);
                if args.info[i].haved then
                    UI.enable(temp, "Node/uiHaved", true);
                else
                    UI.enable(temp, "Node/btnBuy", true);
                    UI.draw(temp, "Node/btnBuy", args.info[i]);
                    UI.text(temp, "Node/btnBuy/sub", args.info[i].itemCount .. "/" .. args.info[i].itemSub);
                    UI.button(temp, "Node/btnBuy", function()
                        -- 购买道具
                        local msgbox = UI.child(self.node, "MsgBox");
                        local temp = args.info[i];
                        UI.enable(msgbox, true);
                        UI.draw(msgbox, temp);
                        UI.image(msgbox, "itemID", "Item", temp.ShopItemID);
                        UI.text(msgbox, "Title", "兑换道具");
                        UI.text(msgbox, "tip", "是否使用" .. temp.itemName .. "X" .. temp.itemSub .. "兑换道具");
                        UI.button(msgbox, "BtnNo", function()
                            UI.enable(msgbox, false);
                        end)
                        UI.button(msgbox, "BtnYes", function()
                            -- 点击确定，兑换道具
                            self:C2S_HD_TbRedeemItem(temp);
                        end)
                        UI.button(msgbox, "itemID", function()
                            UI.showItemInfo(73)
                        end)
                    end)
                end
            end
        end
    end)
end
-- 兑换道具
function Class:C2S_HD_TbRedeemItem(temp)
    local msgbox = UI.child(self.node, "MsgBox");
    if temp.itemSub > temp.itemCount then
        UI.showHint("道具不足");
        UI.enable(msgbox, false);
    else
        message:send("C2S_HD_TbRedeemItem", {
            info = temp
        }, function(args)
            if self.hasClose then
                return
            end
            if args.code == "ok" then
                UI.enable(msgbox, false);
                local t = { args }
                ItemTools.addItemsDis(t);
            elseif args.code == "error_noItem" then
                UI.showHint("道具不足");
            elseif args.code == "fail" then
                UI.showHint("已兑换");
            end
            self:C2S_HD_TbProps();
        end)
    end
end
-- 绝代双骄兑换
function Class:C2S_HD_TbRedeemHongyan(temp)
    local msgbox = UI.child(self.node, "MsgBox");
    if temp.itemSub > temp.itemCount then
        UI.showHint("道具不足");
        UI.enable(msgbox, false);
    else
        message:send("C2S_HD_TbRedeemHongyan", {
            info = temp
        }, function(args)
            if self.hasClose then
                return
            end
            if args.code == "ok" then
                UI.enable(msgbox, false);
                -- UI.close(self);
                Story.show({
                    heroID = args.heroID,
                    endFun = function()
                        Story.show({
                            wifeID = args.wifeID
                        })
                    end
                })
            elseif args.code == "error_noItem" then
                UI.showHint("道具不足");
            elseif args.code == "fail" then
                UI.showHint("已兑换");
            end
            self:C2S_HD_TwoBeauty();
        end)
    end
end
return Class
