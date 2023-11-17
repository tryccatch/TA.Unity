local Class = {
    _parent = "Canvas/Mask",
    _res = "ui/guide"
}

function Class:init(guideId)
    --if guideId>0 then
    --    return "close"
    --end

    if is_debug then
        return "close"
    end

    if client.user.guildId >= guideId then
        return "close"
    end

    self.id = guideId
    --self.step = CS.UnityEngine.PlayerPrefs.GetInt("guideId" .. self.id, 1)

    self.step = 1
    log(self.step)

    --if self.step == -1 then
    --    return "close"
    --end

    if guideId == 2 then
        local node = CS.UIAPI.gNode:Find("LobbyMain/BG1")
        log(node.name)
        UI.setLocalPosition(node, -888, nil, nil)
        local dailyTaskNode = CS.UIAPI.gNode:Find("dailyTask")
        if dailyTaskNode then
            for i = 1, #UI.list do
                if UI.list[i].node == dailyTaskNode then
                    table.remove(UI.list, i)
                    UI.close(dailyTaskNode)
                    break
                end
            end
        end
    end

    local parent = CS.UnityEngine.GameObject.Find(Class._parent)
    self.node = UI.showNode(parent.transform, Class._res)

    self.preStep = 1
    self:doStep()

    self.finger = UI.showNode(self.node, "Base/GuideEffect")
    UI.enable(self.finger, false)

    message.curMsg = {}

    UI.addUpdate(self.node, function()
        self:update()
    end)
end

function Class:onClose()
    local mainUI = UI.getUI("game.lobby.main")
    if mainUI and (mainUI.canShowGuideEffect == false) then
        mainUI.canShowGuideEffect = true
        if self.BtnRushRank then
            UI.enable(self.BtnRushRank, true)
        end
    end
    message.curMsg = nil
end

function Class:update()
    local mainUI = UI.getUI("game.lobby.main")
    if mainUI and mainUI.canShowGuideEffect then
        mainUI.canShowGuideEffect = false
        if self.id == 1 then
            self.BtnRushRank = UI.child(mainUI, "Activity/BtnRushRank")
            UI.enable(self.BtnRushRank, false)
        end
    end

    if self.lockedPath then
        local node = CS.UIAPI.gNode:Find(self.lockedPath)
        if node then
            CS.MaskClick.SetClick(self.node, node)
            self.lockedPath = nil

            UI.enable(self.finger, true)

            self.fingerToNode = node
            self:setFingerPos(self.fingerToNode)
        end
    end

    if UI.isVisual(self.finger) then
        if (not UI.isVisual(self.fingerToNode)) or (not UI.isVisual(self.fingerToNode.parent)) then
            UI.enable(self.finger, false)
        end

        if UI.isVisual(CS.UIAPI.gNode, "story") then
            UI.enable(self.finger, false)
        end

    else
        if UI.isVisual(CS.UIAPI.gNode, "story") then
            UI.closeMask()
        elseif UI.isVisual(self.fingerToNode) and UI.isVisual(self.fingerToNode.parent) then
            UI.enable(self.finger, true)
            self:setFingerPos(self.fingerToNode)
        end
    end

    if UI.isVisual(CS.UIAPI.gNode, "story") then
        self:clearLock()
    else
        if UI.isVisual(self.finger) and self.fingerToNode then
            CS.MaskClick.SetClick(self.node, self.fingerToNode)
        end
    end

    if UI.isVisual(CS.UIAPI.gNode, "Mask") then
        UI.enable(self.finger, false)
        self:clearLock()
    end

    --if message.curMsg then
    --    log(message.curMsg,self.cfg.eventParam)
    --end

    if self.cfg then
        local eventType = self.cfg.eventType
        if eventType == "closeUI" then
            if self.checkUI == nil then
                self.checkUI = CS.UIAPI.gNode:Find(self.cfg.eventParam)
                log("closeUI find:", self.checkUI)
            else
                if not UI.isVisual(self.checkUI) then
                    log("closeUI", self.checkUI)
                    self:nextStep()
                end
            end
        elseif eventType == "showUI" then
            if UI.isVisual(CS.UIAPI.gNode, self.cfg.eventParam) then
                log("showUI", self.cfg.eventParam)
                self:nextStep()
            end
        elseif eventType == "message" then

            if message.curMsg and message.curMsg[self.cfg.eventParam] then
                log(message.curMsg)
                message.curMsg = {}
                --message.curMsg[self.cfg.eventParam] = nil
                self:nextStep()
                log(message.curMsg)
            end

        end
    end
    --
    --message.curMsg = {}
end

function Class:setFingerPos()
    if self.cfg.x == 0 and self.cfg.y == 0 then
        self.finger.position = self.fingerToNode.position
    else
        UI.setLocalPosition(self.finger, self.cfg.x, self.cfg.y)
    end
end

function Class:setLock(path)
    log("set lock:" .. path)
    CS.MaskClick.SetClick(self.node, nil)
    self.lockedPath = path
    UI.closeMask()
end

function Class:clearLock()
    --log("clearLock")
    CS.MaskClick.Clear(self.node)
end

function Class:playStory(id)

end

function Class:save()
    if self.cfg and self.cfg.save ~= 0 then
        CS.UnityEngine.PlayerPrefs.SetInt("guideId" .. self.id, self.cfg.save)
        message:send("C2S_setEndGuide", { id = self.id })
        client.user.guildId = self.id
    end
end

function Class:nextStep()
    local cfg = config.guideMap[self.step + self.id * 10000]

    if self.preStep < #cfg.preId then
        self.preStep = self.preStep + 1
    else
        self.step = self.step + 1
        self.preStep = 999

        self:save()

        cfg = config.guideMap[self.step + self.id * 10000]
        if cfg == nil then
            CS.UnityEngine.PlayerPrefs.SetInt("guideId" .. self.id, -1)
            log("引导已结束")
            local node = CS.UIAPI.gNode:Find("Mask")
            if node then
                CS.UIAPI.Destroy(node)
            end
            UI.close(self)
            return
        end
    end

    self:doStep()
end

function Class:doStep()
    local cfg = config.guideMap[self.step + self.id * 10000]
    log("当前步数：" .. (self.step + self.id * 10000))
    if self.preStep <= #cfg.preId then
        local n = cfg.preId[self.preStep]
        if n > 0 then
            cfg = config.guideMap[self.preStep]
        end
    end

    if cfg.story > 0 then
        Story.show({
            id = cfg.story,
            fun = function()
                self:nextStep()
            end
        })
    end

    if cfg.lock ~= "" then
        self:setLock(cfg.lock)
    else
        self:clearLock()
    end

    if cfg.note == "closeMask" then
        UI.closeMask()
    end

    if cfg.showUI ~= "" then
        UI.show(cfg.showUI)
    end

    log(_s(cfg))

    UI.enable(self.finger, false)
    self.checkUI = nil
    self.cfg = cfg
    self:showGuide()
end

function Class:showGuide()
    if self.step == 2 and self.id == 1 then
        CS.UnityEngine.PlayerPrefs.SetInt("canShowGameGuide", 1)
        message:send("C2S_GetGameNotice", {}, function(msg)
            if msg.code == 1 then
                UI.show("game.other.Notice", { title = msg.title, content = msg.content })
            end
        end)
    end
end

return Class
