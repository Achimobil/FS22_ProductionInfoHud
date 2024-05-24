hlHudMouseKeyEvents = {};
source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHudOwnMouseKeyEvents.lua");

function hlHudMouseKeyEvents:setMouse(args)
	local inClickArea = false;
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return inClickArea;end;
	if args.clickAreaTable.whereClick == "settingAllHud_" then --prio 1
		hlHudMouseKeyEvents:settingAllHud(args);
		inClickArea = true;
	elseif args.clickAreaTable.whereClick == "settingInHud_" then --prio 2
		hlHudMouseKeyEvents:settingInHud(args);
		inClickArea = true;
	elseif args.clickAreaTable.whereClick == "hud_" then		
		if g_currentMission.hlUtils.timers["hlHudSystem_ignoreHudAreaClick"] ~= nil or g_currentMission.hlUtils.dragDrop.on then return true;end;
		local hud = g_currentMission.hlHudSystem.hud[args.clickAreaTable.typPos];		
		if hud ~= nil and hud.show then
			args.hud = hud;
			---optional automatic setZoomOutIn icon or text by HL Hud System---
			local autoSetZoomOutIn = hud.isSetting and hud.autoZoomOutIn:len() >= 4 and (hud.autoZoomOutIn == "icon" or hud.autoZoomOutIn == "text");
			if args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_UP and autoSetZoomOutIn then
				hud:setZoomOutIn( {typ=hud.autoZoomOutIn, up=true} );
				inClickArea = true;
			elseif args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_DOWN and autoSetZoomOutIn then
				hud:setZoomOutIn( {typ=hud.autoZoomOutIn, down=true} );
				inClickArea = true;
			end;
			---optional automatic setZoomOutIn icon or text by HL Hud System---
			---optional automatic line bounds icon or text by HL Hud System---
			local autoSetBounds = not hud.isSetting and hud.screen.canBounds.on and hud.screen.bounds[1] >= 0 and hud.screen.bounds[4] > 1;
			if args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_UP and autoSetBounds then
				hud.screen:setBounds( {up=true} );
				inClickArea = true;
			elseif args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_DOWN and autoSetBounds then
				hud.screen:setBounds( {down=true} );
				inClickArea = true;
			end;
			---optional automatic line bounds icon or text by HL Hud System---
			if not inClickArea and hud.clickAreas ~= nil then
				for k,v in pairs (hud.clickAreas) do	
					if inClickArea then break;end;					
					for clickArea=1, #v do
						if inClickArea then break;end;
						if v[clickArea] ~= nil and v[clickArea][1] ~= nil then 
							if g_currentMission.hlUtils.mouseIsInArea(posX, posY, unpack(v[clickArea]))then
								if v[clickArea].onClick ~= nil and type(v[clickArea].onClick) == "function" then --optional this Hud clickAreas --> hud:setClickArea(.......)
									inClickArea = true;
									args.clickAreaTable=v[clickArea];
									args.trigged = "hud click by found areaClick";
									v[clickArea].onClick(args);								
								elseif hud.onClick ~= nil and type(hud.onClick) == "function" then --optional this Hud --> hud.onClick --> if clickArea onClick not found
									inClickArea = true;
									args.clickAreaTable=v[clickArea];
									args.trigged = "hud click by NOT found areaClick (set hud total area click with clickAreaTable)";
									hud.onClick(args);
								end;								
							end;
						end;
					end;					
				end;
		
			end;
			if not inClickArea and hud.onClick ~= nil and type(hud.onClick) == "function" then 
				inClickArea = true;				
				hud.onClick(args);
			end;
		end;			
	end;
	return inClickArea;	
end;

