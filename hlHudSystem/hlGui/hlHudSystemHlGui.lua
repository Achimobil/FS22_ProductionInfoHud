hlHudSystemHlGui = {};

function hlHudSystemHlGui:generate(change, debugPrint)
	if g_currentMission.hlGui == nil or g_currentMission.hlGui.setGet == nil then 
		if change then print("***Error	-can not generate HL Hud System Settings Menue (! is hlGui Menue loaded !)- Error***");end;
		
		return;
	end;	
	local errorTable = {};


end;