local Class = {
    res = "ui/Login"
}

function Class:init()
    CS.Sound.PlayMusic("music/activity")
    UI.enableAll(self.node, false)
    UI.text(self.node, "version", "V " .. CS.UnityEngine.Application.version .. " Res " .. Tools.getResVersion())
    UI.enable(self.node, "version", true)

    -- load head resource
    CS.Images.Load("Res/Head", "Head")
    CS.Images.Load("Res/Body", "Body")

    if not SdkMgr.isSdkLogin() then
        UI.enable(self.node, "Login", true)

        local account = CS.UnityEngine.PlayerPrefs.GetString("account")
        local pwd = CS.UnityEngine.PlayerPrefs.GetString("pwd")
        UI.text(self.node, "Login/InputAccount", account)
        UI.text(self.node, "Login/InputPwd", pwd)

        log(account, pwd)
    else
        local loginFun = function()
            UI.showWaitting()
            UI.enable(self.node, "Select", false)
            SdkMgr.loginToGameServer(function(ret)
                self:onServerLoginBack(ret)
            end, nil, nil)
        end

        UI.button(self.node, "Select/BtnGame", function()
            loginFun()
        end)
        loginFun()
    end

    UI.button(self.node, "Login/BtnBack", function()
        UI.enable(self.node, "Select", true)
        UI.enable(self.node, "Login", false)
    end)

    UI.button(self.node, "Select/BtnLogin", function()
        UI.enable(self.node, "Select", false)
        UI.enable(self.node, "Login", true)
    end)

    UI.button(self.node, "Login/BtnRegister", function()
        UI.enable(self.node, "Login", false)
        UI.enable(self.node, "Register", true)
    end)

    UI.button(self.node, "Register/BtnLogin", function()
        UI.enable(self.node, "Login", true)
        UI.enable(self.node, "Register", false)
    end)

    -- 登录
    UI.button(self.node, "Login/BtnLogin", function()
        local account = UI.getValue(self.node, "Login/InputAccount")
        local pwd = UI.getValue(self.node, "Login/InputPwd")

        SdkMgr.loginToGameServer(function(ret)
            self:onServerLoginBack(ret)
        end, account, pwd)
    end)

    -- 注册
    UI.button(self.node, "Register/BtnRegister", function()
        local account = UI.getValue(self.node, "Register/InputAccount")
        local pwd1 = UI.getValue(self.node, "Register/InputPwd1")
        local pwd2 = UI.getValue(self.node, "Register/InputPwd2")

        if account == "" then
            account = "test" .. math.random(1000000, 9000000)
            pwd1 = "123456"
            pwd2 = "123456"
        end

        local accountLen = string.len(account)
        local pwLen = string.len(pwd1)

        local i1, j1 = string.find(account, "%w+")
        local i2, j2 = string.find(pwd1, "%w+")

        if accountLen < 6 or accountLen > 24 then
            UI.msgBox("账号字数6-24位")
            return
        end
        if j1 < accountLen then
            UI.msgBox("账号只能使用数字、字母组合")
            return
        end
        if pwd2 ~= pwd1 then
            UI.msgBox("两次密码不一样")
            return
        end
        if pwLen < 6 or pwLen > 24 then
            UI.msgBox("密码字数6-24位")
            return
        end
        if j2 < pwLen then
            UI.msgBox("密码只能使用数字、字母组合")
            return
        end

        local msg = {
            account = account,
            pwd = pwd1,
        }
        message:send("C2S_register", msg, function(ret)
            log("注册结果")
            log(ret)
            if ret.error == "ok" then
                CS.UnityEngine.PlayerPrefs.SetString("account", account)
                CS.UnityEngine.PlayerPrefs.SetString("pwd", pwd1)
                self:showServerList(ret.token)
            else
                UI.msgBox(Tools.getError(ret.error))
            end
        end)
    end)

    UI.button(self.node, "Sever/BtnNotice", function()
        self:showNotice()
    end)
    --UI.button(self.node, "Sever/Notice/BtnBack", function() UI.enable(self.node, "Sever/Notice", false) end)
    UI.button(self.node, "Sever/SeverList/BtnBack", function()
        UI.enable(self.node, "Sever/SeverList", false)
    end)
