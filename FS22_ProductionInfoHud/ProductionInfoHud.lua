--- Anzeige für Produktionen in einem HUD by achimobil@hotmail.com
--- Fehlermeldungen und Verbesserungsvorschläge gerne im Discord Kanal des Mods: https://discord.gg/Va7JNnEkcW

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
ProductionInfoHud.colors.WHITE =    {1.000, 1.000, 1.000, 1}
ProductionInfoHud.colors.ORANGE =   {0.840, 0.270, 0.020, 1}
ProductionInfoHud.colors.RED =      {0.580, 0.040, 0.020, 1}
ProductionInfoHud.colors.YELLOW =   {0.980, 0.420, 0.000, 1}
ProductionInfoHud.PossiblePositions = {"TopCenter", "BelowHelp", "BelowVehicleInspector"}
ProductionInfoHud.PossibleMaxLines = {"2", "3", "4", "5", "6", "7", "8", "9", "10"}
ProductionInfoHud.PossibleAmounts = {"5000", "10000", "50000", "100000", "200000", "250000"}

function ProductionInfoHud:init()
    ProductionInfoHud.isClient = g_currentMission:getIsClient();
    ProductionInfoHud.isInit = true;
    
    ProductionInfoHud.messageCenter = g_messageCenter;
    ProductionInfoHud.i18n = g_i18n;
    ProductionInfoHud.inputManager = g_gui.inputManager;
    ProductionInfoHud.sellPriceDataSorted = {};
    
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
    
    ProductionInfoHud:LoadSettings();
       
    -- Aufrufen nach init, da erst an isclient gesetzt ist und sonst die binding nicht aktiv ist bevor man in ein auto einsteigt
    ProductionInfoHud:registerActionEvents()

    -- overwrite the InfoMessageHUD method to move it to a good location, when it is installed    
    if g_modIsLoaded["FS22_InfoMessageHUD"] then
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
    
    ProductionInfoHud.fixInGameMenu(productionFrame,"InGameMenuProductionInfo", {0,0,1024,1024}, 13, ProductionInfoHud:makeIsProductionInfoEnabledPredicate())
    productionFrame:initialize()    
    
end

function ProductionInfoHud:makeIsProductionInfoEnabledPredicate()
    return function () return true end
end

-- from Courseplay
function ProductionInfoHud.fixInGameMenu(frame,pageName,uvs,position,predicateFunc)
    local inGameMenu = g_gui.screenControllers[InGameMenu]

    -- remove all to avoid warnings
    for k, v in pairs({pageName}) do
        inGameMenu.controlIDs[v] = nil
    end

    inGameMenu:registerControls({pageName})

    
    inGameMenu[pageName] = frame
    inGameMenu.pagingElement:addElement(inGameMenu[pageName])

    inGameMenu:exposeControlsAsFields(pageName)

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
    
    -- print("showType:" .. ProductionInfoHud.settings["display"]["showType"]);
end

function ProductionInfoHud:loadMap(name)
    -- ActionEvents registrieren
    FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, ProductionInfoHud.registerActionEvents);
end

function ProductionInfoHud:update(dt)

    if not ProductionInfoHud.isInit then ProductionInfoHud:init(); end
    
    if not ProductionInfoHud.isClient then return end
    
    ProductionInfoHud.timePast = ProductionInfoHud.timePast + dt;
    
    if ProductionInfoHud.timePast >= 5000 then
        ProductionInfoHud.timePast = 0;

        if ProductionInfoHud.settings["display"]["showType"] == "ALL" or string.find(ProductionInfoHud.settings["display"]["showType"], "PRODUCTION") then 
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
end

