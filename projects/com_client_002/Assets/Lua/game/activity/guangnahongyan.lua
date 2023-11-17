local Class = {
    res = "UI/guangnahongyan"
}

function Class:init()
    UI.button(self.node, "BtnClose", function()
        UI.close(self)
    end)
    UI.enableAll(self.node, false)
    self:showGnHyInfo()
end

function Class:showGnHyInfo()
    message:send("C2S_ReqGnHyInfo", {}, function(ret)
        UI.enableAll(self.node, true)

        local count = ret.value
        local second = ret.nextGetSecond
        log(second)

        local goldInfo = { count = ret.getGold, name = "元宝", icon = 5000 }

        UI.text(self.node, "TextBox/Count/value", count .. "/" .. ret.maxValue)

        if count == 0 then
            self:showTime(0, second)
        elseif count == 8 then
            self:showTime(2)
        else
            self:showTime(1, second)
        end
        if count > 0 then
            UI.enable(self.node, "BgReward", true)
            UI.text(self.node, "BgReward/Reward/value", count)
            UI.text(self.node, "BgReward/Chat/Text", ret.statement)
            UI.button(self.node, "BgReward/Reward/Btn", function()
                message:send("C2S_ReqGetTribute", {}, function()
                    self:showGnHyInfo()
                    ItemTools.showItemResult(goldInfo)
                end)
            end)
        else
            UI.enable(self.node, "BgReward", false)
        end
    end)
end

function Class:showTime(index, second)
    UI.enableOne(self.node, "TV", index)
    if index < 2 then
        UI.txtUpdateTime(self.node, "TV/TC" .. index .. "/value", second, function()
            UI.desObj(self.node, "TV/TC" .. index .. "/value", CS.TxtTime);
            self:showGnHyInfo()
        end)
    end
end

return Class