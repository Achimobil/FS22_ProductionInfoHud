InGameMenuProductionInfo = {}
InGameMenuProductionInfo._mt = Class(InGameMenuProductionInfo, TabbedMenuFrameElement)

InGameMenuProductionInfo.CONTROLS = {
	"fillTypeTable",
	"productionInfoTitle"
}

InGameMenuProductionInfo.MODE_MONTH = 1
InGameMenuProductionInfo.MODE_HOUR = 2
InGameMenuProductionInfo.MODE_YEAR = 3

InGameMenuProductionInfoSections = {
	ALL = 1,
	USED_ONLY = 2,
	PRODUCED_ONLY = 3
}

function InGameMenuProductionInfo.new(productionInfoHud, l10n, messageCenter)
	local self = InGameMenuProductionInfo:superClass().new(nil, InGameMenuProductionInfo._mt)

	self.name = "InGameMenuProductionInfo"
	self.l10n = l10n
	self.messageCenter = messageCenter
	self.productionInfoHud = productionInfoHud
	
	self.dataBindings = {}

	self:registerControls(InGameMenuProductionInfo.CONTROLS)

	self.hasCustomMenuButtons = true
	self.backButtonInfo = {
		inputAction = InputAction.MENU_BACK
	}
  
	self:setMenuButtonInfo({
		self.backButtonInfo
	})
	
	self.mode = InGameMenuProductionInfo.MODE_MONTH

	return self
end

function InGameMenuProductionInfo:delete()
	InGameMenuProductionInfo:superClass().delete(self)
end

function InGameMenuProductionInfo:copyAttributes(src)
	InGameMenuProductionInfo:superClass().copyAttributes(self, src)
	self.l10n = src.l10n
end

function InGameMenuProductionInfo:onGuiSetupFinished()
	InGameMenuProductionInfo:superClass().onGuiSetupFinished(self)
	self.fillTypeTable:setDataSource(self)
	self.fillTypeTable:setDelegate(self)
end

function InGameMenuProductionInfo:initialize()
	self.toggleModeButtonInfo = {
		profile = "buttonActivate",
		inputAction = InputAction.MENU_ACTIVATE,
		text = self.l10n:getText("pih_changeTimeToMonth"),
		callback = function ()
			self:onButtonToggleMode()
		end
	}
end

function InGameMenuProductionInfo:onFrameOpen()
	InGameMenuProductionInfo:superClass().onFrameOpen(self)
	self:setMode(self.mode)
	self:updateContent()
	FocusManager:setFocus(self.fillTypeTable)
end

function InGameMenuProductionInfo:onFrameClose()
	InGameMenuProductionInfo:superClass().onFrameClose(self)   
end

function InGameMenuProductionInfo:updateContent()

	self.productionInfoHud:createProductionNeedingTable(self.mode)

	self.fillTypeResultTable = ProductionInfoHud.fillTypeResultTable
		
	self:sortList()
	self.fillTypeTable:reloadData()	
end

function InGameMenuProductionInfo:sortList()
	local sectionList = {};
	sectionList[InGameMenuProductionInfoSections.ALL] = 
		{
			title = g_i18n:getText("ui_listHeader_" .. InGameMenuProductionInfoSections.ALL),
			fillTypes = {}
		}
	sectionList[InGameMenuProductionInfoSections.USED_ONLY] = 
		{
			title = g_i18n:getText("ui_listHeader_" .. InGameMenuProductionInfoSections.USED_ONLY),
			fillTypes = {}
		}
	sectionList[InGameMenuProductionInfoSections.PRODUCED_ONLY] = 
		{
			title = g_i18n:getText("ui_listHeader_" .. InGameMenuProductionInfoSections.PRODUCED_ONLY),
			fillTypes = {}
		}
		
	for _, fillTypeItem in ipairs(self.fillTypeResultTable) do
		if fillTypeItem.usagePerMonth == 0 then
			if fillTypeItem.producedPerMonth == 0 then
				-- nothing, not existing
			else
				table.insert(sectionList[InGameMenuProductionInfoSections.PRODUCED_ONLY].fillTypes, fillTypeItem)
			end
		else
			if fillTypeItem.producedPerMonth == 0 then
				table.insert(sectionList[InGameMenuProductionInfoSections.USED_ONLY].fillTypes, fillTypeItem)
			else
				table.insert(sectionList[InGameMenuProductionInfoSections.ALL].fillTypes, fillTypeItem)
			end
		end
		
	end
	
	self.sectionFillTypes = {}

	for _,e in pairs(sectionList) do
		table.insert(self.sectionFillTypes, e)
	end
end

function InGameMenuProductionInfo:getNumberOfSections()
	return #self.sectionFillTypes