function ProductionInfoHud:createProductionNeedingTable(mode)
   
    local factor = 1;
    if mode == InGameMenuProductionInfo.MODE_MONTH then
        factor = 1;
    elseif InGameMenuProductionInfo.MODE_HOUR then
        factor = 1 / (24 * g_currentMission.environment.daysPerPeriod); -- tage einstellungen auslesen!!!
    end

    local farmId = g_currentMission.player.farmId;
    local myFillTypes = {} -- filltypeId is key for finding and adding, change later to sortable
    
    -- productions
    if g_currentMission.productionChainManager.farmIds[farmId] ~= nil and g_currentMission.productionChainManager.farmIds[farmId].productionPoints ~= nil then
        for _, productionPoint in pairs(g_currentMission.productionChainManager.farmIds[farmId].productionPoints) do
            
            for fillTypeId, fillLevel in pairs(productionPoint.storage.fillLevels) do
                -- neu erstellen, wenn nicht da
                if myFillTypes[fillTypeId] == nil then
                    local fillTypeItem = {};
                    fillTypeItem.fillTypeId = fillTypeId;
                    fillTypeItem.usagePerMonth = 0;
                    fillTypeItem.producedPerMonth = 0;
                    fillTypeItem.sellPerMonth = 0;
                    fillTypeItem.keepPerMonth = 0;
                    fillTypeItem.distributePerMonth = 0;
                    local filltype = g_fillTypeManager.fillTypes[fillTypeId]
                    fillTypeItem.fillTypeTitle = filltype.title;
                    fillTypeItem.hudOverlayFilename = filltype.hudOverlayFilename;
                    myFillTypes[fillTypeId] = fillTypeItem;
                end
                local fillTypeItem = myFillTypes[fillTypeId];
                
                for _, production in pairs(productionPoint.activeProductions) do
                    for _, input in pairs(production.inputs) do
                        if input.type == fillTypeId then
                            fillTypeItem.usagePerMonth = fillTypeItem.usagePerMonth + (production.cyclesPerMonth * input.amount) * factor
                        end
                    end
                    for _, output in pairs(production.outputs) do
                        local outputMode = productionPoint:getOutputDistributionMode(fillTypeId)
                        
                        if output.type == fillTypeId then
                            local producedPerMonth = production.cyclesPerMonth * output.amount * factor;
                            fillTypeItem.producedPerMonth = fillTypeItem.producedPerMonth + producedPerMonth
                            
                            if outputMode == ProductionPoint.OUTPUT_MODE.DIRECT_SELL then
                                fillTypeItem.sellPerMonth = fillTypeItem.sellPerMonth + producedPerMonth;
                            elseif outputMode == ProductionPoint.OUTPUT_MODE.AUTO_DELIVER then
                                fillTypeItem.distributePerMonth = fillTypeItem.distributePerMonth + producedPerMonth;
                            else
                                fillTypeItem.keepPerMonth = fillTypeItem.keepPerMonth + producedPerMonth;
                            end
                        end
                    end
                end
                
                --table.insert(myProductions, fillTypeItem)
            end
        end
    end
    
    -- print("myFillTypes");
    -- DebugUtil.printTableRecursively(myFillTypes,"_",0,2);
    
    -- in sortierbare Liste eintragen
    local fillTypeResultTable = {};
    for fillTypeId, fillTypeItem in pairs (myFillTypes) do
        if fillTypeItem.usagePerMonth ~= 0 or fillTypeItem.producedPerMonth ~= 0 then
            table.insert(fillTypeResultTable, fillTypeItem)
        end
    end
    
    table.sort(fillTypeResultTable, compFillTypeResultTable)
    
    -- print("fillTypeResultTable");
    -- DebugUtil.printTableRecursively(fillTypeResultTable,"_",0,2);
    
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
                
                -- nicht mix zutaten werden hier summiert
                for fillTypeId, fillLevel in pairs(productionPoint.storage.fillLevels) do
                    local productionItem = {}
                    productionItem.name = productionPoint.owningPlaceable:getName();
                    productionItem.fillTypeId = fillTypeId
                    productionItem.needPerHour = 0
                    productionItem.hoursLeft = 0
                    productionItem.fillLevel = fillLevel
                    productionItem.capacity = productionPoint.storage.capacities[fillTypeId]
                    productionItem.isInput = false;
                    productionItem.isOutput = false;
                    
                    -- prüfen ob input type
                    if productionPoint.inputFillTypeIds[fillTypeId] ~= nil then
                        productionItem.isInput = productionPoint.inputFillTypeIds[fillTypeId];
                    end
                    -- prüfen ob input type
                    if productionPoint.outputFillTypeIds[fillTypeId] ~= nil then
                        productionItem.isOutput = productionPoint.outputFillTypeIds[fillTypeId];
                    end
                    
                    if productionItem.capacity == 0 then 
                        productionItem.capacityLevel = 0
                    elseif productionItem.capacity == nil then
                        productionItem.capacityLevel = 0
                        -- print("Error: No storage for '" .. g_currentMission.fillTypeManager.fillTypes[fillTypeId].name .. "' in productionPoint but defined to used. Has to be fixed in '" .. productionPoint.owningPlaceable.customEnvironment .."'.")
                    else
                        productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
                    end
                    productionItem.fillTypeTitle = g_currentMission.fillTypeManager.fillTypes[fillTypeId].title;
                    
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
                    end

                    if (productionItem.fillLevel ~= 0) and (productionItem.needPerHour ~= 0) then
                        -- hier die anzahl der Tage pro Monat berücksichtigen
                        productionItem.hoursLeft = productionItem.fillLevel / productionItem.needPerHour * g_currentMission.environment.daysPerPeriod;
                    end
                    
                    if (productionItem.needPerHour > 0 and productionItem.capacityLevel <= 0.5 and productionItem.hoursLeft <= (48 * g_currentMission.environment.daysPerPeriod)) then 
                        table.insert(myProductions, productionItem)
                    end
                    
                    -- Ausgangslager voll, dann speziell eintragen
                    if (productionItem.capacityLevel >= 0.99 and productionItem.isOutput) then 
                        productionItem.hoursLeft = -1;
                        table.insert(myProductions, productionItem)
                    end
                end
                
                -- jetzt noch mal alle mix gruppen die restlaufzeit aller berechnen
                for _, production in pairs(productionPoint.activeProductions) do
                    for n = 1, 5 do
                        local productionItem = {}
                        productionItem.name = productionPoint.owningPlaceable:getName();
                        productionItem.fillTypeTitle = production.name .. " (Mix " .. n .. ")";
                        productionItem.hoursLeft = 0
                        local needed = false;
                        
                        for _, input in pairs(production.inputs) do
                            -- status 3 = läuft nicht weil ausgang voll
                            if input.mix == n then 
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
                        
                        if needed and (productionItem.hoursLeft <= (48 * g_currentMission.environment.daysPerPeriod))then
                            table.insert(myProductions, productionItem)
                        end
                    end
                    
                    if ProductionInfoHud.settings["display"]["showBooster"] then
                        -- jeden booster separat
                        for _, input in pairs(production.inputs) do
                            -- status 3 = läuft nicht weil ausgang voll
                            if input.mix == 6 then 
                                -- richtiger mix type
                                if production.status ~= 3 then
                                    -- wie lange läuft dieser booster?
                                    local productionItem = {}
                                    productionItem.name = productionPoint.owningPlaceable:getName();
                                    productionItem.fillTypeTitle = production.name .. " (booster " .. g_currentMission.fillTypeManager.fillTypes[input.type].title .. ")";
                                    productionItem.capacity = productionPoint.storage.capacities[input.type]
                                    productionItem.fillLevel = productionPoint:getFillLevel(input.type);
                                    
                                    if productionItem.capacity == 0 then 
                                        productionItem.capacityLevel = 0
                                    elseif productionItem.capacity == nil then
                                        productionItem.capacityLevel = 0
                                        print("Error: No storage for '" .. g_currentMission.fillTypeManager.fillTypes[input.type].name .. "' in productionPoint but defined to used. Has to be fixed in '" .. productionPoint.owningPlaceable.customEnvironment .."'.")
                                    else
                                        productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
                                    end
                                    
                                    local needPerHour = (production.cyclesPerHour * input.amount);
                                    productionItem.hoursLeft = productionItem.fillLevel / needPerHour * g_currentMission.environment.daysPerPeriod;
                                    
                                    if (needPerHour > 0 and productionItem.capacityLevel <= 0.5 and productionItem.hoursLeft <= (48 * g_currentMission.environment.daysPerPeriod)) then 
                                        table.insert(myProductions, productionItem)
                                    end
                                end
                            end
                        end
                    end
                end
                
            end
        end
        
        -- Tiere
        for _, placeable in pairs(g_currentMission.husbandrySystem.placeables) do
            if placeable.ownerFarmId == farmId then
                
                -- Futter der Tiere als gesamtes pro Stall
                local productionItem = {}
                productionItem.name = placeable:getName();
                -- productionItem.fillTypeId = fillTypeId
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
                    
                if (productionItem.needPerHour > 0 and productionItem.capacityLevel <= 0.5 and productionItem.hoursLeft <= (48 * g_currentMission.environment.daysPerPeriod)) then 
                    table.insert(myProductions, productionItem)
                end
                
                -- Fütterungsroboter vorhanden, dann anders die werte berechnen
                if placeable.spec_husbandryFeedingRobot ~= nil then
                    local feedingRobot = placeable.spec_husbandryFeedingRobot.feedingRobot;
                    local recipe = feedingRobot.robot.recipe;
                    
