local Class = {
    res = "ui/yinyuanci"
}

function Class:addRedDot(addOrRemove)
    local btnRequest = UI.child(self.node, "Home/BottomPin/btnRequestMarried2")
    if addOrRemove then
        RedDot.registerBtn(btnRequest, RedDot.SystemID.DatingHouseMarryRequest)
    else
        RedDot.unregisterBtn(btnRequest, RedDot.SystemID.DatingHouseMarryRequest)
    end
end

function Class:init()
    self.HomeTopPin = UI.child(self.node, "Home/TopPin");
    self.HomeBottomPin = UI.child(self.node, "Home/BottomPin");
    self.UnMarriedSeat = UI.child(self.HomeBottomPin, "UnMarriedChildGroup/Viewport/Content");
    self.MarriedSeat = UI.child(self.HomeBottomPin, "MarriedChildGroup/Viewport/Content");

    self.defultChildID = 0;
    self.homeBtnUnMarried = true;
    self.pageNumUnMarried = 1;
    self.pageNumMarried = 1;
    self.pageNumReqTiqin = 0;
    self.pageNumReqMax = 1;
    -- 未婚子女列表
    -- 内置属性1 childInfo  子数据
    -- 内置属性2 seat Home页面底部席位显示
    self.UnMarriedChildren = {};
    -- 已婚子女列表
    self.MarriedChildren = {};
    self.myItemNum = {
        item53 = 0,
        item54 = 0,
        item55 = 0
    }
    -- 0单个对象提亲 1全服提亲 
    self.allMm = 0;
    self.mmItem = {};
    self.reqTiqinInfo = {};

    self.toChildInfo = nil;

    -- 按钮事件
    UI.button(self.HomeTopPin, "BtnClose", function()
        -- 关闭本页面
        self:addRedDot(false)
        UI.close(self);
    end)
    UI.button(self.HomeTopPin, "btnHelp", function()
        showHelp("marry");
    end)
    UI.button(self.HomeBottomPin, "NoChild/btnGotoSishu", function()
        -- 关闭本页面
        UI.close(self);
        UI.openPage(UIPageName.School)
    end)
    -- ===============================================================================
    -- 未婚子嗣和已婚子嗣
    UI.button(self.HomeBottomPin, "bg/btnUnMarried", function()
        if not self.homeBtnUnMarried then
            self:ResetHomeUI();
            self.homeBtnUnMarried = true
            self:ShowHomeBtnUnMarried();
            self:C2S_UnMarried();
        end
    end)
    UI.button(self.HomeBottomPin, "bg/btnMarried", function()
        -- 已婚子嗣列表
        if self.homeBtnUnMarried then
            self:ResetHomeUI();
            self.homeBtnUnMarried = false
            self:ShowHomeBtnUnMarried();
            self:C2S_MarriedChild();
        end
    end)
    -- ===============================================================================
    -- 提亲页面相关
    UI.button(self.HomeTopPin, "UnMarriedAttr/BtnNode/TxtNode/btnStop", function()
        -- 结束提亲
        self:C2S_StopMarriage();
    end)
    UI.button(self.HomeTopPin, "UnMarriedAttr/BtnNode/tittle/btnMentionMarried", function()
        -- 提亲按钮
        -- 打开提亲页面 选择全服提亲or指定玩家提亲
        local temp = table.find(self.UnMarriedChildren, function(args)
            return args.childInfo.id == self.defultChildID;
        end)
        if temp == nil then
            UI.showHint("提亲错误，请重新打开页面")
            UI.close(self);
        else
            local childInfo = temp.childInfo;
            local mmTopPin = UI.child(self.node, "MentionMarried/TopPin");
            self:SetChildShow(mmTopPin, childInfo);
            UI.SetToggleIsOn(self.node, "MentionMarried/BottomPin/bgMentionMarried/ToggleGroup/toggle2");
        end
        UI.enable(self.node, "MentionMarried", true);
    end)
    UI.button(self.HomeTopPin, "UnMarriedAttr/BtnNode/tittle/btnGiveMarried", function()
        -- 赐婚
        if client.user.vip < config.childConfigureMap[1].VIP then
            UI.showHint("VIP" .. config.childConfigureMap[1].VIP .. "解锁赐婚功能")
            return ;
        end
        local cfg = config.childConfigureMap[1];
        local temp = table.find(self.UnMarriedChildren, function(args)
            return args.childInfo.id == self.defultChildID;
        end)
        if temp == nil then
            UI.showHint("赐婚错误，请重新打开页面")
        else
            local childInfo = temp.childInfo;
            local giveMarried = UI.child(self.node, "giveMarried");
            UI.enable(giveMarried, true);
            local myChild = UI.child(giveMarried, "myChild");
            self:SetChildShow(myChild, childInfo);
            UI.text(myChild, "grawName", childInfo.growName);

            local txtNode = UI.child(giveMarried, "BottomPin/txtNode");
            local growNames = {
                [1] = "童生",
                [2] = "秀才",
                [3] = "举人",
                [4] = "贡生",
                [5] = "进士",
                [6] = "状元"
            }
            UI.text(txtNode, "quaName", childInfo.growName);
            local qua = childInfo.qua
            if qua > 5 then
                qua = 5
            end
            UI.text(txtNode, "quaName2", growNames[qua + 1])
            local color = ColorStr.red;
            if client.user.gold >= cfg.goldMarrigeCost[childInfo.qua] then
                color = ColorStr.gold;
            end
            UI.text(txtNode, "subGold", UI.colorStr(cfg.goldMarrigeCost[childInfo.qua], color));
            UI.button(giveMarried, "BottomPin/btnGiveMarried", function()
                -- 赐婚按钮
                self:C2S_Cihun(childInfo);
            end)
        end
    end)
    UI.button(self.node, "giveMarried/btnBack", function()
        UI.enable(self.node, "giveMarried", false);
    end)
    -- ===============================================================================
    -- 提亲页面相关
    local mentionMarriedNode = UI.child(self.node, "MentionMarried");
    local mmButtomPin = UI.child(self.node, "MentionMarried/BottomPin");
    UI.button(mentionMarriedNode, "btnBack", function()
        -- 关闭提亲页面  还原
        UI.enable(mentionMarriedNode, false);
    end)
    UI.toggle(mmButtomPin, "bgMentionMarried/ToggleGroup/toggle1", function()
        self:RefreshMMToggle();
    end)
    UI.toggle(mmButtomPin, "bgMentionMarried/ToggleGroup/toggle2", function()
        self:RefreshMMToggle(1);
    end)
    UI.button(mmButtomPin, "btnMentionMarried", function()
        -- 提亲功能按钮
        -- 判断是全服提亲还是单个提亲
        if self.allMm == 0 then
            local uuserID = UI.getValueInt(mmButtomPin, "bgMentionMarried/ToggleGroup/toggle1/iptPlayerID");
            if uuserID == nil or uuserID == "" or uuserID == " " then
                UI.showHint("请输入正确的玩家ID");
                return ;
            end
            if client.user.id == uuserID then
                UI.showHint("不能与自身联姻");
                return ;
            end
            if self.mmItem.subNum > self.mmItem.itemCount then
                UI.showHint("道具不足，无法提亲");
                return ;
            end
            self:C2S_Tiqin(uuserID);
        elseif self.allMm == 1 then
            if self.mmItem.subNum > self.mmItem.itemCount then
                UI.showHint("道具不足，无法提亲");
                return ;
            end
            self:C2S_Tiqin();
        end
    end)
    -- =============================================================================
    -- 招亲页面相关
    local zhaoqinNode = UI.child(self.node, "zhaoMarried");
    local myChild = UI.child(zhaoqinNode, "myChild");
    UI.button(self.HomeTopPin, "UnMarriedAttr/BtnNode/tittle/btnRequestMarried", function()
        -- 招亲
        -- 打开招亲页面
        UI.enable(zhaoqinNode, true);
        -- 设置子数据
        local child = table.find(self.UnMarriedChildren, function(args)
            return args.childInfo.id == self.defultChildID;
        end)
        local childInfo = child.childInfo;
        self:SetChildShow(myChild, childInfo);
        UI.text(myChild, "txtQuaName", childInfo.growName);
        self.toChildInfo = childInfo;
        self:C2S_ZhaoQin();
    end)
    UI.button(zhaoqinNode, "btnBack", function()
        -- 关闭招亲页面
        UI.enable(zhaoqinNode, false);
    end)
    UI.button(zhaoqinNode, "bgRefresh/btnRefresh", function()
        -- 刷新招亲对象
        if client.user.gold < config.childConfigureMap[1].zqRefSubGold then
            UI.showHint("元宝不足，可前往充值获得元宝");
        else
            -- 元宝足够  刷新
            self:C2S_ZhaoQin(1);
        end
    end)
    -- =============================================================================
    -- 提亲请求页面相关
    local reqMNode = UI.child(self.node, "RequestMarried");
    UI.dragBottom(reqMNode, "ChildGroup/Viewport/Content", self:C2S_ReqTiqin())
    UI.button(self.HomeBottomPin, "btnRequestMarried2", function()
        -- 打开提亲请求页面
        UI.enable(reqMNode, true);
        self:C2S_ReqTiqin();
    end)
    UI.button(reqMNode, "btnBack", function()
        UI.enable(reqMNode, false);
    end)
    UI.button(reqMNode, "btnAllRefuse", function()
        -- 拒绝全部提亲请求
        if #self.reqTiqinInfo == 0 or self.reqTiqinInfo == nil then
            UI.showHint("当前无提亲请求")
            return ;
        end
        self:C2S_AgreeTiqin(self.reqTiqinInfo[1], 2);
    end)
    -- =============================================================================
    -- 适婚子女页面相关
    local nubileNode = UI.child(self.node, "Nubile");
    UI.button(nubileNode, "btnBack", function()
        -- 关闭适婚子女页面
        UI.enable(nubileNode, false);
    end)
    -- =============================================================================
    -- 婚书页面相关
    UI.button(self.node, "MarriageBook/btnBack", function()
        UI.enable(self.node, "MarriageBook", false);
    end)

    self:C2S_UnMarried()

    self:addRedDot(true)
