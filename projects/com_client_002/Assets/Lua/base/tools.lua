require("base.debug_print")

Tools = {}
log = function(...)
    local msg = { ... }
    if #msg == 1 and type(msg[1]) == "table" then
        print(_s(msg[1]))
    else
        print(...)
    end
end

--log = print

if isDebug then
    logDebug = log
else
    logDebug = function(...)
    end
end

function _s(data, head, name)

    if not head then
        head = ""
    end

    if not name then
        name = "{}"
    elseif type(name) ~= "string" then
        name = tostring(name)
    end

    if data == nil then
        return "\n" .. head .. name .. "[nil]"
    elseif type(data) == "table" then
        local str = "\n" .. head .. tostring(name) .. " ->"
        local nextHead = head .. "    "

        for k, v in pairs(data) do
            str = str .. _s(v, nextHead, k)
        end
        return str
    else
        return "\n" .. head .. name .. "[" .. tostring(data) .. "]"
    end
end

function error(msg)
    log(msg)
end

string.replace = function(s, pattern, repl)
    local i, j = string.find(s, pattern, 1, true)
    if i and j then
        local ret = {}
        local start = 1
        while i and j do
            table.insert(ret, string.sub(s, start, i - 1))
            table.insert(ret, repl)
            start = j + 1
            i, j = string.find(s, pattern, start, true)
        end
        table.insert(ret, string.sub(s, start))
        return table.concat(ret)
    end
    return s
end

function goldFormat(value)
    if value >= 100000000 then
        return string.format("%.2f亿", math.floor(value / 1000000) / 100)
    elseif value >= 10000 then
        return string.format("%.2f万", math.floor(value / 100) / 100)
    else
        return value
    end
end

function goldFormatNotDot(value)
    if value >= 100000000 then
        return string.format("%d亿", math.floor(value / 100000000))
    elseif value >= 10000 then
        return string.format("%d万", math.floor(value / 10000))
    else
        return value
    end
end

function heroFightValueFormat(value)
    if value >= 100000000 then
        return string.format("%d亿", math.floor(value / 100000000))
    elseif value >= 10000 then
        return string.format("%d万", math.floor(value / 10000))
    else
        return value
    end
end

function log_call(str)
    log(str)

    if is_debug then
        local v = nil
        v.name = 100
    end
end

function Tools.getError(error)
    if error == "error_pwd" then
        return "密码或者凭证错误"
    end

    if error == "invalid_pwd" then
        return "无效密码"
    end

    if error == "invalid_account" then
        return "无效账号"
    end

    if error == "exists_account" then
        return "账号已经存在"
    end

    if error == "account_too_short" then
        return "账号太短"
    end

    if error == "exists_name" then
        return "名字已经存在"
    end

    if error == "error_head" then
        return "非法头像"
    end

    if error == "short_name" then
        return "名字太短"
    end

    if error == "long_name" then
        return "名字太长"
    end

    if error == "error_other_login" then
        return "你在其他地方上线了"
    end

    if error == "error_name" then
        return "非法名字"
    end

    if error == "error_serverClose" then
        return "服务器正在维护，请稍后再试！"
    end

    if error == "error_locked" then
        return "角色被封禁"
    end

    return "未知错误"
end

function mergeTable(tabel1, table2)
    for i, v in pairs(table2) do
        tabel1[i] = v
    end
end

function cloneTable(table)
    --local ret = {}
    --for i, v in pairs(table) do
    --    ret[i] = v
    --end
    local tb = {}
    mergeTable(tb, table)
    return tb
end

function showHelp(key)
    message:send("C2S_getHelp", {
        id = key
    }, function(ret)
        local node = UI.showNode("Base/help")

        UI.button(node, "BG/BtnBack", function()
            UI.close(node)
        end)

        UI.text(node, "BG/S/V/C", ret.text)
    end)
end

string.split = function(s, p)

    local rt = {}
    string.gsub(s, '[^' .. p .. ']+', function(w)
        table.insert(rt, w)
    end)
    return rt

end
-- 判断是否为字符串类型
function IsStr(str)
    if type(str) == "string" then
        return true
    end
    return false;
end

function IsNum(num)
    if type(num) == "number" then
        return true
    end
    return false;
end
function IsTable(num)
    if type(num) == "table" then
        return true
    end
    return false;
end

table.find = function(tab, fun)
    for _, v in pairs(tab) do
        if fun(v) then
            return v
        end
    end

    return nil
