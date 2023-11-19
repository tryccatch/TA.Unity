---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Admin.
--- DateTime: 2021/8/6 15:05
---
local cls = {
    res = "ui/unity_build"
}

function cls:close()
    self.controller:close(self.controller.Pages.Build)
end

function cls:init(params)
    self.controller = params.controller
    self:update()
end

function cls:update(data)
    if data ~= nil then
        self:updatePage(data)
    else
        message:send("C2S_openBuild",{},function(msg)
            self:update(msg)
        end)
    end
end

function cls:updatePage(msg)
    if msg.code == "noUnity" then
        UI.showHint("您没有联盟数据")
        self.controller:exit()
    elseif msg.code == "noGold" then
        UI.showHint("元宝不足，可前往充值获取")
    elseif msg.code == "noItem" then
    elseif msg.code == "buildIdErr" then
        UI.showHint("建设类型错误，请重试")
    elseif msg.code == "noBuildCount" then
        UI.showHint("今日建设次数已用完")
    end
    local drawData = {
        gold = goldFormat(msg.gold),
        item1 =  msg.qiangMeng,
        item2 =  msg.qiangMeng2,
        btnClose = function()
            self:close()
        end,BtnHelp=function()
            self:showHelp()
        end
    }
    UI.draw(self.node,drawData)

    local buildConfig = config["allianceBuild"]
    for i = 1, 4 do
        self:updateSingleBuild(
                UI.child(self.node,"buildList/item"..i),
                buildConfig[i],
                msg.buildId,
                i)
    end
end

function cls:showHelp()
    showHelp("unitybulid")
end

function cls:updateSingleBuild(node,data,hasBuildId,index)
    print("hasBuildID:",hasBuildId,"index:",index)
    local drawData = {
        attribute = "贡献+".. data.devote,
        costNum = "X"..(data.type == 1 and data.cost or 1),
        exp = "+"..data.exp,
        rich = "+"..data.wealth,
        influence = "+"..data.influence,
        btnBuild = function()
            self:buildUnity(index)
        end
    }
    UI.draw(node,drawData)
    UI.enable(node,"btnBuild",hasBuildId == 0)
    UI.enable(node,"hasBuild",hasBuildId == index)
    UI.enable(node,"costNum",hasBuildId == 0)
    --UI.enable(node,"costIcon",hasBuildId == 0)
end

function cls:buildUnity(id)
    message:send("C2S_buildUnity",{buildId = id},function(msg)
        if msg.code == "ok" then
            UI.showHint("建设成功")
        elseif msg.code == "noItem" then
            local tempConfig = config["allianceBuild"][id]
            if tempConfig.itemID > 0 then
                local itemName = config.itemMap[tempConfig.itemID].name
                UI.showHint(itemName.."不足")
            end
        elseif msg.code == "maxBuildCount" then
            UI.showHint("建设次数已达到上限，请明日再来")
        end
        self:update(msg)
    end)
end

return cls