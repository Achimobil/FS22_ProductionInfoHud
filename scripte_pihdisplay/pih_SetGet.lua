pih_SetGet = {};

function pih_SetGet:loadFillTypesIcons() --optional laden wenn du die icons in deiner box zum anzeigen brauchst
	g_currentMission.hlUtils.loadFillTypesOverlays();	
end;

function pih_SetGet:loadBoxIcons(box)
	if box.overlays.icons == nil then box.overlays.icons = {byName={}};end;
	local firstIcon, lastIcon = g_currentMission.hlUtils.insertIcons( {xmlTagName="pih_display.boxIcons", modDir=ProductionInfoHud.modDir, iconFile="hlHudSystem/icons/icons.dds", xmlFile="scripte_pihdisplay/icons/icons.xml", modName="defaultIcons", groupName="box", fileFormat={64,512,1024}, iconTable=box.overlays.icons} );
end;

function pih_SetGet:getToObject(nodeId)
	--!!--
	return nil;
end;

function pih_SetGet:teleportPlayerToObject(nodeId) --optional nodeId or object or... !!!
	local object = pih_SetGet:getToObject(nodeId);
	if object ~= nil then
		local isTeleport = false;
		if object.mapHotspot ~= nil then
			for hotspots=1, #object.mapHotspot.mapHotspots do
				local hotspot = object.mapHotspot.mapHotspots[hotspots];
				if hotspot ~= nil and hotspot.teleportWorldX ~= nil and hotspot.teleportWorldY ~= nil and hotspot.teleportWorldZ ~= nil then
					if g_currentMission.controlledVehicle ~= nil then
						g_currentMission:onLeaveVehicle(hotspot.teleportWorldX, hotspot.teleportWorldY, hotspot.teleportWorldZ, true, false);
					else
						g_currentMission.player:moveToAbsolute(hotspot.teleportWorldX, hotspot.teleportWorldY, hotspot.teleportWorldZ, false, false);
					end;				
					isTeleport = true;
					break;			
				end;
			end;	
		end;
		--! or over nodeId !--
		if not isTeleport then
			local objectId = object.rootNode or object.nodeId;
			if objectId ~= nil and entityExists(objectId) then			
				local x, y, z = getWorldTranslation(objectId);
				if x ~= nil and y ~= nil and z ~= nil then
					local terrainHeight = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, y, z);
					y = terrainHeight + y;
					if g_currentMission.controlledVehicle ~= nil then
						g_currentMission:onLeaveVehicle(x, y, z, true, false);
					else		
						g_currentMission.player:moveToAbsolute(x, y, z, false, false);
					end;
					isTeleport = true;
				end;
			end;
		end;
		if isTeleport then
			if g_currentMission.hl ~= nil and g_currentMission.hl.isMouseCursor then
				g_currentMission.hl.mouseOnOff(false, false, g_currentMission.hl.controlMod); --force mouseOff old _hl system
			else
				g_currentMission.hlUtils.mouseOnOff(false, false); --force mouseOff
			end;
		end;
	end;
end;

function pih_SetGet:setBoxAlign(box) --!! schreibe dir deine eigene function wenn du sowas brauchst !!
	if box == nil or not box.show or box.ownTable.autoAlign == 1 then return;end;
	local alignX, alignY, alignW, alignH, alignL, alignR = 0,0,0,0,false,false;
	
	if box.ownTable.autoAlign == 2 then
		if g_currentMission.hud.isVisible then			
			alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.backgroundOverlay.overlay);
		else
			alignX = 0.99;
		end;
		alignR = true;
	end;		
	
	if alignX ~= nil and alignY ~= nil and alignW ~= nil and alignH ~= nil and (alignR or alignL) then
		local difW = g_currentMission.hlHudSystem.screen.pixelW*1;
		local x, y, w, h = box:getScreen();
		if alignR then
			local newX = x;
			local newY = y;
			if alignX-w-difW ~= newX then
				newX = alignX-w-difW;
			end;
			if alignY+alignH ~= newY+h then
				newY = alignY+alignH-h;
			end;
			if newX ~= x or newY ~= y then
				box:setPosition(newX, newY);
			end;
		end;
	end;
end;

function pih_SetGet:isHlHudSystemOff() --wenn spieler im mp sein system deaktiviert hat kann man sich das sammeln und verarbeiten der daten sparen (spart performenc und ressourcen) draw wird dann nicht mehr aufgerufen
	if g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission.hlHudSystem.ownData ~= nil and g_currentMission.hlHudSystem.ownData.mpOff then return true;end;
	return false;