end

function Class:onServerLoginBack(ret)
    if ret.error == "ok" then
        CS.UnityEngine.PlayerPrefs.SetString("account", ret.account)
        CS.UnityEngine.PlayerPrefs.SetString("pwd", ret.pwd)
        self:showServerList(ret.token)
        self.notice = ret.notice
        self:showNotice(false)
    else
        UI.enable(self.node, "Select", true)
        if ret.error == "error_disable" then
            local crtSdk = SdkMgr.getCrtChannel()

            local msg = { tips = "你被禁止登录了，是不是要申诉？", TY = "确定", TN = "取消" }
            if crtSdk == ChannelEnum.JGG then
                msg.tips = "您的遊戲帳號已被凍結"
                msg.TY = "聯絡客服"
                msg.TN = "退出遊戲"
            end

            UI.msgBox(msg.tips, function()
                if crtSdk == ChannelEnum.GK then
                    CS.UnityEngine.Application.OpenURL(ret.token);
                elseif crtSdk == ChannelEnum.H365 then
                    UI.showCopyBox(ret.token, "平台客服联系方式：", "拷贝")
                elseif crtSdk == ChannelEnum.JGG then
                    CS.SDKMgr.JggCustomerSupport()
                end
            end, function()
                CS.UnityEngine.Application.Quit()
            end, msg.TY, msg.TN)
        else
            log("登录结果")
            log(ret)
            UI.msgBox(Tools.getError(ret.error))
            if client.isGK then
                UI.enable(self.node, "Select", true)
            end
        end
    end
end

function Class:showNotice(mustShow)
    local title = "公告"
    local content = "暂无公告"
    if self.notice ~= nil then
        title = self.notice.title
        content = self.notice.content
    end
    if mustShow or self.notice ~= nil then
        UI.show("game.other.Notice", { title = title, content = content })
    end
end

