hlHudSystemMouseKeyEvents = {};
source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHudMouseKeyEvents.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlPda/hlPdaMouseKeyEvents.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlBox/hlBoxMouseKeyEvents.lua");

function hlHudSystemMouseKeyEvents:setKeyMouse(unicode, sym, modifier, isDownKey, posX, posY, isDown, isUp, button)
	if unicode ~= nil then
		if not g_currentMission.hlUtils.dragDrop.on then
			hlHudSystemMouseKeyEvents:setKey(unicode, sym, modifier, isDownKey);			
		end;
	else
		if g_currentMission.hlUtils.isMouseCursor then
			if not g_currentMission.hlUtils.dragDrop.on then
				hlHudSystemMouseKeyEvents:setMouse(posX, posY, isDown, isUp, button);
			elseif g_currentMission.hlUtils.dragDrop.on then
				hlHudSystemMouseKeyEvents:setDragDropMouse(posX, posY, isDown, isUp, button);
			end;
		end;
	end;
end;

function hlHudSystemMouseKeyEvents:setMouse(posX, posY, isDown, isUp, button)
	local isClickInArea = false;
	if g_currentMission.hlHudSystem.areas ~= nil then		
		for key,value in pairs (g_currentMission.hlHudSystem.areas) do		
			for area=1, #value do
				if value[area] ~= nil and value[area][1] ~= nil then 
					if g_currentMission.hlUtils.mouseIsInArea(posX, posY, unpack(value[area]))then --total Areas Hud or Pda or Box or Menue	
						if button == Input.MOUSE_BUTTON_LEFT and isDown and (value[area].whatClick == "_hlHud_" or value[area].whatClick == "_hlPda_" or value[area].whatClick == "_hlBox_") and (value[area].whereClick == "dragDrop_" or value[area].whereClick == "dragDropWH_") then
							if not g_currentMission.hlUtils.dragDrop.on then
								g_currentMission.hlUtils.setDragDrop(true,{system="hlHudSystem",what=value[area].whatClick,where=value[area].whereClick,area=value[area].areaClick, typPos=value[area].typPos,overlay=value[area].overlay,typ=value[area].typ});
							end;
							return;
						end;						
						local isClickSettingIcons = false;
						if value[area].whatClick == "_hlHud_" then
							isClickInArea = hlHudMouseKeyEvents:setMouse( {isDown=isDown, isUp=isUp, button=button, clickAreaTable=value[area], trigged="hud click total area"} ); --in a Hud Area Total and Click somewhere													
						elseif value[area].whatClick == "_hlPda_" then
							isClickInArea = hlPdaMouseKeyEvents:setMouse( {isDown=isDown, isUp=isUp, button=button, clickAreaTable=value[area], trigged="pda click total area"} ); --in a Pda Area Total and Click somewhere							
						elseif value[area].whatClick == "_hlBox_" then
							isClickInArea = hlBoxMouseKeyEvents:setMouse( {isDown=isDown, isUp=isUp, button=button, clickAreaTable=value[area], trigged="box click total area"} ); --in a Box Area Total and Click somewhere							
						end;						
					end;
				end;
			end;
		end;
	end;	
	if not isClickInArea and g_currentMission.hlHudSystem.clickAreas ~= nil and not g_currentMission.hlUtils.dragDrop.on then --free onClick areas somewhere on screen, prio to last
		for key,value in pairs (g_currentMission.hlHudSystem.clickAreas) do		
			for area=1, #value do
				if value[area] ~= nil and value[area][1] ~= nil then 
					if g_currentMission.hlUtils.mouseIsInArea(posX, posY, unpack(value[area]))then
						if value[area].onClick ~= nil and type(value[area].onClick) == "function" then
							value[area].onClick( {isDown=isDown, isUp=isUp, button=button, clickAreaTable=value[area]} );								
						end;
						return;
					end;
				end;
			end;
		end;					
	end;	
end;

function hlHudSystemMouseKeyEvents:setKey(unicode, sym, modifier, isDown)
	
end;

function hlHudSystemMouseKeyEvents:setDragDropMouse(posX, posY, isDown, isUp, button)	
	if button == Input.MOUSE_BUTTON_LEFT and isDown then		
		if g_currentMission.hlUtils.dragDrop.system == "hlHudSystem" then				
			g_currentMission.hlUtils.setDragDrop(false);
			g_currentMission.hlUtils.deleteTextDisplay();
		end;			
	end;
end;

function hlHudSystemMouseKeyEvents.isInArea(typ)	
	if g_currentMission.hlHudSystem:getDetiServer() or g_currentMission.hlUtils:getFullSize() or g_currentMission.hlUtils:disableInArea() then return false;end;
	if typ == nil then return false;end;
	if not typ.show then return;end;
	local value = {typ.screen.posX,typ.screen.posX+typ.screen.width,typ.screen.posY,typ.screen.posY+typ.screen.height};
	return g_currentMission.hlUtils.mouseIsInArea(nil, nil, unpack(value))
end;