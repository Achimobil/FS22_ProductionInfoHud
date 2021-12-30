---
-- GuidanceSteeringStrategyFrame
--
-- Frame to handle the settings and to modify the current guidance data.
--
-- Copyright (c) Wopster, 2019

---@class ProductionInfoHudFrame
ProductionInfoHudFrame = {}

local ProductionInfoHudFrame_mt = Class(ProductionInfoHudFrame, TabbedMenuFrameElement)

ProductionInfoHudFrame.CONTROLS = {
    WIDTH_DISPLAY = "widthDisplay",
    WIDTH_PLUS = "guidanceSteeringMinusButton",
    WIDTH_MINUS = "guidanceSteeringPlusButton",
    WIDTH_RESET = "guidanceSteeringResetWidthButton",
    WIDTH_INCREMENT = "guidanceSteeringWidthIncrementElement",
    WIDTH_TEXT = "guidanceSteeringWidthText",

    OFFSET_DISPLAY = "offsetDisplay",
    OFFSET_PLUS = "guidanceSteeringMinusOffsetButton",
    OFFSET_MINUS = "guidanceSteeringPlusOffsetButton",
    OFFSET_RESET = "guidanceSteeringResetOffsetButton",
    OFFSET_INCREMENT = "guidanceSteeringOffsetIncrementElement",
    OFFSET_TEXT = "guidanceSteeringOffsetWidthText",

    HEADLAND_DISPLAY = "headlandDisplay",
    HEADLAND_MODE = "guidanceSteeringHeadlandModeElement",
    HEADLAND_DISTANCE = "guidanceSteeringHeadlandDistanceElement",

    TOGGLE_SHOW_LINES = "guidanceSteeringShowLinesElement",
    OFFSET_LINES = "guidanceSteeringLinesOffsetElement",
    TOGGLE_SNAP_TERRAIN_ANGLE = "guidanceSteeringSnapAngleElement",
    TOGGLE_ENABLE_STEERING = "guidanceSteeringEnableSteeringElement",
    TOGGLE_AUTO_INVERT_OFFSET = "guidanceSteeringAutoInvertOffsetElement",

    CONTAINER = "container",
    BOX_LAYOUT_SETTINGS = "boxLayoutSettings",
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

function ProductionInfoHudFrame:initialize()
end
