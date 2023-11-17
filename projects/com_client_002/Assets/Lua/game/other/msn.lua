local Class = {
    res = "ui/liaotian",
}

local txtLimit = 80
local msgLimit = 100
local chatCD = 5
local ChannelType = {
    ALL = 1, --全部频道
    WORLD = 2, --世界频道
    UNITY = 3        --联盟频道
}

local ServerMsgType = {
    SYSTEM = 1, --系统
    PLAYER = 2, --玩家
    SYSTEM_UNITY = 3, --联盟系统
    PLAYER_UNITY = 4    --联盟玩家
}

function Class:addTestData()
    for i = 2, 101 do
        local data = {
            level =0,
            cloth =0,
            msgId = 0,
            text = "测试消息"..i,
            link = "RushRank",
            vipLevel = 0,
            fameId = 0,
            head = 0,
            type =1,
            time = 1638774188704+i,
            name = "",
            userId = 0
        }
        table.insert(client.msgData[1],i,data)
    end
end

function Class:getCrtChannelMsgLen()
    local msg = self:getCrtChannelMsg()
    if msg == nil then
        return 0
    end

    if self.channel == ChannelType.WORLD then
        local totalCount = 0
        for i, v in ipairs(msg) do
            if v.type == ServerMsgType.PLAYER then
                totalCount = totalCount + 1
            end
        end
        return totalCount
    else
        return #msg
    end
end

function Class:getMsgMinId()
    local worldMsg = client.msgData[1]
    local unityMsg = client.msgData[2]
    local minId = -1
    if worldMsg ~= nil and worldMsg[1] ~= nil then
        minId = worldMsg[1].msgId
    end
    if unityMsg ~= nil and unityMsg[1] ~= nil then
        if unityMsg[1].msgId < minId or minId < 0 then
            minId = unityMsg[1].msgId
        end
    end
    return minId
end

function Class:getHistoryMsg(scrollRectValue)
    self.scrollY = scrollRectValue.y
end

function Class:init(param)
    if param == nil then
        param = 1
    end
    local scrollNode = UI.child(self.node, "message/S")
    CS.UIAPI.ScrollRectFun(scrollNode, function(value)
        self:getHistoryMsg(value)
    end)

    CS.UIAPI.OnEndDrag(scrollNode, function()
        if self.scrollY >= 1 then
            --print("进入刷新01")
            if self.isGetNewMsg then
                --print("正在获取消息")
                return
            end
            if self:getCrtChannelMsgLen() > msgLimit then
                --print("消息数量超标")
                return
            end

            self.isGetNewMsg = true
            local minId = self:getMsgMinId()
            local id = minId > 0 and minId or 0
            message:send("C2S_getLastMsg", { msgId = id, isUnity = self.isUnityChannel })
            UI.delay(self.node, 0.5, function()
                self.isGetNewMsg = false
            end)
        end
    end)
    self.channel = param
    local inputField = UI.component(self.node, "message/Send/Msg", typeof(CS.UnityEngine.UI.InputField))
    if inputField then
        inputField.onValueChanged:AddListener(function(value)
            if Tools.getStrLen(value) > txtLimit then
                inputField.text = Tools.subString(value, txtLimit)
            end
        end)
    end
    UI.button(self.node, "message/Send/Button", function()
        self:trySendMsg()
    end)

    client.msgData.onMsg = function()
        self:show()
    end

    UI.button(self.node, "BtnBack", function()
        UI.close(self)
    end)

    local tabNode = UI.child(self.node, "Tab")

    local showTab = function(n)
        local change = self.channel ~= n
        self.channel = n
        print("crt channel info:", n)
        for i = 1, 3 do
            local child = UI.child(tabNode, i - 1)
            UI.enable(child, 0, i == n)
        end
        self.isUnityChannel = (n == ChannelType.UNITY)
        UI.enable(self.node, "message/S/V/C", not change)
        self:show(true)
        UI.enable(self.node, "message/S/V/C", true)
    end

    for i = 1, 3 do
        UI.button(tabNode, i - 1, function()
            showTab(i)
        end)
    end

    showTab(self.channel)

    UI.enable(self.node, "userInfo", false)
end

