hlHudSystemDraw = {};
source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHudDraw.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlPda/hlPdaDraw.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlBox/hlBoxDraw.lua");

source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHudOwnDraw.lua");

function hlHudSystemDraw.showHuds()
	
	local mpOff = g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission.hlHudSystem.ownData.mpOff;
	
	g_currentMission.hlHudSystem.areas["_hlHud_"] = {};
	if not g_currentMission.hlHudSystem.ownData.moh then hlHudSystemDraw:showOwnIcons();end;
	
	if not g_currentMission.hlHudSystem.ownData.isHidden and not mpOff then
		hlHudDraw:show();
	end;
	
	g_currentMission.hlHudSystem.areas["_hlPda_"] = {};
	if not mpOff then hlPdaDraw.show();end;
	
	g_currentMission.hlHudSystem.areas["_hlBox_"] = {};
	if not mpOff then hlBoxDraw.show();end;

end;

function hlHudSystemDraw:showOwnIcons()
	if not g_currentMission.hud.isVisible then return;end; --hud hidder mod
	if not g_currentMission.hlUtils.isMouseCursor then return;end;
	local bgX, bgY, bgW, bgH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.backgroundOverlay.overlay);
	if g_currentMission.hlHudSystem.ownData.iconWidth == nil then
		g_currentMission.hlHudSystem.ownData.iconWidth, g_currentMission.hlHudSystem.ownData.iconHeight = g_currentMission.hlHudSystem.screen:getOptiWidthHeight( {typ="icon", height=bgH/4.5, width=bgW} );		
	end;
	if g_currentMission.hlHudSystem.overlays.settingIcons ~= nil then
		local mpOff = g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission.hlHudSystem.ownData.mpOff;
		local setting = g_currentMission.hlHudSystem.overlays.settingIcons.settingO;
		if setting ~= nil and not mpOff then
			g_currentMission.hlUtils.setOverlay(setting, bgX+g_currentMission.hlHudSystem.screen.difWidth, bgY+bgH-g_currentMission.hlHudSystem.ownData.iconHeight-g_currentMission.hlHudSystem.screen.difHeight, g_currentMission.hlHudSystem.ownData.iconWidth, g_currentMission.hlHudSystem.ownData.iconHeight);
			local inIconArea = setting.mouseInArea();			
			if inIconArea then
				g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.inArea, true));
			elseif g_currentMission.hlHudSystem.isSetting.hud then 
				g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.globalSettingOn, true));
			else 
				g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.globalSettingOff, true));
			end;
			setting:render();
			if inIconArea then
				local moreTxt = "";
				local txt = "";
				if g_currentMission.hlUtils.modLoaded["FS22_AllRoundExtension"] ~= nil then
					moreTxt = "\n".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_settingAllRoundExtension");
				end;
				if g_currentMission.hlHudSystem.infoDisplay.on then 
					txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_settingGlobal").. "\n-".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_onOff");
				else 
					txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_on");
				end;
				g_currentMission.hlUtils.addTextDisplay( {txt=tostring(txt).. tostring(moreTxt), posY=0.09, txtSize=0.013, maxLine=0 } );
			end;				
			if inIconArea and not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {setting.x, setting.x+setting.width, setting.y, setting.y+setting.height, whatClick="_hlHud_", whereClick="settingAllHud_", areaClick="settingIcon_"} );end;								
		end;		
		local save = g_currentMission.hlHudSystem.overlays.settingIcons.save;						
		if save ~= nil and (not mpOff or not g_currentMission.hlHudSystem.isSave) then
			local inIconArea = save.mouseInArea();
			g_currentMission.hlUtils.setOverlay(save, bgX+g_currentMission.hlHudSystem.screen.difWidth+g_currentMission.hlHudSystem.ownData.iconWidth, bgY+bgH-(g_currentMission.hlHudSystem.ownData.iconHeight/1.2)-g_currentMission.hlHudSystem.screen.difHeight, g_currentMission.hlHudSystem.ownData.iconWidth/1.2, g_currentMission.hlHudSystem.ownData.iconHeight/1.2);
			if not g_currentMission.hlHudSystem.isSave then 
				g_currentMission.hlUtils.setBackgroundColor(save, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.warning, true));
			else 
				g_currentMission.hlUtils.setBackgroundColor(save, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.on, true));
			end;			
			if inIconArea or not g_currentMission.hlHudSystem.isSave then save:render();end;
			local autoSaveText = "";
			if g_currentMission.hlHudSystem.timer.autoSave > 0 then 									
				autoSaveText = "\n".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveOn").. "\n".. string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveTimer"), tostring(g_currentMission.hlHudSystem.timer.autoSave), tostring(g_currentMission.hlHudSystem.timer.autoSaveDefault)).. "\n".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveOnOff");									
			else
				autoSaveText = "\n".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveOff").. "\n".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveOnOff");
			end;
			if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_saveAll").. autoSaveText, maxLine=0, posY=0.12, txtSize=0.013 } );end;
			if inIconArea and not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {save.x, save.x+save.width, save.y, save.y+save.height, whatClick="_hlHud_", whereClick="settingAllHud_", areaClick="saveIcon_"} );end;
		end;
		if g_currentMission.missionDynamicInfo.isMultiplayer then
			local view = g_currentMission.hlHudSystem.overlays.settingIcons.view;
			if view ~= nil then
				local iconWidthS = g_currentMission.hlHudSystem.ownData.iconWidth/1.1
				local iconHeightS = g_currentMission.hlHudSystem.ownData.iconHeight/1.1
				local inIconArea = view.mouseInArea();
				if not mpOff and save ~= nil then
					g_currentMission.hlUtils.setOverlay(view, bgX+(g_currentMission.hlHudSystem.ownData.iconWidth*2)+(g_currentMission.hlHudSystem.screen.difWidth*2), bgY+bgH-g_currentMission.hlHudSystem.screen.difHeight-iconHeightS, iconWidthS, iconHeightS);
				else
					g_currentMission.hlUtils.setOverlay(view, bgX+g_currentMission.hlHudSystem.screen.difWidth, bgY+bgH-(iconHeightS)-g_currentMission.hlHudSystem.screen.difHeight, iconWidthS, iconHeightS);
				end;
				if g_currentMission.hlHudSystem.ownData.mpOff then
					g_currentMission.hlUtils.setBackgroundColor(view, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.warning, true));
				else
					g_currentMission.hlUtils.setBackgroundColor(view, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.on, true));
				end;
				if inIconArea then 
					view:render();
					g_currentMission.hlUtils.addTextDisplay( {txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_viewMpOff"), maxLine=0, posY=0.12, txtSize=0.013 } );
					if not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {view.x, view.x+view.width, view.y, view.y+view.height, whatClick="_hlHud_", whereClick="settingAllHud_", areaClick="viewIcon_"} );end;
				end;
			end;
		end;
	end;
end;

function hlHudSystemDraw:showSettingIcons(args) --Pda,Box
	local setClickArea = true;
	local typ = args.typ;
	local typName = args.typName;
	local whatClick = "_hlPda_"
	local whereClick = "settingInPda_";
	local whichAreaClick = nil;
	if typName == "pda" then 
		whichAreaClick = hlPdaDraw;		
	else 
		whichAreaClick = hlBoxDraw;
		whatClick = "_hlBox_";
		whereClick = "settingInBox_";
	end;	
	if typ.overlays.settingIcons ~= nil and typ.viewSettingIcons then
		local x, y, w, h = typ:getScreen();
		local bgSettingW, bgSettingH = typ:getOptiWidthHeight( {typ=typName, height=typ.screen.size.settingIcon[2]} );
		local iconWidth = bgSettingW-(typ.screen.pixelW*0.5);
		local iconHeight = bgSettingH-(typ.screen.pixelH*0.5);
		local iconWidthS = bgSettingW-(typ.screen.pixelW*1.2);
		local iconHeightS = bgSettingH-(typ.screen.pixelH*1.2);
		local bgSetting = typ.overlays.settingIcons.bgRoundBlack;
		local maxIconWidth = g_currentMission.hlUtils.getMaxIconWidth(w+bgSettingW, bgSettingW, true);
		if bgSetting ~= nil then
			local viewIcon = {dragDrop=false,extraLine=false,close=false,save=false,help=false,setting=false,dragDropWH=false,autoClose=false};
			---position up Setting Icons---
			---dragDrop---			
			local dragDrop = typ.overlays.settingIcons.dragDrop;
			if dragDrop ~= nil and dragDrop.visible then
				maxIconWidth = maxIconWidth-1;
				viewIcon.dragDrop = true;
				g_currentMission.hlUtils.setOverlay(bgSetting, x-(bgSettingW/3), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);								
				g_currentMission.hlUtils.setOverlay(dragDrop, bgSetting.x+(bgSettingW/2)-(iconWidth/2), bgSetting.y+(bgSettingH/2)-(iconHeight/2), iconWidth, iconHeight);								
				local inIconArea = bgSetting.mouseInArea();
				if inIconArea then setClickArea = false;end;
				if inIconArea then									
					if bgSetting.visible then bgSetting:render();end;
					g_currentMission.hlUtils.setBackgroundColor(dragDrop, g_currentMission.hlUtils.getColor(typ.overlays.color.on, true));
					dragDrop:render();
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_dragDrop"), typName:upper(), typName:upper()), posY=0.12, txtSize=0.013 } );end;
				end;
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick="dragDrop_", areaClick="dragDropIcon_", typPos=args.typPos, overlay=dragDrop} );end;
			end;
			---dragDrop---
			---close---			
			if typ.canClose then
				local closeTyp = typ.overlays.settingIcons.close;
				if closeTyp ~= nil and closeTyp.visible then
					maxIconWidth = maxIconWidth-1;
					viewIcon.close = true;
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);								
					g_currentMission.hlUtils.setOverlay(closeTyp, bgSetting.x+(bgSettingW/2)-(iconWidthS/2), bgSetting.y+(bgSettingH/2)-(iconHeightS/2), iconWidthS, iconHeightS);								
					local inIconArea = bgSetting.mouseInArea();								
					if inIconArea then setClickArea = false;end;
					if inIconArea then									
						if bgSetting.visible then bgSetting:render();end;
						closeTyp:render();
						if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_close"), typName:upper()), posY=0.12, txtSize=0.013 } );end;
					end;
					if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="closeIcon_", typPos=args.typPos} );end;
				end;
			end;			
			---close---	
			---save---
			if typ.canSave then
				local saveTyp = typ.overlays.settingIcons.save;
				if saveTyp ~= nil and saveTyp.visible then
					maxIconWidth = maxIconWidth-1;
					viewIcon.save = true;					
					if not viewIcon.close then
						g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
					else
						g_currentMission.hlUtils.setOverlay(bgSetting, x+w-bgSettingW-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);					
					end;
					g_currentMission.hlUtils.setOverlay(saveTyp, bgSetting.x+(bgSettingW/2)-(iconWidthS/2), bgSetting.y+(bgSettingH/2)-(iconHeightS/2), iconWidthS, iconHeightS);
					local inIconArea = bgSetting.mouseInArea();	
					if inIconArea then setClickArea = false;end;
					if inIconArea or not typ.isSave then
						if bgSetting.visible then bgSetting:render();end;
						if typ.isSave then g_currentMission.hlUtils.setBackgroundColor(saveTyp, g_currentMission.hlUtils.getColor(typ.overlays.color.on, true));else g_currentMission.hlUtils.setBackgroundColor(saveTyp, g_currentMission.hlUtils.getColor(typ.overlays.color.warning, true));end;
						saveTyp:render();
						local autoSaveText = "";
						if g_currentMission.hlHudSystem.timer.autoSave > 0 then 
							if typ.autoSave then
								autoSaveText = "\n".. typ:getI18n("hl_infoDisplay_autoSaveOn").. "\n".. string.format(typ:getI18n("hl_infoDisplay_autoSaveTimer"), tostring(g_currentMission.hlHudSystem.timer.autoSave), tostring(g_currentMission.hlHudSystem.timer.autoSaveDefault));
							else
								autoSaveText = "\n".. string.format(typ:getI18n("hl_infoDisplay_autoSaveTypOff"), typName:upper());
							end;
						else
							autoSaveText = "\n".. typ:getI18n("hl_infoDisplay_autoSaveOff");
						end;
						if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_save"), typName:upper()).. autoSaveText, maxLine=0, posY=0.12, txtSize=0.013 } );end;
					end;	
					if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="saveIcon_", typPos=args.typPos} );end;
				end;
			end;			
			---save---
			---up/down for extraLine---			
			local up = typ.overlays.settingIcons.up;
			local down = typ.overlays.settingIcons.down;
			if up ~= nil and down ~= nil and up.visible and down.visible then
				if not viewIcon.dragDrop then
					g_currentMission.hlUtils.setOverlay(bgSetting, x-(bgSettingW/3), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				else
					g_currentMission.hlUtils.setOverlay(bgSetting, x+bgSettingW-(bgSettingW/3), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				end;
				maxIconWidth = maxIconWidth-1;
				viewIcon.extraLine = true;
				g_currentMission.hlUtils.setOverlay(up, bgSetting.x, bgSetting.y, bgSettingW, bgSettingH);
				g_currentMission.hlUtils.setOverlay(down, bgSetting.x, bgSetting.y, bgSettingW, bgSettingH);
				local inIconArea = bgSetting.mouseInArea();
				if inIconArea then setClickArea = false;end;				
				if inIconArea or args.inArea then									
					if bgSetting.visible then bgSetting:render();end;
					if typ.viewExtraLine then
						up:render();
					else
						down:render();
					end;
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_extraLine"), typName:upper()), maxLine=0, posY=0.12, txtSize=0.013 } );end;
				end;
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="viewExtraLine_", typPos=args.typPos} );end;
			end;			
			---up/down for extraLine---
			---position up Setting Icons---
			
			---position other Setting Icons---
			---help---
			local help = typ.overlays.settingIcons.help;
			if help ~= nil and help.visible then				
				if not viewIcon.close and not not viewIcon.save then
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				elseif (viewIcon.close and not viewIcon.save) or (not viewIcon.close and viewIcon.save) then
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-bgSettingW-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				elseif maxIconWidth > 4 then
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW*2)-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				else
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y+h-bgSettingH-(bgSettingH/1.5), bgSettingW, bgSettingH);
				end;
				g_currentMission.hlUtils.setOverlay(help, bgSetting.x, bgSetting.y, bgSettingW, bgSettingH);
				if typ.isHelp then g_currentMission.hlUtils.setBackgroundColor(help, g_currentMission.hlUtils.getColor(typ.overlays.color.warning, true));else g_currentMission.hlUtils.setBackgroundColor(help, g_currentMission.hlUtils.getColor(typ.overlays.color.notActive, true));end;
				local inIconArea = bgSetting.mouseInArea();								
				if inIconArea then setClickArea = false;end;
				if inIconArea or (typ.isHelp and args.inArea) then
					if bgSetting.visible then bgSetting:render();end;
					help:render();
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_help"), typName:upper()), maxLine=0, posY=0.12, txtSize=0.013 } );end;
				end;
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="helpIcon_", typPos=args.typPos} );end;
			end;
			---help---	
			---position other Setting Icons---
			
			---position down Setting Icons---
			---setting---
			local setting = typ.overlays.settingIcons.setting;
			if setting ~= nil and setting.visible then								
				viewIcon.setting = true;
				g_currentMission.hlUtils.setOverlay(bgSetting, x-(bgSettingW/3), y-(bgSettingH/3), bgSettingW, bgSettingH);
				g_currentMission.hlUtils.setOverlay(setting, bgSetting.x+(bgSettingW/2)-(iconWidth/2), bgSetting.y+(bgSettingH/2)-(iconHeight/2), iconWidth, iconHeight);								
				if typ.isSetting then g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(typ.overlays.color.settingOn, true));else g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(typ.overlays.color.settingOff, true));end;
				local inIconArea = bgSetting.mouseInArea();
				if inIconArea then setClickArea = false;end;
				if inIconArea or typ.isSetting then
					if bgSetting.visible then bgSetting:render();end;
					setting:render();					
					if inIconArea then						
						if g_currentMission.hlHudSystem.infoDisplay.on then 
							local txtInfoDisplayOnOff = "";
							if g_currentMission.hlHudSystem.infoDisplay.where == typName then txtInfoDisplayOnOff = "\n-".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_onOff");end;
							g_currentMission.hlUtils.addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_setting"), typName:upper()).. txtInfoDisplayOnOff, maxLine=0, posY=0.12, txtSize=0.013 } );
						elseif g_currentMission.hlHudSystem.infoDisplay.where == typName then 
							g_currentMission.hlUtils.addTextDisplay( {txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_on"), posY=0.09, txtSize=0.013 } );
						end;
					end;
				end;
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="settingIcon_", typPos=args.typPos} );end;
			end;			
			---setting---
			---autoClose---
			local autoClose = typ.overlays.settingIcons.autoClose;
			if typ.canAutoClose and autoClose ~= nil and autoClose.visible then
				if not viewIcon.setting then
					g_currentMission.hlUtils.setOverlay(bgSetting, x-(bgSettingW/3), y-(bgSettingH/3), bgSettingW, bgSettingH);
				else
					g_currentMission.hlUtils.setOverlay(bgSetting, x+bgSettingW-(bgSettingW/3), y-(bgSettingH/3), bgSettingW, bgSettingH);
				end;
				g_currentMission.hlUtils.setOverlay(autoClose, bgSetting.x+(bgSettingW/2)-(iconWidth/2), bgSetting.y+(bgSettingH/2)-(iconHeight/2), iconWidth, iconHeight);
				if typ.autoClose then g_currentMission.hlUtils.setBackgroundColor(autoClose, g_currentMission.hlUtils.getColor(typ.overlays.color.off, true));else g_currentMission.hlUtils.setBackgroundColor(autoClose, g_currentMission.hlUtils.getColor(typ.overlays.color.notActive, true));end;
				local inIconArea = bgSetting.mouseInArea();	
				if inIconArea then setClickArea = false;end;
				if inIconArea then									
					if bgSetting.visible then bgSetting:render();end;
					autoClose:render();
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=typ:getI18n("hl_infoDisplay_autoClose"), maxLine=0, posY=0.12, txtSize=0.013 } );end;
					if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="autoCloseIcon_", typPos=args.typPos} );end;
				end;	
			end;
			---autoClose---
			---dragDropWH---
			local sizeWidthHeight = typ.overlays.settingIcons.sizeWidthHeight;							
			if sizeWidthHeight ~= nil and sizeWidthHeight.visible then
				g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y-(bgSettingH/3), bgSettingW, bgSettingH);
				g_currentMission.hlUtils.setOverlay(sizeWidthHeight, bgSetting.x+(bgSettingW/2)-(iconWidthS/2), bgSetting.y+(bgSettingH/2)-(iconHeightS/2), iconWidthS, iconHeightS);
				local inIconArea = bgSetting.mouseInArea();	
				if inIconArea then setClickArea = false;end;
				if inIconArea then									
					if bgSetting.visible then bgSetting:render();end;
					sizeWidthHeight:render();
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_dragDropWH"), typName:upper()), maxLine=0, posY=0.12, txtSize=0.013 } );end;
				end;
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick="dragDropWH_", areaClick="dragDropWHIcon_", typPos=args.typPos, overlay=sizeWidthHeight} );end;
			end;			
			---dragDropWH---
			---position down Setting Icons---
		end;
	end;
	return setClickArea;
