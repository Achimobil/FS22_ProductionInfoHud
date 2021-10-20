-- Begonnen
-- - Erweitern mit Dialog für Preise mit Lagerbeständen aus allen Lagern und Produktionen
--  - Da Lager zu nah zusammen stehen die Silos mal neu plazieren mit mehr abstand. Mehr als 50 m sind notwendig.
--  - Einfach Verkaufen, neu setzen und alte Lagerbestände wieder einfügen per items.xml oder ingame umziehen

-- Was fehlt noch?
-- - Speichern der Werte als Einstellungen
-- - Einstellungen in GC Menü mit gesamtliste zum scollen
-- - Per Taste ein und ausblenden können

-- - Bei Giants nachfragen, wie die HUD Klassen verwendet werden sollen
--   - https://gdn.giants-software.com/thread.php?categoryId=3&threadId=9326
-- - Bei GC nachfragen, wo eine Doku ist die man auch verwenden kann, habe jetzt alles aus anderen Mods rausgelesen
--   - https://ls-modcompany.com/forum/thread/9203-wo-finde-ich-eine-vollst%C3%A4ndige-dokumentation-und-beispiele/


GC_ProductionInfoHud = {};
GC_ProductionInfoHud._mt = Class(GC_ProductionInfoHud);
GC_ProductionInfoHud.moddir = g_currentModDirectory;
GC_ProductionInfoHud.ModName = g_currentModName
InitObjectClass(GC_ProductionInfoHud, "GC_ProductionInfoHud");

function GC_ProductionInfoHud:initGlobalCompany(customEnvironment, baseDirectory, xmlFile)
	if (g_company == nil) or (GC_ProductionInfoHud.isInitiated ~= nil) then
		return;
	end

	GC_ProductionInfoHud.debugIndex = g_company.debug:registerScriptName("GC_ProductionInfoHud");
	GC_ProductionInfoHud.modName = customEnvironment;
	GC_ProductionInfoHud.baseDirectory = baseDirectory;
	GC_ProductionInfoHud.isInitiated = true;
    GC_ProductionInfoHud.sellPriceDataSorted = {};
	g_company.ProductionInfoHud = GC_ProductionInfoHud;

	g_company.addInit(GC_ProductionInfoHud, GC_ProductionInfoHud.init);

    -- einstellungen hier defineren und später beim laden der cfg ersetzen
    -- hier eingestellt werte werden für neue cfgs als default gespeichert
    GC_ProductionInfoHud.settings = {};
    GC_ProductionInfoHud.settings["display"] = {};
    GC_ProductionInfoHud.settings["display"]["textSize"] = {};
    GC_ProductionInfoHud.settings["display"]["textSize"].Value = 11;
    GC_ProductionInfoHud.settings["display"]["textSize"].PossbileValues = {9,10,11,12,13,14};
    GC_ProductionInfoHud.settings["display"]["maxFactoryLines"] = {};
    GC_ProductionInfoHud.settings["display"]["maxFactoryLines"].Value = 10;
    GC_ProductionInfoHud.settings["display"]["maxFactoryLines"].PossbileValues = {5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};
    GC_ProductionInfoHud.settings["display"]["productionShowHours"] = {};
    GC_ProductionInfoHud.settings["display"]["productionShowHours"].Value = 72;
    GC_ProductionInfoHud.settings["display"]["productionShowHours"].PossbileValues = {6,12,18,24,36,48,72,96,120,144,168};
    GC_ProductionInfoHud.settings["display"]["showType"] = "ALL";
    GC_ProductionInfoHud.settings["display"]["minSellAmount"] = {};
    GC_ProductionInfoHud.settings["display"]["minSellAmount"].Value = 100000;
    GC_ProductionInfoHud.settings["display"]["minSellAmount"].PossbileValues = {10000,50000,100000,200000};
    GC_ProductionInfoHud.settings["display"]["positionBelowVehicleInspector"] = false;
    GC_ProductionInfoHud.settings["display"]["maxSellingLines"] = {};
    GC_ProductionInfoHud.settings["display"]["maxSellingLines"].Value = 10;
    GC_ProductionInfoHud.settings["display"]["maxSellingLines"].PossbileValues = {5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};
    GC_ProductionInfoHud.settings["factory"] = {};

    -- config speichern, wenn savegame gespeichert wird
    FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, GC_ProductionInfoHud.saveCfg)

    -- ActionEvents registrieren
    FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, GC_ProductionInfoHud.registerActionEvents)
end

function GC_ProductionInfoHud:registerActionEvents()
	if GC_ProductionInfoHud.isClient then
		_, GC_ProductionInfoHud.eventIdToggle = g_inputBinding:registerActionEvent(InputAction.TOGGLE_GUI, GC_ProductionInfoHud, GC_ProductionInfoHud.ToggleGui, false, true, false, true, -1, true)
		_, GC_ProductionInfoHud.eventIdToggle = g_inputBinding:registerActionEvent(InputAction.OPEN_GUI, GC_ProductionInfoHud, GC_ProductionInfoHud.OpenGui, false, true, false, true, -1, true)
	end
