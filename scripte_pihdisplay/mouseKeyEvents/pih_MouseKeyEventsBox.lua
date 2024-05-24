pih_MouseKeyEventsBox = {};

function pih_MouseKeyEventsBox.onClick(args)
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return;end;
	if args.isDown then
		if g_currentMission.hlUtils.dragDrop.on then return;end;
		if args.button == Input.MOUSE_BUTTON_LEFT then
			local box = args.box;
			if box ~= nil then
				if args.clickAreaTable.whereClick == "settingInBox_" and args.clickAreaTable.areaClick == "settingIcon_" then
					if box.isSetting then 
						box.ownTable.lastStateExtraLine=box.viewExtraLine;
						box.viewExtraLine = true;
					else 
						box.viewExtraLine = box.ownTable.lastStateExtraLine;
					end;
				elseif args.clickAreaTable.whereClick == "settingInBox_" and args.clickAreaTable.areaClick == "menueClose_" then
					box.isSetting = false;box.viewExtraLine = box.ownTable.lastStateExtraLine;				
				elseif args.clickAreaTable.whereClick == "settingInBox_" and args.clickAreaTable.areaClick == "viewExtraLine_" then
					box.ownTable.lastStateExtraLine = box.viewExtraLine;
				end;
			end;
		end;
	end;
end;

