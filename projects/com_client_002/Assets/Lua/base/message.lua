local Class = {
}

function Class:clear()
    self.funs = {}
    self.ackMaxId = 0
    self.ackFun = {}
    self.curMsg = {}
end

function Class:init()

    self:clear()

    if self.pb then
        return
    end

    self.pb = require "pb"
    --self.protoc = require "proto.protoc"

    local data = require("proto.opcode")
    data = cloneTable(data)

    self.msgId = {}
    self.realName = {}
    self.msgName = {}

    local loaded = {}

    for k, v in pairs(data) do

        local pos = string.find(v, "%.")

        local package = string.sub(v, 1, pos - 1)
        if not loaded[package] then
            local data = CS.ResTools.ReadLuaBytes("proto/" .. string.sub(v, 1, pos - 1) .. ".bytes")
            self.pb.load(data)
            loaded[package] = true
        end

        name = string.sub(v, pos + 1)

        -- log(name,string.sub(v,1,pos-1))

        self.msgId[name] = k
        self.realName[name] = v
        self.msgName[k] = name
    end

    --local data = CS.ResTools.ReadLuaBytes("proto/data.bytes")
    --self.protoc:load(data)
end

function Class:setOnMsg(name, fun)
    self.funs[name] = fun
end

function Class:send(name, msg, ackFun, notWaitting)

    local id = self.msgId[name]
    if not id then
        log("can't found msg:" .. name)
        log(_s(msg))
        return
    end
    --log("msg:",name)
    --log(_s(msg))
    local bytes = self:encode(name, msg)

    if not bytes then
        log('error msg:' .. name)
        log(_s(msg))
        return
    end

    local ackId = 0
    if ackFun then
        self.ackMaxId = self.ackMaxId + 1
        if self.ackMaxId > 1000 then
            self.ackMaxId = 1
        end
        ackId = self.ackMaxId
        self.ackFun[ackId] = ackFun

        if not notWaitting then
            UI.showWaitting(1)
        end
    end
    if net then
        net:Send(id, ackId, bytes)
    end
end

function Class:onMsg(bin)
    if bin.ackId > 0 then
        UI.closeWaitting()
        local id = bin.ackId

        if self.ackFun[id] then
            local msgName = self.msgName[bin.msgId]
            if self.curMsg then
                self.curMsg[msgName] = true
            end

            local msg = self:decode(msgName, bin.bytes)
            self.ackFun[id](msg)
            self.ackFun[id] = nil
            return
        end
    end

    local msgName = self.msgName[bin.msgId]
    if self.curMsg then
        self.curMsg[msgName] = true
    end

    if self.funs[msgName] then
        local msg = self:decode(msgName, bin.bytes)
        self.funs[msgName](msg)
        return
    end
end

function Class:decode(name, bytes)
    name = "proto." .. self.realName[name]
    name = self:changeName(name)
    return self.pb.decode(name, bytes)
end

function Class:encode(name, msg)
    name = "proto." .. self.realName[name]
    name = self:changeName(name)
    local bytes = self.pb.encode(name, msg)
    return bytes
end

function Class:changeName(name)

    -- for i,pack in ipairs(self.packageNames) do
    --     name = string.replace(name,pack .. ".","")
    -- end

    return name
end

return Class