end

function GC_ProductionInfoHud:ToggleGui()
    local sellPriceTriggerAvailable = true;
    if FS19_SellPriceTrigger == nil or FS19_SellPriceTrigger.SellPriceTrigger == nil or FS19_SellPriceTrigger.SellPriceTrigger.triggers == nil then 
        sellPriceTriggerAvailable = false; 
    end;

    if sellPriceTriggerAvailable then
        if GC_ProductionInfoHud.settings["display"]["showType"] == "ALL" then 
            GC_ProductionInfoHud.settings["display"]["showType"] = "PRODUCTION"
        elseif GC_ProductionInfoHud.settings["display"]["showType"] == "PRODUCTION" then 
            GC_ProductionInfoHud.settings["display"]["showType"] = "SELLPRICE"
        elseif GC_ProductionInfoHud.settings["display"]["showType"] == "SELLPRICE" then 
            GC_ProductionInfoHud.settings["display"]["showType"] = "NONE"
        else 
            GC_ProductionInfoHud.settings["display"]["showType"] = "ALL"
        end
    else
        if GC_ProductionInfoHud.settings["display"]["showType"] == "ALL" then 
            GC_ProductionInfoHud.settings["display"]["showType"] = "NONE"
        else 
            GC_ProductionInfoHud.settings["display"]["showType"] = "ALL"
        end
    end

--    print("showType:" .. GC_ProductionInfoHud.settings["display"]["showType"]);
end

function GC_ProductionInfoHud:OpenGui()

	-- dialog test
	if g_gui.currentGui == nil then
		g_gui:showGui("ProductionInfoHudGUI")
	end
end

function GC_ProductionInfoHud:loadCfg()
    print("GC_ProductionInfoHud:loadCfg()");
	if g_currentMission.missionInfo.savegameDirectory ~= nil then
		local file = g_currentMission.missionInfo.savegameDirectory.. "/ProductionInfoHudSettings.xml"
        if fileExists(file) then
            print("GC_ProductionInfoHud: Settings loaded from file");
            local XML = loadXMLFile("ProductionInfoHudSettings_XML", file, "ProductionInfoHudSettings")

            local xmlTag = ("ProductionInfoHudSettings.display.textSize(%d)"):format(0); 
            local value = getXMLInt(XML, xmlTag.. "#int");
            if value ~= nil then GC_ProductionInfoHud.settings["display"]["textSize"].Value = value;end;
            
            xmlTag = ("ProductionInfoHudSettings.display.showType(%d)"):format(0); 
            value = getXMLString(XML, xmlTag.. "#string");
            if value ~= nil then GC_ProductionInfoHud.settings["display"]["showType"] = value;end;

            xmlTag = ("ProductionInfoHudSettings.display.minSellAmount(%d)"):format(0); 
            value = getXMLInt(XML, xmlTag.. "#int");
            if value ~= nil then GC_ProductionInfoHud.settings["display"]["minSellAmount"].Value = value;end;

            xmlTag = ("ProductionInfoHudSettings.display.maxSellingLines(%d)"):format(0); 
            value = getXMLInt(XML, xmlTag.. "#int");
            if value ~= nil then GC_ProductionInfoHud.settings["display"]["maxSellingLines"].Value = value;end;

            xmlTag = ("ProductionInfoHudSettings.display.maxFactoryLines(%d)"):format(0); 
            value = getXMLInt(XML, xmlTag.. "#int");
            if value ~= nil then GC_ProductionInfoHud.settings["display"]["maxFactoryLines"].Value = value;end;

            xmlTag = ("ProductionInfoHudSettings.display.productionShowHours(%d)"):format(0); 
            value = getXMLInt(XML, xmlTag.. "#int");
            if value ~= nil then GC_ProductionInfoHud.settings["display"]["productionShowHours"].Value = value;end;

            xmlTag = ("ProductionInfoHudSettings.display.positionBelowVehicleInspector(%d)"):format(0); 
            value = getXMLBool(XML, xmlTag.. "#bool");
            if value ~= nil then GC_ProductionInfoHud.settings["display"]["positionBelowVehicleInspector"] = value;end;

			for x=0,200 do
				local groupNameTag = ("ProductionInfoHudSettings.factorys.factory(%d)"):format(x)
				local indexName = getXMLString(XML, groupNameTag.. "#indexName")

				if indexName == nil then
					break
				end

				if GC_ProductionInfoHud.settings["factory"][indexName] == nil then
                    GC_ProductionInfoHud.settings["factory"][indexName] = {};
                end

				local ignore = getXMLBool(XML, groupNameTag.. "#ignore")
                if ignore ~= nil then GC_ProductionInfoHud.settings["factory"][indexName].ignore = ignore end;
				local ignoreSelling = getXMLBool(XML, groupNameTag.. "#ignoreSelling")
                if ignore ~= nil then GC_ProductionInfoHud.settings["factory"][indexName].ignoreSelling = ignoreSelling end;
				
				for y=0,50 do
					local innerGroupNameTag = (groupNameTag.. ".inputProducts.inputProduct(%d)"):format(y);
					local inputProductId = getXMLInt(XML, innerGroupNameTag.. "#inputProductId")
					local minNeededAmount = getXMLInt(XML, innerGroupNameTag.. "#minNeededAmount")
					local capacity = getXMLInt(XML, innerGroupNameTag.. "#capacity")
					local fillTypeTitles = getXMLString(XML, innerGroupNameTag.. "#fillTypeTitles")
					
					if inputProductId == nil then
						break
					end
					
					if GC_ProductionInfoHud.settings["factory"][indexName].inputProducts == nil then
						GC_ProductionInfoHud.settings["factory"][indexName].inputProducts = {};
					end

					if GC_ProductionInfoHud.settings["factory"][indexName].inputProducts[inputProductId] == nil then
						GC_ProductionInfoHud.settings["factory"][indexName].inputProducts[inputProductId] = {};
					end
					
					if minNeededAmount ~= nil then GC_ProductionInfoHud.settings["factory"][indexName].inputProducts[inputProductId].minNeededAmount = minNeededAmount end;	
					if capacity ~= nil then GC_ProductionInfoHud.settings["factory"][indexName].inputProducts[inputProductId].capacity = capacity end;	
					if fillTypeTitles ~= nil then GC_ProductionInfoHud.settings["factory"][indexName].inputProducts[inputProductId].fillTypeTitles = fillTypeTitles end;	
				end
			end
            
            --saveXMLFile(XML)
        else
            print("GC_ProductionInfoHud: No settings file found");
        end
	end
