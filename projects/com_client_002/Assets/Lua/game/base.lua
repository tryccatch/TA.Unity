HeroTools = {}
ItemTools = {}
ComTools = {}
client.msgData = {}
Story = {}
SystemOpen = {}
SystemEventOpen = {}
RushRank = {}

function SystemOpen.init()
    SystemOpen.callbackList = {} --回调列表
    SystemOpen.lockSystemData = {} --未解锁系统列表
    SystemOpen.newUnlockSystemData = {} --新解锁系统列表
    SystemOpen.btnMap = {} --要显示特效的按钮集合
    SystemOpen.effectMap = {} --展示特效的集合
end

function SystemEventOpen.init()
    SystemEventOpen.callbackList = {} --回调列表
    SystemEventOpen.eventOpenList = {} --已解锁活动列表
    SystemEventOpen.newEventOpenList = {} --新解锁活动列表
    SystemEventOpen.btnMap = {} --要显示特效的按钮集合
    SystemEventOpen.effectMap = {} --展示特效的集合
end

function HeroTools.setHeadTemp(head, level, cloth)

    if not cloth then
        cloth = 0
    end

    HeroTools.tempHead = client.user.head
    HeroTools.tempLevel = client.user.level
    HeroTools.tempCurCloth = client.user.curCloth
    client.user.head = head
    client.user.level = level
    client.user.curCloth = cloth
end

function HeroTools.clearHeadTemp()
    client.user.head = HeroTools.tempHead
    client.user.level = HeroTools.tempLevel
    client.user.curCloth = HeroTools.tempCurCloth
end

function HeroTools.setHeadSprite(node, pathOrId, id)
    if not UI.check(node) then
        return
    end
    local realId = nil
    if id then
        realId = id
    else
        realId = pathOrId
    end

    local childName = "the_me_node"
    if realId == 1 then
        if id then
            node = UI.child(node, pathOrId)
        end

        UI.enableImage(node, false)

        local child = UI.child(node, childName, true)

        if not child then
            child = UI.showNode(node, "Base/MeHead")
            child.name = childName
            -- log(child)
        else
            UI.enable(child, true)
        end

        -- log(client.user.level,client.user.head)
        if client.user.curCloth > 0 then
            UI.sprite(child, "Body", "KingCloth", client.user.curCloth)
        else
            UI.sprite(child, "Body", "Body", client.user.level)
        end
        UI.sprite(child, "Head", "Head", client.user.head)
    else
        if id then

            UI.enableImage(node, pathOrId, true)

            local child = UI.child(node, pathOrId .. "/" .. childName, true)
            if child then
                UI.enable(child, false)
            end

            UI.sprite(node, pathOrId, "HeroHead", id)
        else
            UI.enableImage(node, true)

            local child = UI.child(node, childName, true)
            if child then
                UI.enable(child, false)
            end

            UI.sprite(node, "HeroHead", realId)
        end
    end
end

function HeroTools.setCHeadSprite(node, pathOrId, id)

    local realId = nil
    if id then
        realId = id
    else
        realId = pathOrId
    end

    local childName = "the_me_node"

    if realId == 1 then
        if id then
            node = UI.child(node, pathOrId)
        end

        UI.enableImage(node, false)

        local child = UI.child(node, childName, true)

        if not child then
            child = UI.showNode(node, "Base/CMeHead")
            child.name = childName
            -- log(child)
        else
            UI.enable(child, true)
        end

        -- log(client.user.level,client.user.head)
        if client.user.curCloth > 0 then
            UI.sprite(child, "Mask/Body", "KingCloth", client.user.curCloth)
        else
            UI.sprite(child, "Mask/Body", "Body", client.user.level)
        end
        UI.sprite(child, "Head", "Head", client.user.head)
    else
        if id then
            UI.enableImage(node, pathOrId, true)

            local child = UI.child(node, pathOrId .. "/" .. childName, true)
            if child then
                UI.enable(child, false)
            end

            UI.sprite(node, pathOrId, "CHeroHead", id)
        else
            UI.enableImage(node, true)

            local child = UI.child(node, childName, true)
            if child then
                UI.enable(child, false)
            end

            UI.sprite(node, "CHeroHead", realId)
        end
    end
end

function HeroTools.setSchoolHero(node, pathOrId, id)

    local realId = nil
    if id then
        realId = id
    else
        realId = pathOrId
    end

    local childName = "the_me_node"

    if realId == 1 then
        if id then
            node = UI.child(node, pathOrId)
        end

        UI.enableRawImage(node, false)

        local child = UI.child(node, childName, true)

        if not child then
            child = UI.showNode(node, "Base/SchoolHero")
            child.name = childName
            -- log(child)
        else
            UI.enable(child, true)
        end

        -- log(client.user.level,client.user.head)
        if client.user.curCloth > 0 then
            UI.sprite(child, "Mask/Body", "KingCloth", client.user.curCloth)
        else
            UI.sprite(child, "Mask/Body", "Body", client.user.level)
        end
        UI.sprite(child, "Head", "Head", client.user.head)
    else
        if id then
            UI.enableRawImage(node, pathOrId, true)

            local child = UI.child(node, pathOrId .. "/" .. childName, true)
            if child then
                UI.enable(child, false)
            end

            UI.rawImage(node, pathOrId, "hero/hero_square_full_" .. id)

            --UI.sprite(node, pathOrId, "CHeroHead", id)
        else
            UI.enableRawImage(node, true)

            local child = UI.child(node, childName, true)
            if child then
                UI.enable(child, false)
            end
            UI.rawImage(node, "hero/hero_square_full_" .. id)

            --UI.sprite(node, "CHeroHead", realId)
        end
    end
