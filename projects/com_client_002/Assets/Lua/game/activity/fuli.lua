local Class = {
    res = "ui/fuli"
}
-- 福利脚本
function Class:init()
    local bottomBtn = UI.child(self.node, "BottomBtns");
    local page = UI.child(self.node, "page");
    -- 动画相关
    local ani1 = UI.showNode(self.node, "page/monthCard/aniNode", "Anim/wife6");
    UI.playAnim(ani1, "idle")
    local ani2 = UI.showNode(self.node, "page/yearCard/aniNode", "Anim/wife10");
    UI.playAnim(ani2, "idle")
    local ani3 = UI.showNode(self.node, "page/shuochong/aniNode", "Anim/hero27");
    UI.setScale(ani3, 80, 80, 1);
    UI.playAnim(ani3, "idle")
    local ani4 = UI.showNode(self.node, "page/guanqun/aniNode", "Anim/wife1");
    UI.playAnim(ani4, "idle")

    UI.button(self.node, "btnClose", function()
        UI.close(self);
    end)
    self:drawFun();

    -- 默认打开首充页面
    self:ShowPage(4);
end

function Class:drawFun()
    local bottomBtn = UI.child(self.node, "BottomBtns");
    local fun = {
        btnQiandao = function()
            -- 签到
            self:ShowPage(0);
        end,
        btnMonthCard = function()
            -- 月卡
            self:ShowPage(1);
        end,
        btnYearCard = function()
            -- 年卡
            self:ShowPage(2);
        end,
        btnMiracle = function()
            -- 神迹
            self:ShowPage(3);
        end,
        btnFrist = function()
            -- 首充
            self:ShowPage(4);
        end,
        btnGuanqun = function()
            -- 官群
            self:ShowPage(5);
        end
    }
    UI.draw(bottomBtn, fun);
end

function Class:ShowPage(index)
    UI.enableAll(self.node, "page", false);
    local t = UI.child(self.node, "page");
    UI.enable(t, index, true);
end
return Class