end

function GC_ProductionInfoHud:saveCfg()
	if g_currentMission.missionInfo.savegameDirectory ~= nil then
		local file = g_currentMission.missionInfo.savegameDirectory.. "/ProductionInfoHudSettings.xml"
		local XML = createXMLFile("ProductionInfoHudSettings_XML", file, "ProductionInfoHudSettings")

		local xmlTag = ("ProductionInfoHudSettings.display.textSize(%d)"):format(0);
		setXMLInt(XML, xmlTag.."#int", GC_ProductionInfoHud.settings["display"]["textSize"].Value)

		local xmlTag = ("ProductionInfoHudSettings.display.showType(%d)"):format(0);
		setXMLString(XML, xmlTag.."#string", GC_ProductionInfoHud.settings["display"]["showType"])

		local xmlTag = ("ProductionInfoHudSettings.display.minSellAmount(%d)"):format(0);
		setXMLInt(XML, xmlTag.."#int", GC_ProductionInfoHud.settings["display"]["minSellAmount"].Value);

		local xmlTag = ("ProductionInfoHudSettings.display.maxSellingLines(%d)"):format(0);
		setXMLInt(XML, xmlTag.."#int", GC_ProductionInfoHud.settings["display"]["maxSellingLines"].Value);

		local xmlTag = ("ProductionInfoHudSettings.display.maxFactoryLines(%d)"):format(0);
		setXMLInt(XML, xmlTag.."#int", GC_ProductionInfoHud.settings["display"]["maxFactoryLines"].Value);

		local xmlTag = ("ProductionInfoHudSettings.display.productionShowHours(%d)"):format(0);
		setXMLInt(XML, xmlTag.."#int", GC_ProductionInfoHud.settings["display"]["productionShowHours"].Value);

		local xmlTag = ("ProductionInfoHudSettings.display.positionBelowVehicleInspector(%d)"):format(0);
		setXMLBool(XML, xmlTag.."#bool", GC_ProductionInfoHud.settings["display"]["positionBelowVehicleInspector"]);

		local x = 0
		for factoryId,factory in pairs(GC_ProductionInfoHud.settings["factory"]) do
			local groupNameTag = ("ProductionInfoHudSettings.factorys.factory(%d)"):format(x);
			setXMLString(XML, groupNameTag.. "#indexName", factoryId)
			setXMLBool(XML, groupNameTag.. "#ignore", factory.ignore)
			setXMLBool(XML, groupNameTag.. "#ignoreSelling", factory.ignoreSelling)

			local y = 0
			for inputProductId, inputProduct in pairs (factory.inputProducts) do
				local innerGroupNameTag = (groupNameTag.. ".inputProducts.inputProduct(%d)"):format(y);
				setXMLInt(XML, innerGroupNameTag.. "#inputProductId", inputProductId)
				if inputProduct.capacity ~= nil then
					setXMLInt(XML, innerGroupNameTag.. "#capacity", inputProduct.capacity)
				end
				if inputProduct.fillTypeTitles ~= nil then
					setXMLString(XML, innerGroupNameTag.. "#fillTypeTitles", inputProduct.fillTypeTitles)
				end
				setXMLInt(XML, innerGroupNameTag.. "#minNeededAmount", inputProduct.minNeededAmount)
				y=y+1
			end
			x=x+1
		end


		
		saveXMLFile(XML)

        -- output for debug
        -- print("g_currentMission.vehicleInspector.overlays[ground]: ");
        -- print_r(g_currentMission.vehicleInspector.overlays["ground"]);

	end
