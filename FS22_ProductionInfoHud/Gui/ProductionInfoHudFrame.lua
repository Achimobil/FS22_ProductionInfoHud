ProductionInfoHudFrame = {}

local ProductionInfoHudFrame_mt = Class(ProductionInfoHudFrame, TabbedMenuFrameElement)

ProductionInfoHudFrame.CONTROLS = {
    POSITION_ELEMENT = "pihPositionElement",
    BOX_LAYOUT_SETTINGS = "boxLayoutSettings",
    SHOWFULLANIMALS_ELEMENT = "pihShowFullAnimalsElement",
}

ProductionInfoHudFrame.INCREMENTS = { 0.01, 0.05, 0.1, 0.5, 1 }

---Creates a new instance of the ProductionInfoHudFrame.
---@return ProductionInfoHudFrame
function ProductionInfoHudFrame.new(ui, i18n)
    local self = TabbedMenuFrameElement.new(nil, ProductionInfoHudFrame_mt)

    self.ui = ui
    self.i18n = i18n

    self.allowSave = false

    self:registerControls(ProductionInfoHudFrame.CONTROLS)

    return self
end

function ProductionInfoHudFrame:copyAttributes(src)
    ProductionInfoHudFrame:superClass().copyAttributes(self, src)

    self.ui = src.ui
    self.i18n = src.i18n
end

function ProductionInfoHudFrame:initialize()

    local possiblePositions = {}
    for id, position in pairs(ProductionInfoHud.PossiblePositions) do
        table.insert(possiblePositions, self.i18n:getText(("pih_possiblePosition_%d"):format(id)))
    end

    self.pihPositionElement:setTexts(possiblePositions)
    
end

function ProductionInfoHudFrame:onFrameOpen()
    ProductionInfoHudFrame:superClass().onFrameOpen(self)
    
    self.pihPositionElement:setState(ProductionInfoHud.settings["display"]["position"]);
    self.pihShowFullAnimalsElement:setIsChecked(ProductionInfoHud.settings["display"]["showFullAnimals"])

    self.boxLayoutSettings:invalidateLayout()

    if FocusManager:getFocusedElement() == nil then
        self:setSoundSuppressed(true)
        FocusManager:setFocus(self.boxLayoutSettings)
        self:setSoundSuppressed(false)
    end
end