function hlHudMouseKeyEvents:settingAllHud(args) --all Hud default Setting
	if args.isDown then	
		if g_currentMission.hlUtils.dragDrop.on then return;end;
		if args.button == Input.MOUSE_BUTTON_LEFT then
			if args.clickAreaTable.areaClick == "settingIcon_" then
				local showHuds = g_currentMission.hlHudSystem.hlHud:getAllShowHuds();
				if #g_currentMission.hlHudSystem.hud == 0 or #showHuds == 0 then 
					g_currentMission:showBlinkingWarning(g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_notFoundHud"), 2500);	
					return;
				end;
				g_currentMission.hlHudSystem.isSetting.hud = not g_currentMission.hlHudSystem.isSetting.hud;
				g_currentMission.hlUtils.deleteTextDisplay(); --delete Hud Creator Info
				if not g_currentMission.hlHudSystem.isSetting.hud then
					g_currentMission.hlHudSystem.isSetting.viewFrame = false;
					if g_currentMission.hlUtils.timers["hlHudSystem_ignoreHudAreaClick"] == nil then g_currentMission.hlUtils.addTimer( {delay=1, name="hlHudSystem_ignoreHudAreaClick", repeatable=false, action=nil} );end; --cooldown Timer for first showHud and clickAreas settingIcon Global Off
				else
					if not g_currentMission.hlHudSystem.ownData.moh then g_currentMission.hlHudSystem.isSetting.viewFrame = true;end;
				end;
			elseif args.clickAreaTable.areaClick == "saveIcon_" then
				hlHudSystemXml:save();
				g_currentMission.hlUtils.deleteTextDisplay(); --delete Hud Creator Info				
				g_currentMission.hlHudSystem.isSave = true;
				g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, "HL Hud System INFO: ".. g_i18n:getText("ui_savingFinished", "All Data Saved"), 2500, GuiSoundPlayer.SOUND_SAMPLES.NOTIFICATION);
			elseif args.clickAreaTable.areaClick == "viewIcon_" then
				g_currentMission.hlHudSystem.ownData.mpOff = not g_currentMission.hlHudSystem.ownData.mpOff;
				hlHudSystemXml:save();
				g_currentMission.hlUtils.deleteTextDisplay(); --delete Hud Creator Info				
				g_currentMission.hlHudSystem.isSave = true;
			end;
		elseif args.button == Input.MOUSE_BUTTON_MIDDLE then
			if args.clickAreaTable.areaClick == "settingIcon_" then
				g_currentMission.hlHudSystem.infoDisplay.on = not g_currentMission.hlHudSystem.infoDisplay.on;
				g_currentMission.hlHudSystem.isSave = false;
				if not g_currentMission.hlHudSystem.infoDisplay.on then				
					g_currentMission.hlUtils.addTextDisplay( {txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_off"), txtSize=0.013, txtBold=true, duration=2} );
				else
					hlHudSystem:setFirstInfo();
				end;
				return;
			end;
		elseif args.button == Input.MOUSE_BUTTON_RIGHT then
			if args.clickAreaTable.areaClick == "settingIcon_" then				
				local box = g_currentMission.hlHudSystem.hlBox:getData("AllRound_Extension_Box"); --search Box 
				if box ~= nil then
					if g_currentMission.hlHudSystem.ownData.moh then 
						g_currentMission:showBlinkingWarning("! Settings NOT Compatible with MultiOverlayV4 Mod !", 2500)
					else
						box.show = not box.show;
					end;
				end;
			elseif args.clickAreaTable.areaClick == "saveIcon_" then
				if g_currentMission.hlHudSystem.timer.autoSave > 0 then
					g_currentMission.hlUtils.removeTimer("hlHudSystem_autoSave");
					g_currentMission.hlHudSystem.timer.autoSave = 0;
					if not g_currentMission.hlHudSystem.infoDisplay.on then
						g_currentMission.hlUtils.addTextDisplay( {txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveOff"), txtSize=0.013, txtBold=true, duration=2} );
					end;
				else
					g_currentMission.hlHudSystem.timer.autoSave = g_currentMission.hlHudSystem.timer.autoSaveDefault;
					g_currentMission.hlUtils.addTimer( {delay=g_currentMission.hlHudSystem.timer.autoSave, name="hlHudSystem_autoSave", repeatable=true, ms=false, action=hlHudSystem.autoSave} );
					if not g_currentMission.hlHudSystem.infoDisplay.on then						
						g_currentMission.hlUtils.addTextDisplay( {txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveOn").. "\n".. string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveTimer"), tostring(g_currentMission.hlHudSystem.timer.autoSave), tostring(g_currentMission.hlHudSystem.timer.autoSaveDefault)), txtSize=0.013, txtBold=true, duration=2} );
					end;
				end;
			end;
		end;
	end;
end;

function hlHudMouseKeyEvents:settingInHud(args) --Hud default Setting
	if args.isDown then	
		if g_currentMission.hlUtils.dragDrop.on then return;end;
		if args.button == Input.MOUSE_BUTTON_LEFT then			
			local hud = g_currentMission.hlHudSystem.hud[args.clickAreaTable.typPos];
			if args.clickAreaTable.areaClick == "leftRightIcon_" then							
				if #g_currentMission.hlHudSystem.hud <= 1 then return;end;
				if args.clickAreaTable.typPos > 1 then
					g_currentMission.hlHudSystem.hlHud:setNewOrderPosition(args.clickAreaTable.typPos, args.clickAreaTable.typPos-1);
				else
					g_currentMission.hlHudSystem.hlHud:setNewOrderPosition(args.clickAreaTable.typPos, #g_currentMission.hlHudSystem.hud);
				end;
				return;
			elseif args.clickAreaTable.areaClick == "settingIcon_" then
				if hud ~= nil then 
					hud.isSetting = not hud.isSetting;
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Hud Creator Info					
					args.hud = hud
					if hud.onSettingClick ~= nil and type(hud.onSettingClick) == "function" then hud.onSettingClick(args);
					elseif hud.onClick ~= nil and type(hud.onClick) == "function" then hud.onClick(args);end;
				end;
				return;			
			elseif args.clickAreaTable.areaClick == "viewSeparatorIcon_" then
				if hud ~= nil then
					hud.viewSeparator = not hud.viewSeparator;
				end;
				return;
			end;
		elseif args.button == Input.MOUSE_BUTTON_RIGHT then			
			if args.clickAreaTable.areaClick == "leftRightIcon_" then
				if #g_currentMission.hlHudSystem.hud <= 1 then return;end;
				if args.clickAreaTable.typPos < #g_currentMission.hlHudSystem.hud then
					g_currentMission.hlHudSystem.hlHud:setNewOrderPosition(args.clickAreaTable.typPos, args.clickAreaTable.typPos+1);
				else
					g_currentMission.hlHudSystem.hlHud:setNewOrderPosition(args.clickAreaTable.typPos, 1);
				end;				
				return;							
			end;
		end;		
	end;
end;