end

function GC_ProductionInfoHud:init()
	GC_ProductionInfoHud.isServer = g_server ~= nil;
	GC_ProductionInfoHud.isClient = g_dedicatedServerInfo == nil;
	GC_ProductionInfoHud.isMultiplayer = g_currentMission.missionDynamicInfo.isMultiplayer;
	GC_ProductionInfoHud.FirstRun = true;
	GC_ProductionInfoHud.TimePast = 0;
	GC_ProductionInfoHud.overlay = Overlay:new("dataS2/menu/hud/hud_elements_2160p.png", 0, 0, 0, 0);

	g_company.addUpdateable(GC_ProductionInfoHud, GC_ProductionInfoHud.update);	

    GC_ProductionInfoHud:loadCfg();

    -- ein mal direkt aufrufen, damit beim start schon verfügbar
    GC_ProductionInfoHud.registerActionEvents();
	
	-- dialog test
	g_gui:loadProfiles(GC_ProductionInfoHud.moddir .. "Gui/guiProfiles.xml")
	GC_ProductionInfoHud.gui = g_gui:loadGui(GC_ProductionInfoHud.moddir .. "Gui/ProductionInfoHudGui.xml", "ProductionInfoHudGUI", ProductionInfoHudGUI:new())

-- for debug
----    GC_ProductionInfoHud.refreshOutputTable();
--    print("outputTable : ");
--    print_r(g_currentMission.storageSystem.loadingStations);
end;

function GC_ProductionInfoHud:update(dt)
	
	GC_ProductionInfoHud.TimePast = GC_ProductionInfoHud.TimePast + dt;
	
	if GC_ProductionInfoHud.TimePast >= 5000 then
		GC_ProductionInfoHud.TimePast = 0;

		if GC_ProductionInfoHud.settings["display"]["showType"] == "ALL" or string.find(GC_ProductionInfoHud.settings["display"]["showType"], "PRODUCTION") then 
			GC_ProductionInfoHud:refreshOutputTable();
		end
		
		if GC_ProductionInfoHud.sellPriceDataSorted ~= nil and (GC_ProductionInfoHud.settings["display"]["showType"] == "ALL" or string.find(GC_ProductionInfoHud.settings["display"]["showType"], "SELLPRICE")) then
			GC_ProductionInfoHud:refreshSellPriceData();
		end
	end	
	
    GC_ProductionInfoHud:drawHud();
end;

function GC_ProductionInfoHud:refreshSellPriceData()
    if FS19_SellPriceTrigger == nil then return end;
    if FS19_SellPriceTrigger.SellPriceTrigger == nil then return end;
    if FS19_SellPriceTrigger.SellPriceTrigger.triggers == nil then return end;

    local prices = {};

    -- liste füllen mit den types, die gerade einen guten preis haben
	for fillType,trigger in pairs(FS19_SellPriceTrigger.SellPriceTrigger.triggers) do
        if trigger.over == true then
            prices[fillType] = {info=trigger,storages={},total=0}
        end
	end

    -- für alle mit gutem preis aus den produktionen die Lagerbestände sammeln
    for i, globalFactory in pairs (g_company.loadedFactories) do
		local factorySetting = GC_ProductionInfoHud:GetSettingForFactory(globalFactory);
        if not(factorySetting.ignoreSelling) and (g_currentMission.player.farmId == globalFactory.ownerFarmId) then
            for a, product in pairs (globalFactory.outputProducts) do
                if prices[product.fillTypeIndex] ~= nil then
				
					-- Eigenen Namen benutzen, wenn gesetzt, ansonsten den FactoryTitle
					local guiName;
					if (globalFactory.guiData.factoryCustomTitle ~= nil and globalFactory.guiData.factoryCustomTitle ~= "") then
						guiName = globalFactory.guiData.factoryCustomTitle;
					else
						guiName = globalFactory.guiData.factoryTitle;
					end
				
				
                    prices[product.fillTypeIndex].storages[globalFactory.indexName] = {fillLevel=product.fillLevel, GuiName = guiName}
                    prices[product.fillTypeIndex].total = prices[product.fillTypeIndex].total + product.fillLevel;
                end
            end
        end
    end

    -- storageSystem benutzen. Storages splitten sich auf, wenn diese zu nah zusammen stehen, aber das ist in LS so und ich kann das nicht ändern.
    local storages = g_currentMission.storageSystem:getStorages();
    for i, storage in pairs (storages) do
        local storageName = "";
        for j, unloadingStation in pairs (storage.unloadingStations) do
            if storageName ~= "" then storageName = storageName .. "-" end;
            storageName = storageName .. unloadingStation.stationName;
        end

        if (g_currentMission.player.farmId == storage.ownerFarmId) then
            for fillType, fillLevel in pairs(storage.fillLevels) do
                if prices[fillType] ~= nil then
                    if prices[fillType].storages[storageName] ~= nill then
                        prices[fillType].storages[storageName].fillLevel=prices[fillType].storages[storageName].fillLevel + fillLevel;
                    else
                        prices[fillType].storages[storageName] = {fillLevel=fillLevel, GuiName = storageName}
                    end
                    prices[fillType].total = prices[fillType].total + fillLevel;
                end
            end
        end
    end

    -- List für Anzeige erstellen
	local sortableOutputTable = {};
	for a, sellPriceItem in pairs (prices) do
		for b, sellPriceStorage in pairs (sellPriceItem.storages) do
			local outputItem = {};
			outputItem.station = sellPriceItem.info.station;
			outputItem.title = sellPriceItem.info.title;
			outputItem.fillLevel = sellPriceStorage.fillLevel;
			outputItem.GuiName = sellPriceStorage.GuiName;
			table.insert(sortableOutputTable , outputItem)
		end
	end

    table.sort(sortableOutputTable,compSellingTable)
	
    GC_ProductionInfoHud.sellPriceDataSorted = sortableOutputTable;
