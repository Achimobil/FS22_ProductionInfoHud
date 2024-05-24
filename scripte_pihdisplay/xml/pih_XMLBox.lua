pih_XmlBox = {};

function pih_XmlBox:defaultValues(box)
	box.ownTable = { updateTimer=10, lastStateExtraLine=false, autoAlign=1, maxAutoAlign=2, sortBy=1, maxSortBy=4, viewFillType=1, maxViewFillType=3, daysLeftFilter=2, capacityLevelFilter=0.8, showMissingAmount=false, filterForFillType=nil, filterForProduction=nil, openProductions={} }; --own values viewFillType=1(by Name), 2(by Icon), 3(by Icon/Name)
end;

function pih_XmlBox:onLoadXml(box, Xml, xmlNameTag)
	if box.ownTable.lastStateExtraLine == nil then pih_XmlBox:defaultValues(box);end;	
	if Xml ~= nil and xmlNameTag ~= nil then	
		if getXMLInt(Xml, xmlNameTag.."#version") ~= nil then 
		
		else
			return; --first config not found
		end;
		if getXMLFloat(Xml, xmlNameTag.. "#capacityLevelFilter") ~= nil then
			box.ownTable.capacityLevelFilter = getXMLFloat(Xml, xmlNameTag.. "#capacityLevelFilter");
			box.ownTable.capacityLevelFilter = MathUtil.round(box.ownTable.capacityLevelFilter, 2)
		end;
		if getXMLInt(Xml, xmlNameTag.. "#daysLeftFilter") then
			box.ownTable.daysLeftFilter = getXMLInt(Xml, xmlNameTag.. "#daysLeftFilter");
		end;
		if getXMLInt(Xml, xmlNameTag.."#sortBy") ~= nil then 
			box.ownTable.sortBy = getXMLInt(Xml, xmlNameTag.. "#sortBy");
			if box.ownTable.sortBy > box.ownTable.maxSortBy or box.ownTable.sortBy < 1 then box.ownTable.sortBy = 1;end;
		end;
		if getXMLBool(Xml, xmlNameTag.."#showMissingAmount") ~= nil then 
			box.ownTable.showMissingAmount = getXMLBool(Xml, xmlNameTag.."#showMissingAmount");
		end;		
		if getXMLInt(Xml, xmlNameTag.."#viewFillType") ~= nil then 
			box.ownTable.viewFillType = getXMLInt(Xml, xmlNameTag.. "#viewFillType");
			if box.ownTable.viewFillType > box.ownTable.maxViewFillType or box.ownTable.viewFillType > 1 then box.ownTable.viewFillType = 1;end;
		end;
		if getXMLInt(Xml, xmlNameTag.."#autoAlign") ~= nil then 
			box.ownTable.autoAlign = getXMLInt(Xml, xmlNameTag.."#autoAlign");
			if box.ownTable.autoAlign > box.ownTable.maxAutoAlign or box.ownTable.autoAlign < 1 then box.ownTable.autoAlign = 1;end;
		end;
	end;	
end;

function pih_XmlBox.onSaveXml(box, Xml, xmlNameTag)
	setXMLInt(Xml, xmlNameTag.."#version", 1);	
	
	setXMLInt(Xml, xmlNameTag.. "#daysLeftFilter", box.ownTable.daysLeftFilter);
	setXMLFloat(Xml, xmlNameTag.. "#capacityLevelFilter", box.ownTable.capacityLevelFilter);
	setXMLInt(Xml, xmlNameTag.."#sortBy", box.ownTable.sortBy);
	setXMLInt(Xml, xmlNameTag.."#autoAlign", box.ownTable.autoAlign);
	setXMLBool(Xml, xmlNameTag.."#showMissingAmount", box.ownTable.showMissingAmount);	
	setXMLInt(Xml, xmlNameTag.."#viewFillType", box.ownTable.viewFillType);
end;

function pih_XmlBox:loadBox(name, onSave)
	if name == "Pih_Display_Box" then
		local box = g_currentMission.hlHudSystem.hlBox.generate( {name=name, width=250, height=150, info="ProductionInfoHud Mod\nPih Display Box", autoZoomOutIn="text"} );
		if box ~= nil then
			g_currentMission.hlUtils.loadLanguage( {modTitle=tostring(ProductionInfoHud.metadata.title), class="FS22_ProductionInfoHud", modDir=ProductionInfoHud.modDir.. "scripte_pihdisplay/", xmlDir="FS22_ProductionInfoHud", xmlVersion=1} ); --optional deine eigenen sprachdateien nutzen(texte in deinen hinterlegen)
			pih_SetGet:loadBoxIcons(box);
			box:setMinWidth(box.screen.pixelW*80); --set min. width new (default ..pixelW*30)
			box.onDraw = pih_DrawBox.setBox;
			box.onClick = pih_MouseKeyEventsBox.onClick;							
			box.screen.canBounds.on = true;
			box.resetBoundsByDragDrop = false;
			box.overlays.settingIcons.up.visible = true; --for viewExtraLine
			box.overlays.settingIcons.down.visible = true; --for viewExtraLine
			box.overlays.settingIcons.save.visible = false; --only over global save icon
			box.isHelp = true;
			box.onSaveXml = pih_XmlBox.onSaveXml;						
			pih_XmlBox:onLoadXml(box, box:getXml()); --own box load over Xml (replace Data)
			box.canAutoClose = false;			
			box.canClose = false;
			if onSave == nil or not onSave then 
				box.viewExtraLine = true;
				box.ownTable.lastStateExtraLine = true;
			else
				if box.viewExtraLine then box.ownTable.lastStateExtraLine = true;end;
			end;
			if not box.show then box.show = true;end; --or set on off over !!!

		end;
	end;
end;