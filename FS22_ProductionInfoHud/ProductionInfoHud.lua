--- Anzeige für Produktionen in einem HUD by achimobil@hotmail.com

ProductionInfoHud = {}

ProductionInfoHud.metadata = {
	title = "ProductionInfoHud",
	notes = "Anzeige für Produktionen in einem HUD",
	author = "Achimobil",
	info = "Das verändern und wiederöffentlichen, auch in Teilen, ist untersagt und wird abgemahnt."
};
ProductionInfoHud.modDir = g_currentModDirectory;
ProductionInfoHud.firstRun = false;
ProductionInfoHud.isClient = false;
ProductionInfoHud.timePast = 0;
ProductionInfoHud.overlay = Overlay.new(HUD.MENU_BACKGROUND_PATH, 0, 0, 0, 0);

function ProductionInfoHud:init()
    ProductionInfoHud.isClient = g_currentMission:getIsClient();
    ProductionInfoHud.isInit = true;
end

function ProductionInfoHud:loadMap(name)
end

function ProductionInfoHud:update(dt)

    if not ProductionInfoHud.isInit then ProductionInfoHud:init(); end
	
    if not ProductionInfoHud.isClient then return end
    
    ProductionInfoHud.timePast = ProductionInfoHud.timePast + dt;
	
    if ProductionInfoHud.timePast >= 5000 then
		ProductionInfoHud.timePast = 0;
        ProductionInfoHud:refreshProductionsTable();
    end
	
    if not ProductionInfoHud.firstRun then
        -- print("Testoutput")
        -- DebugUtil.printTableRecursively(g_currentMission,"_",0,1)        
        ProductionInfoHud.firstRun = true;
    end
end

function ProductionInfoHud:refreshProductionsTable()
        
        local farmId = g_currentMission.player.farmId;
        local myProductions = {}
        
        if g_currentMission.productionChainManager.farmIds[farmId] ~= nil and g_currentMission.productionChainManager.farmIds[farmId].productionPoints ~= nil then
            for _, productionPoint in pairs(g_currentMission.productionChainManager.farmIds[farmId].productionPoints) do
-- print("productionPoint")
-- DebugUtil.printTableRecursively(productionPoint,"_",0,2)
                for fillTypeId, fillLevel in pairs(productionPoint.storage.fillLevels) do
                    local productionItem = {}
                    productionItem.name = productionPoint.owningPlaceable:getName();
                    productionItem.fillTypeId = fillTypeId
                    productionItem.needPerHour = 0
                    productionItem.hoursLeft = 0
                    productionItem.fillLevel = fillLevel
                    productionItem.capacity = productionPoint.storage.capacities[fillTypeId]
                    if productionItem.capacity == 0 then 
                        productionItem.capacityLevel = 0
                    else
                        productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
                    end
                    productionItem.fillTypeTitle = g_currentMission.fillTypeManager.fillTypes[fillTypeId].title;
                    
                    for _, production in pairs(productionPoint.activeProductions) do
                        for _, input in pairs(production.inputs) do
                            if input.type == fillTypeId then
                                productionItem.needPerHour = productionItem.needPerHour + (production.cyclesPerHour * input.amount)
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
                end
            end
        end

        table.sort(myProductions, compPrductionTable)
        
        ProductionInfoHud.productionDataSorted = myProductions;
        
        -- print("myProductions")
        -- DebugUtil.printTableRecursively(myProductions,"_",0,2)
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
    
    local lineCount = 0;
    local maxLines = 5;
    local productionOutputTable = {}
    local posX = 0.413;
    local posY = 0.97;
    local posYStart = posY;
    local textSize = 12/1000;
    local totalTextHeigh = 0;
    local maxTextWidth = 0;

    for _, productionData in pairs(ProductionInfoHud.productionDataSorted) do
        if (lineCount < maxLines) then
            
            lineCount = lineCount + 1;
        
            local productionOutputItem = {}
            productionOutputItem.productionPointName = productionData.name
            productionOutputItem.fillTypeTitle = productionData.fillTypeTitle
            
            if productionData.hoursLeft <= 0 then
                productionOutputItem.TimeLeftString = "Empty";
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
                end
                timeString = timeString .. hours .. ":" .. minutes;
                productionOutputItem.TimeLeftString = timeString;
            end
            table.insert(productionOutputTable, productionOutputItem)
        end
    end
        
    for _, productionOutputItem in pairs(productionOutputTable) do
        posY = posY - textSize;
                        
        local textLine = (productionOutputItem.productionPointName .. " - " .. productionOutputItem.fillTypeTitle .. " - " .. productionOutputItem.TimeLeftString);
        totalTextHeigh = totalTextHeigh + getTextHeight(textSize, textLine)
        local textWidth = getTextWidth(textSize, textLine);
        if (textWidth > maxTextWidth) then maxTextWidth = textWidth; end
        
        setTextColor(1,1,1,1);								
        setTextBold(false);
        renderText(posX,posY,textSize,textLine);
    end
                
		
	
		-- overlay für produktionen
		setOverlayColor(ProductionInfoHud.overlay.overlayId, 0, 0, 0, 0.7);
		setOverlayUVs(ProductionInfoHud.overlay.overlayId, 0.0078125,0.990234375, 0.0078125,0.9921875, 0.009765625,0.990234375, 0.009765625,0.9921875);
		ProductionInfoHud.overlay:setPosition(posX-0.001, posYStart - totalTextHeigh - 0.002);
		ProductionInfoHud.overlay:setDimension(maxTextWidth+0.002, totalTextHeigh);
		ProductionInfoHud.overlay:render();
end


-- local rX, rY, rZ = getRotation(place.node);
-- print("place.node rX:"..rX.." rY:"..rY.." rZ:"..rZ);

-- print("loadingPattern")
-- DebugUtil.printTableRecursively(loadingPattern,"_",0,2)

addModEventListener(ProductionInfoHud);