end;

function compSellingTable(w1,w2)
	-- Zum Sortieren der Ausgabeliste nach Zeit
    if w1.station == w2.station and w1.title < w2.title then
        return true
    end
    if w1.station < w2.station then
        return true
    end
end

function GC_ProductionInfoHud:drawHud()

-- try to use the y below the normal HUD
--if g_currentMission.hud ~= nil and g_currentMission.hud.vehicleSchema ~= nil and g_currentMission.hud.vehicleSchema.overlay ~= nil then 
--    local test = Utils.getNoNil(g_currentMission.hud.inputHelp.overlay.x);
--    print("g_currentMission.hud.inputHelp.overlay.x: "..test);
--    local test2 = Utils.getNoNil(g_currentMission.hud.inputHelp.overlay.y);
--    print("g_currentMission.hud.inputHelp.overlay.y: "..test2);
--    print("g_currentMission.hud.inputHelp.overlay.visible: ");
--    print(g_currentMission.hud.inputHelp.overlay.visible);
--    --print("g_currentMission.hud.isMenuVisible : "..g_currentMission.hud.isMenuVisible);
--end

	if g_gui.currentGui ~= nil and g_gui.currentGui.name ~= "ProductionInfoHudGUI" then
		return;
	end

    local posX = 0.013;
    local spaceY = 0.01;
    local posYStart = 0.90;
    local textSize = GC_ProductionInfoHud.settings["display"]["textSize"].Value/1000;
    local lineCount = 0;
    local maxLines = GC_ProductionInfoHud.settings["display"]["maxFactoryLines"].Value;
    local totalTextHeigh = 0;
    local maxTextWidth = 0;
    local additionalCounter = 0;
    local minSellAmount = GC_ProductionInfoHud.settings["display"]["minSellAmount"].Value;
    local positionBelowVehicleInspector = GC_ProductionInfoHud.settings["display"]["positionBelowVehicleInspector"];
	local productionShowHours = GC_ProductionInfoHud.settings["display"]["productionShowHours"].Value;

    if positionBelowVehicleInspector and g_currentMission.vehicleInspector ~= nil and g_currentMission.vehicleInspector.simple.isDraw[1] and g_currentMission.vehicleInspector.overlays["ground"].y ~= nil and g_currentMission.vehicleInspector.overlays["ground"].y > 0 then
        -- position below vehicleInspector
        posX = g_currentMission.vehicleInspector.overlays["ground"].x;
        posYStart = g_currentMission.vehicleInspector.overlays["ground"].y - spaceY;
		-- print("Begin Output");
		-- DebugUtil.printTableRecursively(g_currentMission.vehicleInspector.simple.isDraw,"_",0,2)
    elseif (g_currentMission.hud.inputHelp.overlay.visible == true) then
        -- move under Help Dialog, when help visible
        posX = g_currentMission.hud.inputHelp.overlay.x;
        posYStart = g_currentMission.hud.inputHelp.overlay.y - spaceY;
    end

    local posY = posYStart;

    if GC_ProductionInfoHud.outputTable ~= nil and (GC_ProductionInfoHud.settings["display"]["showType"] == "ALL" or string.find(GC_ProductionInfoHud.settings["display"]["showType"], "PRODUCTION")) then 
        for a, outputItem in pairs (GC_ProductionInfoHud.outputTable) do
            if (outputItem.HoursLeft <= productionShowHours) then
                if (outputItem.HoursLeft <= 0) then
                    -- ausgabe im Log für Debug
                    -- print(outputItem.Fabrik .. " braucht " .. outputItem.NeedsItem .. ". Platz für " .. math.floor(outputItem.NeedsAmount));
                    if (lineCount < maxLines) then
                        lineCount = lineCount+1;
                        posY = posY - textSize;
                        local textLine = (outputItem.Fabrik .. " | " .. outputItem.NeedsItem .. " | " .. math.floor(outputItem.NeedsAmount));
                        setTextColor(1,0.3,0,1);								
                        setTextBold(true);
                        totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
                        local textWidth = getTextWidth(textSize, textLine);
                        if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
                        renderText(posX,posY,textSize,textLine);
                        --renderText(posX + getTextWidth(textSize, textLine),posY,textSize, "Test");
                    else
                       additionalCounter = additionalCounter + 1;
                    end
                else
                    local days = math.floor(outputItem.HoursLeft/24);
                    local hoursLeft = outputItem.HoursLeft-(days*24);
                    local hours = math.floor(hoursLeft);
                    local hoursLeft = hoursLeft-hours;
                    local minutes = math.floor(hoursLeft * 60);
                    if(minutes <= 9) then minutes = "0" .. minutes end;
                    local timeString = "";
                    if (days ~= 0) then 
                        timeString = days .. "d ";
                    end
                    timeString = timeString .. hours .. ":" .. minutes;
                    -- ausgabe im Log für Debug
                    -- print(outputItem.Fabrik .. " braucht " .. outputItem.NeedsItem .. " in " .. timeString .. " Stunden. Platz für " .. math.floor(outputItem.NeedsAmount));
                    if (lineCount < maxLines) then
                        lineCount = lineCount+1;
                        posY = posY - textSize;
                        if (days == 0) then
                            setTextColor(1,0.65,0,1);		
                            setTextBold(false);
                        else
                            setTextColor(1,1,1,1);		
                            setTextBold(false);
                        end	
                        local textLine = (outputItem.Fabrik .. " | " .. outputItem.NeedsItem .. " | " .. timeString .. " | " .. math.floor(outputItem.NeedsAmount));
                        totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
                        local textWidth = getTextWidth(textSize, textLine);
                        if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
                        renderText(posX,posY,textSize,textLine);
                    else
                       additionalCounter = additionalCounter + 1;
                    end
                end
            end
        end
        
		if (additionalCounter > 0) then
			posY = posY - textSize;
			local textLine = (additionalCounter .. "  " ..g_i18n:getText("MoreAvailable"));
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
			setTextColor(1,1,1,1);								
			setTextBold(false);
			totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
			local textWidth = getTextWidth(textSize, textLine);
			if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
			renderText(posX,posY,textSize,textLine);
		end
	
		-- overlay für produktionen
		setOverlayColor(GC_ProductionInfoHud.overlay.overlayId, 0, 0, 0, 0.7);
		setOverlayUVs(GC_ProductionInfoHud.overlay.overlayId, 0.0078125,0.990234375, 0.0078125,0.9921875, 0.009765625,0.990234375, 0.009765625,0.9921875);
		GC_ProductionInfoHud.overlay:setPosition(posX-0.001, posYStart - totalTextHeigh - 0.002);
		GC_ProductionInfoHud.overlay:setDimension(maxTextWidth+0.002, totalTextHeigh);
		GC_ProductionInfoHud.overlay:render();
		
		-- make a space between the sale list and the production list
		posYStart = posY - spaceY;
		posY = posY - spaceY;
    end

	-- daten für nächsten overlay zurücksetzen
    totalTextHeigh = 0;
    maxTextWidth = 0;
    local maxSellPriceLines = GC_ProductionInfoHud.settings["display"]["maxSellingLines"].Value;
    local totalCountSellPrices = 0;
    local lineCountSellPrices = 0;
    additionalCounter = 0;
    if GC_ProductionInfoHud.sellPriceDataSorted ~= nil and (GC_ProductionInfoHud.settings["display"]["showType"] == "ALL" or string.find(GC_ProductionInfoHud.settings["display"]["showType"], "SELLPRICE")) then
		local lastTextPart1;
		local lastTextPart1Width;
		local lastTextPart2;
		local lastTextPart2Width;
		
        for a, outputItem in pairs (GC_ProductionInfoHud.sellPriceDataSorted) do
			if outputItem.fillLevel >= minSellAmount then
				if (lineCountSellPrices == 0) then
					posY = posY - textSize;
					setTextColor(1,1,1,1);	
					renderText(posX,posY,textSize,"PriceInfo: ");
				totalTextHeigh = totalTextHeigh + getTextHeight(textSize, "PriceInfo: ")
				end
				
				local textPart1 = (outputItem.station);
				local textPart2 = (" | " .. outputItem.title);
				local textPart3 = (" | " .. outputItem.GuiName .. " (" .. math.floor(outputItem.fillLevel) .. ")");
				
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
					setTextColor(1,1,1,1);		
					setTextBold(false);
					totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
					local textWidth = getTextWidth(textSize, textLine)+(actualPosX-posX);
					if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
					renderText(actualPosX,posY,textSize,textLine);
					--renderText(posX + getTextWidth(textSize, textLine),posY,textSize, "Test");
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
			setTextColor(1,1,1,1);								
			setTextBold(false);
			totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
			local textWidth = getTextWidth(textSize, textLine);
			if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
			renderText(posX,posY,textSize,textLine);
		end
    end