-- print("feedingRobot")
-- DebugUtil.printTableRecursively(feedingRobot,"_",0,2)
                    
                    -- Jede zutat der Rezeptes durchlaufen und dann ausrechnen wie lange das hält
                    for _, ingredient in pairs(recipe.ingredients) do
                    
-- print("ingredient")
-- DebugUtil.printTableRecursively(ingredient,"_",0,2)
                        local fillLevel = 0

                        for _, fillType in ipairs(ingredient.fillTypes) do
                            fillLevel = fillLevel + feedingRobot:getFillLevel(fillType)
                        end
                        
                        local producableWithThisIngredient = fillLevel / ingredient.ratio;
                        local hoursLeft = producableWithThisIngredient / placeable.spec_husbandryFood.litersPerHour
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
                                            
                        if (productionItem.capacityLevel <= 0.5 and productionItem.hoursLeft <= (48 * g_currentMission.environment.daysPerPeriod)) then 
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

                        --print(productionItem.name .. " (Wasser) needPerHour: " .. productionItem.needPerHour .. " fillLevel: " .. productionItem.fillLevel .. " capacity: " .. productionItem.capacity)
                        
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
                            
                        if (productionItem.needPerHour > 0 and productionItem.capacityLevel <= 0.5 and productionItem.hoursLeft <= (48 * g_currentMission.environment.daysPerPeriod)) then 
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
                    
                    --print(productionItem.name .. " (Stroh) needPerHour: " .. productionItem.needPerHour .. " fillLevel: " .. productionItem.fillLevel .. " capacity: " .. productionItem.capacity)
                    
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
                        
                    if (productionItem.needPerHour > 0 and productionItem.capacityLevel <= 0.5 and productionItem.hoursLeft <= (48 * g_currentMission.environment.daysPerPeriod)) then 
                        table.insert(myProductions, productionItem)
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
                    
                    --print(productionItem.name .. " (Milch) needPerHour: " .. productionItem.needPerHour .. " fillLevel: " .. productionItem.fillLevel .. " capacity: " .. productionItem.capacity)
                    
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
                        productionItem.hoursLeft = -1;
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
                    
                    --print(productionItem.name .. " (Milch) needPerHour: " .. productionItem.needPerHour .. " fillLevel: " .. productionItem.fillLevel .. " capacity: " .. productionItem.capacity)
                    
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
                        productionItem.hoursLeft = -1;
                        table.insert(myProductions, productionItem)
                    end
                end
                
                -- Tiere voll, also muss was verkauft werden
                if ProductionInfoHud.settings["display"]["showFullAnimals"] and placeable:getNumOfFreeAnimalSlots() == 0 then
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
                        productionItem.fillTypeTitle = g_i18n:getText("helpLine_animals") 
                    end
                    productionItem.capacityLevel = 0;
                    productionItem.hoursLeft = -1;
                    table.insert(myProductions, productionItem)
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

