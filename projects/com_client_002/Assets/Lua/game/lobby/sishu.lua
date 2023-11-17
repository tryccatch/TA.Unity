local Class = {
    res = "ui/sishu"
}

CS.Images.Load("Res/KeJuTitle", "KeJuTitle")

function Class:init()
    self.hasClose = false
    CS.Sound.Play("effect/childSystem");

    -- 常用节点数据
    self.seatNode = nil;
    self.bgChild = nil;
    self.childAttributes = nil;
    self.topTips = nil;
    self.bgBottomNode = nil;
    self.promptboxNode = nil;
    self.promptBtnNode = nil;
    self.iptChildName = nil;
    self.jinbangtimingNode = nil;
    -- 席位选中
    self.seatSelected = {};
    self.selectedIndex = 0;
    self.defultChildID = 0;
    self.children = {};
    self.bBgChildTween = false;
    self.time = 0
    -- 发送消息 默认显示孩子  id为1
    self.seatNode = UI.child(self.node, "Home/BottomPin/BG/ChildGroup/Viewport/Content");
    self.bgBottomNode = UI.child(self.node, "Home/BottomPin/BGBottom");
    self.promptboxNode = UI.child(self.node, "Promptbox");
    self.promptBtnNode = UI.child(self.promptboxNode, "RenamedNode/BtnNode");
    self.topTips = UI.child(self.node, "Home/TopPin/TopTips");
    self.bgChild = UI.child(self.node, "Home/TopPin/BgChild");
    self.childAttributes = UI.child(self.node, "Home/TopPin/ChildAttributes/bg");
    self.iptChildName = UI.child(self.promptBtnNode, "IptName");
    self.jinbangtimingNode = UI.child(self.node, "jinbangtiming");
    -- 设置选中列表
    for i = 1, self.seatNode.childCount - 1 do
        local temp = {}
        temp.bgSelected = UI.child(self.seatNode, tostring(i) .. "/bgSelected");
        temp.txtLevel = UI.child(self.seatNode, tostring(i) .. "/noIdle/bgLevel/txtLevel");
        temp.txtTeach = UI.child(self.seatNode, tostring(i) .. "/noIdle/bgTeach/txtTeach");
        temp.txtName = UI.child(self.seatNode, tostring(i) .. "/noIdle/txtName");
        temp.txtUp = UI.child(self.seatNode, tostring(i) .. "/noIdle/txtUp");
        temp.txtNo = UI.child(self.seatNode, tostring(i) .. "/txtNo");
        temp.noIdle = UI.child(self.seatNode, tostring(i) .. "/noIdle");
        table.insert(self.seatSelected, temp);
    end
    UI.enable(self.node, "jinbangtiming", false);
    -- 常用功能按钮设置
    UI.button(self.node, "Home/TopPin/BtnBack", function()
        self.hasClose = true
        UI.close(self);
    end)
    UI.button(self.node, "Home/TopPin/BtnHelp", function()
        -- UI.enable(self.promptboxNode, true);
        -- UI.enable(self.promptboxNode, "HelpNode", true);
        showHelp("child");
    end)
    UI.button(self.promptboxNode, "BtnBack", function()
        UI.enable(self.promptboxNode, false);
        UI.enable(self.promptboxNode, "HelpNode", false);
        UI.enable(self.promptboxNode, "RenamedNode", false);
        self.promptBtnNode:Find("IptName"):GetComponent("InputField").text = "";
    end)
    UI.button(self.bgBottomNode, "BtnAllChildUp", function()
        -- 私塾子嗣一键培养Btn
        self:C2S_Teach(0);
    end)
    UI.button(self.bgBottomNode, "BtnAllRestore", function()
        -- 私塾子嗣一键恢复
        local index = 0;
        for i = 1, #self.children do
            if self.children[i].teach == 0 and self.children[i].level < self.children[i].kejuLevel then
                index = index + 1;
            end
        end
        if index > 0 then
            ItemTools.used(56, index, function(args)
                self:C2S_OnOpenSiShu(self.defultChildID);
            end, 0)
        else
            UI.showHint("没有可恢复的孩子");
        end
    end)
    UI.button(self.childAttributes, "BtnKeju", function()
        message:send("C2S_Keju", { childID = self.defultChildID }, function(args)
            if self.hasClose then
                return
            end
            -- 打开页面设置数据
            if self.hasClose then
                return
            end
            if args.code == "ok" then
                UI.enable(self.jinbangtimingNode, true);
                UI.image(self.jinbangtimingNode, "bg/Image", "KeJuTitle", args.childBase.qua);
                UI.image(self.jinbangtimingNode, "ChildSprite", "ChildrenPic", args.childBase.pic);
                --log(args.childBase)
                UI.draw(self.jinbangtimingNode, "Attr/TxtNode", args.childBase);
            else
                UI.showHint("科举失败")
            end
        end)
    end)

    UI.button(self.jinbangtimingNode, function()
        UI.enable(self.jinbangtimingNode, false);
        -- 打开帮助页面
        UI.msgBoxTitle("帮 助", "您的孩子已经到了适婚年龄\n是否前往姻缘祠进行联姻", function()
            -- yes 打开姻缘祠页面
            UI.openPage(UIPageName.YinYuanCi)
            UI.close(self)
            -- 姻缘祠提亲页面
        end, function()
            -- 取消
            self:C2S_OnOpenSiShu(0);
        end)
    end)
    UI.button(self.seatNode, "Expansion/btn", function()
        -- 扩建按钮事件添加
        self:C2S_AddSeat(0);
    end)
    UI.button(self.promptBtnNode, "BtnCancel", function()
        -- body
        self:BtnCancelRenamed();
    end);
    self:C2S_OnOpenSiShu(0);
