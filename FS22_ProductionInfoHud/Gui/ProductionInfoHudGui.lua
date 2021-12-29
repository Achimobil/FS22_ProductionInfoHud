
ProductionInfoHudGUI = {}
ProductionInfoHudGUI.CONTROLS = {
    PAGE_SETTINGS = "pageSettings"
}
ProductionInfoHudGUI.overColor = {0.9,0.9,0.5,1}

local ProductionInfoHudGUI_mt = Class(ProductionInfoHudGUI, TabbedMenu)

function ProductionInfoHudGUI:new(messageCenter, i18n, inputManager)
    local self = TabbedMenu.new(nil, ProductionInfoHudGUI_mt, messageCenter, i18n, inputManager)
    
    self:registerControls(ProductionInfoHudGUI.CONTROLS)

    self.i18n = i18n
    self.performBackgroundBlur = false
    
    return self
end

function ProductionInfoHudGUI:onGuiSetupFinished()
print(" GuidanceSteeringMenu:onGuiSetupFinished()");
    ProductionInfoHudGUI:superClass().onGuiSetupFinished(self)

    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack) -- store to be able to apply it always when assigning menu button info

    self.pageSettings:initialize()
    self.pageStrategy:initialize()

    self:setupPages()
    self:setupMenuButtonInfo()
end