local Class = {
    res = "ui/unity_noble"
}

function Class:close()
    self.controller:close(self.controller.Pages.Rich)
end
-- 联盟  权贵
function Class:init(params)
    self.controller = params.controller
    local HomeBtnNode = UI.child(self.node, "Home/btnNode");

    UI.button(HomeBtnNode, "btnClose", function()
        -- 关闭页面
        self:close();
    end)

    UI.button(self.node, "ranking/btnBack", function()
        -- 关闭排行榜页面
        UI.enable(self.node, "ranking", false);
    end)

    UI.button(self.node, "noLalong/btnBack", function()
        -- 关闭拉拢条件不足页面
        UI.enable(self.node, "noLalong", false);
    end)

    UI.button(self.node, "noLalong/btnOK", function()
        -- 关闭拉拢条件不足页面
        UI.enable(self.node, "noLalong", false);
    end)

    UI.button(self.node, "shihao/btnNode/btnBack", function()
        -- 关闭示好功能页面
        self:HideShihao();
    end)
    UI.button(HomeBtnNode, "btnHelp", function()
        -- 权贵帮助页面
        showHelp("alliancepower");
    end)

    self:C2S_UN();
end

function Class:dealWithCode(code, successMsg, failMsg, itemName, funType)
    print("权贵结果：", code, successMsg)
    local tip = successMsg
    local exit = false
    local close = false
    if code == "noUnity" then
        exit = true
        tip = "联盟数据不存在！"
    elseif code == "notMember" then
        exit = true
        tip = "您已不是联盟成员！"
    elseif code == "noAuthority" then
        tip = "暂无权限！"
    elseif code == "validNobleId" then
        tip = "权贵Id错误 ，请退出重试"
        close = true
    elseif code == "fail" then
        tip = failMsg
    elseif code == "error_noDrawNum" then
        tip = "拉拢次数已耗完"
    elseif code == "error_noTime" then
        tip = "该权贵处于保护状态，不可拉拢"
    elseif code == "alreadyInUnity" then
        if funType == 2 or funType == 3 then
            tip = "该权贵已经加入联盟，不能进行离间"
        elseif funType == 1 or funType == 2 then
            tip = "该权贵已加入联盟，无需再次拉拢"
        end
    elseif code == "error_noItem" then
        if itemName then
            tip = itemName .. "不足"
        else
            tip = "道具不足"
        end
    elseif code == "error_noGold" then
        tip = "元宝不足，可前往充值获取"
    elseif code == "error_noMoney" then
        tip = "银两不足"
    elseif code == "error_noWealth" then
        tip = "联盟财富不足"
    end

    if tip ~= nil then
        UI.showHint(tip)
    end
    if exit then
        self.controller:exit()
    elseif close then
        self:close()
    end

    return exit, close
end
--- 获取联盟 权贵Toggle
function Class:C2S_UN(nobleID)
    local tempNode = UI.child(self.node, "Home/G/V/C");
    local btnShihao = UI.child(self.node, "Home/btnNode/btnShihao");
    local btnLijian = UI.child(self.node, "Home/btnNode/btnLijian");
    local btnLalong = UI.child(self.node, "Home/btnNode/btnLalong");

    if nobleID == nil then
        nobleID = 1;
    end

    message:send("C2S_UN", {
        nobleID = nobleID
    }, function(args)
        local exit, close = self:dealWithCode(args.code)
        if exit or close then
            return
        end

        local nobleList = args.roles
        for i = 1, #nobleList do
            if nobleList[i].isTarget then
                nobleID = nobleList[i].id
                break
            end
        end

        UI.enable(self.node, "Home/btnNode/btnSetTarget", args.isSetTarget);
        UI.draw(tempNode, args.roles);
        for i = 1, #args.roles do
            local temp = UI.child(tempNode, i - 1);
            local role = args.roles[i];
            UI.toggle(temp, function()
                print("执行回调：", i)
                UI.button(btnShihao, function()
                    -- 对权贵示好
                    self:C2S_UNShihaoOpen(0, i);
                end)
                self:C2S_UNInfo(role.id);

                if role.isMyNoble then
                    UI.setGray(btnLijian);
                    UI.setGray(btnLalong);
                    UI.button(btnLijian);
                    UI.button(btnLalong);
                else
                    UI.clearGray(btnLijian);
                    UI.clearGray(btnLalong);
                    UI.button(btnLijian, function()
                        -- 对权贵离间
                        self:C2S_UNShihaoOpen(2, role.id);
                    end);
                    UI.button(btnLalong, function()
                        -- 对权贵拉拢
                        self:C2S_UNQueryDraw(role.id);
                    end);
                end
                UI.button(self.node, "Home/btnNode/btnAllianceLB", function()
                    -- 联盟排行
                    self:C2S_UNRank(role.id);
                end)
                if args.isSetTarget then
                    UI.button(self.node, "Home/btnNode/btnSetTarget", function()
                        -- 设为目标
                        self:C2S_UNSetTarget(role.id);
                    end);
                end
            end)
        end
        UI.SetToggleIsOn(tempNode, nobleID - 1);
    end)
