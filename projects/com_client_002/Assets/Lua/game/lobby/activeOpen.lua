---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/8/17 10:42
---

local cls = {
    res = "ui/ActiveLoginTips"
}

function cls:init()
    UI.button(self.node, "BtnClose", function()
        UI.close(self)
    end)
    self:show(true)
end

function cls:show()

end

return cls