end

function Class:C2S_UnMarried()

    if self.C2S_UnMarried_ret then
        self:C2S_UnMarried_draw(self.C2S_UnMarried_ret)
    else
        message:send("C2S_UnMarriedChild", {
            pageNum = self.pageNumUnMarried
        }, function(args)
            -- self:ResetHomeUI();
            self.C2S_UnMarried_ret = args
            self:C2S_UnMarried_draw(args)
        end)
    end
end

function Class:C2S_UnMarried_draw(args)
    UI.enable(self.node, "Home/BottomPin/UnMarriedChildGroup", true);

    for _, v in ipairs(args.childBase) do
        v.momName = config.wifeMap[v.momID].name
        v.quaName = config.childGrowMap[v.qua].name
        v.growName = config.childGrowMap[v.qua].growName
        if v.level == 1 then
            v.talk = "哇--哇--";
        else
            local talk = config.childConfigure[1].talk;
            local n = math.random(1, #talk)
            v.talk = talk[n]
        end
    end

    local childCount = #args.childBase
    if childCount > 0 then
        -- 克隆节点
        UI.draw(self.UnMarriedSeat, args.childBase);
        self:SetChildDatas(args);
        self:ShowUnMarriedSeat();
        UI.SetToggleIsOn(self.UnMarriedChildren[1].seat);
        self.defultChildID = self.UnMarriedChildren[1].childInfo.id;
    else
        if self.pageNumUnMarried == 1 then
            UI.enable(self.HomeBottomPin, "NoChild", true);
            UI.enable(self.HomeTopPin, "mPic", false);
            UI.enable(self.HomeTopPin, "fPic", false);
        end
    end
    self:RefreshItemNum(args);
end

-- 重置主页面
function Class:ResetHomeUI()
    UI.enable(self.HomeTopPin, "mPic", false);
    UI.enable(self.HomeTopPin, "fPic", false);
    UI.enable(self.HomeTopPin, "UnMarriedAttr", false);
    UI.enable(self.HomeBottomPin, "MarriedChildGroup", false);
    UI.enable(self.HomeBottomPin, "UnMarriedChildGroup", false);
    UI.enable(self.HomeBottomPin, "NoChild", false);
    UI.enable(self.HomeBottomPin, "noMarriedChild", false);
    UI.enable(self.HomeBottomPin, "bg/btnUnMarried/Selected", false);
    UI.enable(self.HomeBottomPin, "bg/btnMarried/Selected", false);

    UI.enableAll(self.UnMarriedSeat, false);
    UI.enableAll(self.MarriedSeat, false);
end
-- 刷新用户拥有的物品数量
function Class:RefreshItemNum(args)
    self.myItemNum.item53 = args.item53;
    self.myItemNum.item54 = args.item54;
    self.myItemNum.item55 = args.item55;
end
--- 加物品数量（本地数据）
---@param itemID any 物品ID
---@param itemNum any 物品数量
function Class:SubItemNum(itemID, itemNum)
    if itemID == 53 then
        self.myItemNum.item53 = self.myItemNum.item53 + itemNum;
    elseif itemID == 54 then
        self.myItemNum.item54 = self.myItemNum.item54 + itemNum;
    elseif itemID == 55 then
        self.myItemNum.item55 = self.myItemNum.item55 + itemNum;
    end
end
-- 按钮选中状态  因为图片做不了单选
function Class:ShowHomeBtnUnMarried()
    UI.enable(self.HomeTopPin, "mPic", false);
    UI.enable(self.HomeTopPin, "fPic", false);

    if self.homeBtnUnMarried then
        UI.enable(self.HomeBottomPin, "bg/btnUnMarried/Selected", true);
    else
        UI.enable(self.HomeBottomPin, "bg/btnMarried/Selected", true);
    end
end

function Class:HideChildState()
    UI.enable(self.HomeTopPin, "UnMarriedAttr/BtnNode/tittle", false);
    UI.enable(self.HomeTopPin, "UnMarriedAttr/BtnNode/TxtNode", false);
    UI.enable(self.HomeTopPin, "UnMarriedAttr", false);
end
-- 隐藏提亲页面
function Class:HideTiqin()
    UI.enable(self.node, "MentionMarried", false);
end
-- 显示孩子状态 -- 是否在提亲
function Class:ShowChildState(args)
    self:HideChildState();
    UI.enable(self.HomeTopPin, "UnMarriedAttr", true);
    if args.mentionMarriedTime > 0 then
        local tiqinTime = math.abs(os.time() - args.mentionMarriedTime);
        UI.enable(self.HomeTopPin, "UnMarriedAttr/BtnNode/TxtNode", true);
        UI.txtUpdateTime(self.HomeTopPin, "UnMarriedAttr/BtnNode/TxtNode/txtTime", tiqinTime, function()
            self:ShowChildState({
                mentionMarriedTime = 0
            });
        end);
        if args.mentionMarriedUserID == 0 or args.mentionMarriedUserID == nil then
            UI.text(self.HomeTopPin, "UnMarriedAttr/BtnNode/TxtNode/txt01", "正在向全服玩家提亲");
        else
            UI.text(self.HomeTopPin, "UnMarriedAttr/BtnNode/TxtNode/txt01",
                    "正在向 " .. args.mentionMarriedUser .. "\n编号(" .. args.mentionMarriedUserID .. ")");
        end
    else
        UI.enable(self.HomeTopPin, "UnMarriedAttr/BtnNode/tittle", true);
    end
end

-- 显示未婚子嗣列表节点
function Class:ShowUnMarriedSeat(args)
    UI.enable(self.HomeBottomPin, "MarriedChildGroup", false);
    UI.enable(self.HomeTopPin, "fPic", true);
    UI.enable(self.HomeTopPin, "UnMarriedAttr", true);
    local temp = args;
    if temp == nil then
        temp = self.UnMarriedChildren[1].childInfo;
    end
    UI.image(self.HomeTopPin, "fPic", "ChildrenPic", temp.pic)
    UI.draw(self.HomeTopPin, "UnMarriedAttr/BtnNode/AttrPanel/txtNode", temp);
end
-- 设置未婚（已婚）子嗣数据
-- types 空：未婚  
function Class:SetChildDatas(args, types)
    if types == nil then
        self.UnMarriedChildren = nil;
        self.UnMarriedChildren = {};
        for i = 1, #args.childBase do
            -- local index = (self.pageNumUnMarried - 1) * 10 - 1;
            local temp = {
                childInfo = args.childBase[i],
                seat = UI.child(self.UnMarriedSeat, i - 1)
            }
            table.insert(self.UnMarriedChildren, temp);
            UI.toggle(self.UnMarriedChildren[i].seat, function()
                if self.defultChildID == self.UnMarriedChildren[i].childInfo.id then
                    return
                end
                self.defultChildID = self.UnMarriedChildren[i].childInfo.id;
                self:ShowUnMarriedSeat(self.UnMarriedChildren[i].childInfo)
                message:send("C2S_YyChildState", {
                    childID = self.UnMarriedChildren[i].childInfo.id
                }, function(args)
                    self:ShowChildState(args);

                    local soundId = temp.childInfo.pic
                    CS.Sound.PlayOne("voice/childVoice" .. soundId);
                end)
            end)
        end
    else
        self.MarriedChildren = nil;
        self.MarriedChildren = {};
        for i = 1, #args.m do
            local index = (self.pageNumMarried - 1) * 10 - 1;
            local temp = {
                m = args.m[i],
                seat = UI.child(self.MarriedSeat, index + i)
            }
            table.insert(self.MarriedChildren, temp);
            UI.toggle(self.MarriedChildren[i].seat, function()
                self.defultChildID = self.MarriedChildren[i].m.id;
                self:ShowMarriedChildState(self.MarriedChildren[i]);
            end)
        end
    end
end
-- 客户端到服务器  发送停止联姻
function Class:C2S_StopMarriage()
    message:send("C2S_StopMarriage", {
        childID = self.defultChildID
    }, function(args)
        -- 主动停止联姻 返还道具
        self:ShowChildState(args)
        local str = "您的子嗣 " .. args.childBase.name .. " 提亲失败";
        UI.ShowTipReturnItem(str, args.itemID, args.itemSub)
        self:SubItemNum(args.itemID, args.itemSub);
    end)
end
--- 刷新提示页面  通过toggle
---@param typeToggle any 0单个玩家提亲 1全服提亲
function Class:RefreshMMToggle(typeToggle)
    self.mmItem = nil;
    local mmButtomPin = UI.child(self.node, "MentionMarried/BottomPin");
    local temp = table.find(self.UnMarriedChildren, function(args)
        return args.childInfo.id == self.defultChildID;
    end);
    local childInfo = temp.childInfo;
    local subNum = 0;
    local itemID = 0;
    local ipt = UI.child(mmButtomPin, "bgMentionMarried/ToggleGroup/toggle1/iptPlayerID");
    if typeToggle == 0 or typeToggle == nil then
        subNum = config.childConfigureMap[1].talentMarrigeCost[childInfo.qua * 2]
        itemID = config.childConfigureMap[1].talentMarrigeCost[childInfo.qua * 2 - 1];
        ipt:GetComponent(typeof(CS.UnityEngine.UI.InputField)).interactable = true;
        self.allMm = 0;
    else
        subNum = config.childConfigureMap[1].talentMarketCost[childInfo.qua * 2]
        itemID = config.childConfigureMap[1].talentMarketCost[childInfo.qua * 2 - 1];
        UI.setValue(ipt, "");
        ipt:GetComponent(typeof(CS.UnityEngine.UI.InputField)).interactable = false;
        self.allMm = 1;
    end

    local itemName = config.item[itemID].name;
    UI.image(mmButtomPin, "bgItem/item", "Item", itemID);
    UI.text(mmButtomPin, "bgItem/txtItemName", itemName .. "X" .. subNum);
    local itemCount = 0
    if itemID == 53 then
        itemCount = self.myItemNum.item53;
    elseif itemID == 54 then
        itemCount = self.myItemNum.item54;
    elseif itemID == 55 then
        itemCount = self.myItemNum.item55
    end
    UI.text(mmButtomPin, "bgItem/txtItemNum", "(现有:" .. itemCount .. ")");
    self.mmItem = {
        subNum = 0,
        itemID = 0,
        itemCount = 0
    }
    self.mmItem.subNum = subNum;
    self.mmItem.itemID = itemID;
    self.mmItem.itemCount = itemCount;
end
--- 客户端到服务器  提亲
---@param uPlayerID any 对方玩家ID,ID可为0或空（全服提亲）
function Class:C2S_Tiqin(uPlayerID)
    if uPlayerID == nil then
        uPlayerID = 0;
    end
    self:SubItemNum(self.mmItem.itemID, -self.mmItem.subNum);
    message:send("C2S_Tiqin", {
        childID = self.defultChildID,
        uPlayerID = uPlayerID
    }, function(args)
        if args.code == "ok" then
            message:send("C2S_YyChildState", {
                childID = self.defultChildID
            }, function(args)
                self:HideTiqin();
                self:ShowChildState(args)
            end)
        elseif args.code == "error_count" then
            UI.showHint("对方用户不存在");
        end
    end)
end
-- 设置子数据显示
function Class:SetChildShow(node, childInfo)
    UI.image(node, "imgIdentity", "Jinbangtiming", childInfo.qua + 6);
    UI.image(node, "imgChild", "ChildrenPic", childInfo.pic);
    UI.text(node, "txtFather", client.user.name);
    UI.text(node, "txtName", childInfo.name);
    UI.text(node, "txtAttr", childInfo.attr);
end
-- 招亲 ref为是否刷新
function Class:C2S_ZhaoQin(ref)
    local childGroup = UI.child(self.node, "zhaoMarried/ChildGroup");
    UI.enable(self.node, "zhaoMarried/txtNo", false);
    if ref == nil then
        ref = 0;
    end
    message:send("C2S_ZhaoQin", {
        childID = self.defultChildID,
        ref = ref
    }, function(args)
        UI.enableAll(childGroup, false);
        UI.txtUpdateTime(self.node, "zhaoMarried/bgRefresh/txtRefreshTime", args.time, function()
            -- 刷新时间到  重新拉取列表
            self:C2S_ZhaoQin();
        end);
        local color = ColorStr.gold;
        if args.subGold > client.user.gold then
            color = ColorStr.red;
        end
        UI.text(self.node, "zhaoMarried/bgRefresh/txtSubGold", UI.colorStr(args.subGold, color));
        UI.text(self.node, "zhaoMarried/bgRefresh/txtItemNum", args.itemNum);
        UI.image(self.node, "zhaoMarried/bgRefresh/imgItem", "Item", args.itemID);

        if args.code == "ok" then
            if #args.info > 0 then
                UI.enable(self.node, "zhaoMarried/txtNo", false);
                for i = 1, #args.info do
                    UI.enable(childGroup, tostring(i), true);
                    UI.draw(childGroup, tostring(i) .. "/txtNode", args.info[i]);
                    UI.button(childGroup, tostring(i) .. "/btnOK", function()
                        -- 招亲联姻按钮
                        self:C2S_Married(args.info[i], self.toChildInfo)
                    end)
                    UI.image(childGroup, i .. "/imgIdentity", "Jinbangtiming", args.info[i].qua + 6);
                end
            else
                UI.enable(self.node, "zhaoMarried/txtNo", true);
            end

        elseif args.code == "error_noGold" then
            UI.showHint("元宝不足，可前往充值获得元宝");
        end
    end)
end
-- 提亲请求功能
function Class:C2S_ReqTiqin()
    local ChildGroup = UI.child(self.node, "RequestMarried/ChildGroup/Viewport/Content");
    local reqMNode = UI.child(self.node, "RequestMarried");
    -- if self.pageNumReqMax <= self.pageNumReqTiqin then
    --     return;
    -- end
    -- self.pageNumReqTiqin = self.pageNumReqTiqin + 1;
    self.reqTiqinInfo = nil;
    self.reqTiqinInfo = {};
    self.pageNumReqTiqin = 1;
    message:send("C2S_ReqTiqin", {
        -- pageNum = self.pageNumReqTiqin
        pageNum = 1
    }, function(args)
        if args.code == "ok" then
            UI.draw(self.node, "RequestMarried/ItemNode", args);
            UI.enable(reqMNode, "txtNo", true);
            UI.enableAll(ChildGroup, false);
            if #args.info > 0 then
                self:RefreshItemNum(args);
                -- 根据提亲请求大小生成孩子长度
                UI.draw(ChildGroup, args.info);
                UI.enable(reqMNode, "txtNo", false);
                for i = 1, #args.info do
                    table.insert(self.reqTiqinInfo, args.info[i]);
                    local x = (self.pageNumReqTiqin - 1) * 10 + i - 1;
                    local childNode = UI.child(ChildGroup, x);
                    UI.enable(childNode, true);
                    UI.image(childNode, "txtNode/qua", "Jinbangtiming", args.info[i].qua + 6);
                    UI.button(childNode, "BtnNode/btnYes", function()
                        -- 同意
                        self.toChildInfo = args.info[i];
                        self:C2S_AgreeTiqin(args.info[i], 0);
                    end)
                    UI.button(childNode, "BtnNode/btnNo", function()
                        -- 拒绝
                        self:C2S_AgreeTiqin(args.info[i], 1);
                    end)
                end
            end
        end
    end)
end
--- 同意或拒绝提亲：0 同意提亲 1拒绝提亲  2拒绝所有提亲
function Class:C2S_AgreeTiqin(info, state)
    local nubileNode = UI.child(self.node, "Nubile");
    UI.enable(nubileNode, "txtNo", true);
    message:send("C2S_AgreeTiqin", {
        state = state,
        info = info
    }, function(args)
        if state == 0 then
            UI.enable(nubileNode, true);
            if #args.info > 0 then
                UI.enable(nubileNode, "txtNo", false);
                UI.draw(nubileNode, "ChildGroup/Viewport/Content", args.info);
                UI.draw(nubileNode, "Item", args);
                local content = UI.child(nubileNode, "ChildGroup/Viewport/Content");
                for i = 1, #args.info do
                    -- local x = (self.pageNumReqTiqin - 1) * 10 + i - 1;
                    local childNode = UI.child(content, i - 1);
                    UI.image(childNode, "qua", "Jinbangtiming", args.info[i].qua + 6);
                    UI.button(childNode, "BtnNode/btnOK", function()
                        -- 联姻 ok
                        local sub = config.childConfigureMap[1].talentMarrigeCost[args.info[i].qua * 2];
                        if args.itemNum < sub then
                            UI.showHint("道具不足")
                            return ;
                        else
                            self:C2S_Married(self.toChildInfo, args.info[i]);
                        end
                    end)
                end
            end
        elseif state == 1 then
            -- 拒绝
            self:C2S_ReqTiqin();
            self.toChildInfo = nil;
        elseif state == 2 then
            -- 全部拒绝
            self:C2S_ReqTiqin();
            self.toChildInfo = nil;
            UI.showHint("已全部拒绝")
        end
    end)
end
--- 结婚
---@param info1 any 对方子嗣
---@param info2 any 我方子嗣
function Class:C2S_Married(info1, info2)
    message:send("C2S_Married", {
        toChildInfo = info1,
        myChildInfo = info2
    }, function(args)
        UI.enableAll(self.node, false);
        UI.enable(self.node, 0, true);
        if args.code == "ok" then
            -- 联姻成功  打开婚书界面
            -- 打开已婚子嗣页面
            UI.enable(self.node, "MarriageBook", true);
            UI.draw(self.node, "MarriageBook/draw", args);

            self:ack_married(args.married)
        elseif args.code == "fail" then
            --  联姻失败  返回提亲请求界面并刷新；
            UI.showHint("提亲失败");
        elseif args.code == "error_noItem" then
            --  提示联姻失败  返回上一层页面
            UI.showHint("道具不足");
        end
        self:ResetHomeUI();
        self.homeBtnUnMarried = true
        self:ShowHomeBtnUnMarried();
        self:C2S_UnMarried()
    end)
end

function Class:C2S_MarriedChild()

    if self.C2S_MarriedChild_ret then
        self:C2S_MarriedChild_draw(self.C2S_MarriedChild_ret)
    else
        message:send("C2S_MarriedChild", {
            pageNum = self.pageNumMarried
        }, function(args)
            self.C2S_MarriedChild_ret = args
            self:C2S_MarriedChild_draw(args)
        end)
        -- body
    end
end

function Class:C2S_MarriedChild_draw(args)
    local seat = UI.child(self.HomeBottomPin, "MarriedChildGroup/Viewport/Content");
    -- self:ResetHomeUI();
    UI.enable(self.node, "Home/BottomPin/MarriedChildGroup", true);
    local childCount = #args.m
    if childCount > 0 then
        -- 克隆节点
        UI.draw(seat, args.m);
        self:SetChildDatas(args, 1);
        UI.SetToggleIsOn(self.MarriedChildren[1].seat);
        self.defultChildID = self.MarriedChildren[1].m.id;

        UI.enable(self.HomeTopPin, "mPic", true);
        UI.enable(self.HomeTopPin, "fPic", true);
    else
        if self.pageNumUnMarried == 1 then
            UI.enable(self.HomeBottomPin, "noMarriedChild", true);
            UI.enable(self.HomeTopPin, "mPic", false);
            UI.enable(self.HomeTopPin, "fPic", false);
        end
    end
    self:RefreshItemNum(args);
end

--- 设置已婚子嗣数据列表
function Class:ShowMarriedChildState(arg)
    UI.draw(arg.seat, "txtNode", arg.m);
    UI.draw(self.HomeTopPin, arg.m);
end
-- 赐婚
function Class:C2S_Cihun(childBase)
    message:send("C2S_Cihun", {
        childBase = childBase
    }, function(args)
        UI.enableAll(self.node, false);
        UI.enable(self.node, 0, true);
        log("ok");
        if args.code == "ok" then
            -- 联姻成功  打开婚书界面
            -- 打开已婚子嗣页面
            UI.enable(self.node, "MarriageBook", true);
            UI.draw(self.node, "MarriageBook/draw", args);

            self:ack_married(args.married)
        elseif args.code == "fail" then
            --  联姻失败  返回提亲请求界面并刷新；
            UI.showHint("赐婚失败，请重试");
        elseif args.code == "error_noGold" then
            --  提示联姻失败  返回上一层页面
            UI.showHint("元宝不足");
        elseif args.code == "error_noVip" then
            --  提示联姻失败  返回上一层页面
            UI.showHint("vip等级不足");
        end
        self:ResetHomeUI();
        self.homeBtnUnMarried = true
        self:ShowHomeBtnUnMarried();
        self:C2S_UnMarried()
    end)
end

function Class:ack_married(info)
    if self.C2S_MarriedChild_ret == nil then
        self.C2S_MarriedChild_ret = {}
    end
    for i, v in ipairs(self.C2S_UnMarried_ret) do
        if v.id == info.id then
            table.remove(self.C2S_UnMarried_ret, i)
            break
        end
    end
    table.insert(self.C2S_MarriedChild_ret, 1, info);
end

return Class