-- print("FS22_SellPriceTrigger.SellPriceTrigger.triggers")
-- DebugUtil.printTableRecursively(FS22_SellPriceTrigger.SellPriceTrigger.triggers,"_",0,2)
    
        
    if g_currentMission.productionChainManager.farmIds[farmId] ~= nil and g_currentMission.productionChainManager.farmIds[farmId].productionPoints ~= nil then
        for _, productionPoint in pairs(g_currentMission.productionChainManager.farmIds[farmId].productionPoints) do
            
            local storageName = productionPoint.owningPlaceable:getName();
-- print("productionPoint.outputFillTypeIds")
-- DebugUtil.printTableRecursively(productionPoint.outputFillTypeIds,"_",0,2)
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
    
    
-- print("prices")
-- DebugUtil.printTableRecursively(prices,"_",0,2)
    

    -- storageSystem benutzen. Storages splitten sich auf, wenn diese zu nah zusammen stehen, aber das ist in LS so und ich kann das nicht ändern.
    local usedStorages = {};
    local storages = g_currentMission.storageSystem:getStorages();
    for i, storage in pairs (storages) do
        -- print(i.." : "..storage.indexName);
        -- print("test");
        -- DebugUtil.printTableRecursively(storage,"_",0,2);
    
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
    
-- print("prices")
-- DebugUtil.printTableRecursively(prices,"_",0,2)
    

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
    local textSize = 12/1000;
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
            if (lineCount < maxLines) then
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
                
                if productionData.hoursLeft == -1 then
                    productionOutputItem.TimeLeftString = g_i18n:getText("Full");
                    productionOutputItem.TextColor = ProductionInfoHud.colors.RED;
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
                        timeString = days .. "d ";
                    else
                        productionOutputItem.TextColor = ProductionInfoHud.colors.YELLOW;
                    end
                    timeString = timeString .. hours .. ":" .. minutes;
                    productionOutputItem.TimeLeftString = timeString;
                end
                table.insert(productionOutputTable, productionOutputItem)
            else
                additionalLines = additionalLines + 1;
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
end