--print("posY: "..posY);
--print("totalTextHeigh: "..totalTextHeigh);
--print("posYStart: "..posYStart);
--print("y: "..(posYStart - totalTextHeigh + textSize));
    setOverlayColor(GC_ProductionInfoHud.overlay.overlayId, 0, 0, 0, 0.7);
	setOverlayUVs(GC_ProductionInfoHud.overlay.overlayId, 0.0078125,0.990234375, 0.0078125,0.9921875, 0.009765625,0.990234375, 0.009765625,0.9921875);
	GC_ProductionInfoHud.overlay:setPosition(posX-0.001, posYStart - totalTextHeigh - 0.002);
	GC_ProductionInfoHud.overlay:setDimension(maxTextWidth+0.002, totalTextHeigh);
	GC_ProductionInfoHud.overlay:render();
    
end;

function GC_ProductionInfoHud:GetSettingForFactory(globalFactory)
    -- einfügen was an settings fehlt, also nicht aus der config geladen wurde
    if (GC_ProductionInfoHud.settings["factory"][globalFactory.indexName] == nil) then
        GC_ProductionInfoHud.settings["factory"][globalFactory.indexName] = {};
        GC_ProductionInfoHud.settings["factory"][globalFactory.indexName].indexName = globalFactory.indexName;
    end
	local currentFactorySetting = GC_ProductionInfoHud.settings["factory"][globalFactory.indexName];
	
    if (currentFactorySetting.ignore == nil) then
        if (globalFactory.customEnvironment ~= "FS19_FEDmods_Ballenlager") and (globalFactory.customEnvironment ~= "FS19_AgrarSiloKDS_GC") and (globalFactory.indexName ~= "Einkauf") and (globalFactory.indexName ~= "Brueckenbau") and (globalFactory.indexName ~= "Hofladen") then
            -- standard wie vor der einstellbarkeit, wenn noch nichts eingestellt ist
            currentFactorySetting.ignore = false;
        else
            currentFactorySetting.ignore = true;
        end
    end
    if (currentFactorySetting.ignoreSelling == nil) then
		currentFactorySetting.ignoreSelling = false;
    end
	
	if currentFactorySetting.inputProducts == nill then
		currentFactorySetting.inputProducts = {};
	end
	
	if currentFactorySetting.GuiName == nill then
		currentFactorySetting.GuiName = globalFactory.guiData.factoryTitle;
	end
	
	for inputProductId, inputProduct in pairs (globalFactory.inputProducts) do
		if currentFactorySetting.inputProducts[inputProductId] == nil then
			currentFactorySetting.inputProducts[inputProductId] = {};
		end
		local currentInputProductSetting = currentFactorySetting.inputProducts[inputProductId];
		
		if inputProduct.concatedFillTypeTitles ~= nil then
			currentInputProductSetting.fillTypeTitles = inputProduct.concatedFillTypeTitles;
		end
		if inputProduct.capacity ~= nil then
			currentInputProductSetting.capacity = inputProduct.capacity;
		end
		if currentInputProductSetting.minNeededAmount == nil then
			currentInputProductSetting.minNeededAmount = inputProduct.capacity*0.25;
		end
		
		-- correct min amount to dividable by 5000 for easier settings
		local rest = math.fmod(currentInputProductSetting.minNeededAmount, 5000);
		local newAmount = currentInputProductSetting.minNeededAmount - rest;
		currentInputProductSetting.minNeededAmount = newAmount;
	end

    return currentFactorySetting;