function pih_MouseKeyEventsBox.onClickArea(args)
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return;end;
		
	if args.isDown then
		if g_currentMission.hlUtils.dragDrop.on then return;end;
		if args.button == Input.MOUSE_BUTTON_LEFT then
			local box = args.box;
			if box ~= nil then
				if box.viewExtraLine then					
					if args.clickAreaTable.whereClick == "settingLineDistance_" then
						local maxDistance = box.screen.pixelH*8;
						if box.screen.size.distance.textLine+(box.screen.pixelH/2) <= maxDistance then
							box.screen.size.distance.textLine = box.screen.size.distance.textLine+(box.screen.pixelH/2);
							box:setUpdateState(true);							
						end;
						return;
					elseif args.clickAreaTable.whereClick == "settingAutoAlign_" then
						if box.ownTable.autoAlign+1 > box.ownTable.maxAutoAlign then box.ownTable.autoAlign = 1;else box.ownTable.autoAlign = box.ownTable.autoAlign+1;end;
						box:setUpdateState(false);
						return;	
					elseif args.clickAreaTable.whereClick == "sortBy_" then
						if box.ownTable.sortBy+1 > box.ownTable.maxSortBy then box.ownTable.sortBy = 1;else box.ownTable.sortBy = box.ownTable.sortBy+1;end;						
						box:setUpdateState(true);
						return;
					elseif args.clickAreaTable.whereClick == "daysMinusUpDown_" then
						if box.ownTable.daysLeftFilter > 1 then
							box.ownTable.daysLeftFilter = box.ownTable.daysLeftFilter - 1;
							box:setUpdateState(true);
							return;
						end;
					elseif args.clickAreaTable.whereClick == "capacityLevelMinusUpDown_" then
						if box.ownTable.capacityLevelFilter > 0.05 then
							box.ownTable.capacityLevelFilter = box.ownTable.capacityLevelFilter - 0.05;
							box:setUpdateState(true);
							return;
						end;					
					elseif args.clickAreaTable.whereClick == "viewFillTypeIcon_" then
						if box.ownTable.viewFillType+1 > box.ownTable.maxViewFillType then box.ownTable.viewFillType = 1;else box.ownTable.viewFillType	= box.ownTable.viewFillType+1;end;			
						return;	
					elseif args.clickAreaTable.whereClick == "clickInfoIcon_" then						
						g_currentMission.hud:showInGameMessage(tostring(g_i18n:getText("pih_moh_help_titel")), tostring(g_i18n:getText("pih_moh_help_text")), -1);	
					end;					
				end;
				if args.clickAreaTable.whereClick == "viewDetails_" then
					if args.clickAreaTable.ownTable[1] ~= nil then	
						if box.ownTable.openProductions[args.clickAreaTable.ownTable[1]] == nil then
							box.ownTable.openProductions[args.clickAreaTable.ownTable[1]] = true;
						else
							box.ownTable.openProductions[args.clickAreaTable.ownTable[1]] = not box.ownTable.openProductions[args.clickAreaTable.ownTable[1]];
						end;
						box:setUpdateState(false);						
						return;
					end;	
				elseif args.clickAreaTable.whereClick == "clickOnProductionColumn_" then
					if args.clickAreaTable.ownTable[2] ~= nil then
						if args.clickAreaTable.ownTable[2].productionPoint ~= nil and args.clickAreaTable.ownTable[2].productionPoint.openMenu ~= nil then
							args.clickAreaTable.ownTable[2].productionPoint:openMenu();
						end;
					end;
				elseif args.clickAreaTable.whereClick == "closeAllDetailsLines_" then
					pih_SetGet:setCloseAllDetailsLines(box);					
					return;									
				elseif args.clickAreaTable.whereClick == "pihObject_" then
					if args.clickAreaTable.ownTable[1] ~= nil then						
						
					end;												
				end;
			end;
		elseif args.button == Input.MOUSE_BUTTON_RIGHT then
			local box = args.box;
			if box ~= nil then
				if box.viewExtraLine then					
					if args.clickAreaTable.whereClick == "sortBy_" then
						if box.ownTable.sortBy+1 > box.ownTable.maxSortBy then box.ownTable.sortBy = 1;else box.ownTable.sortBy = box.ownTable.sortBy+1;end;						
						box:setUpdateState(true);
						return;
					elseif args.clickAreaTable.whereClick == "settingLineDistance_" then
						local minDistance = box.screen.pixelH*1;
						if box.screen.size.distance.textLine-(box.screen.pixelH/2) >= minDistance then
							box.screen.size.distance.textLine = box.screen.size.distance.textLine-(box.screen.pixelH/2);
							box:setUpdateState(true);							
						end;
						return;					
					elseif args.clickAreaTable.whereClick == "daysMinusUpDown_" then
						if box.ownTable.daysLeftFilter < 10 then							
							box.ownTable.daysLeftFilter = box.ownTable.daysLeftFilter + 1;
							box:setUpdateState(true);
							return;
						end;
					elseif args.clickAreaTable.whereClick == "capacityLevelMinusUpDown_" then
						if box.ownTable.capacityLevelFilter < 1 then
							box.ownTable.capacityLevelFilter = box.ownTable.capacityLevelFilter + 0.05;
							box:setUpdateState(true);
							return;
						end;					
					end;					
				end;
				if args.clickAreaTable.whereClick == "clickOnProductionColumn_" then
					if args.clickAreaTable.ownTable[1] ~= nil then
						if box.ownTable.filterForProduction == nil then
							box.ownTable.filterForProduction = tostring(args.clickAreaTable.ownTable[1]);
						else
							box.ownTable.filterForProduction = nil;
						end;
					end;
				elseif args.clickAreaTable.whereClick == "clickOnFillTypeColumn_" then
					if args.clickAreaTable.ownTable[2] ~= nil then
						if box.ownTable.filterForFillType == nil then
							box.ownTable.filterForFillType = tostring(args.clickAreaTable.ownTable[2]);
						else
							box.ownTable.filterForFillType = nil;
						end;
					end;
				elseif args.clickAreaTable.whereClick == "clickOnTimeColumn_" then
					box.ownTable.showMissingAmount = not box.ownTable.showMissingAmount;					
				elseif args.clickAreaTable.whereClick == "pihObject_" then --teleport !
					if args.clickAreaTable.ownTable[1] ~= nil then --nodeId/rootNode						
						pih_SetGet:teleportPlayerToObject(args.clickAreaTable.ownTable[1]);
					end;
				end;
			end;
		elseif args.button == Input.MOUSE_BUTTON_MIDDLE then
			local box = args.box;
			if box ~= nil then
				if box.viewExtraLine then
					
				end;
				if args.clickAreaTable.whereClick == "pihObject_" then --map hotspot !
					if args.clickAreaTable.ownTable[1] ~= nil then --nodeId/rootNode
						local object = {nodeId=args.clickAreaTable.ownTable[1]};
						g_currentMission.hlHudSystem.setMapHotspot( {object} );
					end;
				end;
			end;
		end;	
	end;
end;