end

function ItemTools.usedItemHit(id, fun)
    local msg = {
        id = id
    }

    message:send("C2S_itemInfo", msg, function(ret)

        local cfg = config.itemMap[id]
        local node = UI.showNode("Base/UsedItem2")
        UI.text(node, "Name", cfg.name)
        UI.text(node, "Count", ret.count)
        UI.image(node, "Icon", "Item", "item" .. ret.icon)

        UI.button(node, "BtnClose", function()
            UI.close(node)
        end)
        UI.button(node, "BtnNo", function()
            UI.close(node)
        end)

        UI.button(node, "BtnYes", function()
            UI.close(node)
            fun()
        end)
    end)
end

-- id 物品id
-- count 数量/{minCount,maxCount}
-- fun 回调函数
-- des 使用对象目标的id 比如英雄id，比如孩子id
function ItemTools.used(id, count, fun, des)
    local msg = {
        id = id
    }

    local cfg = config.itemMap[id]

    message:send("C2S_itemInfo", msg, function(ret)
        log(ret)
        local minCount = 1
        if type(count) == "table" then
            minCount = count.minCount
        end

        if ret.count < minCount then
            local tempConfig = table.find(config["item"], function(a)
                return a.id == id
            end)
            local result = "道具"
            if tempConfig then
                result = tempConfig.name
            end
            UI.showHint(result .. "不足")
            return
        else
            if type(count) == "table" then
                local node = UI.showNode("Base/UsedItem1")

                UI.text(node, "Name", cfg.name)
                UI.text(node, "Hint", cfg.description)
                UI.image(node, "Icon", "Item", "item" .. cfg.icon)

                local curCount = 1

                local showCount = function()
                    UI.text(node, "Count", curCount .. "/" .. ret.count)
                end

                UI.button(node, "BtnClose", function()
                    UI.close(node)
                end)

                showCount()

                local onChangeValue = function(value)
                    curCount = value
                    showCount()
                end

                local maxCount = ret.count
                if count.maxCount < maxCount then
                    maxCount = count.maxCount
                end

                UI.slider(node, "usedCount", {
                    minValue = minCount,
                    maxValue = maxCount,
                    value = 1,
                    fun = onChangeValue
                })

                UI.button(node, "BtnYes", function()
                    UI.close(node)
                    message:send("C2S_usedItem", {
                        id = id,
                        count = curCount,
                        des = des
                    }, function(ret)
                        if ret.succeed then
                            CS.Sound.Play("effect/use")
                            if fun then
                                fun(ret)
                            end
                        end
                    end)
                end)

                UI.button(node, "BtnAdd", function()
                    UI.slider(node, "usedCount", {
                        value = curCount + 1
                    })
                end)

                UI.button(node, "BtnDec", function()
                    UI.slider(node, "usedCount", {
                        value = curCount - 1
                    })
                end)
            else

                if count > ret.count then
                    count = ret.count
                end

                local node = UI.showNode("Base/UsedItem2")
                UI.text(node, "Name", cfg.name)
                UI.text(node, "Count", ret.count)
                UI.text(node, "UsedCount", count)
                UI.image(node, "Icon", "Item", "item" .. ret.icon)

                UI.button(node, "BtnClose", function()
                    UI.close(node)
                end)
                UI.button(node, "BtnNo", function()
                    UI.close(node)
                end)

                UI.button(node, "BtnYes", function()
                    UI.close(node)

                    -- des 只能是number
                    if type(des) == "string" then
                        des = 0
                    end

                    message:send("C2S_usedItem", {
                        id = id,
                        count = count,
                        des = des
                    }, function(ret)

                        if ret.succeed then
                            CS.Sound.Play("effect/use")
                            if fun then
                                fun(ret)
                            end
                        else
                            UI.showHint(ret.error)
                        end
                    end)
                end)
            end
        end
    end)
end

function ItemTools.onItemResult(results)
    for i, v in ipairs(results) do
        -- if v.type == "gold" then
        --     client.user.gold = client.user.gold + v.value
        -- end

        -- if v.type == "money" then
        --     client.user.money = client.user.money + v.value
        -- end
    end
end