-- local rX, rY, rZ = getRotation(place.node);
-- print("place.node rX:"..rX.." rY:"..rY.." rZ:"..rZ);

-- print("loadingPattern")
-- DebugUtil.printTableRecursively(loadingPattern,"_",0,2)

addModEventListener(ProductionInfoHud);


-- function ProductionInfoHud:removeFillLevel(superFunc, deltaFillLevel, fillTypeIndex)
-- print("ProductionInfoHud:removeFillLevel deltaFillLevel:" .. tostring(deltaFillLevel) .. " - " .. tostring(fillTypeIndex))
    -- local spot = self.fillTypeToUnloadingSpot[fillTypeIndex]
    -- local absDelta = math.abs(deltaFillLevel)

    -- if spot ~= nil then
        -- absDelta = math.min(absDelta, spot.fillLevel)
        -- spot.fillLevel = spot.fillLevel - absDelta

        -- if self.isServer then
            -- self:raiseDirtyFlags(self.dirtyFlagFillLevel)
        -- end

        -- self:updateUnloadingSpot(spot)
    -- end

-- print("ProductionInfoHud:removeFillLevel absDelta: " .. tostring(absDelta) .. " - " .. tostring(fillTypeIndex))
    -- return absDelta
-- end

-- FeedingRobot.removeFillLevel = Utils.overwrittenFunction(FeedingRobot.removeFillLevel, ProductionInfoHud.removeFillLevel)