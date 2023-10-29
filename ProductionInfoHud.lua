--- Anzeige für Produktionen in einem HUD by achimobil
--- It is not allowed to copy my code complete or in Parts into other mods.
--- Publishing only by myself, rehosting is forbidden in any way. Only links to my published mod version is allowed.
--- If you have any issues please report them in GitHub: https://github.com/Achimobil/FS22_ProductionInfoHud

ProductionInfoHud = {}

ProductionInfoHud.metadata = {
	title = "ProductionInfoHud",
	notes = "Anzeige für Produktionen in einem HUD",
	author = "Achimobil",
	info = "Das verändern und wiederöffentlichen, auch in Teilen, ist untersagt und wird abgemahnt."
};
ProductionInfoHud.modDir = g_currentModDirectory;
ProductionInfoHud.firstRun = false;
ProductionInfoHud.sellPriceTriggerAvailable = true;
ProductionInfoHud.isClient = false;
ProductionInfoHud.timePast = 0;
ProductionInfoHud.overlay = Overlay.new(HUD.MENU_BACKGROUND_PATH, 0, 0, 0, 0);
ProductionInfoHud.colors = {};
ProductionInfoHud.colors.WHITE =	{1.000, 1.000, 1.000, 1}
ProductionInfoHud.colors.ORANGE =   {0.840, 0.270, 0.020, 1}
ProductionInfoHud.colors.RED =	  {0.580, 0.040, 0.020, 1}
ProductionInfoHud.colors.YELLOW =   {0.980, 0.420, 0.000, 1}
ProductionInfoHud.PossiblePositions = {"TopCenter", "BelowHelp", "BelowVehicleInspector"}
ProductionInfoHud.PossibleMaxLines = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "12", "15", "20", "25"}
ProductionInfoHud.PossibleAmounts = {"5000", "10000", "50000", "100000", "200000", "250000"}
ProductionInfoHud.PossibleTextSizes = {"8", "9", "10", "11", "12", "13", "14", "15"}

local function isDedi()
  local result = g_currentMission:getIsServer() and g_currentMission.connectedToDedicatedServer == true;
  -- print("isDedi: " .. tostring(result));
  return result;
end

function ProductionInfoHud:init()
	ProductionInfoHud.isClient = not isDedi();
	-- isClient korrektur, wenn es die dynamic info gibt
	-- if g_currentMission.missionDynamicInfo ~= nil and g_currentMission.missionDynamicInfo.isClient ~= nil then
		-- ProductionInfoHud.isClient = g_currentMission.missionDynamicInfo.isClient;
	-- end
	
	ProductionInfoHud.isInit = true;
	
	ProductionInfoHud.messageCenter = g_messageCenter;
	ProductionInfoHud.i18n = g_i18n;
	ProductionInfoHud.inputManager = g_gui.inputManager;
	ProductionInfoHud.sellPriceDataSorted = {};
	ProductionInfoHud.productionDataSorted = {};
	
	-- default settings einstellen
	ProductionInfoHud.settings = {};
	ProductionInfoHud.settings["display"] = {};
	ProductionInfoHud.settings["display"]["showType"] = "NONE";
	ProductionInfoHud.settings["display"]["position"] = 1;
	ProductionInfoHud.settings["display"]["showFullAnimals"] = true;
	ProductionInfoHud.settings["display"]["maxLines"] = 5;
	ProductionInfoHud.settings["display"]["maxSellingLines"] = 5;
	ProductionInfoHud.settings["display"]["minSellAmount"] = 1;
	ProductionInfoHud.settings["display"]["showBooster"] = true;
	ProductionInfoHud.settings["display"]["textSize"] = 5;
	
	ProductionInfoHud:LoadSettings();
	   
	-- Aufrufen nach init, da erst an isclient gesetzt ist und sonst die binding nicht aktiv ist bevor man in ein auto einsteigt
	ProductionInfoHud:registerActionEvents()

	-- overwrite the InfoMessageHUD method to move it to a good location, when it is installed	
	if g_modIsLoaded["FS22_InfoMessageHUD"] then ---by HappyLooser Info das solltest du anders lösen
		print("Info: ProductionInfoHud override position of InfoMessageHUD");
		local mod2 = getfenv(0)["FS22_InfoMessageHUD"];
		ProductionInfoHud.InfoMessageHUD = mod2.InfoMessageHUD;		

		function ProductionInfoHud.InfoMessageHUD:renderText(x, y, size, text, bold, colorId)
			x = x + 0.4;

			setTextColor(unpack(ProductionInfoHud.InfoMessageHUD.Colors[colorId][2]))
			setTextBold(bold)
			setTextAlignment(RenderText.ALIGN_LEFT)
			renderText(x, y, size, text)
			
			-- Back to defaults
			setTextBold(false)
			setTextColor(unpack(ProductionInfoHud.InfoMessageHUD.Colors[1][2])) --Back to default color which is white
			setTextAlignment(RenderText.ALIGN_LEFT)
		end
	end
	   
	-- sie produktions seite
	g_gui:loadProfiles(ProductionInfoHud.modDir .. "Gui/guiProfiles.xml")
	local productionFrame = InGameMenuProductionInfo.new(ProductionInfoHud, ProductionInfoHud.i18n, ProductionInfoHud.messageCenter)
	g_gui:loadGui(ProductionInfoHud.modDir .. "Gui/InGameMenuProductionInfo.xml", "InGameMenuProductionInfo", productionFrame, true)
	
	ProductionInfoHud.fixInGameMenu(productionFrame,"InGameMenuProductionInfo", {0,0,1024,1024}, ProductionInfoHud:makeIsProductionInfoEnabledPredicate())
	productionFrame:initialize()
end

function ProductionInfoHud:makeIsProductionInfoEnabledPredicate()
	return function () return true end
end

-- from Courseplay
function ProductionInfoHud.fixInGameMenu(frame, pageName, uvs, predicateFunc)
	local inGameMenu = g_gui.screenControllers[InGameMenu]

	-- remove all to avoid warnings
	for k, v in pairs({pageName}) do
		inGameMenu.controlIDs[v] = nil
	end

	inGameMenu:registerControls({pageName})

	
	inGameMenu[pageName] = frame
	inGameMenu.pagingElement:addElement(inGameMenu[pageName])

	inGameMenu:exposeControlsAsFields(pageName)
	
	-- position bestimmen anhand des produktions menues, den da soll es drüber stehen
	local position = 13;
	-- find original production page
	for i = 1, #inGameMenu.pagingElement.elements do
		local child = inGameMenu.pagingElement.elements[i];

		if child == inGameMenu.pageProduction then
			position = i;
			break
		end
	end	

	-- alles was 
	for i = 1, #inGameMenu.pagingElement.elements do
		local child = inGameMenu.pagingElement.elements[i]
		if child == inGameMenu[pageName] then
			table.remove(inGameMenu.pagingElement.elements, i)
			table.insert(inGameMenu.pagingElement.elements, position, child)
			break
		end
	end

	for i = 1, #inGameMenu.pagingElement.pages do
		local child = inGameMenu.pagingElement.pages[i]
		if child.element == inGameMenu[pageName] then
			table.remove(inGameMenu.pagingElement.pages, i)
			table.insert(inGameMenu.pagingElement.pages, position, child)
			break
		end
	end

	inGameMenu.pagingElement:updateAbsolutePosition()
	inGameMenu.pagingElement:updatePageMapping()
	
	inGameMenu:registerPage(inGameMenu[pageName], position, predicateFunc)
	local iconFileName = Utils.getFilename('menuIcon.dds', ProductionInfoHud.modDir)
	inGameMenu:addPageTab(inGameMenu[pageName],iconFileName, GuiUtils.getUVs(uvs))
	inGameMenu[pageName]:applyScreenAlignment()
	inGameMenu[pageName]:updateAbsolutePosition()

	for i = 1, #inGameMenu.pageFrames do
		local child = inGameMenu.pageFrames[i]
		if child == inGameMenu[pageName] then
			table.remove(inGameMenu.pageFrames, i)
			table.insert(inGameMenu.pageFrames, position, child)
			break
		end
	end

	inGameMenu:rebuildTabList()
end

function ProductionInfoHud:registerActionEvents()
	if ProductionInfoHud.isClient then
		_, ProductionInfoHud.eventIdToggle = g_inputBinding:registerActionEvent(InputAction.TOGGLE_GUI, ProductionInfoHud, ProductionInfoHud.ToggleGui, false, true, false, true)
	end
end

function ProductionInfoHud:ToggleGui()
	local sellPriceTriggerAvailable = true;
	if FS22_SellPriceTrigger == nil or FS22_SellPriceTrigger.SellPriceTrigger == nil or FS22_SellPriceTrigger.SellPriceTrigger.triggers == nil then 
		sellPriceTriggerAvailable = false; 
	end;
	
	if sellPriceTriggerAvailable then
		if ProductionInfoHud.settings["display"]["showType"] == "ALL" then 
			ProductionInfoHud.settings["display"]["showType"] = "PRODUCTION"
		elseif ProductionInfoHud.settings["display"]["showType"] == "PRODUCTION" then 
			ProductionInfoHud.settings["display"]["showType"] = "SELLPRICE"
		elseif ProductionInfoHud.settings["display"]["showType"] == "SELLPRICE" then 
			ProductionInfoHud.settings["display"]["showType"] = "NONE"
		else 
			ProductionInfoHud.settings["display"]["showType"] = "ALL"
		end
	else
		if ProductionInfoHud.settings["display"]["showType"] == "ALL" then 
			ProductionInfoHud.settings["display"]["showType"] = "NONE"
		else 
			ProductionInfoHud.settings["display"]["showType"] = "ALL"
		end
	end
end

