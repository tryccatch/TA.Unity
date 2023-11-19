---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Admin.
--- DateTime: 2021/7/2 15:14
---

local class = {
}

local controller = nil

---@param ctr [catchAssailant]
function class:init(root, ctr)
    self.root = root
    controller = ctr

    UI.button(self.root, function()
        self:show(false)
    end)
    UI.button(self.root, "BtnClose", function()
        self:show(false)
    end)
end

function class:show(show)
    UI.enable(self.root, show)
    UI.text(self.root, "S/V/C", Tools.getHelp("whitenights"))
end

return class