pihOutputForMoh = {};
--du hast vollen zugriff auf das _hl.lua script und fragste die werte von dort zum Beispiel mit g_currentMission.hl.getProzentColor(args, args) <-- einfach mal in die lua rein schauen,hat etliche funktionen,incl Laufschrift !!!hast nur zugriff wenn es von einem meiner mods hinterlegt wurde,am besten mit g_currentMission.hl ~= nil vorher prüfen

function pihOutputForMoh:load(cmdTable, slotTable) --cmdTable ist dein hinterlegter Befehl und damit hast du auch deine ownTable die du dort optional hinterlegt hast mit eigenen werten, slotTable ist der Anzeige Slot wenn du von diesem irgendwelche Relevanten Daten brauchst
	local playerFarmId = g_currentMission.player.farmId;
	local cmdRegName = cmdTable.regName;
	
-- print("cmdTable")
-- DebugUtil.printTableRecursively(cmdTable,"_",0,2)
-- print("slotTable")
-- DebugUtil.printTableRecursively(slotTable,"_",0,2)
			
	-----------------die Überschrift habe ich dir mal schon vorgefertigst----------------	
	local lineTable = {line={}};
	function setSeparator()
		lineTable.line[#lineTable.line+1] = {};
		isLineTable = lineTable.line[#lineTable.line];
		isLineTable.txt = {};
		isLineTable.txt[1] = {};
		isLineTable.txt[1].slotColor = "txtOutputTitle";
		isLineTable.txt[1].bold = true;
		isLineTable.txt[1].txt = "----";
		isLineTable.txt[2] = {};
		isLineTable.txt[2].slotColor = "txtOutputTitle";
		isLineTable.txt[2].bold = true;
		isLineTable.txt[2].txt = "----";
		isLineTable.txt[2].alignment = 3;
	end;
	
	
	lineTable.line[#lineTable.line+1] = {};
	local isLineTable = lineTable.line[#lineTable.line];
	isLineTable.txt = {};
	isLineTable.txt[1] = {};
	isLineTable.txt[1].alignment = 1;
	isLineTable.txt[1].width = 20;
	isLineTable.txt[1].callback = pihOutputForMoh.clickDaysMinus;
	isLineTable.txt[1].infoTxt = g_i18n:getText("pih_moh_infoTextDaysSetting");
	isLineTable.txt[1].txt = tostring(g_i18n:formatNumDay(pihConfigForMoh.values.daysLeftFilter));
	isLineTable.txt[1].prozentColor = 3;
	
	-- +/- davor und dahinter clickbar
	if g_currentMission.hl.isMouseCursor then
		local iconColor = "yellow";
		if isLineTable.txt[1].icon == nil then isLineTable.txt[1].icon = {before={},after={},behindTxt={}};end;
		isLineTable.txt[1].icon.behindTxt[#isLineTable.txt[1].icon.behindTxt+1] = {name="buttonUpDown", color=iconColor, settingButton=true, callback={[1]=pihOutputForMoh.clickDaysMinus}, infoTxt=g_i18n:getText("pih_moh_infoTextDaysSetting")};
	end
	
	isLineTable.txt[2] = {};
	isLineTable.txt[2].slotColor = "txtOutputTitle";
	isLineTable.txt[2].txt = g_i18n:getText("pih_moh_headline");
	isLineTable.txt[2].width = 60;
	isLineTable.txt[2].bold = true;
	isLineTable.txt[2].alignment = 2;
	if slotTable ~= nil and slotTable.help.outputOn then
		isLineTable.txt[2].icon = {before={},after={}};
		isLineTable.txt[2].icon.before[1] = {name="buttonHelp", color="yellow", settingButton=true, callback={[1]=pihOutputForMoh.clickIconHelpTxt}};
	end;
	isLineTable.txt[3] = {};
	isLineTable.txt[3].alignment = 3;
	isLineTable.txt[3].infoTxt = g_i18n:getText("pih_moh_infoTextCapacitySetting")
	isLineTable.txt[3].width = 20;
	isLineTable.txt[3].callback = pihOutputForMoh.clickCapacityLevelMinus;
	isLineTable.txt[3].txt = tostring(pihConfigForMoh.values.capacityLevelFilter * 100) .. "%";
	isLineTable.txt[3].prozentColor = 3;
	
	-- +/- davor und dahinter clickbar
	if g_currentMission.hl.isMouseCursor then
		local iconColor = "yellow";
		if isLineTable.txt[3].icon == nil then isLineTable.txt[3].icon = {before={},after={},behindTxt={}};end;
		isLineTable.txt[3].icon.after[#isLineTable.txt[3].icon.after+1] = {name="buttonUpDown", color=iconColor, settingButton=true, callback={[1]=pihOutputForMoh.clickCapacityLevelMinus}, infoTxt=g_i18n:getText("pih_moh_infoTextCapacitySetting")};
	end
	
	-----------------die Überschrift habe ich dir mal schon vorgefertigst----------------	
	
	-- Gruppieren nach Produktion. also alles was es sonst noch gibt für eine Produktion in die erste rein schieben
	-- aber nur, wenn kein Filter gesetzt ist
	local dataForMoh = {}
	local dataForMohNameToId = {}
	local viewIsFiltered = cmdTable.ownTable.filterForProduction ~= nil or cmdTable.ownTable.filterForFillType ~= nil;
	if viewIsFiltered then
		dataForMoh = ProductionInfoHud.productionDataSorted
	else
		for _, productionData in ipairs(ProductionInfoHud.productionDataSorted) do
			local productionName = tostring(productionData.name);
			if productionData.capacityLevel ~= nil and productionData.capacityLevel > pihConfigForMoh.values.capacityLevelFilter and productionData.isInput == true then
				goto skipProductionData;
			end
			
			if productionData.hoursLeft ~= nil then
				local compareValue = 24 * pihConfigForMoh.values.daysLeftFilter;
				if productionData.timeAdjustment ~= nil then
					compareValue = compareValue * productionData.timeAdjustment;
				end
				if productionData.hoursLeft > compareValue then
					goto skipProductionData;
				end
			end
			
			if dataForMohNameToId[productionName] == nil then
				productionData.additionalProductionData = {};
				table.insert(dataForMoh, productionData);
				dataForMohNameToId[productionName] = #dataForMoh
			else
				table.insert(dataForMoh[dataForMohNameToId[productionName]].additionalProductionData, productionData);
			end
			
			::skipProductionData::
		end
	end
		
	------hier kommen deine restlichen Daten rein die du an den MultiOverlayV4 übergibst-----
	
	for _, productionData in pairs(dataForMoh) do
		pihOutputForMoh.CreateLineTable(cmdTable, slotTable, lineTable, productionData, true);
		
		-- zusätzliche infos anzeigen
		local productionName = tostring(productionData.name)
		if cmdTable.ownTable.openProductions[productionName] ~= nil and cmdTable.ownTable.openProductions[productionName] == true and productionData.additionalProductionData ~= nil and not viewIsFiltered then
			local innerIsShown = false;
			for _, productionDataInner in pairs(productionData.additionalProductionData) do
				innerIsShown = true;
			
				pihOutputForMoh.CreateLineTable(cmdTable, slotTable, lineTable, productionDataInner, false);
			end
			if innerIsShown then
				setSeparator();
			end
		end
	end
	
	pihOutputForMoh[cmdRegName] = {output=lineTable}; --musste dann aktivieren wenn der test deaktiviert ist
end;

function pihOutputForMoh.CreateLineTable(cmdTable, slotTable, lineTable, productionData, isMainLine)
		local productionName = tostring(productionData.name)
		if cmdTable.ownTable.filterForProduction ~= nil and cmdTable.ownTable.filterForProduction ~= productionName then
			goto continue;
		end
		if cmdTable.ownTable.filterForFillType ~= nil and cmdTable.ownTable.filterForFillType ~= tostring(productionData.fillTypeTitle) then
			goto continue;
		end
		
		local viewIsFiltered = cmdTable.ownTable.filterForProduction ~= nil or cmdTable.ownTable.filterForFillType ~= nil;
	
		lineTable.line[#lineTable.line+1] = {};
		local isLineTable = lineTable.line[#lineTable.line];
		isLineTable.txt = {};

		isLineTable.txt[1] = {};
		isLineTable.txt[1].alignment = 1;
		isLineTable.txt[1].width = 45;
		if isMainLine then
			isLineTable.txt[1].bold = true;
			isLineTable.txt[1].txt = productionName;
			isLineTable.txt[1].callback = pihOutputForMoh.clickOnProductionColumn;
			isLineTable.txt[1].ownTable = productionData;
			if productionData.productionPoint ~= nil and productionData.productionPoint.openMenu ~= nil then
				isLineTable.txt[1].infoTxt = g_i18n:getText("pih_moh_leftClickToOpenRightClickForFilterProduction");
			else
				isLineTable.txt[1].infoTxt = g_i18n:getText("pih_moh_rightClickForFilterProduction");
			end
			if cmdTable.ownTable.filterForProduction ~= nil then
				isLineTable.txt[1].prozentColor = 2;
			else
				isLineTable.txt[1].slotColor = "txtOutputTitle";
			end
		end
		
		-- icon zum auf und zu klappen wie bei HappyLoosers Produktionen
		local viewProductionInfo = cmdTable.ownTable.openProductions[productionName] ~= nil and cmdTable.ownTable.openProductions[productionName] == true;
		if g_currentMission.hl.isMouseCursor and not viewIsFiltered and isMainLine then
			local iconColor = "gray";
			local buttonName = "buttonDown";
			if viewProductionInfo then iconColor = "green";buttonName = "buttonUp";end;				
			if productionData.additionalProductionData ~= nil and #productionData.additionalProductionData == 0 then iconColor = "green";buttonName = "free";end;				
			isLineTable.txt[1].icon = {before={},after={},behindTxt={}};
			isLineTable.txt[1].icon.before[1] = {name=buttonName, color=iconColor, settingButton=true, callback={[1]=pihOutputForMoh.clickViewProductionInfo}, ownTable={productionName}, infoTxt=g_i18n:getText("pih_moh_colapseEntry")};
		end;
		

		local timeLeftString = nil;
		local timeColor = 1; --als int, prozent color farbe der schrift fest hinterlegt in dem _hl.lua script welches alle meine mods haben --> 1="white", 2="green", 3="yellowGreen", 4="yellow", 5="orange", 6="orangeRed", 7="red"};
		if cmdTable.ownTable.showMissingAmount then
			if productionData.capacity ~= nil and productionData.fillLevel ~= nil then
				timeLeftString = g_i18n:formatVolume(productionData.capacity - productionData.fillLevel, 0)
			else
				timeLeftString = "";
			end
		elseif productionData.hoursLeft == -3 then
			timeLeftString = g_i18n:getText("Overcrowded");
			timeColor = 7;
		elseif productionData.hoursLeft == -2 then
			timeLeftString = g_i18n:getText("Full");
			timeColor = 7;
		elseif productionData.hoursLeft == -1 then
			timeLeftString = g_i18n:getText("NearlyFull");
			timeColor = 5;
		elseif productionData.hoursLeft == 0 then
			timeLeftString = g_i18n:getText("Empty");
			timeColor = 6;
		else
			local days = math.floor(productionData.hoursLeft / 24);
			local hoursLeft = productionData.hoursLeft - (days * 24);
			local hours = math.floor(hoursLeft);
			local hoursLeft = hoursLeft - hours;
			local minutes = math.floor(hoursLeft * 60);
			if(minutes <= 9) then minutes = "0" .. minutes end;
			local timeString = "";
			if (days ~= 0) then 
				timeString = g_i18n:formatNumDay(days) .. " ";
			else
				timeColor = 4;
			end
			timeString = timeString .. hours .. ":" .. minutes;
			timeLeftString = timeString;
		end

		isLineTable.txt[2] = {};
		isLineTable.txt[2].txt = tostring(productionData.fillTypeTitle);
		isLineTable.txt[2].callback = pihOutputForMoh.clickOnFillTypeColumn;
		isLineTable.txt[2].ownTable = productionData;
		isLineTable.txt[2].infoTxt = g_i18n:getText("pih_moh_rightClickForFilterFillType");
		isLineTable.txt[2].alignment = 1;
		isLineTable.txt[2].width = 35;
		isLineTable.txt[2].prozentColor = timeColor;
		if cmdTable.ownTable.filterForFillType ~= nil then
			isLineTable.txt[2].prozentColor = 2;
		end
				
		isLineTable.txt[3] = {};
		isLineTable.txt[3].txt = tostring(timeLeftString);
		isLineTable.txt[3].callback = pihOutputForMoh.clickOnTimeColumn;
		isLineTable.txt[3].infoTxt = g_i18n:getText("pih_moh_rightClickForSwitchTimeAndFreeSpace");
		isLineTable.txt[3].alignment = 3;
		isLineTable.txt[3].width = 20;
		isLineTable.txt[3].prozentColor = timeColor;
		
		::continue::
end

function pihOutputForMoh.giveOutputTable(args)
	if args == nil or type(args) ~= "table" then return false;end;	
	pihOutputForMoh:load(args.cmdTable, args.slotTable);
	return pihOutputForMoh[args.cmdTable.regName].output;	
end;

function pihOutputForMoh.clickDaysMinus(args)
	if args == nil or type(args) ~= "table" then return;end;
	if args.mouseClick == "MOUSE_BUTTON_LEFT" and args.isDown and pihConfigForMoh.values.daysLeftFilter > 1 then
		pihConfigForMoh.values.daysLeftFilter = pihConfigForMoh.values.daysLeftFilter - 1;
		ProductionInfoHud.moh.mod.moGeneralSettings.isSave = false;	
	end;
	if args.mouseClick == "MOUSE_BUTTON_RIGHT" and args.isDown and pihConfigForMoh.values.daysLeftFilter < 10 then
		pihConfigForMoh.values.daysLeftFilter = pihConfigForMoh.values.daysLeftFilter + 1;
		ProductionInfoHud.moh.mod.moGeneralSettings.isSave = false;	
	end;
end;

function pihOutputForMoh.clickCapacityLevelMinus(args)
	if args == nil or type(args) ~= "table" then return;end;
	if args.mouseClick == "MOUSE_BUTTON_LEFT" and args.isDown and pihConfigForMoh.values.capacityLevelFilter > 0.05 then
		pihConfigForMoh.values.capacityLevelFilter = pihConfigForMoh.values.capacityLevelFilter - 0.05;
		ProductionInfoHud.moh.mod.moGeneralSettings.isSave = false;	
	end;
	if args.mouseClick == "MOUSE_BUTTON_RIGHT" and args.isDown and pihConfigForMoh.values.capacityLevelFilter < 1 then
		pihConfigForMoh.values.capacityLevelFilter = pihConfigForMoh.values.capacityLevelFilter + 0.05;
		ProductionInfoHud.moh.mod.moGeneralSettings.isSave = false;	
	end;
end;

function pihOutputForMoh.clickOnTimeColumn(args)
	if args == nil or type(args) ~= "table" then return;end;
	if args.mouseClick == "MOUSE_BUTTON_RIGHT" and args.isDown then
		args.cmdTable.ownTable.showMissingAmount = not args.cmdTable.ownTable.showMissingAmount;
	end;
end;

function pihOutputForMoh.clickOnFillTypeColumn(args)
	if args == nil or type(args) ~= "table" then return;end;
	if args.mouseClick == "MOUSE_BUTTON_RIGHT" and args.isDown then
		if args.cmdTable.ownTable.filterForFillType == nil then
			args.cmdTable.ownTable.filterForFillType = tostring(args.ownTable.fillTypeTitle);
		else
			args.cmdTable.ownTable.filterForFillType = nil;
		end
	end;
end;

function pihOutputForMoh.clickOnProductionColumn(args)
	if args == nil or type(args) ~= "table" and args.ownTable == nil then return false;end;
	if args.mouseClick == "MOUSE_BUTTON_LEFT" and args.isDown then
		if args.ownTable ~= nil then
			--mach was
			if args.ownTable.productionPoint ~= nil and args.ownTable.productionPoint.openMenu ~= nil then
				args.ownTable.productionPoint:openMenu();
			end
		end;
	elseif args.mouseClick == "MOUSE_BUTTON_RIGHT" then
		if args.cmdTable.ownTable.filterForProduction == nil then
			args.cmdTable.ownTable.filterForProduction = tostring(args.ownTable.name);
		else
			args.cmdTable.ownTable.filterForProduction = nil;
		end
	end;
end;

function pihOutputForMoh.clickIconHelpTxt(args)
    if args == nil or type(args) ~= "table" then return;end;
    if args.mouseClick == "MOUSE_BUTTON_LEFT" and args.isDown then
        g_currentMission.multiOverlayV4.moSetGetOverlays.infoHelpBox.help.lsTimer = -1;
        g_currentMission.multiOverlayV4.moSetGetOverlays.infoHelpBox.help.titel = g_i18n:getText("pih_moh_help_titel");
        g_currentMission.multiOverlayV4.moSetGetOverlays.infoHelpBox.help.txt = g_i18n:getText("pih_moh_help_text");
        -- g_currentMission.multiOverlayV4.moSetGetOverlays.infoHelpBox.help.txt = "Click Left Mouse on Production name or Filltype to filter list. Press again to remove filter\nRight click on Production Name to open Production Menu\nClick Left Mouse on Time left to switch between time left and free available capacity";
    end;
end;

function pihOutputForMoh.clickViewProductionInfo(args)
	if args == nil or type(args) ~= "table" or args.ownTable == nil then return;end;	
	if args.mouseClick == "MOUSE_BUTTON_LEFT" and args.isDown then
		if args.ownTable[1] ~= nil then
			if args.cmdTable.ownTable.openProductions[args.ownTable[1]] == nil then
				args.cmdTable.ownTable.openProductions[args.ownTable[1]] = true;
			else
				args.cmdTable.ownTable.openProductions[args.ownTable[1]] = not args.cmdTable.ownTable.openProductions[args.ownTable[1]];
			end
			
		end;	
	end;
end;