function ProductionInfoHud:loadMap(name)
	-- ActionEvents registrieren
	FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, ProductionInfoHud.registerActionEvents);
	if not ProductionInfoHud:getServer() then Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, ProductionInfoHud.onStartMission);end; --new by HappyLooser
end

function ProductionInfoHud:update(dt)
	local mohFound = false;
	if not ProductionInfoHud:getServer() then --new by HappyLooser
		if ProductionInfoHud.moh ~= nil and ProductionInfoHud.moh.found and ProductionInfoHud.moh.outputCmdActive then --new by HappyLooser for MOH Features, solltest du aufrufen egal wie dein showType Status gesetzt ist
			--hier alles laden was du den spielern anzeigen lassen willst oder was du brauchst, nutze einfach deinen vorhandene table und schiebe das hier dann um
			--du kannst ruhig alles laden und es später dann in der pihOutputForMoh.lua aussortieren was du den Spielern anzeigen lassen willst, zusätzlich hast du dann auch die möglichkeit dem spieler mit zu teilen das irgend eine produktion nicht läuft, wenn er den MOH Slot gerade nicht offen hat
			--muss nur auf client ausgeführt werden
			mohFound = true;
		end;
	end;
	
	if not ProductionInfoHud.isInit then ProductionInfoHud:init(); end
	
	if not ProductionInfoHud.isClient then return end
	
	
	ProductionInfoHud.timePast = ProductionInfoHud.timePast + dt;
	
	if ProductionInfoHud.timePast >= 5000 then
		ProductionInfoHud.timePast = 0;

		if ProductionInfoHud.settings["display"]["showType"] == "ALL" or string.find(ProductionInfoHud.settings["display"]["showType"], "PRODUCTION") or mohFound then 
			ProductionInfoHud:refreshProductionsTable();
		end
		
		if ProductionInfoHud.sellPriceTriggerAvailable and (ProductionInfoHud.settings["display"]["showType"] == "ALL" or string.find(ProductionInfoHud.settings["display"]["showType"], "SELLPRICE")) then
			ProductionInfoHud:refreshSellPriceData();
		end
	end
	
	if not ProductionInfoHud.firstRun then	
	
		if FS22_SellPriceTrigger == nil or FS22_SellPriceTrigger.SellPriceTrigger == nil or FS22_SellPriceTrigger.SellPriceTrigger.triggers == nil then 
			ProductionInfoHud.sellPriceTriggerAvailable = false;
		end;
		
		ProductionInfoHud.firstRun = true;
	end
	
	-- if mohFound then
		-- local cmdTable = {regName = "ProductionInfoHudDataTable"}
		-- local slotTable = nil
		-- pihOutputForMoh:load(ProductionInfoHud.productionDataSorted, slotTable)
	-- end
end

