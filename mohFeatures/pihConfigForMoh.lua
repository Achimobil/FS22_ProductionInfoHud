pihConfigForMoh = {};

function pihConfigForMoh:defaultValues()
	pihConfigForMoh.values = {daysLeftFilter=2,capacityLevelFilter=0.8}; --hier deine table kannst du aber auch ändern
end;

function pihConfigForMoh.loadXml(Xml, xmlNameTag, directory, typ) --loadConfig Callback	
	if typ ~= "profilSettings" then return;end;	
	if pihConfigForMoh.values == nil then pihConfigForMoh:defaultValues();end;	
	local groupNameTag = (xmlNameTag.. ".module.productionInfoHud(%d)"):format(0);
	if getXMLFloat(Xml, groupNameTag.. "#capacityLevelFilter") ~= nil then
		pihConfigForMoh.values.capacityLevelFilter = getXMLFloat(Xml, groupNameTag.. "#capacityLevelFilter");
		pihConfigForMoh.values.capacityLevelFilter = MathUtil.round(pihConfigForMoh.values.capacityLevelFilter, 2)
	else
		return; --first config not found
	end;
	if getXMLInt(Xml, groupNameTag.. "#daysLeftFilter") then
		pihConfigForMoh.values.daysLeftFilter = getXMLInt(Xml, groupNameTag.. "#daysLeftFilter");
	end;	
end;

function pihConfigForMoh.saveXml(Xml, xmlNameTag, directory, typ) --saveConfig Callback
	if typ ~= "profilSettings" then return;end;	
	if pihConfigForMoh.values == nil then pihConfigForMoh:defaultValues();end;
	----------------------------------------------------------------------------------------------
	local groupNameTag = (xmlNameTag.. ".module.productionInfoHud(%d)"):format(0);
	setXMLInt(Xml, groupNameTag.. "#daysLeftFilter", pihConfigForMoh.values.daysLeftFilter);
	setXMLFloat(Xml, groupNameTag.. "#capacityLevelFilter", pihConfigForMoh.values.capacityLevelFilter);
	----------------------------------------------------------------------------------------------	
end;

if g_currentMission.multiOverlayV4 ~= nil then
	g_currentMission.multiOverlayV4.moduleFunction.addCallbackModul( {modName="productionInfoHud", modulCallbackName="loadConfig", callback=pihConfigForMoh.loadXml } );
	g_currentMission.multiOverlayV4.moduleFunction.addCallbackModul( {modName="productionInfoHud", modulCallbackName="saveConfig", callback=pihConfigForMoh.saveXml } );
end;