function Class:getCrtChannelMsg()
    local messageIndex = 1
    if self.channel == ChannelType.UNITY then
        messageIndex = 2
    end
    --print("获取信息---:",messageIndex,#client.msgData[messageIndex])

    return client.msgData[messageIndex]
end


function Class:reverse(data)
    local halfLen = math.floor(#data/2)
    for i = 1, halfLen do
        local tem= data[i]
        local endIndex =  #data - i +1
        data[i] = data[endIndex]
        data[endIndex] = tem
    end
end

function Class:screenDataForShow(data)
    local remainCount = msgLimit
    local result = {}
    if self.channel == ChannelType.WORLD then
        for i = #data, 1, -1 do
            if data[i].type == ServerMsgType.PLAYER then
                --// 1系统 2玩家 3联盟系统 4联盟
                table.insert(result,#result+1,data[i])
                --result[remainCount] = data[i]
                remainCount = remainCount - 1
                if remainCount == 0 then
                    self:reverse(result)
                    return result,msgLimit
                end
            end
        end
        self:reverse(result)
        return result,msgLimit-remainCount
    else
        if #data < msgLimit then
            return data,#data
        end
        local startIndex = #data - msgLimit + 1
        for i = startIndex, #data do
            table.insert(result, #result + 1, data[i])
        end
        return result,msgLimit
    end
end

function Class:show(first)
    --log("+++++++++++++++++++++++++++")
    local msgNode = UI.child(self.node, "message/S/V/C")

    local msg = self:getCrtChannelMsg()

    if not msg then
        UI.cloneChild(msgNode, 0)
        return
    end

    --local count = #msg
    --if self.channel == ChannelType.WORLD then
    --    count = 0
    --    for i,v in ipairs(msg) do
    --        if v.type == ServerMsgType.PLAYER then     --// 1系统 2玩家 3联盟系统 4联盟
    --            count = count + 1
    --        end
    --    end
    --end
    --
    --if count >100 then
    --    count = 100
    --end

    local showData,count = self:screenDataForShow(msg)
    print("show msg count:", count)
    log(showData)
    UI.cloneChild(msgNode, count)
    msg = showData
    local i = 0
    local lastTime = 0
    for k=1, count  do
        local v = msg[k]
        if i>count then
            break
        end
        local needDraw = true
        if self.channel == ChannelType.WORLD then
            if v.type ~= ServerMsgType.PLAYER then
                needDraw = false
            end
        end

        --print("信息：",i,"channel= ",self.channel,"v.type=",v.type,"needDraw=",needDraw)
        if needDraw then
            local child = msgNode:GetChild(i)
            local n = 0
            if (v.type % 2) == 0 then
                n = 1
            end

            if v.userId == client.user.id then
                n = 2
                v.text = "<color=#01ff00>" .. v.text .. "</color>"
            end
            UI.enableOne(child, n)
            --print("显示信息：userid =",v.userId,"i=",i,"childName=",child.name,"n=",n)
            child = UI.child(child, n)
            local showTime = false
            if lastTime == 0 then
                lastTime = v.time
                showTime = true
            else
                showTime = (v.time - lastTime) >= 120 * 1000
                lastTime = v.time
            end

            if n == 0 then
                v.btnShowHero = function()
                    if UIPageName[v.link] then
                        UI.openPage(UIPageName[v.link])
                    end
                end
                UI.draw(child, v)
            else
                v.btnShowHero = function()
                    if v.userId ~= client.user.id then
                        ComTools.showPlayerInfo(v.userId, true)
                    else
                        self:addTestData()
                        UI.showHint("自身消息，不可操作")
                    end
                end
                v.heroId = 1
                HeroTools.setHeadTemp(v.head, v.level, v.cloth)
                UI.draw(child, v)
                HeroTools.clearHeadTemp()

                UI.enable(child, "fameId", v.fameId > 0)
            end

            UI.enable(child, "time", showTime)
            if showTime then
                local timeInfo = convertToTime(v.time / 1000)
                UI.text(child, "time/time", timeInfo.hour .. ":" .. timeInfo.minute)
            end

            if v.type == ServerMsgType.SYSTEM or v.type == ServerMsgType.SYSTEM_UNITY then
                local temp = UI.child(msgNode, i)
                local rect = UI.component2(temp, typeof(CS.UnityEngine.RectTransform))
                if rect then
                    local comp2 = UI.component2(temp, typeof(CS.MaxSize))
                    comp2.enabled = false
                    rect.sizeDelta = CS.UnityEngine.Vector2(547.9, 85)
                    comp2.enabled = true
                end
            end


        else
            local child = msgNode:GetChild(i)
            UI.enable(child, false)
        end
        i = i + 1
    end

    local scollRect = UI.component(self.node, "message/S", typeof(CS.UnityEngine.UI.ScrollRect))
    local show = first
    if scollRect then
        local temp = scollRect.verticalNormalizedPosition
        show = show or (scollRect.verticalNormalizedPosition < 0.01)
    end

    if show then
        CS.UIAPI.TweenNormalizePosition(scollRect, CS.UnityEngine.Vector2.zero, 0.5)
    end
    self:showCountDown()
end

function Class:onClose()
    client.msgData.onMsg = nil
end

local lastSendTime = 0
function Class:trySendMsg()
    local crtTime = os.time()
    if crtTime - lastSendTime >= chatCD then
        local msg = UI.getValue(self.node, "message/Send/Msg")
        if msg == "" then
            UI.showHint("内容不能为空")
            return
        end

        local _, msg2 = Tools.sensitiveCheck(msg)
        message:send("C2S_sendMsg", { text = msg2, isUnity = self.isUnityChannel }, function(ret)
            if ret.error and ret.error ~= "" then
                UI.showHint(ret.error)
            else
                UI.setValue(self.node, "message/Send/Msg", "")
                UI.showHint("发送成功")
                lastSendTime = crtTime
                self:showCountDown()
            end
        end)
    else
        UI.showHint("大人话说的太快，喘口气吧")
    end
end

local hasADD = false
function Class:showCountDown()
    local offset = chatCD - os.time() + lastSendTime
    if offset > 0 then
        UI.CountDown(self.node, "message/Send/Button/Text", offset, function()
            UI.text(self.node, "message/Send/Button/Text", "发送")
        end, 1, true, false)
    else
        UI.text(self.node, "message/Send/Button/Text", "发送")
        --if not hasADD then
        --    self:addTestData()
        --    hasADD = true
        --end
    end
end

return Class