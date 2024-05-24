pih_DrawBox = {};

function pih_DrawBox.setBox(args)
	if args == nil or type(args) ~= "table" or args.typPos == nil or args.inArea == nil then return;end;
	local box = g_currentMission.hlHudSystem.box[args.typPos];
	if box == nil then return;end;
		
	--pih_SetGet:setBoxAlign(box); --optional vorbereitet für GameInfoDisplay	
		
	local inArea = args.inArea
	local boxNumber = args.typPos;
	
	local x, y, w, h = box:getScreen();	
	
	local mW = w/2;
	local mH = h/2;
	
	local distance = box:getSize( {"distance"} ); 
	local difW = distance.textWidth --default width
	local difH = distance.textHeight; --default height	
	local size = box.screen.size.zoomOutIn.text[1];
	local difSize = 0.0015;	
	
	local overlayFillTypesGroup = g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"];
	local overlayFillTypesByName = g_currentMission.hlUtils.overlays.byName["LS_FillTypes"]["fillTypes"];	
	local overlayDefaultGroup = box.overlays.icons["defaultIcons"]["box"];
	local overlayDefaultByName = box.overlays.icons.byName["defaultIcons"]["box"];	
	local overlay = nil;
	local tempOverlay = nil;	
	local typesOverlay = nil;	
	
	function needsUpdate()		
		if box.needsUpdate or box.ownTable.lineHeight == nil then
			box.ownTable.lineHeight = getTextHeight(size, utf8Substr("Äg", 0))+distance.textLine;
			box.ownTable.iconWidth, box.ownTable.iconHeight = box:getOptiWidthHeight( {typ="icon", height=box.ownTable.lineHeight-distance.textLine-(difH), width=w-(difW*2)} );
			box.ownTable.productivityWidth = getTextWidth(size, utf8Substr(" 100%", 0)); --!
			local timeString = g_i18n:formatNumDay(2) .. " 99:99";
			box.ownTable.timeStringWidth = getTextWidth(size, utf8Substr(timeString, 0)); --!
			--box.ownTable.fillLevelWidth = getTextWidth(size, utf8Substr(g_i18n:formatVolume(999999, 0), 0)); --!	
		end;		
		box.needsUpdate = false;
	end;	
	needsUpdate();
	
	if not g_currentMission.hlUtils.isMouseCursor then box.isSetting = false;end;
	
	local playerFarmId = g_currentMission.player.farmId;
	local iconColor = nil;
	local iconWidth = box.ownTable.iconWidth;
	local iconHeight = box.ownTable.iconHeight;
	local iconWidthS = iconWidth/1.3;
	local iconHeightS = iconHeight/1.3;
	local iconWidthB = iconWidth*1.3;
	local iconHeightB = iconHeight*1.3;
	local iconWidthV = iconWidth*1.8;
	local iconHeightV = iconHeight*1.8;
	local nextPosX = x+difW;
	local nextPosY = y;		
	local nextIconPosX = x+difW;
	local nextLeftPosX = nextPosX;
	local nextRightPosX = x+w-difW;
	nextPosY = nextPosY+(h)-(box.ownTable.lineHeight)-difH;
	local openDetails = pih_SetGet:setViewBoxData(box);
	box.screen.bounds[4] = #ProductionInfoHud.viewBoxData+1; -- +1 for Imaginäre Line wenn untergruppen an sind (viewDetails etc.)
	if box.viewExtraLine then box.screen.bounds[4] = box.screen.bounds[4]+1;end;
	
	
	if box.screen.bounds[1] > 0 then
		--warningLine--
		function setWarningLineIcon()
			overlay = overlayDefaultGroup[overlayDefaultByName["right"]];
			g_currentMission.hlUtils.setOverlay(overlay, x+w-((iconWidth/1.5/2)), nextPosY-0.003, iconWidth/1.5, iconHeight/1.5);
			g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.warning, true));
			local inIconArea = overlay.mouseInArea();
			if inIconArea and box.isHelp then g_currentMission.hlUtils.addTextDisplay( {txt=string.format(box:getI18n("hl_infoDisplay_viewNotAllIcons"), "Box"), maxLine=0, txtSize=0.013, posY=0.12} );end; 
			if g_currentMission.hlUtils.runsTimer("1sec", true) then
				overlay:render();
			end;
		end;
		--warningLine--
		--viewExtraLineSetting--
		function viewExtraLineSetting()
			if nextPosY < y then return;end;
			local setWarningLine = false;
			local inIconArea = false;
			local boxMoreInfo = false;
			if nextIconPosX+iconWidth < x+w then
				overlay = overlayDefaultGroup[overlayDefaultByName["lineHorizontalUpDown"]];
				tempOverlay = box.overlays.bgLine;
				if overlay ~= nil and tempOverlay ~= nil then
					g_currentMission.hlUtils.setOverlay(overlay, nextIconPosX, nextPosY, iconWidth, iconHeight);
					inIconArea = overlay.mouseInArea();
					if inIconArea then g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.inArea, true));else g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.text, true));end;
					overlay:render();
					if inIconArea and box.isHelp then box:setMoreInfo(string.format(box:getI18n("hl_infoDisplay_lineDistance"), string.format("%1.2f", box.screen.size.distance.textLine/box.screen.pixelH)));boxMoreInfo=true;end;					
					if not g_currentMission.hlUtils:disableInArea() and inArea and inIconArea then box:setClickArea( {overlay.x, overlay.x+overlay.width, overlay.y, overlay.y+overlay.height, onClick=pih_MouseKeyEventsBox.onClickArea, whatClick="Pih_Display_Box", typPos=boxNumber, whereClick="settingLineDistance_", ownTable={}} );end;
					nextIconPosX = nextIconPosX+iconWidth+difW;
				end;
			else
				setWarningLine = true;
			end;
			if nextIconPosX+iconWidth < x+w then
				overlay = overlayDefaultGroup[overlayDefaultByName["autoAlign"]];
				tempOverlay = box.overlays.bgLine;
				if overlay ~= nil and tempOverlay ~= nil then
					g_currentMission.hlUtils.setOverlay(overlay, nextIconPosX, nextPosY, iconWidth, iconHeight);
					inIconArea = overlay.mouseInArea();
					local formatTxt = g_i18n:getText("ui_off");
					local status = "";
					if box.ownTable.autoAlign == 1 then g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.text, true));else formatTxt = g_i18n:getText("ui_on");status = "-GAMEINFODISPLAY-";g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.on, true));end;
					overlay:render();
					if inIconArea and box.isHelp then box:setMoreInfo(string.format(g_i18n:getText("box_autoAlign"), formatTxt, status));boxMoreInfo=true;end;					
					if not g_currentMission.hlUtils:disableInArea() and inArea and inIconArea then box:setClickArea( {overlay.x, overlay.x+overlay.width, overlay.y, overlay.y+overlay.height, onClick=pih_MouseKeyEventsBox.onClickArea, whatClick="Pih_Display_Box", typPos=boxNumber, whereClick="settingAutoAlign_", ownTable={}} );end;
					nextIconPosX = nextIconPosX+iconWidth+difW;
				end;
			else
				setWarningLine = true;
			end;			
			if nextIconPosX+(iconWidthB*3) < x+w then
				setTextColor(1, 1, 1, 1);
				renderText(nextIconPosX+difW, nextPosY, size-difSize, tostring(" |S:"..string.format("%1.1f", size*1000)));
			else
				setWarningLine = true;
			end;
			if not boxMoreInfo then box:setMoreInfo();end;
			if setWarningLine then
				setWarningLineIcon();
			end;
			nextPosY = nextPosY-box.ownTable.lineHeight;
		end;
		--viewExtraLineSetting--
		--viewExtraLine--
		function viewExtraLine()
			if nextPosY < y then return;end;			
			local onOffTxt = g_i18n:getText("ui_on").. "/".. g_i18n:getText("ui_off");
			local setWarningLine = false;
			local inIconArea = false;
			function setOverlay(whereClick, color)
				if color == nil then color = box.overlays.color.notActive;end;
				g_currentMission.hlUtils.setOverlay(overlay, nextIconPosX, nextPosY, iconWidth, iconHeight);
				inIconArea = overlay.mouseInArea();
				g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(color, true));
				overlay:render();
				if not g_currentMission.hlUtils:disableInArea() and inArea and inIconArea and whereClick ~= nil then box:setClickArea( {overlay.x, overlay.x+overlay.width, overlay.y, overlay.y+overlay.height, onClick=pih_MouseKeyEventsBox.onClickArea, whatClick="Pih_Display_Box", typPos=boxNumber, whereClick=whereClick, ownTable={}} );end;
				nextIconPosX = nextIconPosX+iconWidth+difW;
				iconColor = nil;				
			end;
			if not setWarningLine and nextIconPosX+iconWidth < x+w then --!!-- sortBy !
				overlay = overlayDefaultGroup[overlayDefaultByName["flip"]];
				if overlay ~= nil then
					if box.ownTable.sortBy > 1 then iconColor = box.overlays.color.on;end;
					setOverlay("sortBy_", iconColor);
					local sortByWhat = g_i18n:getText("button_no"); 
					if box.ownTable.sortBy == 2 then sortByWhat = "NAME";elseif box.ownTable.sortBy == 3 then sortByWhat = "DAYS";elseif box.ownTable.sortBy == 4 then sortByWhat = "TIMES";end;
					if inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=g_i18n:getText("button_sortTable").. "... ".. g_i18n:getText("fieldJob_active").. ": ".. tostring(sortByWhat), txtSize=0.013, posY=0.12} );end;
				end;				
			else
				setWarningLine = true;
			end;
			
			----DaysMinus----
			if not setWarningLine and nextIconPosX+iconWidth < x+w then
				overlay = overlayDefaultGroup[overlayDefaultByName["daysMinusUpDown"]];
				if overlay ~= nil then								
					iconColor = box.overlays.color.text;					
					setOverlay("daysMinusUpDown_", iconColor);
					local moreTxt = "\nState:".. tostring(g_i18n:formatNumDay(box.ownTable.daysLeftFilter));
					if inIconArea and box.isHelp then g_currentMission.hlUtils.addTextDisplay( {txt=g_i18n:getText("pih_moh_infoTextDaysSetting").. moreTxt, maxLine=0, txtSize=0.013, posY=0.12} );end;
				end;					
			else
				setWarningLine = true;
			end;
			if not setWarningLine and nextIconPosX+iconWidth < x+w then
				overlay = overlayDefaultGroup[overlayDefaultByName["daysMinus"]];
				if overlay ~= nil then								
					iconColor = box.overlays.color.on;					
					setOverlay(nil, iconColor);										
				end;					
			else
				setWarningLine = true;
			end;			
			----DaysMinus----
			----CapacityLevelMinus----
			if not setWarningLine and nextIconPosX+iconWidth < x+w then
				overlay = overlayDefaultGroup[overlayDefaultByName["capacityLevelMinusUpDown"]];
				if overlay ~= nil then								
					iconColor = box.overlays.color.text;					
					setOverlay("capacityLevelMinusUpDown_", iconColor);
					local moreTxt = "\nState: ".. tostring(box.ownTable.capacityLevelFilter * 100) .. "%";
					if inIconArea and box.isHelp then g_currentMission.hlUtils.addTextDisplay( {txt=g_i18n:getText("pih_moh_infoTextCapacitySetting").. moreTxt, maxLine=0, txtSize=0.013, posY=0.12} );end; --2 zeilen oder mehr dann maxLine=0 angeben
				end;					
			else
				setWarningLine = true;
			end;
			if not setWarningLine and nextIconPosX+iconWidth < x+w then
				overlay = overlayDefaultGroup[overlayDefaultByName["capacityLevelMinus"]];
				if overlay ~= nil then								
					iconColor = box.overlays.color.on;					
					setOverlay(nil, iconColor);										
				end;					
			else
				setWarningLine = true;
			end;
			----CapacityLevelMinus----			
			
			if not setWarningLine and nextIconPosX+iconWidth < x+w then
				overlay = overlayDefaultGroup[overlayDefaultByName["wheat"]];
				if overlay ~= nil then									
					local moreTxt = "";
					if box.ownTable.viewFillType == 2 then iconColor = box.overlays.color.on;moreTxt = "(Icon)";elseif box.ownTable.viewFillType == 3 then iconColor = box.overlays.color.warning;moreTxt = "(Icon + Name)";else moreTxt = "(Name)";end;
					setOverlay("viewFillTypeIcon_", iconColor);
					local addText = g_i18n:getText("shop_fruitTypes").. "/Name,Icon,Icon + Name ".. moreTxt;
					if inIconArea and box.isHelp then g_currentMission.hlUtils.addTextDisplay( {txt=addText, maxLine=0, txtSize=0.013, posY=0.12} );end;					
				end;					
			else
				setWarningLine = true;
			end;
			if not setWarningLine and nextIconPosX+iconWidth < x+w then
				overlay = overlayDefaultGroup[overlayDefaultByName["closeLines"]];
				if overlay ~= nil then
					if openDetails ~= nil and openDetails then iconColor = box.overlays.color.warning;end;
					if openDetails ~= nil and not openDetails then
						setOverlay(nil, iconColor);
					else
						setOverlay("closeAllDetailsLines_", iconColor);
					end;
					if inIconArea and box.isHelp then g_currentMission.hlUtils.addTextDisplay( {txt=g_i18n:getText("box_closeDetailsLines"), txtSize=0.013, posY=0.12} );end;
				end;					
			else
				setWarningLine = true;
			end;
			if not setWarningLine and nextIconPosX+iconWidth < x+w then
				overlay = overlayDefaultGroup[overlayDefaultByName["infos"]];
				if overlay ~= nil then					
					setOverlay("clickInfoIcon_", box.overlays.color.title); 					
					if inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=g_i18n:getText("box_clickInfos"), maxLine=0, txtSize=0.013, posY=0.12} );end;
				end;					
			else
				setWarningLine = true;
			end;
			
			if setWarningLine then
				setWarningLineIcon();
			end;
			nextPosY = nextPosY-box.ownTable.lineHeight;
		end;
		if box.viewExtraLine and not box.isSetting then viewExtraLine();elseif box.viewExtraLine and box.isSetting then viewExtraLineSetting();end;
		--viewExtraLine--
		
		---deine anzeige daten---
		local color = nil;		
		local titleColor = g_currentMission.hlUtils.getColor(box.overlays.color.columTitle, true);
		local bounds1 = box.screen.bounds[1];
		local bounds2 = box.screen.bounds[2];
		local extraLineBounds = 0; --braucht man nur wenn man vorher nicht genau weiß wieviel Zeilen man anzeigt
		for t=bounds1, bounds2 do			
			overlay = nil;
			tempOverlay = nil;
			typesOverlay = nil;			
			if nextPosY < y then break;end;	--immer abfragen bei jeder zeile und gegbenfalls die anzeige abbrechen wenn die zeile nicht mehr innerhalb der box wäre	
			if ProductionInfoHud.viewBoxData[t] ~= nil then
				local data = ProductionInfoHud.viewBoxData[t];												
				
				color = g_currentMission.hlUtils.getColor(box.overlays.color.text, true);
								
				local canNextView = true;
				local lineWidth = w-(difW*2);
				
				function getInIconArea(posX, posY, width, height) --optional zum abfragen ob spieler in einem text bereich mit der maus ist (und gegebenfalls klickt) um etwas anzuzeigen !
					if not inArea then return false;end;
					overlay = box.overlays.bgLine; --hidden overlay
					if overlay ~= nil then
						g_currentMission.hlUtils.setOverlay(overlay, posX, posY or nextPosY, width or lineWidth, height or box.ownTable.lineHeight);
						return overlay.mouseInArea();
					end;
					return false;
				end;
				
				
				---------------------------------------------------------------------------deine zeilen				
				local text = "";
				if canNextView then	--spalte 3
					text = tostring(data[3].txt);
					text = g_currentMission.hlUtils.getTxtToWidth(text, size, lineWidth, true, "."); --hier ein *true* damit er von vorne die buchstaben(text) kürzt
					color = g_currentMission.hlUtils.getColor(data[3].color, true);
					setTextBold(data[3].bold);
					setTextColor(unpack(color));
					setTextAlignment(2);					
					renderText(nextRightPosX, nextPosY, size-difSize, tostring(text)); --optional difSize bei der Anzeige um differenzen bei umlauten oder ... auszugleichen				
					setTextColor(1, 1, 1, 1);
					setTextAlignment(0);
					setTextBold(false);
					
					--text help--
					if data[3].infoTxt ~= nil and data[3].infoTxt:len() > 0 and box.isHelp then
						local inIconArea = getInIconArea(nextRightPosX-box.ownTable.timeStringWidth, nil, box.ownTable.timeStringWidth);						
						if inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=tostring(data[3].infoTxt), maxLine=0, txtSize=0.013, posY=0.12} );end;
					end;
					--text help--					
					---clickArea erstellen *pih_MouseKeyEventsBox.lua* onClickArea--
					if not g_currentMission.hlUtils:disableInArea() and inArea then box:setClickArea( {nextRightPosX-box.ownTable.timeStringWidth, nextRightPosX, nextPosY, nextPosY+box.ownTable.lineHeight, onClick=pih_MouseKeyEventsBox.onClickArea, whatClick="Pih_Display_Box", typPos=boxNumber, whereClick=tostring(data[3].whereClick), ownTable={data[1].txt}} );end;
					---clickArea erstellen *pih_MouseKeyEventsBox.lua* onClickArea--
					
					--zeilen daten ändern dann--
					lineWidth = lineWidth-box.ownTable.timeStringWidth;
					nextRightPosX = nextRightPosX-box.ownTable.timeStringWidth;
					canNextView = lineWidth > iconWidth; --< wichtig um sicherzustellen das weitere daten in die zeile zum anzeigen passen
					--zeilen daten ändern dann--
				end;
				
				if canNextView then --spalte 2
					local tempWidth = 0;
					local setFillTypeIcon = false;
					if box.ownTable.viewFillType > 1 and data[2].fillTypeIndex ~= nil then
						local fillTypeName = g_fillTypeManager:getFillTypeNameByIndex(data[2].fillTypeIndex);
						overlay = overlayFillTypesGroup[overlayFillTypesByName[fillTypeName]];
						if overlay ~= nil then
							g_currentMission.hlUtils.setOverlay(overlay, nextRightPosX-iconWidthB, nextPosY-difH, iconWidthB, iconHeightB);
							overlay:render();
							lineWidth = lineWidth-iconWidthB;
							nextRightPosX = nextRightPosX-iconWidthB;
							canNextView = lineWidth > iconWidth;
							setFillTypeIcon = true;
						end;
					end;
					if canNextView and (box.ownTable.viewFillType == 1 or box.ownTable.viewFillType == 3 or data[2].fillTypeIndex == nil) then
						text = tostring(data[2].txt);
						text = g_currentMission.hlUtils.getTxtToWidth(text, size, lineWidth, true, "."); --hier ein *true* damit er von vorne die buchstaben(text) kürzt
						if nextRightPosX > nextLeftPosX then
							setTextAlignment(2);
						end;
						color = g_currentMission.hlUtils.getColor(data[2].color, true);
						setTextBold(data[2].bold);
						setTextColor(unpack(color));
						renderText(nextRightPosX, nextPosY, size-difSize, tostring(text));
						setTextColor(1, 1, 1, 1);
						setTextAlignment(0);
						setTextBold(false);
												
						tempWidth = getTextWidth(size, utf8Substr(text, 0)); --wenn möglichkeit besteht die textlänge festzuhinterlegen dann optional über needsUpdate() eventuell schon hinterlegen oder anders (eventuell mit icons arbeiten da diese immer die gleiche breite und höhe hätten)
						if setFillTypeIcon then tempWidth = tempWidth+iconWidthB;end;
					else
						tempWidth = iconWidthB;
						local inIconArea = getInIconArea(nextRightPosX, nil, tempWidth);
						if inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=tostring(data[2].txt), txtSize=0.013, posY=0.12} );end;
					end;
					
					--text help--
					if data[2].infoTxt ~= nil and data[2].infoTxt:len() > 0 and box.isHelp then
						local inIconArea = getInIconArea(nextRightPosX-tempWidth, nil, tempWidth);						
						if inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=tostring(data[2].infoTxt), maxLine=0, txtSize=0.013, posY=0.12} );end;
					end;
					--text help--
					---clickArea erstellen *pih_MouseKeyEventsBox.lua* onClickArea--
					if not g_currentMission.hlUtils:disableInArea() and inArea then box:setClickArea( {nextRightPosX-tempWidth, nextRightPosX, nextPosY, nextPosY+box.ownTable.lineHeight, onClick=pih_MouseKeyEventsBox.onClickArea, whatClick="Pih_Display_Box", typPos=boxNumber, whereClick=tostring(data[2].whereClick), ownTable={data[1].txt, data[2].txt}} );end;
					---clickArea erstellen *pih_MouseKeyEventsBox.lua* onClickArea--
					
					--zeilen daten ändern dann--					
					lineWidth = lineWidth-tempWidth;
					nextRightPosX = nextRightPosX-tempWidth;
					canNextView = lineWidth > iconWidth;
					--zeilen daten ändern dann--
				end;
				
				if canNextView then --spalte 1
					if data[1].canViewDetails then
						tempOverlay = overlayDefaultGroup[overlayDefaultByName["viewDetails"]];
					else
						tempOverlay = overlayDefaultGroup[overlayDefaultByName["viewDetailsBlank"]];
					end;
					if g_currentMission.hlUtils.isMouseCursor and tempOverlay ~= nil and canNextView and data[1].isMainLine and not data[1].viewIsFiltered then
						g_currentMission.hlUtils.setOverlay(tempOverlay, nextLeftPosX, nextPosY, iconWidth, iconHeight);
						if data[1].canViewDetails then
							local stateColor = nil;
							if box.ownTable.openProductions[data[1].txt] ~= nil and box.ownTable.openProductions[data[1].txt] == true then
								stateColor = box.overlays.color.on;
							else
								stateColor = box.overlays.color.text;
							end;
							g_currentMission.hlUtils.setBackgroundColor(tempOverlay, g_currentMission.hlUtils.getColor(stateColor, true));							
						end;
						tempOverlay:render();
						nextLeftPosX = nextLeftPosX+iconWidth+difW;
						lineWidth = lineWidth-iconWidth;
						canNextView = lineWidth > iconWidth;						
						if data[1].canViewDetails then
							local inIconArea = tempOverlay.mouseInArea();
							--icon help--
							if inIconArea and box.isHelp then g_currentMission.hlUtils.addTextDisplay( {txt=g_i18n:getText("pih_moh_colapseEntry"), txtSize=0.013, posY=0.12} );end;
							--icon help--
							---clickArea erstellen *pih_MouseKeyEventsBox.lua* onClickArea--
							if not g_currentMission.hlUtils:disableInArea() and inArea and inIconArea then box:setClickArea( {tempOverlay.x, tempOverlay.x+tempOverlay.width, nextPosY, nextPosY+box.ownTable.lineHeight, onClick=pih_MouseKeyEventsBox.onClickArea, whatClick="Pih_Display_Box", typPos=boxNumber, whereClick="viewDetails_", ownTable={data[1].txt}} );end;
							---clickArea erstellen *pih_MouseKeyEventsBox.lua* onClickArea--
						end;
					end;
					if canNextView and data[1].isMainLine then
						text = tostring(data[1].txt);
						text = g_currentMission.hlUtils.getTxtToWidth(text, size, lineWidth, false, "."); --hier ein *false* damit er von hinten die buchstaben(text) kürzt
						color = g_currentMission.hlUtils.getColor(data[1].color, true);
						setTextBold(data[1].bold);
						setTextColor(unpack(color));
						renderText(nextLeftPosX, nextPosY, size-difSize, tostring(text));
						setTextColor(1, 1, 1, 1);
						setTextBold(false);
						
						local textWidth = getTextWidth(size, utf8Substr(text, 0));						
						--text help--
						if data[1].infoTxt ~= nil and data[1].infoTxt:len() > 0 and box.isHelp then
							local inIconArea = getInIconArea(nextLeftPosX, nil, textWidth);						
							if inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=tostring(data[1].infoTxt), maxLine=0, txtSize=0.013, posY=0.12} );end;
						end;
						--text help--						
						---clickArea erstellen *pih_MouseKeyEventsBox.lua* onClickArea--
						if not g_currentMission.hlUtils:disableInArea() and inArea then box:setClickArea( {nextLeftPosX, nextLeftPosX+textWidth, nextPosY, nextPosY+box.ownTable.lineHeight, onClick=pih_MouseKeyEventsBox.onClickArea, whatClick="Pih_Display_Box", typPos=boxNumber, whereClick=tostring(data[1].whereClick), ownTable={data[1].txt, data[1].productionData}} );end;
						---clickArea erstellen *pih_MouseKeyEventsBox.lua* onClickArea--
						
						--zeilen daten ändern dann, wenn notwendig--					
						lineWidth = lineWidth-textWidth;
						nextLeftPosX = nextLeftPosX+textWidth;
						canNextView = lineWidth > iconWidth;
						--zeilen daten ändern dann, wenn notwendig--
					end;
				end;							
				---------------------------------------------------------------------------deine zeilen
				
				
				--für nächste zeile daten neu schreiben--
				nextPosY = nextPosY-box.ownTable.lineHeight;
				nextRightPosX = x+w-difW;
				nextLeftPosX = x+difW;
				--für nächste zeile daten neu schreiben--
			elseif #ProductionInfoHud.viewBoxData == 0 then --optional deine daten 0 or spieler in keiner farm oder ... !
				color = box.overlays.color.text;
				local moreTxt = "";
				local text = "";				
				text = g_currentMission.hlUtils.getTxtToWidth(tostring(g_i18n:getText("character_option_none")).. moreTxt, size, w-(difW*2), false, ".");							
				setTextColor(unpack(g_currentMission.hlUtils.getColor(color, true)));
				renderText(nextLeftPosX, nextPosY, size, tostring(text));
				setTextColor(1, 1, 1, 1);
				break;			
			end;
			if extraLineBounds+t >= bounds2 then break;end; --braucht man nur wenn man vorher nicht genau weiß wieviel Zeilen man anzeigt
		end;
		---deine anzeige daten---
		box.screen.bounds[4] = box.screen.bounds[4]+extraLineBounds; --braucht man nur wenn man vorher nicht genau weiß wieviel Zeilen man anzeigt
	end;	
end;