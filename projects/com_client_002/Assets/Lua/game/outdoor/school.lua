local Class = {
    res = "UI/school"
}

function Class:init()
    UI.button(self.node, "HeroStudy/BtnBack", function()
        UI.close(self)
    end)

    UI.button(self.node, "HeroStudy/BtnHelp", function()
        self:showHelp()
    end)

    self:showSeatInfo()

    self.seatNode = self.node:Find("HeroStudy/SeatList/Viewport/Content")

    self.heroNode = self.node:Find("SelectHero/BG/HeroList/Viewport/Content")

    UI.button(self.node, "SelectHero/BG/BtnClose", function()
        UI.enableOne(self.node, 0)
    end)
end

function Class:showSeatInfo()
    message:send("C2S_ReqSchoolSeatInfo", {}, function(ret)
        UI.enableOne(self.node, 0)
        local seatCount = #ret.seatInfo
        local seatLearn = 0

        self.seatInfo = ret.seatInfo
        local cloneNode = UI.child(self.seatNode, 2)

        local addNode = self.node:Find("HeroStudy/SeatList/Viewport/Content/AddTable")
        if addNode then
            UI.cloneChild(self.seatNode, seatCount + 1, 2, cloneNode)
            UI.setAsLastChild(addNode)
        else
            UI.cloneChild(self.seatNode, seatCount, 2, cloneNode)
        end
        if seatCount < 10 then
            UI.button(addNode, "BtnAdd", function()
                self:addEmptySeat(ret)
            end)
        else
            UI.close(addNode)
        end

        if seatCount >= 5 then
            UI.enable(self.node, "HeroStudy/Bottom/Text", false)
            UI.clearGray(self.node, "HeroStudy/Bottom/BtnOneKey")
            UI.button(self.node, "HeroStudy/Bottom/BtnOneKey", function()
                self:showSeatInfo()
                log("OneKey")
                local finishCount = 0;
                for i, v in ipairs(self.seatInfo) do
                    if v.value == 0 and v.haveHero then
                        finishCount = finishCount + 1
                    end
                end
                if finishCount > 0 then
                    for i, v in ipairs(self.seatInfo) do
                        local child = UI.child(self.seatNode, i + 1)

                        if v.value == 0 and v.haveHero then
                            message:send("C2S_ReqStudyReward", { index = i }, function(reward)
                                log(reward.growsName .. reward.growsReward)
                                self:showReward(child, reward)
                            end)
                        end
                    end

                else
                    UI.showHint("暂无豪杰已完成学习")
                end


            end)
        else
            UI.setGray(self.node, "HeroStudy/Bottom/BtnOneKey")
        end

        for i, v in ipairs(self.seatInfo) do
            local child = UI.child(self.seatNode, i + 1)

            if v.haveHero then
                seatLearn = seatLearn + 1
                UI.enableAll(child, true)
                UI.enable(child, "BtnSelect", false)
                UI.enableAll(child, "Studying", false)
                UI.enable(child, "Studying/Time", true)
                UI.enable(child, "Studying/Double", true)

                if v.value == 0 then
                    self:reward(child, i)
                else
                    UI.enableAll(child, "BG/Book", true)
                    if child:Find("BG/Book/book") == nil then
                        UI.showNode(child, "BG/Book", "Effect/fanshu").name = "book"
                    end
                    --log(v.value)
                    UI.CountDown(child, "Studying/Time/value", v.value, function()
                        UI.enable(child, "BG/Book/book", false)
                        self:showSeatInfo()
                        self:reward(child, i)
                    end, 3)
                end

                HeroTools.setSchoolHero(child, "hero", v.heroId)

                if v.double then
                    UI.enableOne(child, "Studying/Double", 1)
                else
                    UI.enableOne(child, "Studying/Double", 0)
                    UI.button(child, "Studying/Double/BtnDouble", function()
                        local msgSchool = UI.showNode("Base/MsgSchool")
                        local fun = function()
                            UI.close(msgSchool)
                        end
                        UI.text(msgSchool, "Title", "双倍收益")
                        UI.text(msgSchool, "Text", "<color=#D97834>是否将 </color>" .. v.name .. " <color=#D97834>提升为双倍收益?</color>")
                        UI.text(msgSchool, "goldCost/Value", ret.goldCost)
                        UI.button(msgSchool, "BtnYes", function()
                            if ret.gold > ret.goldCost then
                                message:send("C2S_ReqDoubleLearn", { index = i }, function()
                                    self:showSeatInfo()
                                end)

                                UI.close(msgSchool)
                                UI.showHint("成功开启双倍收益！")
                            else
                                UI.close(msgSchool)
                                UI.showHint("元宝不足，可前往充值获得")
                            end
                        end)

                        UI.button(msgSchool, "BtnNo", fun)
                        UI.button(msgSchool, "BtnClose", fun)
                    end)
                end
            else
                UI.enableAll(child, true)
                --UI.enable(child, "BtnSelect", true)
                UI.enableAll(child, "BG/Book", false)
                --UI.enable(child, "AddValue", true)

                UI.enable(child, "hero", false)
                UI.enable(child, "Studying", false)

            end

            UI.button(child, "BtnSelect", function()

                UI.enableAll(self.node, true)
                self:showHeroList(i)
            end)
        end

        UI.text(self.node, "HeroStudy/SeatCount/Text", "当前席位\t" .. seatLearn .. "/" .. seatCount)
        UI.button(self.node, "HeroStudy/SeatCount", function()
            if seatCount == 10 then
                UI.showHint("席位已是最大值了！")
            else
                self:addEmptySeat(ret)
            end
        end)
    end)
