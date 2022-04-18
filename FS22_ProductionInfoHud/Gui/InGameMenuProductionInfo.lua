InGameMenuProductionInfo = {}
InGameMenuProductionInfo._mt = Class(InGameMenuProductionInfo, TabbedMenuFrameElement)

InGameMenuProductionInfo.CONTROLS = {
	TABLE = "fillTypeTable"
}

InGameMenuProductionInfoSections = {
    ALL = 1,
    USED_ONLY = 2,
    PRODUCED_ONLY = 3
}

function InGameMenuProductionInfo.new(productionInfoHud, i18n, messageCenter)
	local self = InGameMenuProductionInfo:superClass().new(nil, InGameMenuProductionInfo._mt)

    self.name = "InGameMenuProductionInfo"
    self.i18n = i18n
    self.messageCenter = messageCenter
    self.productionInfoHud = productionInfoHud
    
	self.dataBindings = {}

    self:registerControls(InGameMenuProductionInfo.CONTROLS)

    self.backButtonInfo = {
		inputAction = InputAction.MENU_BACK
	}
  
    self:setMenuButtonInfo({
        self.backButtonInfo
    })

    return self
end

function InGameMenuProductionInfo:delete()
	InGameMenuProductionInfo:superClass().delete(self)
end

function InGameMenuProductionInfo:copyAttributes(src)
    InGameMenuProductionInfo:superClass().copyAttributes(self, src)
    self.i18n = src.i18n
end

function InGameMenuProductionInfo:onGuiSetupFinished()
	InGameMenuProductionInfo:superClass().onGuiSetupFinished(self)
	self.fillTypeTable:setDataSource(self)
	self.fillTypeTable:setDelegate(self)
end

function InGameMenuProductionInfo:initialize()
end

function InGameMenuProductionInfo:onFrameOpen()
	InGameMenuProductionInfo:superClass().onFrameOpen(self)   
    self:updateContent()
	FocusManager:setFocus(self.fillTypeTable)
end

function InGameMenuProductionInfo:onFrameClose()
	InGameMenuProductionInfo:superClass().onFrameClose(self)   
end

function InGameMenuProductionInfo:updateContent()  

    self.productionInfoHud:createProductionNeedingTable()

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

function InGameMenuProductionInfo:populateCellForItemInSection(list, section, index, cell)
	local fillTypeItem = self.sectionFillTypes[section].fillTypes[index]    
	-- cell:getAttribute("field"):setText(fillTypeItem.fieldId)
	cell:getAttribute("fillTypeIcon"):setImageFilename(fillTypeItem.hudOverlayFilename)
	cell:getAttribute("fillTypeTitle"):setText(fillTypeItem.fillTypeTitle)
	cell:getAttribute("sellPerMonth"):setText(g_i18n:formatNumber(fillTypeItem.sellPerMonth, 2))
	cell:getAttribute("keepPerMonth"):setText(g_i18n:formatNumber(fillTypeItem.keepPerMonth, 2))
	cell:getAttribute("distributePerMonth"):setText(g_i18n:formatNumber(fillTypeItem.distributePerMonth, 2))
	cell:getAttribute("usagePerMonth"):setText(g_i18n:formatNumber(fillTypeItem.usagePerMonth))  
end

function InGameMenuProductionInfo:showSeedUi()
    local dialog = g_gui:showDialog("SeedFrame")
    if dialog ~= nil then
        dialog.target:setFieldData(self.currentFillTypeItem)
    end
end