end;

function pih_SetGet:setCloseAllDetailsLines(box) --alle offenen details linien schliessen
	--!!--
end;

function pih_SetGet:setViewBoxData(box) --optional hier die daten vorbereiten oder direkt in der pih_DrawBox verarbeiten ! hier ist es besser zum verarbeiten für die scroll function im HL Hud System (bounds)
	if ProductionInfoHud.viewBoxData == nil then ProductionInfoHud.viewBoxData = {};end;
	
	local playerFarmId = g_currentMission.player.farmId;
	local values = box.ownTable;
	local viewBoxData = {};
	
	local openDetails = false; --extra zeilen offen !! optional für closeAllDetailsLines Icon
	
	if not pih_SetGet:isHlHudSystemOff() then 
		function setSortBy()
			function sortByString(w1,w2)			
				if w1.sortByString < w2.sortByString then
					return true;
				end;			
			end;
			function sortByNumber(w1,w2)		
				if w1.sortByNumber > w2.sortByNumber then
					return true;
				end;				
			end;
			function sortByBoolean(w1,w2)		
				return w1.sortByBoolean and not w2.sortByBoolean;							
			end;
			if values.sortBy == 2 then table.sort(viewBoxData, sortByString);end;
			if values.sortBy == 3 then table.sort(viewBoxData, sortByNumber);end;
			if values.sortBy == 4 then table.sort(viewBoxData, sortByBoolean);end;
		end;
		
		
		
		--virtuell zeilen damit deine anzeige box die beispiel zeilen anzeigt--
			--viewBoxData[1] = {};
			--viewBoxData[2] = {};
		--virtuell zeilen damit deine anzeige box die beispiel zeilen anzeigt--
		
		viewBoxData, openDetails = pih_SetGet:getViewBoxData(box, {}); --habe mal die alte scripte erstmal genommen die du für den moh gemacht hast
		
		--setSortBy(); --optional before/after !
	
	end;	
	ProductionInfoHud.viewBoxData = viewBoxData;
	return openDetails;
end;

function pih_SetGet:getViewBoxData(box, viewBoxData) --alte daten für den moh (umgeschrieben), geht aber sicherlich besser und einfacher, weil alles doppel aufgerufen wird, am besten alles in dieser function verarbeiten pih_SetGet:setViewBoxData(box)
	local values = box.ownTable;
	local dataForBox = {}
	local dataForBoxNameToId = {}
	local viewIsFiltered = values.filterForProduction ~= nil or values.filterForFillType ~= nil;
	if viewIsFiltered then
		dataForBox = ProductionInfoHud.productionDataSorted
	else
		for _, productionData in ipairs(ProductionInfoHud.productionDataSorted) do
			local productionName = tostring(productionData.name);
			if productionData.capacityLevel ~= nil and productionData.capacityLevel > values.capacityLevelFilter and productionData.hoursLeft ~= nil and productionData.hoursLeft >= 0 then
				goto skipProductionData;
			end
			
			if productionData.hoursLeft ~= nil then
				local compareValue = 24 * values.daysLeftFilter;
				if productionData.timeAdjustment ~= nil then
					compareValue = compareValue * productionData.timeAdjustment;
				end
				if productionData.hoursLeft > compareValue then
					goto skipProductionData;
				end
			end
			
			if dataForBoxNameToId[productionName] == nil then
				productionData.additionalProductionData = {};
				table.insert(dataForBox, productionData);
				dataForBoxNameToId[productionName] = #dataForBox
			else
				table.insert(dataForBox[dataForBoxNameToId[productionName]].additionalProductionData, productionData);
			end
			
			::skipProductionData::
		end
	end
		
	------hier kommen deine restlichen Daten rein die du an die Box übergibst-----
	local openDetails = false;
	for _, productionData in pairs(dataForBox) do
		pih_SetGet.CreateLineTable(box, viewBoxData, productionData, true);
		
		-- zusätzliche infos anzeigen
		local productionName = tostring(productionData.name)
		if values.openProductions[productionName] ~= nil and values.openProductions[productionName] == true and productionData.additionalProductionData ~= nil and not viewIsFiltered then
			for _, productionDataInner in pairs(productionData.additionalProductionData) do
				if not openDetails then openDetails = true;end;
			
				pih_SetGet.CreateLineTable(box, viewBoxData, productionDataInner, false);
			end			
		end
	end
	return viewBoxData, openDetails;
