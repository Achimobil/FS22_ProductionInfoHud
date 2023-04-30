pihOutputForMoh = {};
--du hast vollen zugriff auf das _hl.lua script und fragste die werte von dort zum Beispiel mit g_currentMission.hl.getProzentColor(args, args) <-- einfach mal in die lua rein schauen,hat etliche funktionen,incl Laufschrift !!!hast nur zugriff wenn es von einem meiner mods hinterlegt wurde,am besten mit g_currentMission.hl ~= nil vorher prüfen

function pihOutputForMoh:load(cmdTable, slotTable) --cmdTable ist dein hinterlegter Befehl und damit hast du auch deine ownTable die du dort optional hinterlegt hast mit eigenen werten, slotTable ist der Anzeige Slot wenn du von diesem irgendwelche Relevanten Daten brauchst
	local playerFarmId = g_currentMission.player.farmId;
	local cmdRegName = cmdTable.regName;
	
-- print("cmdTable")
-- DebugUtil.printTableRecursively(cmdTable,"_",0,2)
-- print("slotTable")
-- DebugUtil.printTableRecursively(slotTable,"_",0,2)
	
	
	-- pihOutputForMoh:loadTest(cmdTable, slotTable); --zum testen eingerichtet, kannste deaktivieren dann
	
		
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
	isLineTable.txt[1].txt = tostring(g_i18n:formatNumDay(cmdTable.ownTable.daysLeftFilter));
	isLineTable.txt[1].prozentColor = 3;
	
	-- +/- davor und dahinter clickbar
	if g_currentMission.hl.isMouseCursor then
		local iconColor = "yellow";
		if isLineTable.txt[1].icon == nil then isLineTable.txt[1].icon = {before={},after={},behindTxt={}};end;
		isLineTable.txt[1].icon.behindTxt[#isLineTable.txt[1].icon.behindTxt+1] = {name="buttonUpDown", color=iconColor, settingButton=true, callback={[1]=pihOutputForMoh.clickDaysMinus}, infoTxt="Left for down, right for up"};
	end
	
	isLineTable.txt[2] = {};
	isLineTable.txt[2].slotColor = "txtOutputTitle";
	isLineTable.txt[2].txt = "ProductionInfo Hud";
	isLineTable.txt[2].width = 60;
	isLineTable.txt[2].bold = true;
	isLineTable.txt[2].alignment = 2;
	if slotTable ~= nil and slotTable.help.outputOn then
		isLineTable.txt[2].icon = {before={},after={}};
		isLineTable.txt[2].icon.before[1] = {name="buttonHelp", color="yellow", settingButton=true, callback={[1]=pihOutputForMoh.clickIconHelpTxt}};
	end;
	isLineTable.txt[3] = {};
	isLineTable.txt[3].alignment = 3;
	isLineTable.txt[3].width = 20;
	isLineTable.txt[3].callback = pihOutputForMoh.clickCapacityLevelMinus;
	isLineTable.txt[3].txt = tostring(cmdTable.ownTable.capacityLevelFilter * 100) .. "%";
	isLineTable.txt[3].prozentColor = 3;
	
	-- +/- davor und dahinter clickbar
	if g_currentMission.hl.isMouseCursor then
		local iconColor = "yellow";
		if isLineTable.txt[3].icon == nil then isLineTable.txt[3].icon = {before={},after={},behindTxt={}};end;
		isLineTable.txt[3].icon.after[#isLineTable.txt[3].icon.after+1] = {name="buttonUpDown", color=iconColor, settingButton=true, callback={[1]=pihOutputForMoh.clickCapacityLevelMinus}, infoTxt="Left for down, right for up"};
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
			if productionData.capacityLevel ~= nil and productionData.capacityLevel > cmdTable.ownTable.capacityLevelFilter then
				goto skipProductionData;
			end
			
			if productionData.hoursLeft ~= nil then
				local compareValue = 24 * cmdTable.ownTable.daysLeftFilter;
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
			isLineTable.txt[1].icon.before[1] = {name=buttonName, color=iconColor, settingButton=true, callback={[1]=pihOutputForMoh.clickViewProductionInfo}, ownTable={productionName}, infoTxt="Production Info"};
		end;
		

		local timeLeftString = nil;
		local timeColor = 1; --als int, prozent color farbe der schrift fest hinterlegt in dem _hl.lua script welches alle meine mods haben --> 1="white", 2="green", 3="yellowGreen", 4="yellow", 5="orange", 6="orangeRed", 7="red"};
		if cmdTable.ownTable.showMissingAmount then
			if productionData.capacity ~= nil and productionData.fillLevel ~= nil then
				timeLeftString = g_i18n:formatVolume(productionData.capacity - productionData.fillLevel, 0)
			else
				timeLeftString = "";
			end
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
		isLineTable.txt[2].alignment = 1;
		isLineTable.txt[2].width = 35;
		isLineTable.txt[2].prozentColor = timeColor;
		if cmdTable.ownTable.filterForFillType ~= nil then
			isLineTable.txt[2].prozentColor = 2;
		end
				
		isLineTable.txt[3] = {};
		isLineTable.txt[3].txt = tostring(timeLeftString);
		isLineTable.txt[3].callback = pihOutputForMoh.clickOnTimeColumn;
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

-- print("args")
-- DebugUtil.printTableRecursively(args,"_",0,2)
	if args == nil or type(args) ~= "table" then return;end;
	if args.mouseClick == "MOUSE_BUTTON_LEFT" and args.isDown and args.cmdTable.ownTable.daysLeftFilter > 1 then
		args.cmdTable.ownTable.daysLeftFilter = args.cmdTable.ownTable.daysLeftFilter - 1;
	end;
	if args.mouseClick == "MOUSE_BUTTON_RIGHT" and args.isDown and args.cmdTable.ownTable.daysLeftFilter < 10 then
		args.cmdTable.ownTable.daysLeftFilter = args.cmdTable.ownTable.daysLeftFilter + 1;
	end;
end;

function pihOutputForMoh.clickCapacityLevelMinus(args)

-- print("args")
-- DebugUtil.printTableRecursively(args,"_",0,2)
	if args == nil or type(args) ~= "table" then return;end;
	if args.mouseClick == "MOUSE_BUTTON_LEFT" and args.isDown and args.cmdTable.ownTable.capacityLevelFilter > 0.05 then
		args.cmdTable.ownTable.capacityLevelFilter = args.cmdTable.ownTable.capacityLevelFilter - 0.05;
	end;
	if args.mouseClick == "MOUSE_BUTTON_RIGHT" and args.isDown and args.cmdTable.ownTable.capacityLevelFilter < 1 then
		args.cmdTable.ownTable.capacityLevelFilter = args.cmdTable.ownTable.capacityLevelFilter + 0.05;
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

function pihOutputForMoh.clickOnProductionColumn(args) --Callback für Strings -Beispiel
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
        g_currentMission.multiOverlayV4.moSetGetOverlays.infoHelpBox.help.titel = "ProduktionsInfoHud Help";
        g_currentMission.multiOverlayV4.moSetGetOverlays.infoHelpBox.help.txt = "Click Left Mouse on Production name or Filltype to filter list. Press again to remove filter\nRight click on Production Name to open Production Menu\nClick Left Mouse on Time left to switch between time left and free available capacity";
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



---für test anzeige, kannste später raus löschen oder drinn lassen wie du willst---
local testValue = false;
function pihOutputForMoh:loadTest(cmdTable, slotTable)
	local playerFarmId = g_currentMission.player.farmId;
	local cmdRegName = cmdTable.regName;
	local lineTable = {line={}};
	function setSeparator() --für output table mit 2 spalten
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
	
	--erste zeile und erste spalte--
	lineTable.line[#lineTable.line+1] = {};
	local isLineTable = lineTable.line[#lineTable.line];
	isLineTable.txt = {};
	isLineTable.txt[1] = {};	 --über ..txt[1], ..txt[2], ..txt[3] etc. damit legst du fest wieviele spalten die linie hat, das prüft der MOH vorher, je nachdem wielang eine text ist wird der dieser vom MOH gekürzt und die Spieler müssen den Slot dann breiter machen um den text komplett zu sehen
	isLineTable.txt[1].slotColor = "txtOutputTitle"; --als string, color farben die fest hinterlegt sind in der moSetGetSlot.lua /settingOn,settingOff,settingReady,settingDefault,settingActiveCmd,settingAlreadyExistsCmd,txtExtra,txtOutputTitle,txt,ground,txtTitle,txtMarker,selectMarker;
	--isLineTable.txt[1].prozentColor = 2; --als int, prozent color farbe der schrift fest hinterlegt in dem _hl.lua script welches alle meine mods haben --> 1="white", 2="green", 3="yellowGreen", 4="yellow", 5="orange", 6="orangeRed", 7="red"};
	--isLineTable.txt[1].otherColor = {1, 1, 1, 1}; --als table, color farbe der schrift von dir selbst oder woher auch immer
	--isLineTable.txt[1].outputColor = "txtGreatDemandColor"; --möglichkeiten als string--> txtGreatDemandColor,txtFillTypesColor,txtAmountColor,txtPriceColor,txtNoPriceColor,txtNoAmountColor;
	--isLineTable.txt[1].color = "darkGreen" --als string, color farben die festhinterlegt sind in dem _hl.lua script welches alle meine mods haben	
	isLineTable.txt[1].bold = true; --soll die schrift fett angezeigt werden oder nicht, default ist immer false
	isLineTable.txt[1].txt = tostring("Zeile 1 erste Spalte"); --der txt der in der ersten spalte angezeigt werden soll, ! solltest du immer als string hinterlegen das spart fehlermeldungen ! also keine Int,Float,table etc.
	isLineTable.txt[1].callback = pihOutputForMoh.testClickFirstLineString; --Callback für den txt[1] String -Beispiel
	isLineTable.txt[1].ownTable = {"hier kann man eigene Werte hinterlegen die man dann bei Callbacks bekommt wenn man callback nutzt"}; --diese table wird mit übergeben, zum beispiel von einem Object die node.id um einen teleport zu ermöglichen oder was auch immer
	isLineTable.txt[1].alignment = 1; --1,2 oder 3, default ist immer 1 also links bündig, 2 ist mittig und 3 ist rechts bündig !immer an die breite der spalte angelegt!
	isLineTable.txt[1].width = 60; --damit legst du fest das er die erste spalte nur 60 breit macht und die zweite würde 40 sein oder wenn du drei spalten hast dann zweite spalte 20 und dritte spalte 20, ansonst musst du in jeder txt[x].width einen wert selbst hinterlegen, wenn dann überall hinterlegen das spart rechen zeit,also wenn du bei txt[x].width was hinterlegt dann hinterlege auch in der zeile bei den anderen txt[x] die werte
	--erste zeile und erste spalte--
	--erste zeile und zweite spalte--
	isLineTable.txt[2] = {};
	isLineTable.txt[2].prozentColor = 3;
	--isLineTable.txt[1].bold = false;
	isLineTable.txt[2].txt = tostring("Zeile 1 zweite Spalte");
	isLineTable.txt[2].alignment = 3;
	isLineTable.txt[2].width = 40;	
	--erste zeile und zweite spalte--
	
	setSeparator();
	
	--zweite zeile und erste spalte, zweite spalte und dritte spalte-- width ist ihr nicht hinterlegt und damit automatisch 100/3 = 33.33 länge für jede spalte
	lineTable.line[#lineTable.line+1] = {};
	isLineTable = lineTable.line[#lineTable.line];
	isLineTable.txt = {};
	isLineTable.txt[1] = {};
	isLineTable.txt[1].color = "txtMarker";	
	isLineTable.txt[1].txt = tostring("Zeile 2 erste Spalte");	
	isLineTable.txt[2] = {};
	isLineTable.txt[2].color = "txtTitle";	
	isLineTable.txt[2].txt = tostring("Zeile 2 zweite Spalte")
	isLineTable.txt[2].bold = true;
	isLineTable.txt[2].alignment = 2;
	isLineTable.txt[3] = {};
	isLineTable.txt[3].color = "txtTitle";	
	isLineTable.txt[3].txt = tostring("Zeile 2 dritte Spalte")	
	isLineTable.txt[3].alignment = 3;
	--zweite zeile und erste spalte, zweite spalte und dritte spalte--
	
	setSeparator();
	
	--dritte zeile und erste spalte und zweite spalte-- mit Icons
	lineTable.line[#lineTable.line+1] = {};
	isLineTable = lineTable.line[#lineTable.line];
	isLineTable.txt = {};
	isLineTable.txt[1] = {};
	isLineTable.txt[1].color = "txtMarker";	
	isLineTable.txt[1].txt = tostring("Zeile 3 erste Spalte");
	--icon
	if isLineTable.txt[1].icon == nil then isLineTable.txt[1].icon = {before={},after={},behindTxt={}};end; --nil abfrage, weil wenn man mehre hintereinander setzt kann man sich änderung sparen,weil man schonmal vergisst das man schon das icon tabel vorher gesetzte hatte
	isLineTable.txt[1].icon.before[#isLineTable.txt[1].icon.before+1] = {name="viewWarning", modName="MultiOverlayV4", groupName="slotoutput", slotColor="settingReady", callback={[1]=pihOutputForMoh.testClickLineIcon}, ownTable={1, true}, infoTxt="Icon 1 was man klicken kann"};
	--icon
	isLineTable.txt[2] = {};
	isLineTable.txt[2].color = "txtTitle";	
	isLineTable.txt[2].txt = tostring("Test Value")
	isLineTable.txt[2].bold = true;
	--isLineTable.txt[2].alignment = 3;
	if isLineTable.txt[2].icon == nil then isLineTable.txt[2].icon = {before={},after={},behindTxt={}};end; --behindTxt kann man nutzen wenn man das icon genau hinter einem text haben möchte ansonsten wird es an anfang der spalte gesetzt (before) oder ans ende (after) ! in dieser txt Spalte !
	local iconColor = "red";
	if testValue then iconColor = "green";end;
	isLineTable.txt[2].icon.before[#isLineTable.txt[2].icon.before+1] = {name="buttonOnOff", color=iconColor, settingButton=true, callback={[1]=pihOutputForMoh.testClickLineIcon}, ownTable={2, false}, infoTxt="Icon 2 was man klicken kann"}; --callback={...,[2]...} wäre ein Icon welches man oben und unten klicken kann zum Beispiel ein Up Down Icon der erste Werte ist dann für Up und der zweite für Down (dito right/left) is settingButton=true
	--icon setting namen stehen in der settings.xml im zip ordner von MOH /icons/settings.xml diese fangen alle mit button... an, brauchst du nur wenn du auch settingButton=true hast, andernfalls kannst du auch eigene in den moh hinzufügen oder die hinterlegten nutzen, siehe vorherige Icon bei txt[1]
	--dritte zeile und erste spalte und zweite spalte-- mit Icons
	
	
	
	pihOutputForMoh[cmdRegName] = {output=lineTable}; --das tabel wird am schluss erst übergeben, so hat man die möglichkeit seine lineTable nochmal zu bearbeiten hinterher,um zum Beispiel in der ersten Zeile einen Text neu zusetzen weil man gerne noch eine anzahl in klammern setzen möchte die man vorher noch nicht weiss oder oder
end;


function pihOutputForMoh.testClickFirstLineString(args) --Callback für Strings -Beispiel
	if args == nil or type(args) ~= "table" and args.ownTable == nil then return false;end; --Info, du hast einen wert bei ownTable hinterlegt den du unbedingt brauchst in diesem callback, dann vorher prüfen args.ownTable[1] oder wie du es dort auch hinterlegt hast
	--if args == nil or type(args) ~= "table" then return;end;	--Info, ohne ownTable prüfung
	if args.mouseClick == "MOUSE_BUTTON_LEFT" and args.isDown then	--welche Mousetaste hat der Spieler geklickt, so kannst du auf verschieden klicks reagieren, die freigabe dafür wird in deinem hinterlegten Cmd festgelegt (pihSetGetForMoh.loadCmds)
		if args.ownTable ~= nil then
			--mach was
			if args.ownTable.productionPoint ~= nil and args.ownTable.productionPoint.openMenu ~= nil then
				args.ownTable.productionPoint:openMenu();
			end
-- print("args")
-- DebugUtil.printTableRecursively(args,"_",0,2)
			-- g_currentMission:showBlinkingWarning("Click Line 1 Mouse Left", 2000);
		end;
	elseif args.mouseClick == "MOUSE_BUTTON_RIGHT" then
		--mach was anderes
		-- g_currentMission:showBlinkingWarning("Click Line 1 Mouse Right", 2000);
	end;
end;

function pihOutputForMoh.testClickLineIcon(args) --Double Callback für Icon -Beispiel, man könnte auch für jedes Icon einen eigenen Callback machen
	if args == nil or type(args) ~= "table" and args.ownTable == nil then return false;end;
	if args.mouseClick == "MOUSE_BUTTON_LEFT" and args.isDown then 
		if args.ownTable[1] ~= nil and args.ownTable[2] ~= nil then
			if args.ownTable[1] == 1 then
				testValue = args.ownTable[2];
			elseif args.ownTable[1] == 2 then
				testValue = args.ownTable[2];
			end;
			g_currentMission:showBlinkingWarning("Click Icon Mouse Left", 2000);
		end;
	end;
end;
---für test anzeige, kannste später raus löschen oder drinn lassen wie du willst---
