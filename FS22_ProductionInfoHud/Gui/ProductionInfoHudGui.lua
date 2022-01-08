
ProductionInfoHudGUI = {}
ProductionInfoHudGUI.CONTROLS = {
    PAGE_SETTINGS = "pageSettings",
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

    ProductionInfoHudGUI:superClass().onGuiSetupFinished(self)

    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack) -- store to be able to apply it always when assigning menu button info
    self.clickOkCallback = self:makeSelfCallback(self.onClickOk) -- store to be able to apply it always when assigning menu button info

    self.pageSettings:initialize()

    self:setupMenuButtonInfo()
end

--- Define default properties and retrieval collections for menu buttons.
function ProductionInfoHudGUI:setupMenuButtonInfo()
    local onButtonBackFunction = self.clickBackCallback
    local onButtonOkFunction = self.clickOkCallback

    self.defaultMenuButtonInfo = {
        { inputAction = InputAction.MENU_BACK, text = self.l10n:getText("button_back"), callback = onButtonBackFunction },
        { inputAction = InputAction.MENU_ACCEPT, text = self.l10n:getText("button_save"), callback = onButtonOkFunction },
    }

    self.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1]

    self.defaultButtonActionCallbacks = {
        [InputAction.MENU_BACK] = onButtonBackFunction,
        [InputAction.MENU_ACCEPT] = onButtonOkFunction,
    }
end

function ProductionInfoHudGUI:onClickOk()
    local state = self.pageSettings.pihPositionElement:getState();
    ProductionInfoHud.settings["display"]["position"] = state;
    ProductionInfoHud.settings["display"]["showFullAnimals"] = self.pageSettings.pihShowFullAnimalsElement:getIsChecked();
    local state = self.pageSettings.pihMaxLinesElement:getState();
    ProductionInfoHud.settings["display"]["maxLines"] = state;
    
    ProductionInfoHud:SaveSettings()
end