function ProductionInfoHud:createProductionNeedingTable(mode)
   
	local factor = 1;
	if mode == InGameMenuProductionInfo.MODE_MONTH then
		factor = 1;
	elseif mode == InGameMenuProductionInfo.MODE_HOUR then
		factor = 1 / (24 * g_currentMission.environment.daysPerPeriod); -- tage einstellungen auslesen!!!
	else
		factor = 12;
	end

	local farmId = g_currentMission.player.farmId;
	local myFillTypes = {} -- filltypeId is key for finding and adding, change later to sortable
	
	-- productions
	if g_currentMission.productionChainManager.farmIds[farmId] ~= nil and g_currentMission.productionChainManager.farmIds[farmId].productionPoints ~= nil then
		for _, productionPoint in pairs(g_currentMission.productionChainManager.farmIds[farmId].productionPoints) do
		
			-- hidden stuff from GTX production script
			if productionPoint.hiddenOnUI ~= nil and productionPoint.hiddenOnUI == true then
				goto ignoreProduction
			end
			
			-- hidden stuff from revamp production script
			for i = 1, #productionPoint.activeProductions do
				local activeProduction = productionPoint.activeProductions[i];
				
				if activeProduction.hideComplete ~= nil and activeProduction.hideComplete == true then
					goto ignoreProduction
				end
			end
			
				
			local numActiveProductions = #productionPoint.activeProductions
			
			for fillTypeId, fillLevel in pairs(productionPoint.storage.fillLevels) do
				-- neu erstellen, wenn nicht da
				if myFillTypes[fillTypeId] == nil then
					local fillTypeItem = {};
					fillTypeItem.fillTypeId = fillTypeId;
					fillTypeItem.usagePerMonth = 0;
					fillTypeItem.producedPerMonth = 0;
					fillTypeItem.producedPerMonthWithBooster = 0;
					fillTypeItem.sellPerMonth = 0;
					fillTypeItem.sellPerMonthWithBooster = 0;
					fillTypeItem.keepPerMonth = 0;
					fillTypeItem.keepPerMonthWithBooster = 0;
					fillTypeItem.distributePerMonth = 0;
					fillTypeItem.distributePerMonthWithBooster = 0;
					local filltype = g_fillTypeManager.fillTypes[fillTypeId]
					fillTypeItem.fillTypeTitle = filltype.title;
					fillTypeItem.hudOverlayFilename = filltype.hudOverlayFilename;
					
					local fruitDesc = g_fruitTypeManager:getFruitTypeByFillTypeIndex(fillTypeId);
					if fruitDesc ~= nil and mode == InGameMenuProductionInfo.MODE_YEAR and fillTypeId ~= FillType.STRAW then
						if fruitDesc.windrowName == "ALFALFA_WINDROW" or fruitDesc.windrowName == "GRASS_WINDROW" then
							fillTypeItem.literPerSqm = g_fruitTypeManager:getFillTypeLiterPerSqm(fillTypeId, 1);
						else
							fillTypeItem.literPerSqm = fruitDesc.literPerSqm;
						end
					end
					
					myFillTypes[fillTypeId] = fillTypeItem;
				end
				local fillTypeItem = myFillTypes[fillTypeId];
				
				for _, production in pairs(productionPoint.activeProductions) do
					-- berechnen des yearFactor wenn notwendig
					local yearFactor = 1
						if mode == InGameMenuProductionInfo.MODE_YEAR then
						if production.months ~= nil then
							local months = string.split(production.months, " ");
							yearFactor = yearFactor * (#months/12)
						end
						if production.seasons ~= nil then
							local seasons = string.split(production.seasons, " ");
							yearFactor = yearFactor * (#seasons/4)
						end
					end
				
					for _, input in pairs(production.inputs) do
						if input.type == fillTypeId then
							fillTypeItem.usagePerMonth = fillTypeItem.usagePerMonth + (production.cyclesPerMonth * input.amount) * factor / (productionPoint.sharedThroughputCapacity and numActiveProductions or 1) * yearFactor;
						end
						
						-- outputConditional von Revamp könnte im Input stehen
						if input.outputConditional ~= nil and not input.outputConditional == false then
												
							local outputMode = productionPoint:getOutputDistributionMode(fillTypeId)
						
							-- wenn es dieser filltype ist der gerade durchläuft und wenn wenn davo auch was drin ist, wird berechnet
							if input.outputConditional == fillTypeId and productionPoint:getFillLevel(fillTypeId) > 1 then
								local producedPerMonth = production.cyclesPerMonth * input.outputAmount * factor / (productionPoint.sharedThroughputCapacity and numActiveProductions or 1) * yearFactor;
								
								-- outputConditional hat keine Booster
								local boostFactor = 1;
								
								local producedPerMonthWithBooster = (producedPerMonth*boostFactor);
								fillTypeItem.producedPerMonth = fillTypeItem.producedPerMonth + producedPerMonth
								fillTypeItem.producedPerMonthWithBooster = fillTypeItem.producedPerMonthWithBooster + producedPerMonthWithBooster
								
								if outputMode == ProductionPoint.OUTPUT_MODE.DIRECT_SELL then
									fillTypeItem.sellPerMonth = fillTypeItem.sellPerMonth + producedPerMonth;
									fillTypeItem.sellPerMonthWithBooster = fillTypeItem.sellPerMonthWithBooster + producedPerMonthWithBooster;
								elseif outputMode == ProductionPoint.OUTPUT_MODE.AUTO_DELIVER then
									fillTypeItem.distributePerMonth = fillTypeItem.distributePerMonth + producedPerMonth;
									fillTypeItem.distributePerMonthWithBooster = fillTypeItem.distributePerMonthWithBooster + producedPerMonthWithBooster;
								else
									fillTypeItem.keepPerMonth = fillTypeItem.keepPerMonth + producedPerMonth;
									fillTypeItem.keepPerMonthWithBooster = fillTypeItem.keepPerMonthWithBooster + producedPerMonthWithBooster;
								end
							end
						
						end
					end
					
					for _, output in pairs(production.outputs) do
						local outputMode = productionPoint:getOutputDistributionMode(fillTypeId)
						
						if output.type == fillTypeId then
							local producedPerMonth = production.cyclesPerMonth * output.amount * factor / (productionPoint.sharedThroughputCapacity and numActiveProductions or 1) * yearFactor;
							
							-- aktive Booster berechnen
							local boostFactor = 1;
							for _, input in pairs(production.inputs) do
								if input.mix ~= nil and input.mix == 6 then
									-- ist ein booster
									if productionPoint:getFillLevel(fillTypeId) > 1 then
										boostFactor = boostFactor + Utils.getNoNil(input.boostfactor, input.boostFactor);
									end
								end
							end
							
							local producedPerMonthWithBooster = (producedPerMonth*boostFactor);
							fillTypeItem.producedPerMonth = fillTypeItem.producedPerMonth + producedPerMonth
							fillTypeItem.producedPerMonthWithBooster = fillTypeItem.producedPerMonthWithBooster + producedPerMonthWithBooster
							
							if outputMode == ProductionPoint.OUTPUT_MODE.DIRECT_SELL then
								fillTypeItem.sellPerMonth = fillTypeItem.sellPerMonth + producedPerMonth;
								fillTypeItem.sellPerMonthWithBooster = fillTypeItem.sellPerMonthWithBooster + producedPerMonthWithBooster;
							elseif outputMode == ProductionPoint.OUTPUT_MODE.AUTO_DELIVER then
								fillTypeItem.distributePerMonth = fillTypeItem.distributePerMonth + producedPerMonth;
								fillTypeItem.distributePerMonthWithBooster = fillTypeItem.distributePerMonthWithBooster + producedPerMonthWithBooster;
							else
								fillTypeItem.keepPerMonth = fillTypeItem.keepPerMonth + producedPerMonth;
								fillTypeItem.keepPerMonthWithBooster = fillTypeItem.keepPerMonthWithBooster + producedPerMonthWithBooster;
							end
						end
					end
				end
			end
			
			::ignoreProduction::
		end
	end
	
	-- in sortierbare Liste eintragen
	local fillTypeResultTable = {};
	for fillTypeId, fillTypeItem in pairs (myFillTypes) do
		if fillTypeItem.usagePerMonth ~= 0 or fillTypeItem.producedPerMonth ~= 0 then
			-- berechnen der feldgröße
			if fillTypeItem.literPerSqm ~= nil and fillTypeItem.usagePerMonth ~= 0 then
				fillTypeItem.squareMeterNeeded = fillTypeItem.usagePerMonth / fillTypeItem.literPerSqm / 10000;
			end
		
			table.insert(fillTypeResultTable, fillTypeItem)
		end
	end
	
	table.sort(fillTypeResultTable, compFillTypeResultTable)
	
	ProductionInfoHud.fillTypeResultTable = fillTypeResultTable;
end

function compFillTypeResultTable(w1,w2)
	-- Zum Sortieren der Ausgabeliste nach Zeit
	if w1.fillTypeTitle == w2.fillTypeTitle and w1.fillTypeId < w2.fillTypeId then
		return true
	end
	if w1.fillTypeTitle < w2.fillTypeTitle then
		return true
	end
end
		
function ProductionInfoHud:refreshProductionsTable()
		
		local farmId = g_currentMission.player.farmId;
		local myProductions = {}
		
		if g_currentMission.productionChainManager.farmIds[farmId] ~= nil and g_currentMission.productionChainManager.farmIds[farmId].productionPoints ~= nil then
			for _, productionPoint in pairs(g_currentMission.productionChainManager.farmIds[farmId].productionPoints) do
				
				if productionPoint.hiddenOnUI ~= nil and productionPoint.hiddenOnUI == true then
					goto ignoreProduction
				end
			
				-- hidden stuff from revamp production script
				for i = 1, #productionPoint.activeProductions do
					local activeProduction = productionPoint.activeProductions[i];
					
					if activeProduction.hideComplete ~= nil and activeProduction.hideComplete == true then
						goto ignoreProduction
					end
				end
				
				-- nicht mix zutaten werden hier summiert
				for fillTypeId, fillLevel in pairs(productionPoint.storage.fillLevels) do
					local fillType = g_currentMission.fillTypeManager.fillTypes[fillTypeId];
					
					local ignoreInput = false;
					if productionPoint.inputFillTypeIdsIgnorePih ~= nil and productionPoint.inputFillTypeIdsIgnorePih[fillTypeId] ~= nil then
						ignoreInput = productionPoint.inputFillTypeIdsIgnorePih[fillTypeId];
					end
					
					local productionItem = {}
					productionItem.name = productionPoint.owningPlaceable:getName();
					productionItem.fillTypeId = fillTypeId
					productionItem.needPerHour = 0
					productionItem.hoursLeft = 0
					productionItem.fillLevel = fillLevel
					productionItem.capacity = productionPoint.storage.capacities[fillTypeId]
					productionItem.isInput = false;
					productionItem.isOutput = false;
					productionItem.timeAdjustment = 1;
					productionItem.productionPoint = productionPoint;
					
					-- prüfen ob input type
					if productionPoint.inputFillTypeIds[fillTypeId] ~= nil then
						productionItem.isInput = productionPoint.inputFillTypeIds[fillTypeId];
					end
					-- prüfen ob output type
					if productionPoint.outputFillTypeIds[fillTypeId] ~= nil then
						productionItem.isOutput = productionPoint.outputFillTypeIds[fillTypeId];
					end
					
					if productionItem.capacity == 0 then 
						productionItem.capacityLevel = 0
					elseif productionItem.capacity == nil then
						productionItem.capacityLevel = 0
					else
						productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
					end
					productionItem.fillTypeTitle = fillType.title;
					
					for _, production in pairs(productionPoint.activeProductions) do
						for _, input in pairs(production.inputs) do
							-- status 3 = läuft nicht weil ausgang voll
							if input.type == fillTypeId then
								productionItem.isInput = true;
								if input.mix == nil or input.mix == 0 then 
									-- nicht mix type
									if production.status ~= 3 then
										productionItem.needPerHour = productionItem.needPerHour + (production.cyclesPerHour * input.amount)
									end
								else
									-- mix type hier ignorieren. müssen separat gerechnet werden
								end
							end
						end
						if production.activeHours ~= nil then
							productionItem.timeAdjustment = productionItem.timeAdjustment * (production.activeHours / 24)
						end
					end
					
					

					if (productionItem.fillLevel ~= 0) and (productionItem.needPerHour ~= 0) then
						-- hier die anzahl der Tage pro Monat berücksichtigen
						productionItem.hoursLeft = productionItem.fillLevel / productionItem.needPerHour * g_currentMission.environment.daysPerPeriod;
					end
					
					if (not ignoreInput and productionItem.needPerHour > 0 and not productionItem.isOutput) then 
						table.insert(myProductions, productionItem)
					end
					
					-- Ausgangslager voll, dann speziell eintragen
					if (productionItem.capacityLevel >= 0.95 and productionItem.isOutput) then 
						-- prüfen ob output einer aktivierten produktion, nicht einer aktiven, soll ja angezeigt werden, wenn die Produktion eingeschaltet ist, aber auch wenn sie nicht läuft weil ganz voll
						local oneProductionWithOutputActive = false;
						for _, production in pairs(productionPoint.productions) do
							for _, output in pairs(production.outputs) do
								if output.type == fillTypeId and production.status ~= ProductionPoint.PROD_STATUS.INACTIVE then
									oneProductionWithOutputActive = true;
								end
							end
						end
						
						if oneProductionWithOutputActive then
							if productionItem.capacityLevel >= 0.99 then
								productionItem.hoursLeft = -2;
							else
								productionItem.hoursLeft = -1;
							end
							table.insert(myProductions, productionItem)
						end
					end
				end
				
				-- jetzt noch mal alle mix gruppen die restlaufzeit aller berechnen
				for _, production in pairs(productionPoint.activeProductions) do
					for n = 1, 5 do
						local productionItem = {}
						productionItem.name = productionPoint.owningPlaceable:getName();
						productionItem.fillTypeTitle = production.name .. " (Mix " .. n .. ")";
						productionItem.hoursLeft = 0
						productionItem.timeAdjustment = 1;
						productionItem.productionPoint = productionPoint;
						productionItem.isInput = true;
						if production.activeHours ~= nil then
							productionItem.timeAdjustment = productionItem.timeAdjustment * (production.activeHours / 24)
						end
						
						local needed = false;
						
						for _, input in pairs(production.inputs) do
							-- status 3 = läuft nicht weil ausgang voll
							if input.mix == n then 
					
								local ignoreInput = false;
								if productionPoint.inputFillTypeIdsIgnorePih ~= nil and productionPoint.inputFillTypeIdsIgnorePih[input.type] ~= nil then
									ignoreInput = productionPoint.inputFillTypeIdsIgnorePih[input.type];
								end
								
								-- richtiger mix type
								if production.status ~= 3 then
									-- wie lange läuft dieser mix mit dem input type aufrechnen.
									needed = true;
									local fillLevel = productionPoint:getFillLevel(input.type);
									local needPerHour = (production.cyclesPerHour * input.amount);
									local hoursLeft = fillLevel / needPerHour * g_currentMission.environment.daysPerPeriod;
									productionItem.hoursLeft = productionItem.hoursLeft + hoursLeft;
								end
							end
						end
						
						if needed then
							table.insert(myProductions, productionItem)
						end
					end
					
					if ProductionInfoHud.settings["display"]["showBooster"] then
						-- jeden booster separat
						for _, input in pairs(production.inputs) do
							-- status 3 = läuft nicht weil ausgang voll
							if input.mix == 6 then 
					
								local ignoreInput = false;
								if productionPoint.inputFillTypeIdsIgnorePih ~= nil and productionPoint.inputFillTypeIdsIgnorePih[input.type] ~= nil then
									ignoreInput = productionPoint.inputFillTypeIdsIgnorePih[input.type];
								end
								
								-- richtiger mix type
								if production.status ~= 3 and not ignoreInput then
									-- wie lange läuft dieser booster?
									local productionItem = {}
									productionItem.name = productionPoint.owningPlaceable:getName();
									productionItem.fillTypeTitle = production.name .. " (booster " .. g_currentMission.fillTypeManager.fillTypes[input.type].title .. ")";
									productionItem.capacity = productionPoint.storage.capacities[input.type]
									productionItem.fillLevel = productionPoint:getFillLevel(input.type);
									productionItem.timeAdjustment = 1;
									productionItem.productionPoint = productionPoint;
									
									if productionItem.capacity == 0 then 
										productionItem.capacityLevel = 0
									elseif productionItem.capacity == nil then
										productionItem.capacityLevel = 0
										print("Error: No storage for '" .. g_currentMission.fillTypeManager.fillTypes[input.type].name .. "' in productionPoint but defined to used. Has to be fixed in '" .. productionPoint.owningPlaceable.customEnvironment .."'.")
									else
										productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
									end
									
									-- mit cyclesPerMonth rechnen, da diese durch die Stundenweise öffnung in Revamp korrigiert wird.
									local needPerHour = (production.cyclesPerHour * input.amount);
									if production.activeHours ~= nil then
										productionItem.timeAdjustment = productionItem.timeAdjustment * (production.activeHours / 24)
									end
									productionItem.hoursLeft = productionItem.fillLevel / needPerHour * g_currentMission.environment.daysPerPeriod;
									
									if (needPerHour > 0) then 
										table.insert(myProductions, productionItem)
									end
								end
							end
						end
					end
				end
				
				::ignoreProduction::
			end
		end
		
		-- Tiere
		for _, placeable in pairs(g_currentMission.husbandrySystem.placeables) do
			if placeable.ownerFarmId == farmId and placeable.spec_husbandryFood.litersPerHour ~= 0 then
				-- Futter der Tiere als gesamtes pro Stall
				local animalFood = g_currentMission.animalFoodSystem:getAnimalFood(placeable.spec_husbandryFood.animalTypeIndex)
				if animalFood.consumptionType == AnimalFoodSystem.FOOD_CONSUME_TYPE_SERIAL then
					local productionItem = {}
					productionItem.name = placeable:getName();
					productionItem.needPerHour = placeable.spec_husbandryFood.litersPerHour;
					productionItem.hoursLeft = 0
					productionItem.fillLevel = placeable:getTotalFood();
					productionItem.capacity = placeable:getFoodCapacity();
					productionItem.isInput = true;
					
					if productionItem.capacity == 0 then 
						productionItem.capacityLevel = 0
					elseif productionItem.capacity == nil then
						productionItem.capacityLevel = 0
						print("Error: No storage for '" .. g_currentMission.fillTypeManager.fillTypes[fillTypeId].name .. "' in productionPoint but defined to used. Has to be fixed in '" .. productionPoint.owningPlaceable.customEnvironment .."'.")
					else
						productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
					end
					productionItem.fillTypeTitle = placeable.spec_husbandryFood.info.title;

					if (productionItem.fillLevel ~= 0) and (productionItem.needPerHour ~= 0) then
						-- hier die anzahl der Tage pro Monat berücksichtigen
						productionItem.hoursLeft = productionItem.fillLevel / productionItem.needPerHour * g_currentMission.environment.daysPerPeriod;
					end
						
					if (productionItem.needPerHour > 0) then 
						table.insert(myProductions, productionItem)
					end
				elseif animalFood.consumptionType == AnimalFoodSystem.FOOD_CONSUME_TYPE_PARALLEL then
					-- parallele Fütterung pro item berechnen
					local needPerHourTotal = placeable.spec_husbandryFood.litersPerHour;
					local capacityTotal = placeable:getFoodCapacity();
					
					-- wie lange hält jede FoodGroup?
					local groupItems = {}
					for _, foodGroup in pairs(animalFood.groups) do
					
						local productionItem = {}
						productionItem.name = placeable:getName();
						productionItem.fillLevel = g_currentMission.animalFoodSystem:getTotalFillLevelInGroup(foodGroup, placeable.spec_husbandryFood.fillLevels)
						productionItem.needPerHour = needPerHourTotal * foodGroup.eatWeight
						productionItem.hoursLeft = 0
						productionItem.capacity = capacityTotal * foodGroup.eatWeight
						productionItem.isInput = true;
					
						if productionItem.capacity == 0 then 
							productionItem.capacityLevel = 0
						elseif productionItem.capacity == nil then
							productionItem.capacityLevel = 0
							print("Error: No storage for '" .. g_currentMission.fillTypeManager.fillTypes[fillTypeId].name .. "' in productionPoint but defined to used. Has to be fixed in '" .. productionPoint.owningPlaceable.customEnvironment .."'.")
						else
							productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
						end
						productionItem.fillTypeTitle = foodGroup.title;

						if (productionItem.fillLevel ~= 0) and (productionItem.needPerHour ~= 0) then
							-- hier die anzahl der Tage pro Monat berücksichtigen
							productionItem.hoursLeft = productionItem.fillLevel / productionItem.needPerHour * g_currentMission.environment.daysPerPeriod;
						end
						
							
						if (productionItem.needPerHour > 0) then 
							productionItem.timeInMinutes = Utils.formatTime(productionItem.hoursLeft * 60)
							table.insert(groupItems, productionItem)
						end
					end
					
					-- Wenn alle gleich sind nur ein eintrag machen
					local allSame = nil;
					local fillLevelTotal = 0;
					local capacityTotal = 0;
					local compareValue = nil;
					for _, item in pairs(groupItems) do
						if compareValue == nil then
							compareValue = item.timeInMinutes
							allSame = true;
							fillLevelTotal = item.fillLevel;
							capacityTotal = item.capacity;
						else
							if compareValue ~= item.timeInMinutes then
								allSame = false;
							end
							fillLevelTotal = fillLevelTotal + item.fillLevel;
							capacityTotal = capacityTotal + item.capacity;
						end
					end
					
					if allSame ~= nil then
						if  allSame then
							local productionItem = groupItems[1]
							productionItem.fillTypeTitle = placeable.spec_husbandryFood.info.title;
							productionItem.capacity = capacityTotal;
							productionItem.fillLevel = fillLevelTotal;
							table.insert(myProductions, productionItem)
						else
							for _, item in pairs(groupItems) do
								table.insert(myProductions, item)
							end
						end
					end


				end
					
				
				-- Fütterungsroboter vorhanden, dann anders die werte berechnen
				if placeable.spec_husbandryFeedingRobot ~= nil and placeable.spec_husbandryFeedingRobot.feedingRobot ~= nil then
					local feedingRobot = placeable.spec_husbandryFeedingRobot.feedingRobot;
					local recipe = feedingRobot.robot.recipe;
					
					-- Jede zutat der Rezeptes durchlaufen und dann ausrechnen wie lange das hält
					for _, ingredient in pairs(recipe.ingredients) do
						local fillLevel = 0

						for _, fillType in ipairs(ingredient.fillTypes) do
							fillLevel = fillLevel + feedingRobot:getFillLevel(fillType)
						end
						
						local producableWithThisIngredient = fillLevel / ingredient.ratio;
						local hoursLeft = producableWithThisIngredient / placeable.spec_husbandryFood.litersPerHour * g_currentMission.environment.daysPerPeriod;
						
						local spot = feedingRobot.fillTypeToUnloadingSpot[ingredient.fillTypes[1]]

						local productionItem = {}
						productionItem.name = placeable:getName();
						productionItem.needPerHour = 0;
						productionItem.hoursLeft = hoursLeft
						productionItem.fillLevel = fillLevel;
						productionItem.capacity = spot.capacity;
						productionItem.isInput = true;
						
						if productionItem.capacity == 0 then 
							productionItem.capacityLevel = 0
						elseif productionItem.capacity == nil then
							productionItem.capacityLevel = 0
						else
							productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
						end
						
						productionItem.fillTypeTitle = ingredient.title .. " (Robot)";
						
						if (placeable.spec_husbandryFood.litersPerHour > 0) then 
							table.insert(myProductions, productionItem)
						end
					end
					
				end
				
				-- Anpassungen Rodberaht Anfang
				
				-- Wasser
				if placeable.spec_husbandryWater ~= nil then
					if not placeable.spec_husbandryWater.automaticWaterSupply then
						local productionItem = {}
						productionItem.name = placeable:getName();
						-- productionItem.fillTypeId = fillTypeId
						productionItem.needPerHour = placeable.spec_husbandryWater.litersPerHour;
						productionItem.hoursLeft = 0
						productionItem.fillLevel = placeable.spec_husbandryWater:getHusbandryFillLevel(FillType.WATER)
						productionItem.capacity = placeable.spec_husbandryWater:getHusbandryCapacity(FillType.WATER)
						productionItem.isInput = true;

						if productionItem.capacity == 0 then 
							productionItem.capacityLevel = 0
						elseif productionItem.capacity == nil then
							productionItem.capacityLevel = 0
							print("Error: No storage for '" .. g_currentMission.fillTypeManager.fillTypes[fillTypeId].name .. "' in productionPoint but defined to used. Has to be fixed in '" .. productionPoint.owningPlaceable.customEnvironment .."'.")
						else
							productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
						end
						productionItem.fillTypeTitle = placeable.spec_husbandryWater.info.title;

						if (productionItem.fillLevel ~= 0) and (productionItem.needPerHour ~= 0) then
							-- hier die anzahl der Tage pro Monat berücksichtigen
							productionItem.hoursLeft = productionItem.fillLevel / productionItem.needPerHour * g_currentMission.environment.daysPerPeriod;
						end
							
						if (productionItem.needPerHour > 0) then 
							table.insert(myProductions, productionItem)
						end
					end
				end
								
				-- Stroh
				if placeable.spec_husbandryStraw ~= nil then
					local productionItem = {}
					productionItem.name = placeable:getName();
					-- productionItem.fillTypeId = fillTypeId
					productionItem.needPerHour = placeable.spec_husbandryStraw.inputLitersPerHour;
					productionItem.hoursLeft = 0
					productionItem.fillLevel = placeable.spec_husbandryStraw:getHusbandryFillLevel(FillType.STRAW)
					productionItem.capacity = placeable.spec_husbandryStraw:getHusbandryCapacity(FillType.STRAW)
					productionItem.isInput = true;
					
					if productionItem.capacity == 0 then 
						productionItem.capacityLevel = 0
					elseif productionItem.capacity == nil then
						productionItem.capacityLevel = 0
						print("Error: No storage for '" .. g_currentMission.fillTypeManager.fillTypes[fillTypeId].name .. "' in productionPoint but defined to used. Has to be fixed in '" .. productionPoint.owningPlaceable.customEnvironment .."'.")
					else
						productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
					end
					productionItem.fillTypeTitle = placeable.spec_husbandryStraw.info.title;

					if (productionItem.fillLevel ~= 0) and (productionItem.needPerHour ~= 0) then
						-- hier die anzahl der Tage pro Monat berücksichtigen
						productionItem.hoursLeft = productionItem.fillLevel / productionItem.needPerHour * g_currentMission.environment.daysPerPeriod;
					end
						
					if (productionItem.needPerHour > 0) then 
						table.insert(myProductions, productionItem)
					end
				end	
				
				-- Mistlager
				if placeable.spec_husbandryStraw ~= nil then
					local productionItem = {}
					productionItem.name = placeable:getName();
					-- productionItem.fillTypeId = fillTypeId
					productionItem.needPerHour = 0;
					productionItem.hoursLeft = 0
					productionItem.fillLevel = placeable.spec_husbandryStraw:getHusbandryFillLevel(FillType.MANURE)
					productionItem.capacity = placeable.spec_husbandryStraw:getHusbandryCapacity(FillType.MANURE)
					productionItem.isInput = false;
					
					if productionItem.capacity == 0 then 
						productionItem.capacityLevel = 0
					elseif productionItem.capacity == nil then
						productionItem.capacityLevel = 0
					else
						productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
					end
					productionItem.fillTypeTitle = g_i18n:getText("fillType_manure");

					-- Ausgangslager voll, dann speziell eintragen
					if (productionItem.capacityLevel >= 0.95) then 
						
						-- if oneProductionWithOutputActive then
							if productionItem.capacityLevel >= 0.99 then
								productionItem.hoursLeft = -2;
							else
								productionItem.hoursLeft = -1;
							end
							table.insert(myProductions, productionItem)
						-- end
					end
				end

				-- Milch
				if placeable.spec_husbandryMilk ~= nil then
					local productionItem = {}
					productionItem.name = placeable:getName();
					-- productionItem.fillTypeId = fillTypeId
					productionItem.needPerHour = 0;
					productionItem.hoursLeft = 0
					productionItem.fillLevel = placeable.spec_husbandryMilk:getHusbandryFillLevel(FillType.MILK)
					productionItem.capacity = placeable.spec_husbandryMilk:getHusbandryCapacity(FillType.MILK)
					productionItem.isInput = false;
					
					if productionItem.capacity == 0 then 
						productionItem.capacityLevel = 0
					elseif productionItem.capacity == nil then
						productionItem.capacityLevel = 0
						print("Error: No storage for '" .. g_currentMission.fillTypeManager.fillTypes[fillTypeId].name .. "' in productionPoint but defined to used. Has to be fixed in '" .. productionPoint.owningPlaceable.customEnvironment .."'.")
					else
						productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
					end
					productionItem.fillTypeTitle = placeable.spec_husbandryMilk.info.title;

					-- Ausgangslager voll, dann speziell eintragen
					if (productionItem.capacityLevel >= 0.95 and not productionItem.isInput) then 
						productionItem.hoursLeft = -2;
						table.insert(myProductions, productionItem)
					end
				end
				-- Anpassungen Rodberaht Ende

				if placeable.spec_husbandryLiquidManure ~= nil then
					local productionItem = {}
					productionItem.name = placeable:getName();
					-- productionItem.fillTypeId = fillTypeId
					productionItem.needPerHour = 0;
					productionItem.hoursLeft = 0
					productionItem.fillLevel = placeable.spec_husbandryLiquidManure:getHusbandryFillLevel(FillType.LIQUIDMANURE)
					productionItem.capacity = placeable.spec_husbandryLiquidManure:getHusbandryCapacity(FillType.LIQUIDMANURE)
					productionItem.isInput = false;
					
					if productionItem.capacity == 0 then 
						productionItem.capacityLevel = 0
					elseif productionItem.capacity == nil then
						productionItem.capacityLevel = 0
						print("Error: No storage for '" .. g_currentMission.fillTypeManager.fillTypes[fillTypeId].name .. "' in productionPoint but defined to used. Has to be fixed in '" .. productionPoint.owningPlaceable.customEnvironment .."'.")
					else
						productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
					end
					productionItem.fillTypeTitle = placeable.spec_husbandryLiquidManure.info.title;

					-- Ausgangslager voll, dann speziell eintragen
					if (productionItem.capacityLevel >= 0.95 and not productionItem.isInput) then 
						productionItem.hoursLeft = -2;
						table.insert(myProductions, productionItem)
					end
				end
				
				-- Tiere voll, also muss was verkauft werden
				if ProductionInfoHud.settings["display"]["showFullAnimals"] then
					-- true, wenn überbelegung zugelassen ist und somit zeigen wir voll nicht mehr an
					local added = false;
					
					-- mit eas überbelegung anders auslesen und das gleiche anzeigen
					local husbandrySpec = placeable.spec_husbandryAnimals
					if husbandrySpec ~= nil and husbandrySpec.allowOvercrowding == true then
						added = true
						local totalNumAnimals = husbandrySpec:getNumOfAnimals()
						if husbandrySpec.maxNumAnimals < totalNumAnimals then
							local productionItem = {}
							productionItem.name = placeable:getName();
							-- productionItem.fillTypeId = fillTypeId
							productionItem.needPerHour = 0;
							productionItem.hoursLeft = 0
							productionItem.fillLevel = 0;
							productionItem.capacity = 0;
							productionItem.isInput = false;
							if (placeable.spec_husbandryPallets ~= nil) then
								productionItem.fillTypeTitle =  placeable.spec_husbandryPallets.animalTypeName
							else
								productionItem.fillTypeTitle = g_i18n:getText("helpLine_Animals") 
							end

							if placeable.eas_numOvercrowdingHours ~= nil and FS22_EnhancedAnimalSystem ~= nil and FS22_EnhancedAnimalSystem.EnhancedAnimalSystem ~= nil and FS22_EnhancedAnimalSystem.EnhancedAnimalSystem.Settings ~= nil and FS22_EnhancedAnimalSystem.EnhancedAnimalSystem.Settings.NumHoursOfOvercrowdingBeforReduceHealth ~= nil then
								productionItem.hoursLeft = FS22_EnhancedAnimalSystem.EnhancedAnimalSystem.Settings.NumHoursOfOvercrowdingBeforReduceHealth - placeable.eas_numOvercrowdingHours;
								if productionItem.hoursLeft < 1 then
									productionItem.hoursLeft = -3
								else
									productionItem.fillTypeTitle = productionItem.fillTypeTitle .. "(" .. g_i18n:getText("Overcrowded") .. ")"
								end
							else
								productionItem.hoursLeft = -3;
							end
							productionItem.capacityLevel = 0;
							table.insert(myProductions, productionItem)
							added = true
						end
					end
					
					-- hier das normale einfach nur voll sein
					if placeable:getNumOfFreeAnimalSlots() == 0 and added == false then
						local productionItem = {}
						productionItem.name = placeable:getName();
						productionItem.needPerHour = 0;
						productionItem.hoursLeft = 0
						productionItem.fillLevel = 0;
						productionItem.capacity = 0;
						productionItem.isInput = false;
						if (placeable.spec_husbandryPallets ~= nil) then
							productionItem.fillTypeTitle =  placeable.spec_husbandryPallets.animalTypeName
						else
							productionItem.fillTypeTitle = g_i18n:getText("helpLine_Animals") 
						end
						productionItem.capacityLevel = 0;
						productionItem.hoursLeft = -2;
						table.insert(myProductions, productionItem)
					end
				end
			end
		end

		table.sort(myProductions, compPrductionTable)
		
		ProductionInfoHud.productionDataSorted = myProductions;
end

function ProductionInfoHud:refreshSellPriceData()
	if FS22_SellPriceTrigger == nil then return end;
	if FS22_SellPriceTrigger.SellPriceTrigger == nil then return end;
	if FS22_SellPriceTrigger.SellPriceTrigger.triggers == nil then return end;

	local farmId = g_currentMission:getFarmId();
	local prices = {};

	-- liste füllen mit den types, die gerade einen guten preis haben
	for fillType,trigger in pairs(FS22_SellPriceTrigger.SellPriceTrigger.triggers) do
		for triggerFarmId,farmTrigger in pairs(trigger.farms) do
			if triggerFarmId == farmId and farmTrigger.over == true then
				prices[fillType] = {info=farmTrigger,storages={},total=0, station=trigger.station}
			end
		end
	end

	if g_currentMission.productionChainManager.farmIds[farmId] ~= nil and g_currentMission.productionChainManager.farmIds[farmId].productionPoints ~= nil then
		for _, productionPoint in pairs(g_currentMission.productionChainManager.farmIds[farmId].productionPoints) do
			
			local storageName = productionPoint.owningPlaceable:getName();
			for fillType, fillLevel in pairs(productionPoint.storage.fillLevels) do
			
				local isOutput = false
				-- prüfen ob input type
				if productionPoint.outputFillTypeIds[fillType] ~= nil then
					isOutput = productionPoint.outputFillTypeIds[fillType];
				end
				
				if prices[fillType] ~= nil and isOutput then
					if prices[fillType].storages[storageName] ~= nil then
						prices[fillType].storages[storageName].fillLevel=prices[fillType].storages[storageName].fillLevel + fillLevel;
					else
						-- filltype hinzufügen zu storage name, damit die mengen aus dem lager nicht addiert werden
						prices[fillType].storages[storageName] = {fillLevel=fillLevel, GuiName = storageName, indexName = storageName .. fillType}
					end
					prices[fillType].total = prices[fillType].total + fillLevel;
				end
			end
		end
	end
	
	-- storageSystem benutzen. Storages splitten sich auf, wenn diese zu nah zusammen stehen, aber das ist in LS so und ich kann das nicht ändern.
	local usedStorages = {};
	local storages = g_currentMission.storageSystem:getStorages();
	for i, storage in pairs (storages) do
	
		local storageName = "";
		if usedStorages[storage] == nil and storage:getOwnerFarmId() == farmId then
			usedStorages[storage] = true;
		
			local currentUnloadingStation = nil;
			for j, unloadingStation in pairs (storage.unloadingStations) do
				if storageName ~= "" then 
					storageName = storageName .. "-" 
				end
				storageName = storageName .. unloadingStation:getName();
				currentUnloadingStation = unloadingStation;
			end
		
			for fillType, fillLevel in pairs(storage.fillLevels) do
				
				-- bestimmte sachen überspringen
				local skipThis = false;
				if currentUnloadingStation ~= nil and currentUnloadingStation.owningPlaceable.spec_husbandryStraw ~= nil and fillType == FillType.STRAW then
					skipThis = true;
				end
			
				if prices[fillType] ~= nil and not skipThis then
					if prices[fillType].storages[storageName] ~= nil then
						prices[fillType].storages[storageName].fillLevel=prices[fillType].storages[storageName].fillLevel + fillLevel;
					else
						-- filltype hinzufügen zu storage name, damit die mengen aus dem lager nicht addiert werden
						prices[fillType].storages[storageName] = {fillLevel=fillLevel, GuiName = storageName, indexName = storageName .. fillType}
					end
					prices[fillType].total = prices[fillType].total + fillLevel;
				end
			end
		
		end
	end
	
	-- List für Anzeige erstellen
	local sortableOutputTable = {};
	for fillTypeId, sellPriceItem in pairs (prices) do
		for b, sellPriceStorage in pairs (sellPriceItem.storages) do
			local outputItem = {};
			outputItem.station = sellPriceItem.station;
			outputItem.title = g_currentMission.fillTypeManager.fillTypes[fillTypeId].title
			outputItem.fillLevel = sellPriceStorage.fillLevel;
			outputItem.GuiName = sellPriceStorage.GuiName;
			outputItem.indexName = sellPriceStorage.indexName;
			-- can be nil because sellprice trigger not nice
			if outputItem.station ~= nil then 
				table.insert(sortableOutputTable , outputItem)
			end
		end
	end
	
	-- gesamtmenge für station und GuiName berechnen, wenn die Menge selbst nicht 0 ist
	for a, outputItem in pairs (sortableOutputTable) do
		outputItem.totalAmount = 0;
		if(outputItem.fillLevel ~= 0) then
			for b, innerItem in pairs (ProductionInfoHud.sellPriceDataSorted) do
				local sourceLocationEqual = outputItem.indexName == innerItem.indexName;
				if string.find(outputItem.indexName, "Lagerhalle_Zentral") and string.find(innerItem.indexName, "Lagerhalle_Zentral") then
					sourceLocationEqual = true;
				end
				if outputItem.station == innerItem.station and sourceLocationEqual then
					outputItem.totalAmount = outputItem.totalAmount + innerItem.fillLevel;
				end
			end
		end
	end

	table.sort(sortableOutputTable,compSellingTable)

	ProductionInfoHud.sellPriceDataSorted = sortableOutputTable;
end;

function compSellingTable(w1,w2)
	-- Zum Sortieren der Ausgabeliste nach Zeit
	if w1.station == w2.station and w1.GuiName < w2.GuiName then
		return true
	end
	if w1.station < w2.station then
		return true
	end
end

function compPrductionTable(w1,w2)
	-- Zum Sortieren der Ausgabeliste nach Zeit
	if w1.hoursLeft == w2.hoursLeft and w1.name < w2.name then
		return true
	end
	if w1.hoursLeft < w2.hoursLeft then
		return true
	end
end

function ProductionInfoHud:draw()
		
	if not ProductionInfoHud.isClient then return end	
	
	if ProductionInfoHud.productionDataSorted == nil then return end
	
	if ProductionInfoHud.settings["display"]["showType"] == "NONE" then 
		return
	end
	
	local lineCount = 0;
	local maxLines = tonumber(ProductionInfoHud.PossibleMaxLines[ProductionInfoHud.settings["display"]["maxLines"]]);
	local additionalLines = 0;
	local productionOutputTable = {}
	local inputHelpDisplay = g_currentMission.hud.inputHelp;
	local posX, posY = inputHelpDisplay.getBackgroundPosition()
	local textSize = tonumber(ProductionInfoHud.PossibleTextSizes[ProductionInfoHud.settings["display"]["textSize"]])/1000;
	local totalTextHeigh = 0;
	local maxTextWidth = 0;
	local spaceY = 0.01;
	
	-- 1-"TopCenter", 2-"BelowHelp", 3-"BelowVehicleInspector"
	-- Startpunkt setzen anhand der Einstellungen
	if ProductionInfoHud.settings["display"]["position"] == 2 or (ProductionInfoHud.settings["display"]["position"] == 3 and g_currentMission.vehicleInspector ~= nil and not g_currentMission.vehicleInspector:getVisible()) then
		if (g_currentMission.hud.inputHelp.overlay.visible == true) then
			-- move under Help Dialog, when help visible or when VI is selected and not visible
			posX = posX + inputHelpDisplay.entryOffsetX;
			posY = g_currentMission.hud.inputHelp.overlay.y - 0.04;
		else
			posX = posX + inputHelpDisplay.entryOffsetX;
		
			-- fix for Precision Farming
			posY = posY + inputHelpDisplay.frameOffsetY
			for _, extension in pairs(inputHelpDisplay.vehicleHudExtensions) do
				local extHeight = extension:getDisplayHeight()
				if extension:canDraw() and extension.variableWorkWidth == nil and extension.mixerWagon == nil and extHeight ~= 0 then
					posY = posY - extHeight - inputHelpDisplay.entryOffsetY
				end
			end

		end
	elseif ProductionInfoHud.settings["display"]["position"] == 3 and g_currentMission.vehicleInspector ~= nil and  g_currentMission.vehicleInspector:getVisible() then
		local viPosition = g_currentMission.vehicleInspector:getPosition()
		
		posX = viPosition.x + inputHelpDisplay.entryOffsetX;
		posY = viPosition.y - g_currentMission.vehicleInspector.global.height[g_currentMission.vehicleInspector.global.viewModus]-0.005;
	elseif ProductionInfoHud.settings["display"]["position"] == 1 then
		posX = 0.413;
		posY = 0.97;
	end
	
	local posYStart = posY;

	if ProductionInfoHud.productionDataSorted ~= nil and (ProductionInfoHud.settings["display"]["showType"] == "ALL" or string.find(ProductionInfoHud.settings["display"]["showType"], "PRODUCTION")) then 
		for _, productionData in pairs(ProductionInfoHud.productionDataSorted) do
			-- new place to filter the data
			local skip = false
			if productionData.capacityLevel ~= nil and productionData.capacityLevel > 0.5 and productionData.isInput == true and productionData.isOutput == false then
				skip = true;
			end
			if productionData.hoursLeft ~= nil then
				local compareValue = 48 * g_currentMission.environment.daysPerPeriod;
				if productionData.timeAdjustment ~= nil then
					compareValue = compareValue * productionData.timeAdjustment
				end
				if productionData.hoursLeft > compareValue then
					skip = true;
				end
			end
			
			if (lineCount < maxLines and not skip) then
				if (lineCount == 0) then
					posY = posY - textSize;
					setTextAlignment(RenderText.ALIGN_LEFT);
					setTextColor(1,1,1,1);		
					setTextBold(true);
					renderText(posX,posY,textSize,"ProductionInfo: ");
					totalTextHeigh = totalTextHeigh + getTextHeight(textSize, "ProductionInfo: ")	
					setTextBold(false);
				end
				
				lineCount = lineCount + 1;
			
				local productionOutputItem = {}
				productionOutputItem.productionPointName = productionData.name
				productionOutputItem.fillTypeTitle = productionData.fillTypeTitle
				productionOutputItem.TextColor = ProductionInfoHud.colors.WHITE;
				
				if productionData.hoursLeft == -3 then
					productionOutputItem.TimeLeftString = g_i18n:getText("Overcrowded");
					productionOutputItem.TextColor = ProductionInfoHud.colors.RED;
				elseif productionData.hoursLeft == -2 then
					productionOutputItem.TimeLeftString = g_i18n:getText("Full");
					productionOutputItem.TextColor = ProductionInfoHud.colors.RED;
				elseif productionData.hoursLeft == -1 then
					productionOutputItem.TimeLeftString = g_i18n:getText("NearlyFull");
					productionOutputItem.TextColor = ProductionInfoHud.colors.ORANGE;
				elseif productionData.hoursLeft == 0 then
					productionOutputItem.TimeLeftString = g_i18n:getText("Empty");
					productionOutputItem.TextColor = ProductionInfoHud.colors.ORANGE;
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
						productionOutputItem.TextColor = ProductionInfoHud.colors.YELLOW;
					end
					timeString = timeString .. hours .. ":" .. minutes;
					productionOutputItem.TimeLeftString = timeString;
				end
				table.insert(productionOutputTable, productionOutputItem)
			else
				if not skip then
					additionalLines = additionalLines + 1;
				end
			end
		end
			
		for _, productionOutputItem in pairs(productionOutputTable) do
			posY = posY - textSize;
							
			local textLine = (productionOutputItem.productionPointName .. " - " .. productionOutputItem.fillTypeTitle .. " - " .. productionOutputItem.TimeLeftString);
			totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
			local textWidth = getTextWidth(textSize, textLine);
			if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
			
			-- farben von oben benutzen
			setTextAlignment(RenderText.ALIGN_LEFT);
			setTextColor(unpack(productionOutputItem.TextColor));								
			setTextBold(false);
			renderText(posX,posY,textSize,textLine);
		end
			
		if (additionalLines > 0) then
			posY = posY - textSize;
			local textLine = (additionalLines .. "  " .. g_i18n:getText("MoreAvailable"));
			setTextAlignment(RenderText.ALIGN_LEFT);
			setTextColor(1,1,1,1);								
			setTextBold(false);
			totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
			local textWidth = getTextWidth(textSize, textLine);
			if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
			renderText(posX,posY,textSize,textLine);
		end
				
		if (lineCount == 0) then
			posY = posY - textSize;
			local textLine = g_i18n:getText("AllProductsOperativ");
			setTextAlignment(RenderText.ALIGN_LEFT);
			setTextColor(1,1,1,1);								
			setTextBold(false);
			totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
			local textWidth = getTextWidth(textSize, textLine);
			if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
			renderText(posX,posY,textSize,textLine);
		end
	
		-- overlay für produktionen
		setOverlayColor(ProductionInfoHud.overlay.overlayId, 0, 0, 0, 0.7);
		setOverlayUVs(ProductionInfoHud.overlay.overlayId, 0.0078125,0.990234375, 0.0078125,0.9921875, 0.009765625,0.990234375, 0.009765625,0.9921875);
		ProductionInfoHud.overlay:setPosition(posX-0.001, posYStart - totalTextHeigh - 0.002);
		ProductionInfoHud.overlay:setDimension(maxTextWidth+0.002, totalTextHeigh);
		ProductionInfoHud.overlay:render();
		
		-- make a space between the sale list and the production list
		posYStart = posY - spaceY;
		posY = posY - spaceY;
	end

	-- daten für nächsten overlay zurücksetzen
	totalTextHeigh = 0;
	maxTextWidth = 0;
	local maxSellPriceLines = tonumber(ProductionInfoHud.PossibleMaxLines[ProductionInfoHud.settings["display"]["maxSellingLines"]]);
	local minSellAmount = tonumber(ProductionInfoHud.PossibleAmounts[ProductionInfoHud.settings["display"]["minSellAmount"]]);
	local totalCountSellPrices = 0;
	local lineCountSellPrices = 0;
	additionalCounter = 0;
	if ProductionInfoHud.sellPriceTriggerAvailable and (ProductionInfoHud.settings["display"]["showType"] == "ALL" or string.find(ProductionInfoHud.settings["display"]["showType"], "SELLPRICE")) then
		local lastTextPart1;
		local lastTextPart1Width;
		local lastTextPart2;
		local lastTextPart2Width;
		
		for a, outputItem in pairs (ProductionInfoHud.sellPriceDataSorted) do
			if outputItem.totalAmount >= minSellAmount then
				if (lineCountSellPrices == 0) then
					posY = posY - textSize;
					setTextAlignment(RenderText.ALIGN_LEFT);
					setTextColor(1,1,1,1);		
					setTextBold(true);
					renderText(posX,posY,textSize,"PriceInfo: ");
					totalTextHeigh = totalTextHeigh + getTextHeight(textSize, "PriceInfo: ")	
					setTextBold(false);
				end
				
				local textPart1 = (outputItem.station);
				local textPart2 = (" | " .. outputItem.GuiName);
				local textPart3 = (" | " .. outputItem.title .. " (" .. math.floor(outputItem.fillLevel) .. ")");--(" .. math.floor(outputItem.totalAmount) .. ")(" .. outputItem.indexName .. ")");
				
				local actualPosX = posX;
				local textLine;
				if textPart1 == lastTextPart1 and textPart2 == lastTextPart2 then
					actualPosX = actualPosX + lastTextPart1Width + lastTextPart2Width;
					textLine = textPart3;
				elseif textPart1 == lastTextPart1 then
					actualPosX = actualPosX + lastTextPart1Width;
					textLine = textPart2 .. textPart3;					
				else
					textLine = textPart1 .. textPart2 .. textPart3;
					lineCountSellPrices = lineCountSellPrices+1;
				end
				
				lastTextPart1 = textPart1;
				lastTextPart1Width = getTextWidth(textSize, textPart1);
				lastTextPart2 = textPart2;
				lastTextPart2Width = getTextWidth(textSize, textPart2);
				
				if (lineCountSellPrices <= maxSellPriceLines) then
					posY = posY - textSize;
					setTextAlignment(RenderText.ALIGN_LEFT);
					setTextColor(1,1,1,1);		
					setTextBold(false);
					totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
					local textWidth = getTextWidth(textSize, textLine)+(actualPosX-posX);
					if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
					renderText(actualPosX,posY,textSize,textLine);
					totalCountSellPrices = totalCountSellPrices + 1;
				else
				   additionalCounter = additionalCounter + 1;
				end
				
				-- set max lines when totallines overdues
				if totalCountSellPrices == maxSellPriceLines then
					maxSellPriceLines = lineCountSellPrices;
				end
			end
		end
	
		if (additionalCounter > 0) then
			posY = posY - textSize;
			local textLine = (additionalCounter .. "  " ..g_i18n:getText("MoreAvailable"));
			setTextAlignment(RenderText.ALIGN_LEFT);
			setTextColor(1,1,1,1);								
			setTextBold(false);
			totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
			local textWidth = getTextWidth(textSize, textLine);
			if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
			renderText(posX,posY,textSize,textLine);
		end
			
		if (lineCountSellPrices == 0) then
			posY = posY - textSize;
			local textLine = g_i18n:getText("NothingToSell");
			setTextAlignment(RenderText.ALIGN_LEFT);
			setTextColor(1,1,1,1);								
			setTextBold(false);
			totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
			local textWidth = getTextWidth(textSize, textLine);
			if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
			renderText(posX,posY,textSize,textLine);
		end

		setOverlayColor(ProductionInfoHud.overlay.overlayId, 0, 0, 0, 0.7);
		setOverlayUVs(ProductionInfoHud.overlay.overlayId, 0.0078125,0.990234375, 0.0078125,0.9921875, 0.009765625,0.990234375, 0.009765625,0.9921875);
		ProductionInfoHud.overlay:setPosition(posX-0.001, posYStart - totalTextHeigh - 0.002);
		ProductionInfoHud.overlay:setDimension(maxTextWidth+0.002, totalTextHeigh);
		ProductionInfoHud.overlay:render();
	end	
end

function ProductionInfoHud:SaveSettings()

	if not ProductionInfoHud.isClient then return end

	createFolder(getUserProfileAppPath().. "modSettings/");
	local file = getUserProfileAppPath() .. "modSettings/ProductionInfoHudSettings.xml"

	local XML = createXMLFile("ProductionInfoHudSettings_XML", file, "ProductionInfoHudSettings")

	local xmlTag = ("ProductionInfoHudSettings.display.showType(%d)"):format(0);
	setXMLString(XML, xmlTag.."#string", ProductionInfoHud.settings["display"]["showType"])

	local xmlTag = ("ProductionInfoHudSettings.display.position(%d)"):format(0);
	setXMLInt(XML, xmlTag.."#int", ProductionInfoHud.settings["display"]["position"])

	local xmlTag = ("ProductionInfoHudSettings.display.showFullAnimals(%d)"):format(0);
	setXMLBool(XML, xmlTag.."#bool", ProductionInfoHud.settings["display"]["showFullAnimals"])

	local xmlTag = ("ProductionInfoHudSettings.display.maxLines(%d)"):format(0);
	setXMLInt(XML, xmlTag.."#int", ProductionInfoHud.settings["display"]["maxLines"])

	local xmlTag = ("ProductionInfoHudSettings.display.maxSellingLines(%d)"):format(0);
	setXMLInt(XML, xmlTag.."#int", ProductionInfoHud.settings["display"]["maxSellingLines"])

	local xmlTag = ("ProductionInfoHudSettings.display.minSellAmount(%d)"):format(0);
	setXMLInt(XML, xmlTag.."#int", ProductionInfoHud.settings["display"]["minSellAmount"])

	local xmlTag = ("ProductionInfoHudSettings.display.showBooster(%d)"):format(0);
	setXMLBool(XML, xmlTag.."#bool", ProductionInfoHud.settings["display"]["showBooster"])

	local xmlTag = ("ProductionInfoHudSettings.display.textSize(%d)"):format(0);
	setXMLInt(XML, xmlTag.."#int", ProductionInfoHud.settings["display"]["textSize"])

	saveXMLFile(XML)
end

function ProductionInfoHud:LoadSettings()

	if not ProductionInfoHud.isClient then return end

	createFolder(getUserProfileAppPath().. "modSettings/");
	local file = getUserProfileAppPath() .. "modSettings/ProductionInfoHudSettings.xml"
	
	if fileExists(file) ~= true then
		print("ProductionInfoHud: No settings file found. Use predefines");
		return;
	end

	local XML = loadXMLFile("ProductionInfoHudSettings_XML", file, "ProductionInfoHudSettings")

	local xmlTag = ("ProductionInfoHudSettings.display.showType(%d)"):format(0); 
	local value = getXMLString(XML, xmlTag.. "#string");
	if value ~= nil then ProductionInfoHud.settings["display"]["showType"] = value;end;

	xmlTag = ("ProductionInfoHudSettings.display.position(%d)"):format(0); 
	value = getXMLInt(XML, xmlTag.. "#int");
	if value ~= nil then ProductionInfoHud.settings["display"]["position"] = value;end;

	xmlTag = ("ProductionInfoHudSettings.display.showFullAnimals(%d)"):format(0); 
	value = getXMLBool(XML, xmlTag.. "#bool");
	if value ~= nil then ProductionInfoHud.settings["display"]["showFullAnimals"] = value;end;

	xmlTag = ("ProductionInfoHudSettings.display.maxLines(%d)"):format(0); 
	value = getXMLInt(XML, xmlTag.. "#int");
	if value ~= nil then ProductionInfoHud.settings["display"]["maxLines"] = value;end;

	xmlTag = ("ProductionInfoHudSettings.display.maxSellingLines(%d)"):format(0); 
	value = getXMLInt(XML, xmlTag.. "#int");
	if value ~= nil then ProductionInfoHud.settings["display"]["maxSellingLines"] = value;end;

	xmlTag = ("ProductionInfoHudSettings.display.minSellAmount(%d)"):format(0); 
	value = getXMLInt(XML, xmlTag.. "#int");
	if value ~= nil then ProductionInfoHud.settings["display"]["minSellAmount"] = value;end;

	xmlTag = ("ProductionInfoHudSettings.display.showBooster(%d)"):format(0); 
	value = getXMLBool(XML, xmlTag.. "#bool");
	if value ~= nil then ProductionInfoHud.settings["display"]["showBooster"] = value;end;

	xmlTag = ("ProductionInfoHudSettings.display.textSize(%d)"):format(0); 
	value = getXMLInt(XML, xmlTag.. "#int");
	if value ~= nil then ProductionInfoHud.settings["display"]["textSize"] = value;end;
end

--Production Revamp: MenüButten um zwischen Inaktive/Aktive/Allen Produktionen umzuschalten
function ProductionInfoHud:updateMenuButtons(superFunc)
	local buttonText = "pih_setFilltypeToIgnore";
	local currentValue = false;

	local isProductionListActive = self.productionList == FocusManager:getFocusedElement()
	local fillTypeId, isInput = self:getSelectedStorageFillType()
	
	if not isProductionListActive and fillTypeId ~= FillType.UNKNOWN and isInput then
		local production, productionPoint = self:getSelectedProduction();
		if productionPoint.inputFillTypeIdsIgnorePih ~= nil and productionPoint.inputFillTypeIdsIgnorePih[fillTypeId] ~= nil then
			if productionPoint.inputFillTypeIdsIgnorePih[fillTypeId] then
				buttonText = "pih_setFilltypeToNotIgnore";
			end
			currentValue = productionPoint.inputFillTypeIdsIgnorePih[fillTypeId];
		end
	
		table.insert(self.menuButtonInfo, {
			profile = "buttonOk",
			inputAction = InputAction.MENU_EXTRA_1,
			text = g_i18n:getText(buttonText),
			callback = function()
				ProductionInfoHud:changeFilltypeSettings(self, not currentValue)
			end
		});
	end
	
	self:setMenuButtonInfoDirty()
end
InGameMenuProductionFrame.updateMenuButtons = Utils.appendedFunction(InGameMenuProductionFrame.updateMenuButtons, ProductionInfoHud.updateMenuButtons)

--Production Revamp: Callback um Inputs zu kaufen
function ProductionInfoHud:changeFilltypeSettings(inGameMenuProductionFrame, newValue)
	local production, productionPoint = inGameMenuProductionFrame:getSelectedProduction();
	local fillTypeId = inGameMenuProductionFrame:getSelectedStorageFillType();
	
	productionPoint:setInputIgnorePih(fillTypeId, newValue);
	
	inGameMenuProductionFrame:updateMenuButtons()
end

function ProductionPoint:setInputIgnorePih(outputFillTypeId, ignoreInput, noEventSend)
	if self.inputFillTypeIdsIgnorePih == nil then
		self.inputFillTypeIdsIgnorePih = {}
	end
	
	if ignoreInput then
		self.inputFillTypeIdsIgnorePih[outputFillTypeId] = ignoreInput;
	else
		if self.inputFillTypeIdsIgnorePih[outputFillTypeId] ~= nil then
			self.inputFillTypeIdsIgnorePih[outputFillTypeId] = nil;
		end
	end
	
	ProductionPointInputIgnorePihEvent.sendEvent(self, outputFillTypeId, ignoreInput, noEventSend)
end

function ProductionInfoHud.registerSavegameXMLPathsProductionPoint(schema, basePath)
	schema:register(XMLValueType.STRING, basePath .. ".ignoreInputPihFillType(?)", "fillType currently configured to not be shown in Production Info Hud")
	Storage.registerSavegameXMLPaths(schema, basePath .. ".storage")
end
ProductionPoint.registerSavegameXMLPaths = Utils.appendedFunction(ProductionPoint.registerSavegameXMLPaths, ProductionInfoHud.registerSavegameXMLPathsProductionPoint)

function ProductionInfoHud:saveToXMLFileProductionPoint(xmlFile, key, usedModNames)
	if self.inputFillTypeIdsIgnorePih ~= nil then
		xmlFile:setTable(key .. ".ignoreInputPihFillType", self.inputFillTypeIdsIgnorePih, function (fillTypeKey, _, fillTypeId)
			local fillType = g_fillTypeManager:getFillTypeNameByIndex(fillTypeId)

			xmlFile:setValue(fillTypeKey, fillType)
		end)
	end
end
ProductionPoint.saveToXMLFile = Utils.appendedFunction(ProductionPoint.saveToXMLFile, ProductionInfoHud.saveToXMLFileProductionPoint)

function ProductionInfoHud:loadFromXMLFileProductionPoint(superFunc, xmlFile, key)
	local success = superFunc(self, xmlFile, key);
	
	xmlFile:iterate(key .. ".ignoreInputPihFillType", function (index, ignoreInputKey)
		local fillType = g_fillTypeManager:getFillTypeIndexByName(xmlFile:getValue(ignoreInputKey))

		if fillType then
			self:setInputIgnorePih(fillType, true)
		end
	end)

	return success
end
ProductionPoint.loadFromXMLFile = Utils.overwrittenFunction(ProductionPoint.loadFromXMLFile, ProductionInfoHud.loadFromXMLFileProductionPoint)

function ProductionInfoHud:readStreamProductionPoint(streamId, connection)
	if self.inputFillTypeIdsIgnorePih == nil then
		self.inputFillTypeIdsIgnorePih = {};
	end
	if connection:getIsServer() then
		for i = 1, streamReadUInt8(streamId) do
			self:setInputIgnorePih(streamReadUIntN(streamId, FillTypeManager.SEND_NUM_BITS), true)
		end
	end
end
ProductionPoint.readStream = Utils.appendedFunction(ProductionPoint.readStream, ProductionInfoHud.readStreamProductionPoint)

function ProductionInfoHud:writeStreamProductionPoint(streamId, connection)
	if self.inputFillTypeIdsIgnorePih == nil then
		self.inputFillTypeIdsIgnorePih = {};
	end
	if not connection:getIsServer() then
		streamWriteUInt8(streamId, table.size(self.inputFillTypeIdsIgnorePih))

		for inputFillTypeIdIgnorePih in pairs(self.inputFillTypeIdsIgnorePih) do
			streamWriteUIntN(streamId, inputFillTypeIdIgnorePih, FillTypeManager.SEND_NUM_BITS)
		end
	end
end
ProductionPoint.writeStream = Utils.appendedFunction(ProductionPoint.writeStream, ProductionInfoHud.writeStreamProductionPoint)


-----------new by HappyLooser-----------
function ProductionInfoHud:onStartMission() --new by HappyLooser
	if ProductionInfoHud:getServer() then return;end; --new by HappyLooser		
	ProductionInfoHud.hl = g_currentMission.hl ~= nil; --new by HappyLooser /for HL Script	
	ProductionInfoHud.moh = {found=false, outputCmdActive=true}; --outputCmdActive hat keine funtion momentan, müssen wir schauen wie deine normale Anzeige dann deaktiviert wird !! Idee !!
	ProductionInfoHud:searchOtherMods();			
	if ProductionInfoHud.moh.found then
		source(ProductionInfoHud.modDir.."mohFeatures/pihConfigForMoh.lua");
		source(ProductionInfoHud.modDir.."mohFeatures/pihSetGetForMoh.lua");
		source(ProductionInfoHud.modDir.."mohFeatures/pihOutputForMoh.lua");
		pihSetGetForMoh:onStartLoad();
	end;	
end;

function ProductionInfoHud:searchOtherMods() 
	local env = getfenv(0);		
	if env["MultiOverlayV4"] ~= nil and env["MultiOverlayV4"]["MultiOverlayV4"] ~= nil then
		ProductionInfoHud.moh.mod = env["MultiOverlayV4"];		
	end;
	if g_currentMission.multiOverlayV4 ~= nil then ProductionInfoHud.moh.found = true;end;
end;

function ProductionInfoHud:getServer()	
	return g_server ~= nil and g_client ~= nil and g_dedicatedServer ~= nil;	
end;

function ProductionInfoHud:getHostServer()	
	if g_currentMission.missionDynamicInfo == nil then return false;end;
	return g_server ~= nil and g_client ~= nil and g_dedicatedServer == nil and g_currentMission.missionDynamicInfo.isMultiplayer;	
end;
-----------new by HappyLooser-----------

addModEventListener(ProductionInfoHud);

-- local rX, rY, rZ = getRotation(place.node);
-- print("place.node rX:"..rX.." rY:"..rY.." rZ:"..rZ);

-- print("FS22_EnhancedAnimalSystem")
-- DebugUtil.printTableRecursively(FS22_EnhancedAnimalSystem,"_",0,2)