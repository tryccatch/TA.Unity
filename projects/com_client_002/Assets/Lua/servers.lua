require "base.tools"
require "base.ui"
require "config"

local transform = CS.UnityEngine.GameObject.Find("Canvas/Center")
if not transform then
    transform = CS.UnityEngine.GameObject.Find("Canvas")
end

transform = transform.transform
CS.UIAPI.SetGlobalNode(transform)
CS.UIAPI.ClearAll()

local node = nil

node = UI.showNode("ui/Update")
UI.enable(node, "Slider", false)

local checkAddr = "http://" .. defIP .. ":" .. defHotFixPort

CS.UnityEngine.GameObject.Find("Canvas").transform:SendMessage("CheckVersionToTest", checkAddr)