end
-- 给服务器发送消息
-- 如果childid值为0  默认取孩子列表第一个数据显示
function Class:C2S_OnOpenSiShu(childid)
    UI.desObj(self.bgChild, "bgTeach/txtRestoreTime", CS.TxtTime);
    --self.children = nil;
    message:send("C2S_OnOpenSiShu", {
        childID = childid
    }, function(args)
        if self.hasClose then
            return
        end
        self:drawAllInfo(args, childid)
    end)
end

function Class:drawAllInfo(args, childid, noAnim)

    if args == nil then
        args = self.C2S_OnOpenSiShu_ret
    end
    self.C2S_OnOpenSiShu_ret = args

    -- 设置当前席位Txt
    UI.text(self.bgBottomNode, "txtChildNum", #args.childBase .. "/" .. args.seat);
    self:ShowChildSeats(args.childBase, args.seat);
    if args.seat < args.seatMax then
        -- 如果 当前席位小于  私塾席位最大值
        -- 显示扩建
        UI.enable(self.seatNode, "Expansion", true);
    else
        -- 不显示扩建
        UI.enable(self.seatNode, "Expansion", false);
    end
    self:ShowOrHideBtnAll(args);
    self.children = args.childBase;
    -- 显示子嗣Top详情
    if #args.childBase > 0 then
        local child = nil;
        if childid == 0 then
            child = args.childBase[1];
            self:SeletedSeatState(1);
            self.defultChildID = child.id;
        else
            for i = 1, #args.childBase do
                if args.childBase[i].id == childid then
                    child = args.childBase[i];
                    self:SeletedSeatState(i);
                    self.defultChildID = child.id;
                    break
                end
            end
        end

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

        UI.enable(self.topTips, "momAtt", true);
        UI.enable(self.topTips, "txtTip", false);
        -- 显示  childid对应的属性
        if child then
            UI.text(self.topTips, "momAtt/txtMother", child.momName);
            UI.text(self.topTips, "momAtt/txtIntimacy", child.intimacy);
        else
            UI.text(self.topTips, "momAtt/txtMother", "");
            UI.text(self.topTips, "momAtt/txtIntimacy", "");
        end

        if self.bBgChildTween then
            self.bBgChildTween = false;
            UI.enable(self.bgChild, true);
            UI.setLocalPosition(self.bgChild, -720);
            UI.tweenList(self.bgChild, { {
                                             offset = {
                                                 x = 720
                                             },
                                             time = 0.5
                                         } })
        end
        UI.enable(self.bgChild, true);
        -- 更换孩子图片
        UI.image(self.bgChild, "ChildSprite", "ChildrenPic", child.pic);
        -- 更换孩子对话内容
        --UI.text(self.bgChild, "bgChildTalk/Text", child.talk)
        UI.showTextByTypeWriter(UI.child(self.bgChild, "bgChildTalk/Text"), child.talk)
        local teachNum = child.teach;
        UI.text(self.bgChild, "bgTeach/txtTeach", teachNum .. "/" .. child.teachMax);
        self:ShowTeach(child);
        -- 孩子经验
        UI.text(self.bgChild, "bgExp/txtExp", child.curExp .. "/" .. child.nextExp);
        -- 经验进度条
        local expPro = child.curExp / child.nextExp;
        --print("孩子信息：lv=", child.level, "keJuLv=", child.kejuLevel)
        if child.level >= child.kejuLevel then
            expPro = 1;
            UI.text(self.bgChild, "bgExp/txtExp", "max");
        end

        if child.level < child.kejuLevel and (not noAnim) then
            UI.showProcessAck(UI.child(self.bgChild, "bgExp/SliderRank"), expPro, self.time)
            self.time = 0
        else
            local sliderNode = UI.child(self.bgChild, "bgExp/SliderRank")
            UI.removeProcessUpdate(sliderNode)
            local slider = UI.component(self.bgChild, "bgExp/SliderRank", typeof(CS.UnityEngine.UI.Slider))
            if slider then
                slider.value = expPro
            end
        end

        -- 孩子属性
        UI.enable(self.childAttributes, true);
        if child.isRenamed then
            -- 赐名
            UI.text(self.childAttributes, "txtName", UI.colorStr("大人请赐名", "FF2900"))
            UI.enable(self.childAttributes, "BtnGiveName", true);
        else
            UI.text(self.childAttributes, "txtName", UI.colorStr(child.name, "F8E6AF"));
            if teachNum > 0 then
                UI.enable(self.childAttributes, "BtnBringUp", true);
            else
                UI.enable(self.childAttributes, "BtnRestore", true);
            end
        end
        -- 根据品质显示名称 属性
        if child.level > child.kejuLevel then
            child.level = child.kejuLevel
        end
        UI.text(self.childAttributes, "TxtNode/txt1", child.quaName);
        UI.text(self.childAttributes, "TxtNode/txt2", child.level .. "/" .. child.kejuLevel);
        UI.text(self.childAttributes, "TxtNode/txt3", child.attr);
        UI.text(self.childAttributes, "TxtNode/txt4", child.strength);
        UI.text(self.childAttributes, "TxtNode/txt5", child.wisdom);
        UI.text(self.childAttributes, "TxtNode/txt6", child.political);
        UI.text(self.childAttributes, "TxtNode/txt7", child.charm);
        -- 按钮事件
        self:ShowChildAttBtn(child);
        UI.button(self.childAttributes, "BtnRenamed", function()
            -- 改名
            if child.isRenamed then
                UI.showHint("尚未赐名")
            else
                self:C2S_Renamed(child, true);
            end
        end)
        UI.button(self.childAttributes, "BtnGiveName", function()
            self:C2S_Renamed(child);
        end)
        UI.button(self.childAttributes, "BtnRestore", function()
            -- 恢复  元气丹物品ID：56
            ItemTools.used(56, 1, function(args)
                self:C2S_OnOpenSiShu(self.defultChildID);
            end, self.defultChildID)
        end)
        UI.button(self.childAttributes, "BtnBringUp", function()
            -- 培养
            self:C2S_Teach(child.id);
        end)
    else
        UI.enable(self.topTips, "txtTip", true);
        UI.enable(self.bgChild, false);
        UI.enable(self.childAttributes, false);
        UI.enable(self.topTips, "momAtt", false);
    end
end

-- 显示子嗣列表 当前已有的在私塾的childBase 席位
function Class:ShowChildSeats(childBase, seat)
    for i = 1, seat do
        local childSeat = UI.child(self.seatNode, tostring(i));
        local noIdle = UI.child(childSeat, "noIdle");
        local color = nil;
        UI.enable(childSeat, true);
        if i <= #childBase then
            -- 如果  i小于子嗣数量  显示子嗣信息
            UI.enable(childSeat, "txtNo", false);
            UI.enable(childSeat, "noIdle", true);
            UI.button(childSeat, function()
                -- 点击发送消息  显示上方对应子嗣图片以及属性
                self.time = 0
                if self.defultChildID ~= childBase[i].id then
                    self:drawAllInfo(nil, childBase[i].id, true)
                end
            end)

            -- 科举 等级相关  更改颜色
            color = ColorQua[childBase[i].qua];
            if childBase[i].isRenamed then
                -- 赐名
                UI.text(noIdle, "txtName", UI.colorStr("大人请赐名", ColorStr.red));
            else
                UI.text(noIdle, "txtName", UI.colorStr(childBase[i].name, color));
            end
            -- 显示等级
            UI.text(noIdle, "bgLevel/txtLevel", UI.colorStr(childBase[i].level .. "/" .. childBase[i].kejuLevel, color));
            if childBase[i].level < childBase[i].kejuLevel then
                -- 显示元气
                UI.enable(noIdle, "bgTeach", true);
                UI.enable(noIdle, "txtUp", false);
                UI.text(noIdle, "bgTeach/txtTeach",
                        UI.colorStr(childBase[i].teach .. "/" .. childBase[i].teachMax, color));
            else
                -- 显示进行科举
                UI.enable(noIdle, "bgTeach", false);
                UI.enable(noIdle, "txtUp", true);
            end
        else
            -- 显示空闲
            UI.enable(childSeat, "txtNo", true);
            UI.enable(childSeat, "noIdle", false);
            UI.button(childSeat, function()
                self.defultChildID = 0
                UI.enable(self.topTips, "txtTip", true);
                if not self.bBgChildTween then
                    self.bBgChildTween = true;
                    UI.setLocalPosition(self.bgChild, 0);
                    UI.tweenList(self.bgChild, { {
                                                     offset = {
                                                         x = -720
                                                     },
                                                     time = 0.5
                                                 } })
                end
                UI.enable(self.childAttributes, false);
                UI.enable(self.topTips, "momAtt", false);
                self:SeletedSeatState(i);
            end);
        end
    end
end
-- 发送网络消息  扩建
-- state 0获取扩建花费 1确定扩建
function Class:C2S_AddSeat(state)
    message:send("C2S_AddSeat", {
        state = state
    }, function(args)
        if self.hasClose then
            return
        end
        local str = args.subgold;
        if args.code == "error_noGold" then
            str = UI.colorStr(args.subgold, ColorStr.red)
        else
            str = UI.colorStr(args.subgold, ColorStr.gold);
        end
        UI.msgBoxTitle("扩 建", "是否花费元宝" .. str .. "扩建席位", function()
            -- 确认
            if args.code == "error_noGold" then
                UI.showHint("元宝数量不足,可前往充值获得");
            elseif args.code == "error_seatMax" then
                UI.showHint("席位已满");
            else
                message:send("C2S_AddSeat", {
                    state = 1
                }, function(args)
                    -- 确定按钮
                    --if args.seat < args.seatMax then
                    --    local childSeat = UI.child(self.seatNode, tostring(args.seat));
                    --    UI.enable(childSeat, true);
                    --    UI.enable(childSeat, "txtNo", true);
                    --    UI.enable(childSeat, "noIdle", false);
                    --    UI.button(childSeat, nil);
                    --else
                    --    UI.enable(self.seatNode, "Expansion", false);
                    --end
                    if self.hasClose then
                        return
                    end
                    UI.enable(self.seatNode, "Expansion", args.seat < args.seatMax);
                    self:ShowChildSeats(self.children, args.seat);

                    self:ShowOrHideBtnAll({
                        seat = args.seat,
                        childBase = self.children
                    });
                end, function()
                    -- 取消按钮
                end);
            end
        end, function()
            -- 取消按钮
        end);
    end)
end

-- 客户端改名
-- child：孩子信息
function Class:C2S_Renamed(child, rename)
    --[[    if is_debug and child.isRenamed then
            message:send("C2S_GetChildRdName", {
                childID = child.id
            }, function(args)
                UI.text(self.iptChildName, args.name);
            end)
            local value = UI.getValue(self.iptChildName);
            message:send("C2S_Renamed", { childID = child.id, name = value }, function(args)
                if args.code == "ok" then
                    -- 改名成功后刷新显示
                    UI.text(self.childAttributes, "txtName", UI.colorStr(args.name, ColorStr.name));
                    UI.text(self.seatSelected[self.selectedIndex].txtName, UI.colorStr(args.name, ColorStr.name));
                    self:BtnCancelRenamed();
                    self:ShowChildAttBtn(args.childBase);
                    self:C2S_OnOpenSiShu(args.childBase.id);
                    if rename then
                        UI.showHint("改名成功");
                    else
                        UI.showHint("赐名成功");
                    end
                    -- 记录下选中状态直接更改
                elseif args.code == "error_count" then
                    UI.showHint("请输入4到10个字符");
                elseif args.code == "error_noChinese" then
                    UI.showHint("请输入中文");
                elseif args.code == "error_noGold" then
                    UI.showHint("元宝不足,请购买后再来改名吧");
                elseif args.code == "error_noGold" then
                    UI.showHint("元宝不足,请购买后再来改名吧");
                elseif args.code == "error_haveName" then
                    UI.showHint("当前名字已存在");
                end
            end)
            return
        end]]

    UI.enable(self.promptboxNode, true);
    UI.enable(self.promptboxNode, "RenamedNode", true);
    if child.isRenamed then
        -- 赐名  无消耗
        UI.enable(self.promptboxNode, "RenamedNode/isRenamed", false);
        UI.text(self.promptboxNode, "RenamedNode/Title", "赐名");
    else
        -- 改名 消耗元宝
        UI.enable(self.promptboxNode, "RenamedNode/isRenamed", true);
        UI.text(self.promptboxNode, "RenamedNode/Title", "改名");
    end

    UI.button(self.iptChildName, "BtnRDName", function()
        -- 发送消息获取随机名字
        message:send("C2S_GetChildRdName", {
            childID = child.id
        }, function(args)
            if self.hasClose then
                return
            end
            UI.text(self.iptChildName, args.name);
        end)
    end)
    UI.button(self.promptBtnNode, "BtnOK", function()
        local value = UI.getValue(self.iptChildName);
        if value == "" then
            UI.showHint("不能为空");
            return ;
        end

        if value == nil then
            return
        end

        local has, v, dirty = Tools.sensitiveCheck(value)
        if has then
            UI.showHint("包含敏感字：" .. dirty)
            UI.text(self.iptChildName, "")
            return
        end

        value = Tools.removeSymbolInString(value)
        local len = Tools.getStrLen(value)
        if len < 4 or len > 10 then
            UI.showHint("请输入4-10个字符")
            return
        end

        message:send("C2S_Renamed", { childID = child.id, name = value }, function(args)
            if self.hasClose then
                return
            end
            if args.code == "ok" then
                -- 改名成功后刷新显示
                UI.text(self.childAttributes, "txtName", UI.colorStr(args.name, ColorStr.name));
                UI.text(self.seatSelected[self.selectedIndex].txtName, UI.colorStr(args.name, ColorStr.name));
                self:BtnCancelRenamed();
                self:ShowChildAttBtn(args.childBase);
                self:C2S_OnOpenSiShu(args.childBase.id);
                if rename then
                    UI.showHint("改名成功");
                else
                    UI.showHint("赐名成功");
                end
                -- 记录下选中状态直接更改
            elseif args.code == "error_count" then
                UI.showHint("请输入4到10个字符");
            elseif args.code == "error_noChinese" then
                UI.showHint("请输入中文");
            elseif args.code == "error_noGold" then
                UI.showHint("元宝不足,请购买后再来改名吧");
            elseif args.code == "error_noGold" then
                UI.showHint("元宝不足,请购买后再来改名吧");
            elseif args.code == "error_haveName" then
                UI.showHint("当前名字已存在");
            end
        end)
    end)
end

-- 隐藏属性按钮
function Class:HideChildAttBtn()
    UI.enable(self.childAttributes, "BtnGiveName", false);
    UI.enable(self.childAttributes, "BtnRestore", false);
    UI.enable(self.childAttributes, "BtnBringUp", false);
    UI.enable(self.childAttributes, "BtnKeju", false);
end
-- 根据孩子状态显示属性按钮
function Class:ShowChildAttBtn(child)
    self:HideChildAttBtn();
    if child.isRenamed then
        UI.enable(self.childAttributes, "BtnGiveName", true);
    else
        if child.level >= child.kejuLevel then
            UI.enable(self.childAttributes, "BtnKeju", true);
        else
            if child.teach > 0 then
                UI.enable(self.childAttributes, "BtnBringUp", true);
            else
                UI.enable(self.childAttributes, "BtnRestore", true);
            end
        end
    end
end
function Class:BtnCancelRenamed()
    UI.enable(self.promptboxNode, false);
    UI.enable(self.promptboxNode, "RenamedNode", false);
    UI.text(self.iptChildName, "");
end

-- 选中席位状态  想法类似togget
function Class:SeletedSeatState(index)
    self.selectedIndex = index;
    for i = 1, #self.seatSelected do
        UI.enable(self.seatSelected[i].bgSelected, false);
    end
    if self.selectedIndex ~= 0 then
        UI.enable(self.seatSelected[index].bgSelected, true);
    end
end

function Class:C2S_Teach(id)
    UI.button(self.childAttributes, "BtnBringUp", function()
        --log("消息还没到，急个串串！")
    end)
    message:send("C2S_Teach", { childID = id }, function(args)
        if self.hasClose then
            return
        end
        UI.button(self.childAttributes, "BtnBringUp", function()
            -- 培养
            self:C2S_Teach(child.id);
        end)
        -- 培养成功
        if args.code == "ok" then
            if id ~= 0 then
                self:C2S_OnOpenSiShu(id);
            else
                self:C2S_OnOpenSiShu(self.defultChildID);
            end
            if args.isUp then
                local soundId = 1;
                if args.level == nil or args.level > 3 then
                    for _, v in ipairs(self.children) do
                        if v.id == id then
                            soundId = v.pic
                        end
                    end
                end
                CS.Sound.Play("voice/childVoice" .. soundId);
            end
            -- 刷新席位显示
            self.time = 0.1
            self:ShowChildSeats(args.childBase, args.seat);
        end
    end)
end

-- 显示一键培养或一键恢复
function Class:ShowOrHideBtnAll(args)
    UI.enable(self.bgBottomNode, "BtnAllChildUp", false);
    UI.enable(self.bgBottomNode, "BtnAllRestore", false);
    UI.enable(self.bgBottomNode, "txt01", false);
    if args.seat > 4 then
        -- 可以显示一键培养or一键恢复
        local isShowUp = false;
        for i = 1, #args.childBase do
            local child = args.childBase[i];
            log(child)
            --[[            if is_debug and child.isRenamed then
                            self:C2S_Renamed(child);
                        end]]
            if child.teach > 0 and not child.isRenamed and child.level < child.kejuLevel then
                -- 只要有一个子嗣元气大于0 并且 不为需要改名状态 就显示一键培养
                isShowUp = true;
                break
            end
        end
        UI.enable(self.bgBottomNode, "BtnAllChildUp", isShowUp);

        local haveName = 0
        local allUse = 0
        for i = 1, #args.childBase do
            local child = args.childBase[i];
            if not child.isRenamed and child.level < child.kejuLevel then
                haveName = haveName + 1
                if child.teach <= 0 then
                    allUse = allUse + 1
                end
            end
        end
        UI.enable(self.bgBottomNode, "BtnAllRestore", haveName > 0 and haveName == allUse);
    else
        UI.enable(self.bgBottomNode, "txt01", true);
    end
    UI.text(self.bgBottomNode, "txtChildNum", #args.childBase .. "/" .. args.seat);
end
-- 显示元气
function Class:ShowTeach(child)
    UI.enableAll(self.bgChild, "bgTeach/BgGray", false);
    UI.enableAll(self.bgChild, "bgTeach/BgGreen", false);
    UI.enable(self.bgChild, "bgTeach/txtRestoreTime", false);
    if child.level < child.kejuLevel then
        UI.enable(self.bgChild, "bgTeach", true);
        for i = 1, child.teachMax do
            UI.enable(self.bgChild, "bgTeach/BgGray/" .. tostring(i), true);
        end
        if child.teach > 0 then
            for i = 1, child.teach do
                UI.enable(self.bgChild, "bgTeach/BgGreen/" .. tostring(i), true);
            end
        else
            UI.enable(self.bgChild, "bgTeach/txtRestoreTime", true);
            UI.txtUpdateTime(self.bgChild, "bgTeach/txtRestoreTime", child.teachTime, function()
                -- 时间到的回调更新元气
                self:C2S_OnOpenSiShu(self.defultChildID);
            end);
        end
    else
        UI.enable(self.bgChild, "bgTeach", false);
        UI.text(self.bgChild, "bgExp/txtExp", "等待科举");
    end
end

return Class
