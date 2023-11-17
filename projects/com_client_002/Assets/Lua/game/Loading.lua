local Class = {
    res = "ui/Loading",
}
--local ret
function Class:init()
    local timeLoading = 0

    local loadRes = {
        "HeroHead",
        "HeroHeads",
        "CHeroHead",
        "PlayerLevel",
        "Item",
        "ChildrenPic",
        "Jinbangtiming",
        "BossHead",
        "HeroWifeName",
        "BattleSkillItem",
        "HDEQua",
        "promotionV",
        "GateNumber",
        "KingCloth",
        "KingName",
        "KingVName",
        "KingHName",
        "RechargeImg",
        "rechargeNum",
        "Vipfuli",
        "AttrImg",
        "HeroWifeNameHeng",
        "RushEventId",
        "RushValue",
        "HeroValueBack",
        "nobleHead",
        "VipIcon",
        "VipFuliJiangliUI",
        "SkillIcon",
        "rushRank",
        "HeroStatus",
        "storyShowBack",
        "WifeHead",
        "EventManagerBtnName",
    }

    local index = 0
    local time = 0.5

    UI.addUpdate(self.node, function()

        if index < #loadRes then
            index = index + 1
            local v = loadRes[index]
            CS.Images.Load("Res/" .. v, v)
        end

        if timeLoading < time then
            timeLoading = timeLoading + CS.UnityEngine.Time.deltaTime
            UI.progress(self.node, "Slider", timeLoading / time)
        else
            if index >= #loadRes then
                UI.close(self)
                UI.show("game.lobby.main")
                local id = 0
                if client.msgData and client.msgData.lastMsg then
                    id = client.msgData.lastMsg.msgId
                end
                message:send("C2S_getLastMsg", {})
            end
        end
    end)
end

return Class