end
--- 获取联盟权贵信息
function Class:C2S_UNInfo(nobleID)
    local tempNode = UI.child(self.node, "Home/txtNode");
    local btnLalong = UI.child(self.node, "Home/btnNode/btnLalong");
    local btnLijian = UI.child(self.node, "Home/btnNode/btnLijian");

    message:send("C2S_UNInfo", {
        nobleID = nobleID
    }, function(args)
        if args.code == "ok" then
            print("获取权贵信息：", nobleID, "保护时间:", args.time)
            UI.draw(self.node, "Home/base", args);
            UI.draw(tempNode, args);
            if args.time > 0 then

                UI.txtUpdateTime(tempNode, "timeNode/time", args.time, function()
                    self:C2S_UNInfo(nobleID);
                end)
                UI.button(btnLalong, function()
                    UI.showHint("在保护期间无法进行拉拢");
                end);
            end
            UI.draw(self.node, "Home/Addition", args.additionTxt);
            UI.enable(tempNode, "timeNode", args.time > 0);
        else
            self:DataError();
        end
    end)
end
-- 设置目标  拉拢权贵的ID
function Class:C2S_UNSetTarget(nobleID)
    message:send("C2S_UNSetTarget", {
        nobleID = nobleID
    }, function(args)
        local exit, close = self:dealWithCode(args.code)
        if exit or close then
            return
        end

        self:C2S_UN(nobleID);
    end)
end

function Class:DataError()
    UI.showHint("数据错误，请重新打开界面");
    self:close();
