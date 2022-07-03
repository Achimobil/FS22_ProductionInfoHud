--[[
Einstellungen für den Production Info Hud ins normale Menü bringen
]]

ProductionInfoHudSettings = {};
ProductionInfoHudSettings.name = g_currentModName;
ProductionInfoHudSettings.modDir = g_currentModDirectory

function ProductionInfoHudSettings.init()

    -- Elemente einfügen, wenn Dialog geöffnet wird
    InGameMenuGeneralSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuGeneralSettingsFrame.onFrameOpen, ProductionInfoHudSettings.initGuiElements);
    
    
	if g_server == nil then
    print("g_server == nil")
        -- Speichern direkt beim schließen des dialogs, da es kein save gibt auf dem client, wenn der server speichert
		InGameMenuGeneralSettingsFrame.onFrameClose = Utils.appendedFunction(InGameMenuGeneralSettingsFrame.onFrameClose, ProductionInfoHud.SaveSettings)
    else
    print("g_server != nil")
        -- Speichern der einstellungen mit dem speichern, wenn server, dann wird von der funktion eh nichts gespeichert, SP und MP Host schon
        FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, ProductionInfoHud.SaveSettings)
	end
end

function ProductionInfoHudSettings.initGuiElements(self)
    ---Darf nur ein mal aufgerufen werden, beim nächsten mal sind die elemente ja schon da, deshalb das erste element prüfen ob vorhanden
    if self.pih_initialized == nil then
        local target = ProductionInfoHud.settings;
        
        ProductionInfoHudSettings:AddTitle(self, "pih_settings_title");

        local possiblePositions = {};
        for id, position in pairs(ProductionInfoHud.PossiblePositions) do
            table.insert(possiblePositions, ProductionInfoHudSettings:getText(("pih_possiblePosition_%d"):format(id)));
        end
        ProductionInfoHudSettings:AddMultiElement(self, target, "position", possiblePositions, "pihPositionElement_title", "pih_tooltip_position", ProductionInfoHud.settings["display"]["position"]);
        
        local possibleMaxLines = {};
        for id, position in pairs(ProductionInfoHud.PossibleMaxLines) do
            table.insert(possibleMaxLines, position .. " " .. ProductionInfoHudSettings:getText("pih_Zeilen"));
        end
        ProductionInfoHudSettings:AddMultiElement(self, target, "maxLines", possibleMaxLines, "pih_MaxLinesElement_title", "pih_tooltip_maxLines", ProductionInfoHud.settings["display"]["maxLines"]);
        
        ProductionInfoHudSettings:AddCheckElement(self, target, "showFullAnimals", "pih_showFullAnimals_title", "pih_tooltip_showFullAnimals", ProductionInfoHud.settings["display"]["showFullAnimals"]);


        -- Die Verkaufspreisauslöser Einstellungen
        ProductionInfoHudSettings:AddTitle(self, "pih_price_settings_title");
        
        ProductionInfoHudSettings:AddMultiElement(self, target, "maxSellingLines", possibleMaxLines, "pih_MaxSellingLinesElement_title", "pih_tooltip_maxSellingLines", ProductionInfoHud.settings["display"]["maxSellingLines"]);
        
        local possibleAmounts = {};
        for id, position in pairs(ProductionInfoHud.PossibleAmounts) do
            table.insert(possibleAmounts, position);
        end
        ProductionInfoHudSettings:AddMultiElement(self, target, "minSellAmount", possibleAmounts, "pih_MinSellAmountElement_title", "pih_tooltip_minSellAmount", ProductionInfoHud.settings["display"]["minSellAmount"]);
        
        self.boxLayout:invalidateLayout();
        
        self.pih_initialized = true;
    end
end

function ProductionInfoHudSettings:AddCheckElement(self, target, settingId, title, tooltip, state)
    -- hier kopieren wir ein checkbox feld element
    local newMultiElement = self.checkShowFieldInfo:clone();
    newMultiElement.target = target;
    newMultiElement.onClickCallback = ProductionInfoHudSettings.onClickCheckbox;
    newMultiElement.buttonLRChange = ProductionInfoHudSettings.onClickCheckbox;
    newMultiElement.id = settingId;

    local settingTitle = newMultiElement.elements[4];
    settingTitle:setText(ProductionInfoHudSettings:getText(title));
    
    local toolTip = newMultiElement.elements[6];
    toolTip:setText(ProductionInfoHudSettings:getText(tooltip));
    
    newMultiElement:setIsChecked(state);
    
    self.boxLayout:addElement(newMultiElement)
end

function ProductionInfoHudSettings:AddMultiElement(self, target, settingId, elementTexts, title, tooltip, state)
    -- hier kopieren wir ein multi feld element
    local newMultiElement = self.multiVolumeGUI:clone();
    newMultiElement.target = target;
    newMultiElement.onClickCallback = ProductionInfoHudSettings.onClickMultiOption;
    newMultiElement.buttonLRChange = ProductionInfoHudSettings.onClickMultiOption;
    newMultiElement.id = settingId;
    newMultiElement:setTexts(elementTexts)

    local settingTitle = newMultiElement.elements[4];
    settingTitle:setText(ProductionInfoHudSettings:getText(title));
    
    local toolTip = newMultiElement.elements[6];
    toolTip:setText(ProductionInfoHudSettings:getText(tooltip));
    
    newMultiElement:setState(state);
    
    self.boxLayout:addElement(newMultiElement)
end

function ProductionInfoHudSettings:AddTitle(self, text)
    local title = TextElement.new()
    title:applyProfile("settingsMenuSubtitle", true)
    title:setText(ProductionInfoHudSettings:getText(text))

    self.boxLayout:addElement(title)
end

function ProductionInfoHudSettings:getText(key)
    return g_i18n.modEnvironments[ProductionInfoHudSettings.name].texts[key]
end

function ProductionInfoHudSettings:onClickMultiOption(state, optionElement)
    print("Change ".. tostring(optionElement.id) .. " to " .. tostring(state))
    ProductionInfoHud.settings["display"][optionElement.id] = state;
end

function ProductionInfoHudSettings:onClickCheckbox(state, checkboxElement)
    print("Change ".. tostring(checkboxElement.id) .. " to " .. tostring(checkboxElement:getIsChecked()))
    ProductionInfoHud.settings["display"][checkboxElement.id] = checkboxElement:getIsChecked()
end

ProductionInfoHudSettings.init()