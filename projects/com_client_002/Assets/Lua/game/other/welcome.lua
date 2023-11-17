local Class = {
    res = "ui/welcome"
}

function Class:init(guideId)

    UI.draw(self.node,{
        BtnClose = function()
            UI.close(self)
        end,
        BtnYes = function()
            UI.close(self)
        end,
    })
end

return Class