function Class:showServerList(token)

    UI.enable(self.node, "Select", false)

    UI.enable(self.node, "Sever/ImgName", false)

    message:send("C2S_get_server_list", {}, function(ret)
        local maxId = 0

        local view = {
            Group = {},
        }

        local datas = {
        }

        local lastServer

        for i, v in ipairs(ret.data) do
            if v.id > maxId then
                maxId = v.id;
            end

            datas[i] = {
                id = v.id,
                new = v.state == 0,
                hot = v.state == 1,
                repair = v.state == 3,
                name = v.name,
                has = v.playerName ~= "",
                ip = v.ip,
                port = v.port,
                playerName = v.playerName,
                state = v.state,
            }

            --log( datas[i])

            if v.id == ret.lastId then
                lastServer = datas[i]
            end
        end

        if not lastServer then
            for i, v in ipairs(datas) do
                if v.new then
                    lastServer = v
                end

                if not lastServer then
                    lastServer = v
                else
                    if lastServer.id == 0 or lastServer.repair then
                        lastServer = v
                    end
                end
            end
        end

        self:selectedServer(lastServer, token)
        UI.enable(self.node, "Sever/SeverList", false)
        UI.button(self.node, "Sever/lastServer/BtnChange", function()
            UI.enable(self.node, "Sever/SeverList", true)
        end)

        local n = (maxId % 10 == 0) and (maxId / 10) or ((maxId - maxId % 10) / 10 + 1)

        for i = 1, maxId, 10 do
            view.Group[n] = {
                Text = i .. "-" .. (i + 9) .. "区"
            }
            n = n - 1
        end

        UI.draw(self.node, "Sever/SeverList", view)

        local selectGroup = function(index)

            view.Servers = {}

            for i, v in ipairs(datas) do
                if v.id >= index and v.id < index + 10 then
                    table.insert(view.Servers, v)
                end
            end

            table.sort(view.Servers, function(a, b)
                if a.hot and b.hot then
                    return a.id > b.id
                else
                    if a.hot then
                        return true
                    end

                    if b.hot then
                        return false
                    end

                    return a.id > b.id
                end
            end)

            UI.draw(self.node, "Sever/SeverList", view)

            local node = UI.child(self.node, "Sever/SeverList/Servers/V/C")
            for i, v in ipairs(view.Servers) do
                local child = UI.child(node, i - 1)
                UI.button(child, function()
                    self:selectedServer(v, token)
                end)
            end

            local selectN = #view.Group - (index - index % 10) / 10
            local node = UI.child(self.node, "Sever/SeverList/Group/V/C")
            for i = 1, #view.Group do
                local child = UI.child(node, i - 1)
                UI.enable(child, 0, selectN == i)
            end
        end

        local node = UI.child(self.node, "Sever/SeverList/Group/V/C")
        --local n = (maxId - maxId % 10) / 10 + 1
        local n = (maxId % 10 == 0) and (maxId / 10) or ((maxId - maxId % 10) / 10 + 1)

        for i = 1, maxId, 10 do
            local child = UI.child(node, n - 1)
            local page = n
            UI.button(child, function()
                selectGroup(i)
            end)
            n = n - 1
        end

        if maxId % 10 == 0 then
            selectGroup(maxId - 10 + 1)
        else
            selectGroup(maxId - maxId % 10 + 1)
        end

        --local noticeId = CS.UnityEngine.PlayerPrefs.GetInt("noticeId", 0)
        --if ret.noticeId > noticeId then
        --    CS.UnityEngine.PlayerPrefs.SetInt("noticeId", ret.noticeId)
        --    self:showNotice()
        --end
    end)

    UI.enable(self.node, "Login", false)
    UI.enable(self.node, "Register", false)
    UI.enable(self.node, "Sever", true)
    UI.button(self.node, "Sever/BtnStart", function()
        self:enterGame(token)
    end)

end

function Class:selectedServer(data, token)
    if data.playerName ~= "" then
        UI.enable(self.node, "Sever/ImgName", true)
        UI.text(self.node, "Sever/ImgName/TextName", data.playerName)
    else
        UI.enable(self.node, "Sever/ImgName", false)
    end

    UI.draw(self.node, "Sever/lastServer", data)
    UI.draw(self.node, "Sever/SeverList/Last", data)

    self.curServer = data
    UI.enable(self.node, "Sever/SeverList", false)

    setNetNotClear(self.curServer.ip, self.curServer.port, function()
        self:enterGameCallback(token)
    end)
end

function Class:enterGame(token)
    if self.curServer.state >= 3 then
        UI.msgBox("服务正在维护，稍后再来")
        return
    end

    client.curServer = self.curServer
    setNet(self.curServer.ip, self.curServer.port, function()
        self:enterGameCallback(token)
    end)
end

function Class:enterGameCallback(token)
    local msg = {
        token = token,
        bundle = Tools.getVersion(),
        channel = Tools.getChannel()
    }

    message:send("C2S_enter", msg, function(ret)
        log("Enter++++++++")
        log(ret)
        if ret.error == "ok" then
            GameStat.onLogin(ret.info.id, ret.info.name, ret.info.level, self.curServer)
            client.user = ret.info
            if client.user.name == "" or client.user.name == nil or client.user.name == "no name" then
                UI.close(self)
                UI.show("game.other.createPlayer")
            else
                UI.close(self)
                UI.show("game.Loading")
            end
        else
            log("进去")
            log(ret)
            UI.msgBox(Tools.getError(ret.error), function()
                UI.close(self)
                UI.show("game.login")
            end)
        end
    end)
end

return Class