end

function InGameMenuProductionInfo:getNumberOfItemsInSection(list, section)
	return #self.sectionFillTypes[section].fillTypes
end

function InGameMenuProductionInfo:getTitleForSectionHeader(list, section)
	return self.sectionFillTypes[section].title
end


InGameMenuProductionInfo.COLOR = {
	NORMAL = { 1, 1, 1, 1},
	BOOSTER = { 0.9157, 0.1420, 0.0002, 1 }
}

function InGameMenuProductionInfo:populateCellForItemInSection(list, section, index, cell)
	local function formatAmounts(amount, amountWithBooster)
		local text = g_i18n:formatNumber(amount, 2);
		if amount ~= amountWithBooster then
			text = text .. "(" .. g_i18n:formatNumber(amountWithBooster, 2) .. ")";
		end
		return text;
	end;
	
	local function formatCell(cell, amount, amountWithBooster)
		local text = g_i18n:formatNumber(amount, 1);
		local color = InGameMenuProductionInfo.COLOR.NORMAL;
		if amount ~= amountWithBooster then
			text = text .. "(" .. g_i18n:formatNumber(amountWithBooster, 1) .. ")";
			color = InGameMenuProductionInfo.COLOR.BOOSTER;
		end
		cell:setText(text);
		cell:setTextColor(unpack(color))
	end;
	
	local fillTypeItem = self.sectionFillTypes[section].fillTypes[index]
	cell:getAttribute("fillTypeIcon"):setImageFilename(fillTypeItem.hudOverlayFilename)
	cell:getAttribute("fillTypeTitle"):setText(fillTypeItem.fillTypeTitle)
	formatCell(cell:getAttribute("sellPerMonth"), fillTypeItem.sellPerMonth, fillTypeItem.sellPerMonthWithBooster)
	formatCell(cell:getAttribute("keepPerMonth"), fillTypeItem.keepPerMonth, fillTypeItem.keepPerMonthWithBooster)
	formatCell(cell:getAttribute("distributePerMonth"), fillTypeItem.distributePerMonth, fillTypeItem.distributePerMonthWithBooster)
	cell:getAttribute("usagePerMonth"):setText(g_i18n:formatNumber(fillTypeItem.usagePerMonth, 1));
	
	local squareMeterNeededText = "";
	if fillTypeItem.squareMeterNeeded ~= nil then
		squareMeterNeededText = g_i18n:formatArea(fillTypeItem.squareMeterNeeded, 1, false);
	end
	cell:getAttribute("neededFieldSize"):setText(squareMeterNeededText);
end

function InGameMenuProductionInfo:onButtonToggleMode()
	if self.mode == InGameMenuProductionInfo.MODE_MONTH then
		self:setMode(InGameMenuProductionInfo.MODE_HOUR)
	elseif self.mode == InGameMenuProductionInfo.MODE_HOUR then
		self:setMode(InGameMenuProductionInfo.MODE_YEAR)
	else
		self:setMode(InGameMenuProductionInfo.MODE_MONTH)
	end
	self:updateContent()
end

function InGameMenuProductionInfo:setMode(mode)
	self.mode = mode

	-- self.pricesColumn:setVisible(mode == InGameMenuPricesFrame.MODE_PRICES)
	-- self.fluctuationsColumn:setVisible(mode == InGameMenuPricesFrame.MODE_FLUCTUATIONS)

	-- if mode == InGameMenuPricesFrame.MODE_FLUCTUATIONS then
		-- FocusManager:setFocus(self.productList)
	-- end

	self:updateMenuButtons()
end

function InGameMenuProductionInfo:updateMenuButtons()
	self.menuButtonInfo = {
		{
			inputAction = InputAction.MENU_BACK
		}
	}
	
	if self.mode == InGameMenuProductionInfo.MODE_MONTH then
		self.toggleModeButtonInfo.text = self.l10n:getText("pih_changeTimeToHour")
		self.productionInfoTitle.text = self.l10n:getText("pih_ingameMenuProductionInfo")
	elseif self.mode == InGameMenuProductionInfo.MODE_YEAR then
		self.toggleModeButtonInfo.text = self.l10n:getText("pih_changeTimeToMonth")
		self.productionInfoTitle.text = self.l10n:getText("pih_ingameMenuProductionInfoYear")
	else
		self.toggleModeButtonInfo.text = self.l10n:getText("pih_changeTimeToYear")
		self.productionInfoTitle.text = self.l10n:getText("pih_ingameMenuProductionInfoHour")
	end

	table.insert(self.menuButtonInfo, self.toggleModeButtonInfo)
	self:setMenuButtonInfoDirty()
end