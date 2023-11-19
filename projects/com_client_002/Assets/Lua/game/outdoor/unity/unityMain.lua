---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Admin.
--- DateTime: 2021/7/30 10:55
---
local cls = {
    res = "ui/unity_main"
}

function cls:addRedDot(add)
    local btnHall = UI.child(self.node, "btnHall")
    local btnNoble = UI.child(self.node, "btnRich")
    local btnShop = UI.child(self.node, "btnShop")
    if add then
        RedDot.registerBtn(btnHall, RedDot.SystemID.UnityEnterReq)
        RedDot.registerBtn(btnHall, RedDot.SystemID.UnityDailyBuild)
        RedDot.registerBtn(btnNoble, RedDot.SystemID.UnityNoble, true)
        RedDot.registerBtn(btnShop, RedDot.SystemID.UnityShop, true)
    else
        RedDot.unregisterBtn(btnHall, RedDot.SystemID.UnityEnterReq)
        RedDot.unregisterBtn(btnHall, RedDot.SystemID.UnityDailyBuild)
        RedDot.unregisterBtn(btnNoble, RedDot.SystemID.UnityNoble, true)
        RedDot.unregisterBtn(btnShop, RedDot.SystemID.UnityShop, true)
    end
end

function cls:close()
    client.msgData.unRegisterNode("unityChat")
    self:addRedDot(false)
    self.controller:close(self.controller.Pages.Main)
end

function cls:init(data)
    CS.Sound.PlayMusic("music/alliance", true, 0.1)
    self.controller = data.controller
    local unityData = data.params
    local btnData = {
        btnRank = function()
            self.controller:openPage(self.controller.Pages.Rank)
        end,
        btnSecret = function()
            self.controller:openPage(self.controller.Pages.Secret)
        end,
        btnMember = function()
            self.controller:openPage(self.controller.Pages.Member)
        end,
        btnRich = function()
            self.controller:openPage(self.controller.Pages.Rich)
        end,
        btnHall = function()
            self.controller:openPage(self.controller.Pages.Hall)
        end,
        btnShop = function()
            self.controller:openPage(self.controller.Pages.Shop)
        end,
        btnClose = function()
            self:close()
            self.controller:exit()
        end,
        btnRichAdd = function()
            self.controller:openPage(self.controller.Pages.RichAdd)
        end

    }
    UI.delay(self.node, 0.1, function()
        client.msgData.disMsg()
    end)
    UI.button(self.node, "Chat", function()
        UI.openPage(UIPageName.ChatUnity)
    end)
    UI.draw(self.node, btnData)

    local chatNode = UI.child(self.node, "Chat")
    client.msgData.registerNode("unityChat", chatNode)
    self:update()
    self:addRedDot(true)
end

function cls:onFront()
    if self.controller.exitUnity then
        return
    end
    self:update()
end

function cls:update(msg)
    --client.msgData.disMsg()
    if msg then
        self:updateShow(msg)
    else
        message:send("C2S_getMyUnityInfo", {}, function(msg2)
            if msg2.info ~= nil then
                self:updateShow(msg2)
            else
                print("更新unityMain")
                UI.showHint("已退出联盟或还未加入联盟！")
                self:close()
            end
        end)
    end
end

function cls:updateShow(data)
    local msg = data.info == nil and data or data.info
    self.secretIsOpen = data.isOpen
    local allianceConfig = config["alliance"]
    local expMax = 0
    local memberMax = 0
    local expStr
    print("联盟数据:", msg.lv, #allianceConfig)
    if msg.lv < #allianceConfig then
        expMax = allianceConfig[msg.lv + 1].exp
        expStr = goldFormat(msg.exp) .. "/" .. goldFormat(expMax)
    else
        expMax = allianceConfig[#allianceConfig].exp
        expStr = "满级"
    end

    if msg.lv <= 0 then
        msg.lv = 1
    end
    memberMax = allianceConfig[msg.lv].memberMax

    local drawData = {
        name = msg.name,
        count = msg.memberCount .. "/" .. memberMax,
        influence = msg.influence,
        level = msg.lv,
        expNum = expStr
    }

    UI.draw(self.node, drawData)
    local slider = UI.child(self.node, "slider")
                     .gameObject:GetComponent(typeof(CS.UnityEngine.UI.Slider))
    slider.value = msg.exp / expMax

    print("msg isOpen:", data.isOpen)
    UI.enable(self.node, "effect", data.isOpen == 1)
end

function cls:onBack()
    UI.enable(self.node, "effect", false)
end

return cls