end

function GC_ProductionInfoHud:refreshOutputTable()

    local usageList = {};

    -- später aus Einstellungen laden
    local ignoreFullProductions = true;
    
    for i, globalFactory in pairs (g_company.loadedFactories) do
		-- output for debugging
		-- if(globalFactory.indexName == "PILZE" and GC_ProductionInfoHud.FirstRun == true) then
			-- print("globalFactory:");
			-- print(i.." : "..globalFactory.indexName);
			-- DebugUtil.printTableRecursively(globalFactory,"_",0,2);
			-- for productLineId, productLine in pairs (globalFactory.productLines) do
				
				-- print(productLineId.." : "..productLine.title);
				-- print("outputPerHour : "..productLine.outputPerHour);
				-- print("getOutputPerHour : "..productLine.getOutputPerHour());
			-- end
			
			-- GC_ProductionInfoHud.FirstRun = false;
			-- print("g_currentMission.player : ");
			-- DebugUtil.printTableRecursively(g_currentMission.player,"_",0,2)
		-- end

        local factorySetting = GC_ProductionInfoHud:GetSettingForFactory(globalFactory);

        if not(factorySetting.ignore) and (g_currentMission.player.farmId == globalFactory.ownerFarmId) then
            local usageItem = {};
            usageList[i] = {};	
            usageList[i].indexName = globalFactory.indexName;
            usageList[i].UsageItem = usageItem;
            
            -- Eigenen Namen benutzen, wenn gesetzt, ansonsten den FactoryTitle
            if (globalFactory.guiData.factoryCustomTitle ~= nil and globalFactory.guiData.factoryCustomTitle ~= "") then
                usageList[i].GuiName = globalFactory.guiData.factoryCustomTitle;
            else
                usageList[i].GuiName = globalFactory.guiData.factoryTitle;
            end

            for inputProductId, inputProduct in pairs (globalFactory.inputProducts) do
                usageItem[inputProductId] = {};	
                usageItem[inputProductId].Name = inputProduct.concatedFillTypeTitles;
                usageItem[inputProductId].capacity = inputProduct.capacity;
                usageItem[inputProductId].fillLevel = inputProduct.fillLevel;
                usageItem[inputProductId].id = inputProduct.id;
                usageItem[inputProductId].usagePerHour = 0;
                usageItem[inputProductId].HoursLeft = 0;
                usageItem[inputProductId].UseCount = 0;
                usageItem[inputProductId].minNeededAmount = factorySetting.inputProducts[inputProduct.id].minNeededAmount;

                for productLineId, productLine in pairs (globalFactory.productLines) do

                    local oneOutputIsFull = false;
                    for outputId, output in pairs (productLine.outputs) do
                        if (output.fillLevel >= output.capacity) then
                            oneOutputIsFull = true;
                        end
                    end

                    if (productLine.userStopped == false and productLine.autoStart == true) and (not (ignoreFullProductions and oneOutputIsFull)) then
                        -- the key for inputPercent is the key for the inputs and in the inputs there is the id to use with b.id
                        for e, f in pairs (productLine.inputs) do
                            if (f.id == inputProduct.id) then
                                if productLine.inputsPercent[e] ~= nil then
                                    local usagePerHour = productLine.getOutputPerHour() * productLine.inputsPercent[e];
                                    usageItem[inputProductId].usagePerHour = usageItem[inputProductId].usagePerHour+usagePerHour;
                                    usageItem[inputProductId].UseCount = usageItem[inputProductId].UseCount + 1;
                                end
                            end
                        end
                    end
                end

                if (usageItem[inputProductId].fillLevel ~= 0) and (usageItem[inputProductId].usagePerHour ~= 0) then
                    usageItem[inputProductId].HoursLeft = usageItem[inputProductId].fillLevel / usageItem[inputProductId].usagePerHour;
                end

            end
        end
    end;