end
-- 根据权贵ID显示排行榜数据
function Class:C2S_UNRank(nobleID)
    local tempNode = UI.child(self.node, "ranking");
    local tempC = UI.child(tempNode, "G/V/C");
    message:send("C2S_UNRank", {
        nobleID = nobleID
    }, function(args)
        local exit, close = self:dealWithCode(args.code)
        if exit or close then
            return
        end
        UI.enable(tempNode, true);
        UI.enable(tempNode, "no", #args.rankdatas < 1);
        UI.draw(tempNode, args);
        if args.myData.rank == -1 then
            UI.text(tempNode, "myData/rank", "暂未上榜");
        end
        UI.draw(tempC, args.rankdatas);
    end)
end

function Class:getItemName(funType, nobleId)
    local temp = config["allianceNoble"][nobleId]
    local itemId = 0
    if funType % 2 == 0 then
        itemId = temp.moneyFrienditem[0]
    else
        itemId = temp.goldFriendItem[0]
    end
    local itemConfig = table.find(config["item"], function(a)
        return a.id == itemId
    end)
    if itemConfig then
        return itemConfig.name
    end

    return "权贵令"
end

function Class:getNobleName(id)
    return config.allianceNobleMap[id].name
end

-- 下方按钮对应的按钮，共有六个
function Class:C2S_UNShihaoOpen(funType, nobleID)
    local tempNode = UI.child(self.node, "shihao");
    message:send("C2S_UNShihaoOpen", {
        funType = funType,
        nobleID = nobleID
    }, function(args)
        -- 设置标签
        local failMsg = nil
        if funType >= 4 then
            failMsg = "拉拢失败"
        end
        local exit, close = self:dealWithCode(args.code, nil, failMsg, self:getItemName(funType, nobleID))
        if exit or close then
            return
        end
        if funType >= 0 and funType <= 1 then
            UI.text(tempNode, "title", "示好");
            UI.text(tempNode, "btnNode/btnMoney/Text", "银两");
            UI.text(tempNode, "btnNode/btnOK/Text", "示好");
        elseif funType >= 2 and funType <= 3 then
            UI.text(tempNode, "title", "离间");
            UI.text(tempNode, "btnNode/btnMoney/Text", "银两");
            UI.text(tempNode, "btnNode/btnOK/Text", "离间");
        elseif funType >= 4 and funType <= 5 then
            UI.text(tempNode, "title", "拉拢");
            UI.text(tempNode, "btnNode/btnMoney/Text", "联盟财富");
            UI.text(tempNode, "btnNode/btnOK/Text", "拉拢");
        end
        -- 设置数据
        args.belongF = goldFormat(args.belongF);
        args.mF = goldFormat(args.mF);
        UI.draw(tempNode, "TxtNode", args);
        UI.draw(tempNode, "TxtNode/jiangli", args.jiangli);
        local items = args.items;
        for i = 1, #items do
            items[i].id = heroFightValueFormat(items[i].id)
        end
        local NodeC = UI.child(tempNode, "G/V/C");
        UI.draw(NodeC, items);

        for i = 1, #items do
            local tempItemNode = UI.child(NodeC, i - 1);
            UI.enable(tempItemNode, "txt01", not UI.child(tempItemNode, "icon").gameObject.activeSelf);
        end
        -- 设置隐藏显示
        UI.enable(tempNode, true);
        UI.enable(tempNode, "TxtNode/lastNum", funType > 3);

        local btnNode = UI.child(tempNode, "btnNode");
        local index = funType;
        UI.button(btnNode, "btnMoney", function()
            if not UI.child(btnNode, "btnMoney/selected").gameObject.activeSelf then
                index = funType - 1;
                self:C2S_UNShihaoOpen(index, nobleID)
                UI.enable(btnNode, "btnMoney/selected", true);
                UI.enable(btnNode, "btnGold/selected", false);
            end
        end)
        UI.button(btnNode, "btnGold", function()
            if not UI.child(btnNode, "btnGold/selected").gameObject.activeSelf then
                index = funType + 1;
                self:C2S_UNShihaoOpen(index, nobleID)
                UI.enable(btnNode, "btnMoney/selected", false);
                UI.enable(btnNode, "btnGold/selected", true);
            end
        end)
        UI.button(btnNode, "btnOK", function()
            -- 确认按钮
            self:C2S_UNFunOK(index, nobleID);
        end)
    end)
end
-- 查询拉拢是否满足条件
function Class:C2S_UNQueryDraw(nobleID)
    message:send("C2S_UNQueryDraw", {
        nobleID = nobleID
    }, function(args)
        local exit, close = self:dealWithCode(args.code)
        if exit or close then
            return
        end

        if args.code == "ok" then
            self:C2S_UNShihaoOpen(4, nobleID);
        elseif args.code == "fail" then
            local tempT = {}
            tempT.drawInfluenceNeed = goldFormat(args.drawInfluenceNeed);
            tempT.drawFavorNeed = goldFormat(args.drawFavorNeed);
            UI.draw(self.node, "noLalong", tempT);
            UI.draw(self.node, "noLalong/G", args);
            UI.enable(self.node, "noLalong");
        end
    end)
end

function Class:C2S_UNFunOK(funType, nobleID)
    message:send("C2S_UNFunOK", {
        funType = funType,
        nobleID = nobleID
    }, function(args)
        local successMsg = "示好成功"
        local failMsg = "示好失败"
        if funType == 2 or funType == 3 then
            successMsg = "离间成功"
            failMsg = "离间失败"
        elseif funType == 4 or funType == 5 then
            successMsg = "拉拢成功"
            failMsg = "离间失败"
        end
        local exit, close = self:dealWithCode(args.code, successMsg, nil, self:getItemName(funType, nobleID), funType)
        if exit or close then
            return
        end
        self:HideShihao();
        print("CN OVER")

        if args.code == "ok" then
            -- 成功，处理主要逻辑
            if funType > 3 then
                -- 拉拢
                print(args)
                UI.enable(self.node, "lalongChenggong", true);
                UI.draw(self.node, "lalongChenggong", args);
                UI.draw(self.node, "lalongChenggong/txtNode", args);
                UI.draw(self.node, "lalongChenggong/txtNode", args.rewardStr);
                UI.text(self.node, "lalongChenggong/txtNode/nobleName", self:getNobleName(nobleID))
                UI.enable(self.node, "lalongChenggong/txtNode/nobleName", true)
                self:C2S_UN(nobleID)
            else
                -- 示好  或者离间
                UI.enable(self.node, "ShowReward/img01", funType < 2);
                UI.enable(self.node, "ShowReward/img02", funType > 1);
                UI.draw(self.node, "ShowReward/txtNode", args.rewardStr);
                UI.enable(self.node, "ShowReward", true);
                self:C2S_UNInfo(nobleID);
            end
        elseif args.code == "fail" then
            if funType > 3 then
                UI.enable(self.node, "lalongShibai", true);
                UI.draw(self.node, "lalongShibai", args);
            end
        end
        self:ShowBelongFriend(args.code,funType)
    end)
end

function Class:ShowBelongFriend(code,funType)
    if funType > 3 then
        UI.enable(self.node,"lalongChenggong/txtNode/03",code == "fail")
        --UI.enable(self.node,"lalongChenggong/text/belongText",code == "fail")
    end
end

function Class:HideShihao()
    UI.enable(self.node, "shihao", false);
    UI.enable(self.node, "shihao/btnNode/btnMoney/selected", true);
    UI.enable(self.node, "shihao/btnNode/btnGold/selected", false);
end

return Class

