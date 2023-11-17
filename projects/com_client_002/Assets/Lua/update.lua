is_debug = CS.API.IsDebug()
server_enum = CS.API.ServerEnum()
if is_debug then
    used_update = false
else
    used_update = true
end

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
local state = "init"
local downloadDatas = {}
local step = 1

if not used_update then
    CS.ResTools.StopUpdate()
    state = nil
end

local updateAddr = "http://" .. defIP .. ":" .. defHotFixPort

function main_update()
    if state == "init" then
        state = ""
        node = UI.showNode("ui/Update")
        UI.enable(node, "Slider", false)
        CS.ResTools.LoadConfig(function()
            state = "check"
        end)
    end

    if state == "check" then
        state = ""
        CS.ResTools.CheckUpdate(updateAddr, function(ret)
            print("------------in check model")
            log(ret)
            if ret == false then
                if is_debug then
                    CS.ResTools.StopUpdate()
                    return
                end
                UI.msgBox("网络链接失败，是否重试?", function()
                    state = "check"
                end, function()
                    CS.UnityEngine.Application.Quit()
                end)
            else

                if ret.Count == 0 then
                    print("------------in check model,count = 0,stop update")
                    CS.ResTools.StopUpdate()
                else
                    if ret[0] == "forceUpdate" then
                        print("------------in check model,count = 0,force update")
                        UI.text(node, "Text", "版本太老，请更新版本")
                        UI.msgBox("版本太老，请更新版本", function()
                            CS.UnityEngine.Application.OpenURL(ret[1])
                        end)
                        return
                    else
                        state = "download"
                        downloadDatas = ret
                        step = 0
                        --CS.ResTools.StopUpdate()
                        print("------------in check model,count = 0,start download")

                    end

                end
            end
        end)
    end

    if state == "download" then
        state = ""
        log("download file:" .. downloadDatas[step])
        UI.enable(node, "Slider", true)
        UI.text(node, "Text", "下载中 " .. (step + 1) .. "/" .. downloadDatas.Count)
        CS.ResTools.DownloadFile(downloadDatas[step], function(process)

            if process >= 0 then
                UI.progress(node, "Slider", process)
            end

            if process == 100 then
                CS.ResTools.UpdateVersion(downloadDatas[step])
                step = step + 1
                if step >= downloadDatas.Count then
                    CS.ResTools.StopUpdate()
                else
                    state = "download"
                end
            else
                if process == -1 then
                    UI.msgBox("下载失败，是否重下?", function()
                        state = "download"
                    end, function()
                        CS.UnityEngine.Application.Quit()
                    end)
                end
            end
        end)
    end
end

