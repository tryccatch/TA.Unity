---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Admin.
--- DateTime: 2021/8/3 11:01
---
local cls = {
    res = "ui/unity_joinRequest"
}

function cls:close()
    self.controller:close(self.controller.Pages.UnityJoinRequest)
end

function cls:onToggleChange(isOn)
    message:send("C2S_changeRandomJoin",{allowRandomJoin = isOn},function(msg)
        print("call back")
        local result  = self:dealWithCode(msg.code)
        if msg.code == "ok" then
            UI.showHint("更改成功")
        end
    end)
end

function cls:init(info)
    self.controller = info.controller
    message:send("C2S_openJoinRequest",{},function(msg)
        self.pageData = msg
        self:updateList(msg.list,msg.allowRandomJoin)
    end)

    UI.button(self.node,"btnClose",function()
        self:close()
    end)

    UI.button(self.node,"btnRefuseAll",function()
        self:dealRequest(0,false,true)
    end)

    UI.toggle(self.node,"randomJoin",function(isOn)
        self:onToggleChange(isOn)
    end,true)
end



function cls:updateList(list,allowRandomJoin)
    local parent = UI.child(self.node,"list/v/c")
    local childCount = list and #list or 0
    UI.cloneChild(parent,#list)
    local noRequest = list == nil or #list < 1
    UI.enable(self.node,"list/v/noText",noRequest)
    if noRequest then
        UI.text(self.node,"askNum",0)
    end
    local toggle = UI.component(self.node,"randomJoin" ,typeof(CS.UnityEngine.UI.Toggle),true)
    if toggle then
        toggle.onValueChanged:RemoveAllListeners()
        toggle.isOn = allowRandomJoin
        UI.toggle(self.node,"randomJoin",function(isOn)
            self:onToggleChange(isOn)
        end,true)
    end
    if noRequest then
        return
    end

    local lvConfig = config["level"]
    for i = 1, childCount do
        local item = parent:GetChild(i-1)
        local data = list[i]
        local drawData = {
            name = data.name,
            level = lvConfig[data.level].name,
            power = data.power,
            btnAgree = function()
                self:dealRequest(data.userId,true,false)
            end,
            btnRefuse = function()
                self:dealRequest(data.userId,false,false)
            end
        }
        UI.draw(item,drawData)
    end

    UI.text(self.node,"askNum",#list)

end

function cls:dealRequest(id,agree,refuseAll)
    local data = {
        unityId=self.pageData.unityId,
        userId = id,
        agree =agree,
        refuseAll = refuseAll
    }
    message:send("C2S_dealJoinRequest",data,function(msg)
        local result =self:dealWithCode(msg.code)
        if msg.code == "ok" then
            local str = agree and "已同意申请" or "已拒绝申请"
            UI.showHint(str)
        end
        if result then
            self.pageData = msg
            self:updateList(msg.list,msg.allowRandomJoin)
        end
    end)
end

function cls:dealWithCode(code)
    if code == "noUnity" then
        UI.showHint("联盟不存在！")
        print("unity join request--联盟不存在")
        self.controller:exit()
        return false
    elseif code == "noRequest" then
        UI.showHint("请求已过时！")
    elseif code == "noAuthority" then
        UI.showHint("没有权限！")
        self:close()
        return false
    elseif code == "playerHasUnity" then
        UI.showHint("玩家已加入别的联盟！")
    elseif code == "memberFull" then
        UI.showHint("联盟成员已满")
    end
    return true
end

return cls