function ItemTools.onItemResultDis(results, node, heroInfo)

    local time = 0
    local items = {}
    for i, v in ipairs(results) do
        local str = nil
        if v.value > 0 then
            if v.type == "gold" then
                str = "增加元宝" .. goldFormat(v.value)
            end

            if v.type == "money" then
                str = "增加银两" .. goldFormat(v.value)
            end

            if v.type == "food" then
                str = "增加粮草" .. goldFormat(v.value)
            end

            if v.type == "soldier" then
                str = "增加士兵" .. goldFormat(v.value)
            end

            if v.type == "score" then
                str = "增加政绩" .. goldFormat(v.value)
            end

            if v.type == "fame" then
                str = "增加名望" .. goldFormat(v.value)
            end

            if v.type == "intimate" then
                str = "亲密度+" .. goldFormat(v.value)
            end

            if v.type == "skillExp" then
                str = "技艺经验+" .. goldFormat(v.value)
            end

            if v.type == "growsEXP" then
                str = "增加资质经验" .. goldFormat(v.value)
            end

            if v.type == "politics" then
                str = "增加政治" .. goldFormat(v.value)
            end

            if v.type == "charm" then
                str = "增加魅力" .. goldFormat(v.value)
            end

            if v.type == "wisdom" then
                str = "增加智力" .. goldFormat(v.value)
            end

            if v.type == "strength" then
                str = "增加武力" .. goldFormat(v.value)
            end

            if v.type == "skillEXP" then
                str = "增加技能经验" .. goldFormat(v.value)
            end
        end

        if str then

            if heroInfo then
                str = heroInfo.name .. str
            end

            local node = UI.show("Base/AddValue")
            UI.text(node, "Value", str)

            UI.tweenList(node, { {
                                     type = "enableAll",
                                     time = time,
                                     value = false
                                 }, {
                                     fun = function()
                                         CS.Sound.Play("effect/get")
                                     end,
                                     type = "enableAll",
                                     time = 0,
                                     value = true
                                 }, {
                                     type = "offset",
                                     pos = {
                                         x = 0,
                                         y = 100,
                                         z = 0
                                     },
                                     time = 2,
                                     waitTime = 1
                                 }, {
                                     type = "alphaAll",
                                     value = 0,
                                     time = 0.5,
                                     waitTime = 2
                                 }, {
                                     type = "delete"
                                 } })

            time = time + 0.5
        end

        log(v)

        if (not str) and (v.type == "item") then
            local itemId = v.item.id
            local icon = config.itemMap[itemId].icon
            items[#items + 1] = {
                icon = icon,
                --value = v.item.type == 9 and v.value or v.item.count
                value = v.value
            }
        end
    end

    if #items > 0 then
        local box = UI.show("Base/GetItems")
        CS.Sound.Play("effect/award")

        UI.button(box, "BG/BtnYes", function()
            UI.close(box)
        end)
        UI.button(box, "BG/BtnClose", function()
            UI.close(box)
        end)
        local parent = UI.child(box, "BG/list/v/c")
        UI.cloneChild(parent, #items)
        for i = 1, #items do
            local temp = parent:GetChild(i - 1)
            UI.draw(temp, items[i])
        end
    end

end

function ItemTools.addItemsDis(items)
    local time = 0
    for i, v in ipairs(items) do

        local icon = v.id

        local name
        if config.itemMap[v.id] then
            name = config.itemMap[v.id].name
            icon = config.itemMap[v.id].icon
        else
            name = "资源"
        end

        local node = UI.show("Base/float2")
        UI.text(node, "count", v.count)
        UI.text(node, "name", name)
        UI.image(node, "icon", "Item", icon)

        UI.tweenList(node, { {
                                 type = "enableAll",
                                 time = time,
                                 value = false
                             }, {
                                 type = "enableAll",
                                 time = 0,
                                 value = true,
                                 fun = function()
                                     CS.Sound.Play("effect/get")
                                 end
                             }, {
                                 type = "offset",
                                 pos = {
                                     x = 0,
                                     y = 100,
                                     z = 0
                                 },
                                 time = 2,
                                 waitTime = 1
                             }, {
                                 type = "alphaAll",
                                 value = 0,
                                 time = 0.5,
                                 waitTime = 2
                             }, {
                                 type = "delete"
                             } })

        time = time + 0.5
    end
end

function ItemTools.showItemResultById(id, count)

    local temp = config.itemMap[id]

    ItemTools.showItemResult({
        name = temp.name,
        icon = temp.icon,
        count = count ~= nil and count or 1
    })
end

function ItemTools.showItemResult(item)
    ItemTools.showItemResultByResName(item, "Item")
end

function ItemTools.showItemsResult(items)
    local time = 0
    local ack = function(v)
        local icon
        local name
        if config.itemMap[v.id] then
            name = config.itemMap[v.id].name
            icon = config.itemMap[v.id].icon
        else
            name = "资源"
        end

        local node = UI.show("Base/ItemResult")

        local item = { icon = icon, name = name, count = v.count }
        UI.draw(node, "item", item)
        --UI.refreshSVC(node, "item", true)

        UI.tweenList(node, { {
                                 type = "enableAll",
                                 time = time,
                                 value = false
                             }, {
                                 type = "enableAll",
                                 time = 0,
                                 value = true,
                                 fun = function()
                                     UI.refreshSVC(node, "item", true)
                                     CS.Sound.Play("effect/get")
                                 end
                             }, {
                                 type = "offset",
                                 pos = {
                                     x = 0,
                                     y = 100,
                                     z = 0
                                 },
                                 time = 2,
                                 waitTime = 1
                             }, {
                                 type = "alphaAll",
                                 value = 0,
                                 time = 0.5,
                                 waitTime = 2
                             }, {
                                 type = "delete"
                             } })
    end
    if #items >= 1 then
        for i, v in ipairs(items) do
            if v.id > 0 then
                ack(v)
                time = time + 0.5
            end
        end
    else
        ack(items)
    end

end

function ItemTools.showItemResultByResName(item, resName)

    local time = 0

    local node = UI.show("Base/ItemResult")

    --UI.enableAll(node, true)
    UI.image(node, "item/icon", resName, item.icon)
    UI.text(node, "item/name", item.name)
    UI.text(node, "item/count", item.count)
    --UI.refreshSVC(node, "item", true)
    CS.Sound.Play("effect/get")

    UI.tweenList(node, { {
                             type = "enableAll",
                             time = time,
                             value = false
                         }, {
                             type = "enableAll",
                             time = 0,
                             value = true
                         }, {
                             type = "offset",
                             pos = {
                                 x = 0,
                                 y = 100,
                                 z = 0
                             },
                             time = 2,
                             waitTime = 1
                         }, {
                             type = "alphaAll",
                             value = 0,
                             time = 0.5,
                             waitTime = 1
                         }, {
                             type = "delete"
                         } })
    time = time + 0.5

end

function HeroTools.getSpecialtyName(type)
    if type == 1 then
        return "武力"
    end

    if type == 2 then
        return "智力"
    end

    if type == 3 then
        return "魅力"
    end

    if type == 4 then
        return "政治"
    end

    return "均衡"
end

function HeroTools.showAnim(node, pathOrId, id)
    if CS.UIAPI.ObjIsNull(node) then
        log("show anim node is Null ------------")
        return
    end

    if id then
        node = UI.child(node, pathOrId)
    else
        id = pathOrId
    end

    local animNode = UI.child(node, "_animNode", true)
    if animNode then
        UI.close(animNode)
    end
    if id == 1 then
        if not client.user then
            local node = UI.showNode(node, "Anim/me1")
            UI.playAnim(node, "idle")
            node.name = "_animNode"
            UI.setLocalPosition(node, 0, -700, 0)
            return node
        end

        local res = "me" .. client.user.level
        local animName = res
        if client.user.level == 1 then
            animName = "me" .. 2
        end
        if client.user.level == 2 then
            animName = "me" .. 1
        end

        if client.user.curCloth > 0 then
            res = "wang" .. client.user.curCloth
            animName = res
        end

        local animNode = UI.showNode(node, "Anim/" .. res)
        UI.playAnim(animNode, "idle")
        UI.setLocalPosition(animNode, 0, -700, 0)

        UI.setLocalScale(animNode, 150, 150, 150)

        animNode.name = "_animNode"

        UI.changAnimSlot(animNode, animName, "191", "" .. client.user.head)
        log(node)
        UI.enableOne(node, node.childCount > 0 and node.childCount - 1)
        print('你大爷的----------')
        return animNode
    else
        local animNode = UI.showNode(node, "Anim/hero" .. id)
        UI.playAnim(animNode, "idle")
        animNode.name = "_animNode"
        log(node)
        UI.enableOne(node, node.childCount > 0 and node.childCount - 1)
        print('你大爷的2----------')
        return animNode
    end
end

function ComTools.onShengJi(msg)
    local node = UI.showNode("Base/shenji")

    local child = UI.child(node, "Node/Node")
    UI.enableOne(child, msg.id);

    CS.Sound.Play("effect/miracle")

    UI.delay(node, 2, function()
        UI.tweenList(node, { {
                                 type = "alphaAll",
                                 value = 0,
                                 time = 1
                             } })
        UI.delay(node, 1, function()
            UI.close(node)
        end)
    end)
end

function ComTools.charge(cfg, type, value, func)
    print("充值：name=", cfg.name_h365)
    print("充值：des=", cfg.des)
    print("充值：url=", cfg.url)
    local params = { type = type,
                     value = value }
    if client.isGK then
        params = {
            type = type,
            value = value,
            gkId = client.gkId,
            gkToken = client.gkToken,
        }
    elseif client.isH365 then
        params = {
            type = type,
            value = value,
            gkId = client.h365Id,
            gkToken = client.h365Token
        }
    elseif client.isJGG then
        params = {
            type = type,
            value = value,
            gkId = client.jggId,
            gkToken = client.jggToken
        }
    end

    if client.isGK then
        if client.isGuest then
            local fYes = function()
                SdkMgr.bindAccount(function(ret, userInfo, token)
                    if ret then
                        client.isGuest = false
                        client.gkId = userInfo.user_id
                        client.gkAccount = userInfo.account
                        client.gkToken = token
                        UI.showHint("绑定成功")
                        message:send("C2S_bind", { account = userInfo.account, id = userInfo.user_id, pwd = token, type = "GK" })
                        self:showPage(3)
                    else
                        UI.showHint("绑定失败")
                    end
                end)
            end
            UI.msgBoxTitleBtnText('提示信息', '您的账号尚未绑定工口会员，无法进行购买商品', "前往绑定", "取消", fYes, function()
            end)
            return
        end
    end

    message:send("C2S_chargeInfo", params, function(ret)
        if ret.money > 0 then
            if client.isGK then
                UI.msgBox("你确定要消费HoneyP" .. ret.money, function()
                    message:send("C2S_charge", params, function(ret2)
                        log(ret2)
                        if ret2.success then
                            GameStat.onChargeSuccess(ret.money, cfg.name_h365)
                            func()
                        else
                            UI.msgBoxTitleBtnText('提示信息', '您的HoneyP不足，无法进行购买。',
                                    '前往购买', '取消', function()
                                        SdkMgr.openPayment()
                                    end, function()
                                    end)
                        end
                    end)
                end, function()
                end)
            elseif client.isH365 then
                UI.msgBox("你确定要消费H币" .. ret.money, function()
                    SdkMgr.charge(cfg, ret.callbackUrl, params.type, params.value, ret.money, function(result, msg)
                        if result == "ok" then
                            if SdkMgr.payCfg == nil then
                                SdkMgr.payCfg = cfg
                            end
                            --print("充值 H365成功了……………………………………………………………………………………")
                            --GameStat.onChargeSuccess(ret.money)
                            func()
                        elseif result == "exception" then
                            UI.msgBoxTitle("充值失败", msg)
                        end
                    end)
                end, function()
                end)
            elseif client.isJGG then
                UI.msgBox("你确定要消费JG币" .. ret.money, function()
                    SdkMgr.charge(cfg, ret.callbackUrl, params.type, params.value, ret.money, function(result, msg)
                        log(msg)
                        if result == "ok" then
                            if msg.transactionId then
                                params.transactionId = msg.transactionId
                            end
                            message:send("C2S_charge", params, function(ret2)
                                log(ret2)
                                func()
                            end)
                        elseif result == "exception" then
                            log(msg.message)
                            UI.msgBoxTitle("充值失败", msg.message)
                        end
                    end)
                end, function()
                end)
            else
                message:send("C2S_chargeTest", params, function()
                    GameStat.onChargeSuccess(ret.money, cfg.name_h365)
                    func()
                end)
            end
        else
            UI.msgBox("无效商品")
        end
    end)
end

function ComTools.disDamage(node, pos, hp, cirt)
    local node = UI.showNode(node, "Base/damage")

    if not pos.x then
        pos.x = 0
    end

    if not pos.y then
        pos.y = 0
    end

    if not pos.z then
        pos.z = 0
    end

    local text = "-" .. hp
    if cirt then
        text = "x" .. text;
    end

    UI.text(node, "hp", text)

    UI.setLocalPosition(node, pos.x, pos.y, pos.z)

    UI.tweenList(node, { {
                             scale = 3,
                             offset = {
                                 y = 600
                             },
                             time = 0.5
                         }, {
                             scale = 2.5,
                             time = 0.1
                         }, {
                             time = 0.3
                         }, {
                             fun = function()
                                 UI.close(node)
                             end
                         } })

    return node
end

-- id 玩家id
function ComTools.showPlayerInfo(id, enableReport)
    message:send("C2S_getUserInfo", { id = id }, function(data)

        if data.id == 0 then
            UI.msgBox("没有此玩家")
            return ;
        end

        local node = UI.show("base/playerInfo")

        UI.enable(node, "btnReport", enableReport)
        if enableReport then
            UI.button(node, "btnReport", function()
                local node = UI.showNode("Base/InputBox2")
                UI.button(node, "BtnYes", function()
                    local str = UI.getValue(node, "input")
                    if string.len(str) <= 10 then
                        UI.msgBox("举报内容太短")
                        return
                    end

                    if string.len(str) >= 100 then
                        UI.msgBox("举报内容太长")
                        return
                    end

                    message:send("C2S_report", { id = id, msg = str }, function(ret)
                        if ret.success then
                            UI.close(node)
                            UI.showHint("举报成功")
                        else
                            UI.showHint(ret.error)
                        end
                    end)
                end)

                UI.button(node, "BtnNo", function()
                    UI.close(node)
                end)

                UI.button(node, "BtnClose", function()
                    UI.close(node)
                end)
            end)
        end

        data.BtnClose = function()
            UI.close(node)
        end

        local level = data.level

        data.level = config.levelMap[data.level].name
        data.disId = "玩家编号：" .. data.id
        data.BG = { heroId = 1 }

        local kingNode = UI.child(node, "BtnKing")
        UI.enableAll(kingNode, true)

        for i, v in ipairs(data.king) do
            UI.enable(kingNode, "King" .. i, v)
            if v then
                UI.enable(kingNode, "kingDis", false)
            end
        end

        HeroTools.setHeadTemp(data.head, level, data.curCloth)
        UI.draw(node, data)
        HeroTools.clearHeadTemp()
    end)
end

client.msgData.updateMsg = function(msg)
    if msg.msg ~= nil then
        --log("新信息数量-----------------,",#msg.msg)
        log(msg.msg)
    end

    local sortMsg = function(data)
        if data == nil or #data < 2 then
            return
        end

        table.sort(data, function(a, b)
            return a.msgId < b.msgId
        end)
    end

    msg = msg.msg
    --client.msgData [1] - 世界消息  [2] - 联盟消息
    for i, v in ipairs(msg) do
        local n = 1
        if v.type > 2 then
            n = 2
        end

        _, v.text = Tools.sensitiveCheck(v.text)

        if not client.msgData[n] then
            client.msgData[n] = {}
        end

        table.insert(client.msgData[n], v)

        --print('type:',v.type)
        if (not client.msgData.lastMsg) or (client.msgData.lastMsg.msgId <= v.msgId) then
            client.msgData.lastMsg = v
            needDis = true
        end
    end

    sortMsg(client.msgData[1])
    sortMsg(client.msgData[2])

    if needDis and client.msgData.disMsg then
        client.msgData.disMsg()
    end

    if client.msgData.onMsg then
        --print("刷新界面")
        client.msgData.onMsg()
    end
end

client.msgData.disMsg = function()
    --print("显示新信息：", client.msgData.lastMsg == nil,client.msgData.nodeTable == nil)
    if client.msgData.lastMsg and client.msgData.nodeTable ~= nil then
        for i, v in pairs(client.msgData.nodeTable) do
            UI.text(v, "text", client.msgData.lastMsg.text)
        end
    end
end

client.msgData.registerNode = function(key, node)
    if key == nil or node == nil then
        return
    end

    if client.msgData.nodeTable == nil then
        client.msgData.nodeTable = {}
    end
    client.msgData.nodeTable[key] = node
    client.msgData.disMsg()
end

client.msgData.unRegisterNode = function(key)
    if key == nil or client.msgData.nodeTable == nil then
        return
    end

    client.msgData.nodeTable[key] = nil
end

client.msgData.clear = function()
    client.msgData.nodeTable = {}
    client.msgData[1] = {}
    client.msgData[2] = {}
    client.msgData.lastMsg = nil
end

Story.show = function(params)
    UI.show("game.other.story", params)
end

Story.showHero = function(id)
    local node = UI.showNode("UI/storyHero")

    local cfg = config.heroMap[id]

    local data = {
        name = cfg.name,
        datas = { {
                      Text = "武力资质" .. cfg.strengthGrows
                  }, {
                      Text = "智力资质" .. cfg.wisdomGrows
                  }, {
                      Text = "魅力资质" .. cfg.charmGrows
                  }, {
                      Text = "政治资质" .. cfg.politicsGrows
                  } },
        all = cfg.strengthGrows + cfg.wisdomGrows + cfg.charmGrows + cfg.politicsGrows
    }

    UI.draw(node, data)

    local animNode = HeroTools.showAnim(node, "Anim", cfg.id)
    UI.setLocalOffset(animNode, 0, 100, 0)

    return node
end

Story.showWife = function(id)
    local node = UI.showNode("UI/storyWife")

    local cfg = config.wifeMap[id]

    local data = {
        name = cfg.name,
        des = cfg.describe,
        all = cfg.beauty
    }

    UI.draw(node, data)

    local animNode = UI.showNode(node, "Anim", "Anim/wife" .. cfg.head)
    UI.playAnim(animNode, "idle")
    UI.setLocalOffset(animNode, 0, -600, 0)

    return node
end

function client.updateAddValue(data)
    if not client then
        return
    end

    if not client.user then
        return
    end

    if data.type == "levelExp" then
        client.user.levelExp = client.user.levelExp + data.value
    end

    if data.type == "kickout" then
        stopForKickout()
        return
    end

    if data.type == "money" then
        client.user.money = client.user.money + data.value
    end

    if data.type == "gold" then
        client.user.gold = client.user.gold + data.value
    end

    log(_s(data))

    if data.type == "allValue" then
        client.user.allValue = client.user.allValue + data.value

        if data.value > 0 then

            local node = CS.UIAPI.gNode:Find("float1")
            if node then
                UI.stopDelay(node, 1)
                --UI.deleteNode("float1")
                --log("++++++++++++++++++")
            else
                node = UI.show("Base/float1")
            end

            UI.setValue(node, "Value", client.user.allValue)

            log(node)

            CS.Sound.Play("effect/get")

            UI.tweenList(node, {
                {
                    alphaAll = 0,
                }, {
                    time = 1,
                }, {
                    node = "BK",
                    alphaAll = 1,
                    time = 0.5,
                }, {
                    node = "Node1",
                    alpha = 0,
                }, {
                    node = "Node2",
                    alpha = 0,
                }, {
                    node = "Value",
                    alpha = 0,
                }, {
                    node = "Node1",
                    alpha = 1,
                    time = 0.2,
                }, {
                    node = "Value",
                    alpha = 1,
                    time = 0.2,
                }, {
                    node = "Node2",
                    alpha = 1,
                    time = 0.2,
                }, {
                    alphaAll = 1,
                    time = 0.5,
                }, {
                    time = 1,
                }, {
                    fun = function()
                        UI.close(node)
                    end
                }
            })
        end
    end

    if data.type == "vip" then
        client.user.vip = client.user.vip + data.value
    end

    if data.type == "curCloth" then
        client.user.curCloth = client.user.curCloth + data.value
    end

    local main_name = "game.lobby.main"
    local ui = UI.getOne(main_name)
    if ui and ui.onFront and UI.isOnTop(main_name) then
        ui:onFront()
    end
end

function HeroTools.getName(id)
    local cfg = config.heroMap[id]
    if id <= 1 then
        return cfg.name .. client.user.name
    else
        return cfg.name
    end
end

function SystemOpen.addCallback(callback)
    if #SystemOpen.callbackList > 0 then
        for i = 1, #SystemOpen.callbackList do
            if SystemOpen.callbackList[i] == nil then
                SystemOpen.callbackList[i] = callback
                return i
            end
        end
    end
    SystemOpen.callbackList[#SystemOpen.callbackList + 1] = callback
    return #SystemOpen.callbackList
end

function SystemOpen.removeCallback(id)
    if #SystemOpen.callbackList > id then
        SystemOpen.callbackList[id] = nil
    end
end

function SystemOpen.executeCallback(id)
    if #SystemOpen.callbackList > 0 then
        for i, v in ipairs(SystemOpen.callbackList) do
            v(id)
        end
    end
end

function SystemEventOpen.executeCallback(id)
    if #SystemEventOpen.callbackList > 0 then
        for i, v in ipairs(SystemEventOpen.callbackList) do
            v(id)
        end
    end
end

function SystemOpen.updateLockSystem(msg)
    if SystemOpen.lockSystemData ~= nil and #SystemOpen.lockSystemData > 0 then
        for i = 1, #SystemOpen.lockSystemData do
            local contain = false
            for j = 1, #msg.ids do
                if SystemOpen.lockSystemData[i] == msg.ids[j] then
                    contain = true
                    break
                end
            end
            if not contain then
                if SystemOpen.newUnlockSystemData == nil then
                    SystemOpen.newUnlockSystemData = {}
                end

                local newUnlock = true
                for z = 1, #SystemOpen.newUnlockSystemData do
                    if SystemOpen.newUnlockSystemData[z] == SystemOpen.lockSystemData[i] then
                        newUnlock = false
                        break
                    end
                end
                SystemOpen.newUnlockSystemData[#SystemOpen.newUnlockSystemData + 1] = SystemOpen.lockSystemData[i]
                SystemOpen.saveNewUnlockSystem()
                SystemOpen.executeCallback(SystemOpen.lockSystemData[i])
            end
        end
    end
    SystemOpen.lockSystemData = msg.ids;
end

function SystemEventOpen.updateOpenEvent(msg)
    log(msg)
    SystemEventOpen.eventOpenList = msg.ids
    SystemEventOpen.closePage(msg)
    if SystemEventOpen.eventOpenList ~= nil and #SystemEventOpen.eventOpenList > 0 then
        local systemEventOpenConfig = config["systemEventOpen"]
        for i = 1, #SystemEventOpen.eventOpenList do
            --log("未解锁的活动：" .. SystemEventOpen.eventOpenList)
            local page = systemEventOpenConfig[SystemEventOpen.eventOpenList[i]].page
            --log(page)

            local list = SystemEventOpen.btnMap[page]
            for j = 1, #list do
                --log(list[j].node)
                UI.enable(list[j].node, true)
            end

            local contain = false
            for j = 1, #msg.ids do
                if SystemEventOpen.eventOpenList[i] == msg.ids[j] then
                    contain = true
                    break
                end
            end
            if not contain then
                if SystemEventOpen.newEventOpenList == nil then
                    SystemEventOpen.newEventOpenList = {}
                end

                local newUnlock = true
                for z = 1, #SystemEventOpen.newEventOpenList do
                    if SystemEventOpen.newEventOpenList[z] == SystemEventOpen.eventOpenList[i] then
                        newUnlock = false
                        break
                    end
                end
                SystemEventOpen.newEventOpenList[#SystemEventOpen.newEventOpenList + 1] = SystemEventOpen.eventOpenList[i]
                SystemEventOpen.saveNewUnlockSystem()
                SystemEventOpen.executeCallback(SystemEventOpen.eventOpenList[i])
            end
        end
    end
end

function SystemEventOpen.closePage(msg)
    SystemEventOpen.eventOpenList = msg.ids
    local eventOpen = msg.ids
    local cfg = config["systemEventOpen"]
    for i, v in ipairs(cfg) do
        --log(v)
        local close = true
        for k, id in ipairs(eventOpen) do
            if id == v.id then
                close = false
                break
            end
        end
        if v.eventID > 0 and close then
            local ui
            if v.eventID == 7 then
                ui = UI.getUI("game.activity.payReward")
            elseif v.eventID == 6 then
                ui = UI.getUI("game.lobby.shop")
            elseif v.eventID == 5 then
                ui = UI.getUI("game.activity.limitReward")
            elseif v.eventID == 302 then
                ui = UI.getUI("game.activity.twoBeauty")
            elseif v.eventID == 301 then
                ui = UI.getUI("game.activity.hdLoveLife")
            end

            if ui then
                ui:closePage()
            end
        end
    end
end

function SystemOpen.saveNewUnlockSystem()
    if SystemOpen.newUnlockSystemData == nil or #SystemOpen.newUnlockSystemData < 1 then
        return
    end
    local key = "newUnlockSystem"
    local result = ""
    for i, v in ipairs(SystemOpen.newUnlockSystemData) do
        if i > 1 then
            result = result .. "," .. v
        else
            result = v
        end
    end

    CS.UnityEngine.PlayerPrefs.SetString(key, result)
end

function SystemEventOpen.saveNewUnlockSystem()
    if SystemEventOpen.newEventOpenList == nil or #SystemEventOpen.newEventOpenList < 1 then
        return
    end
    local key = "newUnlockEventSystem"
    local result = ""
    for i, v in ipairs(SystemEventOpen.newEventOpenList) do
        if i > 1 then
            result = result .. "," .. v
        else
            result = v
        end
    end

    CS.UnityEngine.PlayerPrefs.SetString(key, result)
end

function SystemOpen.removeNewUnlockSystem(id)
    if SystemOpen.newUnlockSystemData == nil or #SystemOpen.newUnlockSystemData < 1 then
        return
    end

    for i = 1, #SystemOpen.newUnlockSystemData do
        if SystemOpen.newUnlockSystemData[i] == id then
            log(id)
            table.remove(SystemOpen.newUnlockSystemData, i)
            break ;
        end
    end

    SystemEventOpen.saveNewUnlockSystem()
end

function SystemEventOpen.removeNewUnlockSystem(id)
    if SystemEventOpen.newEventOpenList == nil or #SystemEventOpen.newEventOpenList < 1 then
        return
    end

    for i = 1, #SystemEventOpen.newEventOpenList do
        if SystemEventOpen.newEventOpenList[i] == id then
            table.remove(SystemEventOpen.newEventOpenList, i)
            break ;
        end
    end

    SystemEventOpen.saveNewUnlockSystem()
end

function SystemOpen.initNewUnlockSystemData()
    local result = CS.UnityEngine.PlayerPrefs.HasKey("newUnlockSystem")
    SystemOpen.newUnlockSystemData = {}
    if not result then
        print("本地没有新解锁系统数据")
        return
    end
    local temp = CS.UnityEngine.PlayerPrefs.GetString("newUnlockSystem")
    local ids = string.split(temp, ",")
    if ids ~= nil and #ids > 0 then
        for i, v in ipairs(ids) do
            SystemOpen.newUnlockSystemData[i] = tonumber(v)
            --print("新解锁系统：", SystemOpen.newUnlockSystemData[i])
        end
    end
end

function SystemEventOpen.initNewUnlockSystemData()
    local result = CS.UnityEngine.PlayerPrefs.HasKey("newUnlockEventSystem")
    SystemEventOpen.newEventOpenList = {}
    if not result then
        print("本地没有新解锁活动数据")
        return
    end
    local temp = CS.UnityEngine.PlayerPrefs.GetString("newUnlockEventSystem")
    local ids = string.split(temp, ",")
    if ids ~= nil and #ids > 0 then
        for i, v in ipairs(ids) do
            SystemEventOpen.newEventOpenList[i] = tonumber(v)
            print("新解锁的活动：", SystemEventOpen.newEventOpenList[i])
        end
    end
end

function SystemOpen.systemIsUnlock(id)
    if SystemOpen.lockSystemData == nil then
        message:send("C2S_lockSystemChange", {}, function(msg)
            SystemOpen.lockSystemData = msg.ids
        end)
        SystemOpen.showLockTip(id)
        return false
    elseif #SystemOpen.lockSystemData < 1 then
        return true
    else
        for i = 1, #SystemOpen.lockSystemData do
            if SystemOpen.lockSystemData[i] == id then
                SystemOpen.showLockTip(id)
                return false
            end
        end
        return true
    end
end

function SystemEventOpen.systemEventIsOpen(id)
    log("eventOpenList:")
    log(SystemEventOpen.eventOpenList)
    if SystemEventOpen.eventOpenList == nil then
        message:send("C2S_ReqUpdateOpenEvent", {}, function(msg)
            SystemEventOpen.eventOpenList = msg.ids
        end)
        SystemEventOpen.showLockTip(id)
        return false
    elseif #SystemEventOpen.eventOpenList < 1 then
        return false
    else
        for i = 1, #SystemEventOpen.eventOpenList do
            if SystemEventOpen.eventOpenList[i] == id then
                return true
            end
        end
        SystemEventOpen.showLockTip(id)
        return false
    end
end

function SystemOpen.registerBtn(btnNode, id, isEnd)
    --print("注册按钮：", btnNode.name, id, isEnd)
    if SystemOpen.btnMap[id] == nil then
        SystemOpen.btnMap[id] = {}
    end

    local list = SystemOpen.btnMap[id]
    for i = 1, #list do
        if list[i].node == btnNode then
            return
        end
    end

    local func = function()
        if btnNode then
            local child = UI.child(btnNode, "BtnLight", true)
            if child ~= nil then
                UI.enable(child, false)
            end
        end
        if isEnd then
            SystemOpen.removeNewUnlockSystem(id)
        end
    end

    UI.buttonMulti(btnNode, func)
    list[#list + 1] = {
        node = btnNode,
        callback = func
    }

    SystemOpen.updateEffect(id)
end

function SystemEventOpen.registerBtn(btnNode, id, isEnd)
    --print("注册按钮：", btnNode.name, id, isEnd)
    if SystemEventOpen.btnMap[id] == nil then
        SystemEventOpen.btnMap[id] = {}
    end

    local systemEventOpenConfig = config["systemEventOpen"]

    for i = 1, #systemEventOpenConfig do
        if systemEventOpenConfig[i].page == id then
            if systemEventOpenConfig[i].effect > 0 then
                if btnNode:Find("effect") == nil then
                    UI.showNode(btnNode, "Effect/activity").name = "effect"
                end
            end
        end
    end

    local list = SystemEventOpen.btnMap[id]
    for i = 1, #list do
        if list[i].node == btnNode then
            return
        end
    end
    local func = function()
        if btnNode then
            local child = UI.child(btnNode, "effect", true)
            if child ~= nil then
                UI.enable(child, false)
            end
            log(btnNode.name)
        end
        if isEnd then
            SystemEventOpen.removeNewUnlockSystem(id)
        end
    end

    UI.buttonMulti(btnNode, func)
    list[#list + 1] = {
        node = btnNode,
        callback = func
    }
    SystemEventOpen.updateEffect(id)
end

function SystemOpen.unRegisterBtn(btnNode, id)
    --print("反注册按钮：",btnNode.name,id)
    if SystemOpen.btnMap[id] == nil then
        return
    end

    local list = SystemOpen.btnMap[id]
    if #list < 1 then
        return
    end

    for i = 1, #list do
        if list[i].node == btnNode then
            local temp = list[i]
            UI.rmButtonListener(temp.node, temp.callback)
            table.remove(list, i)
            return
        end
    end
end

function SystemOpen.updateEffect(id)
    if id ~= nil then
        local result = table.find(SystemOpen.newUnlockSystemData, function(a)
            if a == id then
                return a
            end
        end)
        if result == nil then
            return
        end

        local btnList = SystemOpen.btnMap[id]
        if btnList == nil or #btnList < 1 then
            return
        end

        for i = 1, #btnList do
            local node = btnList[i].node
            local child = UI.child(node, "BtnLight", true)
            if child ~= nil then
                UI.enable(child, true)
            else
                UI.showNode(node, "Base/BtnLight")
            end
        end
    else
        if #SystemOpen.newUnlockSystemData > 0 then
            for i = 1, #SystemOpen.newUnlockSystemData do
                SystemOpen.updateEffect(SystemOpen.newUnlockSystemData[i])
            end
        end
    end
end

function SystemEventOpen.updateEffect(id)
    if id ~= nil then

        local result = table.find(SystemEventOpen.newEventOpenList, function(a)
            if a == id then
                return a
            end
        end)
        if result == nil then
            return
        end

        local btnList = SystemEventOpen.btnMap[id]
        if btnList == nil or #btnList < 1 then
            return
        end

        for i = 1, #btnList do
            local node = btnList[i].node
            --if node:Find("effect") == nil then
            --    UI.showNode(node, "Effect/activity").name = "effect"
            --end
        end
    else
        if #SystemEventOpen.newEventOpenList > 0 then
            for i = 1, #SystemEventOpen.newEventOpenList do
                SystemEventOpen.updateEffect(SystemEventOpen.newEventOpenList[i])
            end
        end
    end
end

function SystemOpen.showLockTip(id)
    local config = config["systemOpen"][id]
    UI.showHint(config.tip)
end

function SystemEventOpen.showLockTip(id)
    local config = config["systemEventOpen"][id]
    if string.len(config.tips) <= 0 then
        UI.showHint("活动未开启")
    else
        UI.showHint(config.tips)
    end
end
-- 点击判断 充值  打开相应界面
function ComTools.openRecharge()
    -- 点击判断 充值
    message:send("C2S_ISOpenFristRecharge", {}, function(args)
        if args.frist then
            UI.openPage(UIPageName.FirstCharge)
        else
            UI.show("game.lobby.recharge")
        end
    end)
end