end

function getTimeZone()
    now = os.time()
    local timeZone = os.difftime(now, os.time(os.date("!*t", now))) / 3600
    print("时区：", timeZone)
    return timeZone
end

function getTimeZone2()
    local a = os.date('!*t', os.time())--中时区的时间
    local b = os.date('*t', os.time())
    local timeZone = (b.hour - a.hour) * 3600 + (b.min - a.min) * 60
    timeZone = timeZone / 3600
    print("时区2：", timeZone)
    return timeZone
end

---转成年月日接口
---@param second any 默认为秒
---@返回year年 month月 day日 hour时 minute分 second秒
function convertToTime(second)
    if second and second >= 0 then
        second = math.floor(second)
        local tb = {}
        local timeZone = getTimeZone2()
        --second = second  - timeZone*60*60
        tb.year = tonumber(os.date("%Y", second))
        tb.month = tonumber(os.date("%m", second)) > 9 and tonumber(os.date("%m", second)) or "0" .. tonumber(os.date("%m", second))
        tb.day = tonumber(os.date("%d", second)) > 9 and tonumber(os.date("%d", second)) or "0" .. tonumber(os.date("%d", second))
        tb.hour = tonumber(os.date("%H", second)) > 9 and tonumber(os.date("%H", second)) or "0" .. tonumber(os.date("%H", second))
        tb.minute = tonumber(os.date("%M", second)) > 9 and tonumber(os.date("%M", second)) or "0" .. tonumber(os.date("%M", second))
        tb.second = tonumber(os.date("%S", second)) > 9 and tonumber(os.date("%S", second)) or "0" .. tonumber(os.date("%S", second))
        return tb
    else
        log("秒为空");
    end
end

--- 敏感字替换
--- @param content string 需要检查的内容
--- @param hasSensitive boolean 是否有敏感字
--- @param replacedWord string 替换后的字符串
--- @param sensitiveWord string 敏感字
function Tools.sensitiveCheck(content)
    local hasSensitive, replacedWord, sensitiveWord = CS.SensitiveCheck.IsContainSensitiveWords(content)
    return hasSensitive, replacedWord, sensitiveWord
end

--- 获取字符串长度 中文算2字符 ，数字英文算1个字符
--- @param content string
function Tools.getStrLen(content)
    return CS.StringTools.getStringLen(content)
end

--- 获取字符串长度 中文算1字符 ，数字英文算1个字符
--- @param content string
function Tools.getStrLenAsOne(content)
    return CS.StringTools.getStringLen(content)
end

--- 移除字符串中的 特殊符号
--- @param content string
function Tools.removeSymbolInString(content)
    return CS.StringTools.RemoveSpecialCharacter(content);
end

--- 截取字符串
--- @param content string
--- @param limit number
function Tools.subString(content, limit)
    return CS.StringTools.SubString(content, limit)
end

--- 截取字符串(汉字视为一个字符)
--- @param content string
--- @param limit number
function Tools.subStringAsOne(content, limit)
    return CS.StringTools.SubString(content, limit)
end

--- @param event (-->多项数据)
--- @param index (2-->返回item2所对应的物品)
--- @param rank (-->返回该名次获得的物品)
function Tools.getEventAllItems(event, index, rank)
    --[[    log("<<<event+++++++++++++++++++++++++")
        log(event)
        log("++++++++++++++++++++++++++++++>>>")]]
    local Items = {}
    for i, v in ipairs(event) do
        local cfg = {}

        if v.item2 and index == 2 then
            cfg = v.item2
            log("item2")
        else
            cfg = v.item
        end

        local items = Tools.getOneEventItems(v, index)

        if v.beginRank and v.endRank then
            if v.beginRank == v.endRank then
                items.rank = "第" .. v.beginRank .. "名"
            else
                items.rank = "第" .. v.beginRank .. "-" .. v.endRank .. "名"
            end
        end

        if rank then
            log("rank:" .. rank)
            if rank >= v.beginRank and rank <= v.endRank then
                return items
            end
        end

        --[[        log("<<<items+++++++++++++++++++++++++")
                log(items)
                log("++++++++++++++++++++++++++++++>>>")]]

        table.insert(Items, items)
    end
    return Items
end

