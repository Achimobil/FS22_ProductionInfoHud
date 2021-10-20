-- 
-- ProductionInfoHudGUI
-- 
-- @Author: Tunis
-- @Date: 29.05.2021
-- @Version: 1.0.0.1
-- 
-- 
-- Changelog:
-- 1.0.0.1
-- Background blur
-- Over color
--

ProductionInfoHudGUI = {}
ProductionInfoHudGUI.CONTROLS = {"pihSettingsList","pihSettingsListItem","pihTitle"}
ProductionInfoHudGUI.overColor = {0.9,0.9,0.5,1}

local ProductionInfoHudGUI_mt = Class(ProductionInfoHudGUI, ScreenElement)

function ProductionInfoHudGUI:new(target)
    local obj = ScreenElement:new(target, ProductionInfoHudGUI_mt)
    obj.returnScreenName = ""
    obj:registerControls(ProductionInfoHudGUI.CONTROLS)
    return obj
end

function ProductionInfoHudGUI:onCreate()
    self.pihSettingsListItem:unlinkElement();
    self.pihSettingsListItem:setVisible(false);
end

function ProductionInfoHudGUI:onOpen()
    ProductionInfoHudGUI:superClass().onOpen(self)
	g_depthOfFieldManager:setBlurState(true)
	self:loadList()
end

function ProductionInfoHudGUI:onClose()
    ProductionInfoHudGUI:superClass().onClose(self)
	g_depthOfFieldManager:setBlurState(false)
end

function ProductionInfoHudGUI:onIgnoreProductionInputButton()
	local element = self.pihSettingsList:getSelectedElement()
	if self.pihSettingsList:getItemCount() > 0 and element ~= nil then
		element.factorySetting.ignore = not(element.factorySetting.ignore);
		element.elements[2]:setText(self:GetIgnoreText(element.factorySetting.ignore));
	end
end

function ProductionInfoHudGUI:onIgnoreProductionOutputSellingButton()
	local element = self.pihSettingsList:getSelectedElement()
	if self.pihSettingsList:getItemCount() > 0 and element ~= nil then
		element.factorySetting.ignoreSelling = not(element.factorySetting.ignoreSelling);
		element.elements[3]:setText(self:GetIgnoreText(element.factorySetting.ignoreSelling));
	end
end

function ProductionInfoHudGUI:onIgnoreProductionFullOutputButton()
	local element = self.pihSettingsList:getSelectedElement()
	if self.pihSettingsList:getItemCount() > 0 and element ~= nil then
		element.factorySetting.ignoreFullProductions = not(element.factorySetting.ignoreFullProductions);
		element.elements[4]:setText(self:GetIgnoreText(element.factorySetting.ignoreFullProductions));
	end
end

function ProductionInfoHudGUI:onSelectionChangedFactoryList()
	local element = self.pihSettingsList:getSelectedElement()
	if self.pihSettingsList:getItemCount() > 0 and element ~= nil then
		--print(element.factorySetting.indexName);
	end
end

function ProductionInfoHudGUI:onClickOk()
    ProductionInfoHudGUI:superClass().onClickOk(self)
	self:onClickBack()
end

function ProductionInfoHudGUI:onClickBack()
    ProductionInfoHudGUI:superClass().onClickBack(self)
end

function ProductionInfoHudGUI:loadList()

    self.pihSettingsList:deleteListItems()

	-- Only tables with numeric indexes can be sorted, so put the items in a temp new table and sort it before adding to the List.
	local sortedList = {}
	for indexName,factorySetting in pairs(GC_ProductionInfoHud.settings["factory"]) do
		if factorySetting.availableInThisGame then
			if factorySetting.GuiName == nil then 
				-- factories with no GuiName are wrong modded by the creator, here I fix them for not having trouble and make a log entry
				factorySetting.GuiName = indexName;
				print("Warning! factory with indexName '" .. indexName .. "' has no GuiName. Indextname used. Please inform the modder of the factory to correct this.");
			end
			table.insert(sortedList, factorySetting)
		end
	end
	table.sort(sortedList, compGuiName)
	
	for id,factorySetting in pairs(sortedList) do
	-- print(indexName);
		local newListItem = self.pihSettingsListItem:clone(self.pihSettingsList)
		newListItem:setVisible(true)
		newListItem.elements[1]:setText(factorySetting.GuiName)
		newListItem.elements[2]:setText(self:GetIgnoreText(factorySetting.ignore));
		newListItem.elements[3]:setText(self:GetIgnoreText(factorySetting.ignoreSelling));
		newListItem.elements[4]:setText(self:GetIgnoreText(factorySetting.ignoreFullProductions));
		newListItem:updateAbsolutePosition()
		newListItem.factorySetting = factorySetting
	end

end

function compGuiName(w1,w2)
    if w1.GuiName < w2.GuiName then
        return true;
    end
end

function ProductionInfoHudGUI:GetIgnoreText(ignoreValue)
	if ignoreValue then
		return g_i18n:getText("Hide");
	else
		return g_i18n:getText("Show");
	end
end

function ProductionInfoHudGUI:onCreateDisplaySetting(element)
    local setting = GC_ProductionInfoHud.settings["display"][element.name];
	element.settings = setting;
	element.labelElement.text = g_i18n:getText(element.name)
    -- element.toolTipText = g_i18n:getText(setting.tooltip)

    local labels = {}
	local currentState = 1;
    for i = 1, #setting.PossbileValues, 1 do
		if setting.Translate ~= nil and setting.Translate then
			labels[i] = g_i18n:getText(setting.PossbileValues[i]);
		else
			labels[i] = setting.PossbileValues[i];
		end
		if setting.Value == setting.PossbileValues[i] then 
			currentState = i;
		end;
    end
    element:setTexts(labels);
	element:setState(currentState, false);
end

function ProductionInfoHudGUI:onCreateTranslateElementText(element)
	element.text = g_i18n:getText(element.text);
end

function ProductionInfoHudGUI:onCreateTranslateElementButton(element)
	element:setText(g_i18n:getText(element.text));
end

function ProductionInfoHudGUI:onOptionChange(state, element)
	element.settings.Value = element.settings.PossbileValues[state];
	-- DebugUtil.printTableRecursively(element,"_",0,2);
end

function ProductionInfoHudGUI:onSaveSettingsButton()
    GC_ProductionInfoHud:saveCfg();
end

function ProductionInfoHudGUI:onCorrectCentralStorageButton()
    GC_ProductionInfoHud:correctCentralStorage();
end