--    print("usageList : ");
--    tprint(usageList);

    -- sortieren und auf dem Schirm ausgeben, aber wie sortieren? Restzeit als Key wird nicht gehen, da gleiche Zahlen mehrmals vorkommen können
    -- Liste erstelle pro Item und Usage zum sortieren und ausgeben
    local outputTable = {};
    for a, usageGroup in pairs (usageList) do
        for c, usageItem in pairs (usageGroup.UsageItem) do
            local neededAmount = usageItem.capacity-usageItem.fillLevel;
            if (usageItem.UseCount ~= 0 and neededAmount >= usageItem.minNeededAmount) then
                local outputItem = {};
                outputItem.Fabrik = usageGroup.GuiName;
                outputItem.NeedsItem = usageItem.Name;
                outputItem.HoursLeft = usageItem.HoursLeft;
                outputItem.NeedsAmount = neededAmount;
                table.insert(outputTable , outputItem)
            end
        end
    end

    table.sort(outputTable,comp)

    GC_ProductionInfoHud.outputTable = outputTable;
end;

function comp(w1,w2)
	-- Zum Sortieren der Ausgabeliste nach Zeit
    if w1.HoursLeft == w2.HoursLeft and w1.Fabrik < w2.Fabrik then
        return true
    end
    if w1.HoursLeft < w2.HoursLeft then
        return true
    end
end

-- Hilfsfunktion um sich eine table im Log an zu schauen
function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if k == "target" or k == "visibilityNodes" or k == "source" or k == "parent" or k == "productionFactories" or k == "movers" or k == "digitalDisplays" or k == "debugData" or k == "operateVisibility" or k == "operateSounds" or k == "playerTrigger" then
      --print(formatting .. "Skipped")      
    elseif type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))   
    elseif type(v) == 'function' then
      --print(formatting .. "function " ..tostring(v))   
    else
      print(formatting .. v)
    end
  end
end