--- @param cfg (-->单条数据)
function Tools.getOneEventItems(cfg, index)
    local items = {}

    if index == 2 and cfg.item2 then
        if #cfg.item2 > 1 then
            for j = 1, #cfg.item2, 2 do
                local item = {}
                item.id = cfg.item2[j]
                item.icon = config.itemMap[cfg.item2[j]].icon
                item.count = cfg.item2[j + 1]
                item.fun = function()
                    UI.showItemInfo(cfg.item2[j])
                end
                table.insert(items, item)
            end
            return items
        end
    end

    if cfg.money > 0 then
        local item = {}
        item.id = 1000
        item.count = cfg.money
        item.icon = config.itemMap[1000].icon
        item.fun = function()
            UI.showItemInfo(1000)
        end
        table.insert(items, item)
    end
    if cfg.food > 0 then
        local item = {}
        item.id = 2000
        item.count = cfg.food
        item.icon = config.itemMap[2000].icon
        item.fun = function()
            UI.showItemInfo(2000)
        end
        table.insert(items, item)
    end

    if cfg.soldier > 0 then
        local item = {}
        item.id = 3000
        item.count = cfg.soldier
        item.icon = config.itemMap[3000].icon
        item.fun = function()
            UI.showItemInfo(3000)
        end
        table.insert(items, item)
    end
    if cfg.gold > 0 then
        local item = {}
        item.id = 5000
        item.count = cfg.gold
        item.icon = config.itemMap[5000].icon
        item.fun = function()
            UI.showItemInfo(5000)
        end
        table.insert(items, item)
    end

    if #cfg.item > 1 then
        for j = 1, #cfg.item, 2 do
            local item = {}
            item.id = cfg.item[j]
            item.icon = config.itemMap[cfg.item[j]].icon
            item.count = cfg.item[j + 1]
            item.fun = function()
                UI.showItemInfo(cfg.item[j])
            end
            table.insert(items, item)
        end
    end
    --[[    log("<<<cfg+++++++++++++++++++++++++++")
        log(cfg)
        log("++++++++++++++++++++++++++++++>>>")
        log("<<<items+++++++++++++++++++++++++")
        log(items)
        log("++++++++++++++++++++++++++++++>>>")]]
    return items
end

function Tools.getEvent(eventId)
    if eventId == 1 then
        return config.event1
    elseif eventId == 2 then
        return config.event2
    elseif eventId == 3 then
        return config.event3
    elseif eventId == 4 then
        return config.event4
    elseif eventId == 5 then
        return config.buildEventRank
    elseif eventId == 6 then
        return config.buildEventRankGuild
    elseif eventId == 201 then
        return config.event201
    elseif eventId == 202 then
        return config.event202
    elseif eventId == 203 then
        return config.event203
    elseif eventId == 204 then
        return config.event204
    elseif eventId == 205 then
        return config.event205
    elseif eventId == 206 then
        return config.event206
    elseif eventId == 207 then
        return config.event207
    elseif eventId == 208 then
        return config.event208
    end
end

--奖励展示Title
function Tools.getEventTips(eventId)
    local cfg = config["event" .. eventId]
    if cfg == nil then
        return "404"
    end
    local max = "前" .. cfg[#cfg].endRank .. "名"
    local mail = config.mailMap[eventId]
    if mail == nil then
        return "404"
    end
    local tips = mail.description
    tips = string.gsub(tips, "max", UI.colorStr(max, ColorStr.green), 1)
    --log(tips)
    return tips
end

--获取帮助
function Tools.getHelp(key)
    local cfg = config.help
    for _, v in ipairs(cfg) do
        if v.id == key then
            return v.text
        end
    end
end

function Tools.getChannel()
    print("channel:", CS.ChannelMgr.getChannel())
    return CS.ChannelMgr.getChannel()
end

function Tools.getChannelMap()
    local channel = Tools.getChannel()
    for _, v in ipairs(config.currencypriceMap) do
        if channel == v.sign then
            return v
        end
    end
    return config.currencypriceMap[1]
end

function Tools.showChannelValue(value)
    local cfg = Tools.getChannelMap()
    if cfg.pos > 0 then
        return math.floor(value / cfg.getGold) .. cfg.name
    else
        return cfg.name .. math.floor(value / cfg.getGold)
    end
    return value
end

function Tools.getVersion()
    return CS.ResTools.GetVerCode()
end

function Tools.getResVersion()
    local v2 = CS.ResTools.getPackageVer("ver")
    local v1 = CS.ResTools.getDownloadVer("ver")
    print("download ver:", v1, "packver:", v2)
    return math.max(v1, v2)
end