end

function Class:addEmptySeat(ret)
    local msgSchool = UI.showNode("Base/MsgSchool")
    local fun = function()
        UI.close(msgSchool)
    end
    UI.text(msgSchool, "Title", "购买席位")
    UI.text(msgSchool, "Text", "是否购买修行席位?")
    UI.text(msgSchool, "goldCost/Value", ret.seatCost)
    UI.button(msgSchool, "BtnYes", function()
        if ret.gold > ret.seatCost then
            message:send("C2S_ReqAddSeat", {}, function()
                self:showSeatInfo()
            end)
            UI.close(msgSchool)
            UI.showHint("购买席位成功")
        else
            UI.close(msgSchool)
            UI.showHint("元宝不足，可前往充值获得")
        end
    end)
    UI.button(msgSchool, "BtnNo", fun)
    UI.button(msgSchool, "BtnClose", fun)
end

function Class:reward(child, index)
    UI.enableAll(child, "Studying", false)
    UI.enable(child, "Studying/Finish", true)
    UI.enable(child, "Studying/Double", true)
    UI.button(child, "Studying/Finish", function()
        UI.enable(child, "BtnSelect", false)
        message:send("C2S_ReqStudyReward", { index = index }, function(reward)
            self:showReward(child, reward)
        end)
    end)
end

function Class:showReward(child, reward)
    self:showSeatInfo()

    local growsNode = UI.showNode(child, "AddValue", "Base/" .. "AddValue")
    growsNode.name = "growsValue"
    UI.setLocalPosition(growsNode, 0, -20, 0)
    UI.text(growsNode, "Value", "<color=green>" .. reward.growsName .. "：+" .. reward.growsReward .. "</color>")

    local skillNode = UI.showNode(child, "AddValue", "Base/" .. "AddValue")
    skillNode.name = "skillValue"
    UI.setLocalPosition(skillNode, 0, -60, 0)
    UI.text(skillNode, "Value", "<color=green>" .. "技能经验" .. "：+" .. reward.skillReward .. "</color>")

    UI.tweenList(growsNode, {
        {
            time = 1.5,
            --waitTime = 2,
            type = "offset",
            pos = {
                x = 0,
                y = 60,
                z = 0,
            }
        },
        {
            type = "delete"
        }
    })
    UI.tweenList(skillNode, {
        {
            time = 1.5,
            --waitTime = 0.5,
            type = "offset",
            pos = {
                x = 0,
                y = 60,
                z = 0,
            }
        },
        {
            type = "delete"
        }
    })
end

function Class:showHeroList(index)
    message:send("C2S_ReqSchoolHeroList", {}, function(ret)
        UI.text(self.node, "SelectHero/BG/Income/Random/Value", "+" .. ret.getGrows)
        UI.text(self.node, "SelectHero/BG/Income/SkillExp/Value", "+" .. ret.getSkillExp)

        self.heroList = ret.schoolHero

        table.sort(self.heroList, function(a, b)

            if a.canstudy == b.canstudy then
                if a.allGrows == b.allGrows then
                    return a.id < b.id
                end
                return a.allGrows > b.allGrows
            end
            return a.canstudy > b.canstudy

        end)

        UI.cloneChild(self.heroNode, #self.heroList)
        for i, v in ipairs(self.heroList) do
            local child = UI.child(self.heroNode, i - 1)
            UI.draw(child, v)
            UI.text(child, "maxLearn", "剩余次数" .. v.maxLearn)
            HeroTools.setCHeadSprite(child, "Hero/head", v.id)
            if v.studying then
                UI.enableOne(child, "HeroSta", 1)
            else
                UI.enableOne(child, "HeroSta", 0)
                UI.button(child, "HeroSta/BtnSure", function()
                    if v.maxLearn > 0 then
                        message:send("C2S_ReqSelectHero", { id = v.id, index = index }, function()
                            UI.showHint((v.id == 1 and client.user.name or v.name) .. "已开始学习")
                            self:showSeatInfo()
                        end)
                    else
                        UI.showHint("剩余学习次数不够")
                    end
                end)
            end
        end
    end)
end

function Class:showHelp()
    showHelp("school")
end

return Class