end;

function hlHudSystemDraw:showMenue(typ, args)
	if args == nil or type(args) ~= "table" or typ == nil or args.typPos == nil then return;end;	
	local whatClick = "_hlPda_";
	local whereClickS = "settingInPda_";
	local whereClick = "pda_";
	local whichAreaClick = hlPdaDraw;
	if typ.typ == "box" then whatClick = "_hlBox_";whereClick = "box_";whereClickS = "settingInBox_";whichAreaClick = hlBoxDraw;elseif typ.typ == "hud" then whatClick = "_hlHud_";whereClick = "hud_";whereClickS = "settingInHud_";whichAreaClick = hlHudDraw;end;
	function drawMenue(menue, menuePos)
		local inIconArea = menue.icon.bg.mouseInArea();
		menue.icon.bg:render();
		if menue.title:len() > 0 then 
			local textHeight = getTextHeight(menue.size, utf8Substr(menue.title, 0));
			setTextAlignment(1);
			setTextColor(unpack(g_currentMission.hlUtils.getColor(typ.overlays.color.title, true)));
			renderText(menue.icon.bg.x+(menue.icon.bg.width/2),menue.icon.bg.y+menue.icon.bg.height-textHeight, menue.size, tostring(menue.title));
			setTextAlignment(0);
			setTextColor(1, 1, 1, 1);
		end;
		if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {menue.icon.bg.x, menue.icon.bg.x+menue.icon.bg.width, menue.icon.bg.y, menue.icon.bg.y+menue.icon.bg.height, whatClick=whatClick, whereClick=whereClick, areaClick="menueArea_", typPos=args.typPos, ownTable={}} );end;
		if menue.icon.close.visible then 
			inIconArea = menue.icon.close.mouseInArea();
			menue.icon.close:render();
			if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlUtils.addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_close"), typ.typ:upper().. " MENUE"), maxLine=0, posY=0.12, txtSize=0.013 } );end;
			if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {menue.icon.close.x, menue.icon.close.x+menue.icon.close.width, menue.icon.close.y, menue.icon.close.y+menue.icon.close.height, whatClick=whatClick, whereClick=whereClickS, areaClick="menueClose_", typPos=args.typPos, ownTable={menuePos}} );end;
		end;
	end;
	if typ.menue ~= nil and type(typ.menue) == "table" then
		if args.menue == nil then
			for m=1, #typ.menue do
				if typ.menue[m].show ~= nil and typ.menue[m].show then
					drawMenue(typ.menue[m], m);
				end;
			end;
		elseif typ.menue[args.menue] ~= nil and typ.menue[args.menue].show ~= nil and typ.menue[args.menue].show then
			drawMenue(typ.menue[args.menue], args.menue);
		end;
	end;
end;