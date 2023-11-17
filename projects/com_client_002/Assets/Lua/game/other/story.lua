local Class = {
    res = "ui/story",
}

function Class:checkParamNotOk(id)
    return id ~= nil and id > 420 and id < 10000
end

function Class:init(params)

    if params == nil or self:checkParamNotOk(params.id) or self:checkParamNotOk(params.storyID) then
        UI.close(self)
        if params.endFun then
            params.endFun()
        end
        return
    end

    CS.Sound.PlayMusic("music/storypublic")

    self.first = true

    if params.heroId then
        params.heroID = params.heroId;
    end

    if params.id then
        params.storyID = params.id;
    end

    if params.fun then
        params.endFun = params.fun;
    end

    if params.wifeId then
        params.wifeID = params.wifeId;
    end

    if params.heroID and params.heroID > 0 then
        for _, v in ipairs(config.storyGet) do
            log(_s(v))
            if v.heroID == params.heroID then
                params.storyID = v.id
                break
            end
        end
    end

    if params.wifeID and params.wifeID > 0 then
        for _, v in ipairs(config.storyGet) do
            if v.wifeID == params.wifeID then
                params.storyID = v.id
                break
            end
        end
    end

    if params.storyID then
        for _, v in ipairs(config.story) do
            if v.storyID == params.storyID then
                params.index = v.id
                log("对白：" .. v.id)
                break
            end
        end
    end

    self.index = params.index
    self.allEndFun = params.endFun

    self.background = UI.child(self.node, "img")
    self.left = UI.child(self.node, "left")
    self.right = UI.child(self.node, "right")
    self.center = UI.child(self.node, "center")
    self.hint = UI.child(self.node, "hint")
    self.hintText = UI.child(self.hint, "Text")
    self.leftName = UI.child(self.node, "leftName")
    self.rightName = UI.child(self.node, "rightName")

    UI.button(self.node, function()
        self:next()
    end)

    self:showStep()

    UI.addUpdate(self.node, function(dt)
        self:update(dt)
    end)
end

function Class:update(dt)
    if self.text then
        local len = string.len(self.text)
        self.textPos = self.textPos + dt * 50;

        if self.textPos >= len then
            UI.text(self.hintText, self.text)
            self.text = nil
        else
            local pos = math.floor(self.textPos)
            --if pos % 3 == 1 then
            --    pos = pos + 2
            --elseif pos % 3 == 2 then
            --    pos = pos + 1
            --end

            local i = 1
            while i <= pos do
                local curByte = string.byte(self.text, i)
                local byteCount = 1;
                if curByte > 127 then
                    byteCount = 3
                end
                i = i + byteCount
            end

            UI.text(self.hintText, string.sub(self.text, 1, i - 1))
        end
    end
end

function Class:next()
    if not self.enableNext then
        return
    end

    if self.text then
        UI.text(self.hintText, self.text)
        self.text = nil
        return
    end

    if self.cfg and self.cfg.IsUseAni == 1 then
        self.enableNext = false
        UI.playEffect(self.node, "whitelight", 0.6)
        UI.delay(self.node, 0.5, function()
            self.index = self.index + 1
            self:showStep()
        end)
    else
        self.index = self.index + 1
        self:showStep()
    end
end

