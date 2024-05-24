hlHudOwnXml = {};

function hlHudOwnXml:defaultValues(hud)
	hud.ownTable.viewColor = 1; --own value for text color
end;

function hlHudOwnXml:onLoadXml(hud, Xml, xmlNameTag)
	if hud.ownTable.viewColor == nil then hlHudOwnXml:defaultValues(hud);end;	
	if Xml ~= nil and xmlNameTag ~= nil then	
		if getXMLInt(Xml, xmlNameTag.."#viewColor") ~= nil then 
			hud.ownTable.viewColor = getXMLInt(Xml, xmlNameTag.. "#viewColor");			
		else
			return; --first config not found
		end;
	end;	
end;

function hlHudOwnXml.onSaveXml(hud, Xml, xmlNameTag)
	setXMLInt(Xml, xmlNameTag.."#viewColor", hud.ownTable.viewColor);
end;