end;

function pih_SetGet.CreateLineTable(box, viewBoxData, productionData, isMainLine) --alte daten für den moh (umgeschrieben), geht aber sicherlich besser und einfacher, weil alles doppel aufgerufen wird, am besten alles in dieser function verarbeiten pih_SetGet:setViewBoxData(box)
		local productionName = tostring(productionData.name)
		if box.ownTable.filterForProduction ~= nil and box.ownTable.filterForProduction ~= productionName then
			goto continue;
		end
		if box.ownTable.filterForFillType ~= nil and box.ownTable.filterForFillType ~= tostring(productionData.fillTypeTitle) then
			goto continue;
		end
		
		local viewIsFiltered = box.ownTable.filterForProduction ~= nil or box.ownTable.filterForFillType ~= nil;
	
		viewBoxData[#viewBoxData+1] = {};
		local isLineTable = viewBoxData[#viewBoxData];
		isLineTable[1] = {};isLineTable[2] = {};isLineTable[3] = {};
		
		isLineTable[1].viewIsFiltered = viewIsFiltered;
		isLineTable[1].canViewDetails = productionData.additionalProductionData ~= nil and #productionData.additionalProductionData > 0;
		isLineTable[1].isMainLine = isMainLine;
		isLineTable[1].fillTypeIndex = productionData.fillTypeId;
		isLineTable[1].productionData = productionData;
		isLineTable[1].bold = true;
		isLineTable[1].txt = productionName;		
		isLineTable[1].whereClick = "clickOnProductionColumn_"; 
		if productionData.productionPoint ~= nil and productionData.productionPoint.openMenu ~= nil then
			isLineTable[1].infoTxt = g_i18n:getText("pih_moh_leftClickToOpenRightClickForFilterProduction");
		else
			isLineTable[1].infoTxt = g_i18n:getText("pih_moh_rightClickForFilterProduction");
		end
		if box.ownTable.filterForProduction ~= nil then
			isLineTable[1].color = box.overlays.color.on;
		else
			isLineTable[1].color = box.overlays.color.columText1;
		end
		

		local timeLeftString = nil;
		local timeColor = "white"; --als int, prozent color farbe der schrift fest hinterlegt in dem _hlUtils.lua script welches alle meine mods haben --> 1="white", 2="green", 3="yellowGreen", 4="yellow", 5="orange", 6="orangeRed", 7="red"};
		if box.ownTable.showMissingAmount then
			if productionData.capacity ~= nil and productionData.fillLevel ~= nil then
				timeLeftString = g_i18n:formatVolume(productionData.capacity - productionData.fillLevel, 0)
			else
				timeLeftString = "";
			end
		elseif productionData.hoursLeft == -3 then
			timeLeftString = g_i18n:getText("Overcrowded");
			timeColor = "red";
		elseif productionData.hoursLeft == -2 then
			timeLeftString = g_i18n:getText("Full");
			timeColor = "red";
		elseif productionData.hoursLeft == -1 then
			timeLeftString = g_i18n:getText("NearlyFull");
			timeColor = "orange";
		elseif productionData.hoursLeft == 0 then
			timeLeftString = g_i18n:getText("Empty");
			timeColor = "orangeRed";
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
				timeColor = "yellow";
			end
			timeString = timeString .. hours .. ":" .. minutes;
			timeLeftString = timeString;
		end
		isLineTable[2].isMainLine = isMainLine;
		isLineTable[2].fillTypeIndex = productionData.fillTypeId;
		isLineTable[2].bold = false;
		isLineTable[2].txt = tostring(productionData.fillTypeTitle);		
		isLineTable[2].whereClick = "clickOnFillTypeColumn_"; 
		isLineTable[2].infoTxt = g_i18n:getText("pih_moh_rightClickForFilterFillType");
		isLineTable[2].color = timeColor;
		if box.ownTable.filterForFillType ~= nil then
			isLineTable[2].color = box.overlays.color.on;
		end
		
		isLineTable[3].isMainLine = isMainLine;
		isLineTable[3].fillTypeIndex = productionData.fillTypeId;
		isLineTable[3].bold = false;
		isLineTable[3].txt = tostring(timeLeftString);
		isLineTable[3].whereClick = "clickOnTimeColumn_";
		isLineTable[3].infoTxt = g_i18n:getText("pih_moh_rightClickForSwitchTimeAndFreeSpace");
		isLineTable[3].color = timeColor;
		
		::continue::
end