function Class:showStep()
    local cfg = config.storyMap[self.index]
    if (cfg == nil) or (self.storyID and cfg.storyID ~= self.storyID) then
        self:endStory()
        return
    end

    print("set cfg:", self.index)

    self.cfg = cfg
    self.storyID = cfg.storyID

    if cfg.background == 0 then
        UI.enable(self.background, false)
    else
        UI.enable(self.background, true)
        UI.rawImage(self.background, "storyShowBack/storyShowback" .. cfg.background, nil, false)
    end

    if cfg.sound ~= "" then
        CS.Sound.PlayGuide("guide/" .. cfg.sound)
    else
        CS.Sound.PlayOne("")
    end
    if cfg.anim ~= "" then
        local node = UI.child(self.node, "Anim/" .. cfg.anim)

        UI.draw(self.node, "Anim", {
            scale = cfg.anim == "scale" and cfg.background,
            shake = cfg.anim == "shake" and cfg.background,
            offset = cfg.anim == "offset" and cfg.background,
        })

        UI.button(self.node, nil)

        local initScale = 1.2
        local nextScale = 1
        if cfg.scale[1] > 0 then
            initScale = cfg.scale[1] / 10
            if #cfg.scale > 1 then
                nextScale = cfg.scale[2] / 10
            end
        end

        UI.setScale(node, initScale, initScale, 0)

        if cfg.anim == "scale" then
            UI.setAlpha(node, 0.3)
            UI.tweenList(node, {
                {
                    alpha = 0.3,
                    time = 0,
                },
                {
                    alpha = 1,
                    time = 1,
                }
            })
            UI.tweenList(node, {
                {
                    scale = initScale,
                    time = 0,
                },
                {
                    scale = nextScale,
                    time = 2,
                }
            })
        end

        local posX = 10
        local posY = 10
        log(#cfg.vector)
        if #cfg.vector > 1 then
            posX = cfg.vector[2]
            posY = cfg.vector[3]
        end
        if cfg.anim == "offset" then
            local sAnim = node.gameObject:GetComponent(typeof(CS.SAnim))
            if cfg.background == 30 then
                sAnim.enabled = true
            else
                sAnim.enabled = false
                local time = 0.5
                local times = 3

                local offset = function()
                    UI.tweenList(node, {
                        {
                            offset = {
                                x = posX,
                                y = posY
                            },
                            time = time,
                        },
                        {
                            offset = {
                                x = -posX,
                                y = -posY
                            },
                            time = time,
                        },
                    })
                end

                UI.tweenList(node, {
                    {
                        scale = 1.2,
                        time = 0,
                    },
                    {
                        fun = function()
                            for i = 1, times do
                                UI.delay(self.node, 2 * (i - 1) * time, function()
                                    offset()
                                end)
                            end
                        end,
                    },
                })
            end
        end

        if cfg.anim == "shake" then
            --UI.tweenList(node, {
            --    {
            --        scale = scale,
            --        time = 0,
            --    },
            --    {
            --        shakeOne = CS.UnityEngine.Vector3(posX, posY, 0),
            --        time = 3,
            --    },
            --})
        end

        UI.delay(self.node, 3, function()
            UI.setLocalPosition(node, 0, 0, 0)
            UI.button(self.node, function()
                self:next()
            end)
        end)

        UI.enable(self.node, "Anim", true)
    else
        UI.enable(self.node, "Anim", false)
    end

    if self.left.childCount > 0 then
        local child = UI.child(self.left, 0)
        UI.close(child)
    end

    if self.right.childCount > 0 then
        local child = UI.child(self.right, 0, true)
        UI.close(child)
    end

    local headNode = self.left
    local nameNode = self.leftName
    if cfg.position == 1 then
        headNode = self.right
        nameNode = self.rightName

        UI.enable(self.right, true)
        UI.enable(self.left, false)
        UI.enable(self.center, false)

        UI.enable(self.leftName, false)
    elseif cfg.position == 0 then
        UI.enable(self.right, false)
        UI.enable(self.left, true)
        UI.enable(self.center, false)

        UI.enable(self.rightName, false)

    else
        UI.enable(self.right, false)
        UI.enable(self.left, false)
        UI.enable(self.center, true)

        UI.enable(self.rightName, false)

        headNode = self.center
    end

    local offX = 0
    local offY = 0

    local animNode
    if cfg.headType == 1 then
        animNode = HeroTools.showAnim(headNode, cfg.head)
        offY = 200
    end

    if cfg.headType == 2 then
        animNode = UI.showNode(headNode, "Anim/wife" .. cfg.head)
        UI.playAnim(animNode, "idle")
        animNode.name = "_animNode"
        offY = -600
    end

    if cfg.headType == 3 then
        UI.rawImageResize(headNode, "character/storyShowCharacter" .. cfg.head, nil, false)
    else
        UI.rawImageResize(headNode, "")
    end

    if cfg.headType == 4 then
        animNode = UI.showNode(headNode, "Anim/wifeUndress" .. cfg.head)
        UI.playAnim(animNode, "idle")
        animNode.name = "_animNode"
        offY = -600
    end

    if animNode then
        UI.setLocalOffset(animNode, offX, offY)
    end

    if string.sub(cfg.name, 1, 1) == "0" then
        UI.enable(nameNode, false)
    else
        UI.enable(nameNode, true)
        UI.text(nameNode, "Text", cfg.name)
    end

    UI.text(self.hintText, "")
    if string.sub(cfg.talk, 1, 1) == "0" then
        self.text = nil
    else
        self.text = cfg.talk
        self.textPos = 1
    end

    if string.len(cfg.black_text) > 1 then
        local tempText = self.text
        self.text = nil

        self.enableNext = false
        UI.enable(self.node, "black", true)
        UI.text(self.node, "black/Text", cfg.black_text)

        local node = UI.child(self.node, "black")

        local firstTime = 0.5
        if self.first then
            firstTime = 0
        end

        UI.tweenList(node, {
            {
                alphaAll = 0,
                time = 0,
            },
            {
                alphaAll = 1,
                time = firstTime,
            },
            {
                time = 1,
            },
            {
                alphaAll = 0,
                time = 0.5,
            },
            {
                fun = function()
                    --UI.enable(self.node,"black",false)        
                    self.enableNext = true
                    self.text = tempText
                end
            }
        })
    else
        UI.enable(self.node, "black", false)
        self.enableNext = true
    end

    self.first = false

    if cfg.voice > 0 then
        CS.Sound.Play("voice/storyVoice" .. cfg.voice)
    end
end

function Class:endStory()
    self:endFun()
end

function Class:endFun()
    local cfg = config.storyGetMap[self.cfg.storyID]

    -- cfg = config.storyGet[1]

    if cfg then
        local node = nil

        if cfg.heroID > 0 then
            node = Story.showHero(cfg.heroID)
        end

        if cfg.wifeID > 0 then
            node = Story.showWife(cfg.wifeID)
        end

        if node ~= nil then
            UI.button(node, "button", function()
                UI.close(node)
                UI.close(self)

                if self.allEndFun then
                    self.allEndFun()
                end
            end)
            return
        end
    end

    UI.close(self)
    if self.allEndFun then
        self.allEndFun()
    end
end

return Class