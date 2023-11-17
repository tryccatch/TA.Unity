local Class = {
    res = "ui/CreatePlayer",
}

local nameLimitMax = 8
local nameLimitMin = 2

function Class:init(params)

    local headNode = UI.child(self.node, "head")
    local selNode = UI.child(headNode, 10)

    local headIndex = 1
    local res = "me12"
    local animName = res
    local input = UI.component(self.node, "name_input", typeof(CS.UnityEngine.UI.InputField))
    if input then
        input.onValueChanged:AddListener(function(value)
            value = Tools.removeSymbolInString(value)
            local hasSensitive, result = Tools.sensitiveCheck(value)
            if Tools.getStrLenAsOne(result) > nameLimitMax then
                log(result)
                result = Tools.subStringAsOne(result, nameLimitMax)
                log(result)
            end
            input.text = result;
            UI.enable(self.node, "errorName", false)
        end)
    end
    UI.enable(self.node, "title", params ~= "changeFace")
    if params == "changeFace" then
        res = "me" .. client.user.level
        headIndex = client.user.head

        if client.user.level == 1 then
            animName = "me" .. 2
        end
        if client.user.level == 2 then
            animName = "me" .. 1
        end

        animName = "me" .. client.user.level
    else
        self:clearSave()
    end

    print("anim res:", res)
    local anim = UI.showNode(self.node, "Anim", "Anim/" .. res)
    UI.playAnim(anim, "idle")
    UI.changAnimSlot(anim, animName, "191", "" .. headIndex)

    UI.enable(self.node, "errorName", false)

    for i = 1, 10 do
        local child = UI.child(headNode, i - 1)
        UI.sprite(child, 0, "Head", i)

        if i == headIndex then
            selNode.localPosition = child.localPosition
        end

        UI.button(child, function()
            print("change head index：", i)
            UI.changAnimSlot(anim, animName, "191", "" .. i)
            selNode.localPosition = child.localPosition
            headIndex = i
        end)
    end

    if params == "changeFace" then
        UI.enable(self.node, "name_input", false)
        UI.enable(self.node, "name_btn", false)
        UI.button(self.node, "game_btn", function()
            local msg = {
                name = "",
                head = headIndex,
            }
            message:send("C2S_create_player", msg, function(ret)
                client.user.head = headIndex
                UI.close(self)
                UI.showHint("易容成功")
            end)
        end)
        return
    end

    local name = UI.getValue(self.node, "name_input")
    UI.button(self.node, "game_btn", function()
        if not headIndex then
            UI.msgBox("请选择头像")
            return
        end

        name = UI.getValue(self.node, "name_input")

        if name == "" or name == nil then
            UI.msgBox("请输入昵称")
            return
        end

        if Tools.sensitiveCheck(name) then
            UI.msgBox("不能输入敏感字")
            return
        end

        local len = Tools.getStrLenAsOne(name)
        if len < nameLimitMin or len > nameLimitMax then
            UI.msgBox("可输入2-8个字符")
            return
        end

        local msg = {
            name = name,
            head = headIndex,
        }

        message:send("C2S_create_player", msg, function(ret)
            if ret.error == "ok" then
                client.user.name = name
                client.user.head = headIndex
                UI.close(self)
                UI.show("game.Loading")

            else
                UI.msgBox(Tools.getError(ret.error))
                if ret.error == "exists_name" then
                    UI.enable(self.node, "errorName", true)
                end
            end
        end)
    end)

    UI.button(self.node, "name_btn", function(ret)
        local value = true
        if headIndex > 5 then
            value = false
        end
        log(value)
        message:send("C2S_rand_name", { male = value }, function(ret)
            UI.text(self.node, "name_input", ret.name)
        end)
    end)

    message:send("C2S_rand_name", { male = value }, function(ret)
        UI.text(self.node, "name_input", ret.name)
    end)
end

function Class:clearSave()
    -- 清除引导
    for i = 1, 10 do
        CS.UnityEngine.PlayerPrefs.DeleteKey("guideId" .. i)
    end

    CS.UnityEngine.PlayerPrefs.DeleteKey("storyId")
end

return Class