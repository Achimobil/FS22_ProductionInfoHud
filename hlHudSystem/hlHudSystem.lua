hlHudSystem = {};

hlHudSystem.metadata = {
	interface = " FS22 ...",
	title = "HL Hud System",
	notes = " Erstellt Hud/PDA und Box Anzeigen für Mods etc. zum selbst befüllen von Daten/Icons etc. (optional selbst befüllen oder nur formatierte Lines Texte übergeben etc.)",
	author = " (by HappyLooser)",
	version = " v0.6 Beta",
	systemVersion = 0.6,
	xmlVersion = 1,
	languageVersion = 1;
	datum = " 21.05.2023",
	update = " 12.04.2024",
	web = " http://www.modhoster.de",
	info = " Link Freigabe und Änderungen ist ohne meine Zustimmung nicht erlaubt",
	info1 = " Benutzung als HUD System in einem Mod (ohne Code Änderung) ist ohne Zustimmung erlaubt",
	"##Orginal Link Freigabe:  http://www.modhoster.de"
};

hlHudSystem.modDir = g_currentModDirectory;
function hlHudSystem:loadMap()
	if hlHudSystem:getDetiServer() then return;end;
	Mission00.onStartMission = Utils.prependedFunction(Mission00.onStartMission, hlHudSystem.onStartMission);
	if g_currentMission.hlHudSystem == nil then 
		g_currentMission.hlHudSystem = {};
		g_currentMission.hlHudSystem.version = hlHudSystem.metadata.systemVersion;
		g_currentMission.hlHudSystem.xmlVersion = hlHudSystem.metadata.xmlVersion;
		g_currentMission.hlHudSystem.modDir = hlHudSystem.modDir;
		g_currentMission.hlHudSystem.meta = hlHudSystem.metadata;
	else
		if g_currentMission.hlHudSystem.version < hlHudSystem.metadata.systemVersion then
			g_currentMission.hlHudSystem = {};
			g_currentMission.hlHudSystem.version = hlHudSystem.metadata.systemVersion;
			g_currentMission.hlHudSystem.xmlVersion = hlHudSystem.metadata.xmlVersion;
			g_currentMission.hlHudSystem.modDir = hlHudSystem.modDir;
			g_currentMission.hlHudSystem.meta = hlHudSystem.metadata;
		else
			print("---Info Not loading ".. tostring(hlHudSystem.metadata.title).. " over Mod, found newer or identical Version")			
		end;		
	end;	
end;

function hlHudSystem.onStartMission()	
	if g_currentMission == nil or g_currentMission.hlHudSystem == nil or g_currentMission.hlHudSystem.modDir ~= hlHudSystem.modDir or g_currentMission.hlUtils == nil then
		if g_currentMission.hlUtils == nil then
			print("---WARNING ".. tostring(hlHudSystem.metadata.title).. " needs HL Utils Script by HappLooser, deinstalled HL Hud System")
		end;
		removeModEventListener(hlHudSystem);
	else
		if hlHudSystem:getDetiServer() then return;end;
		print("---loading ".. tostring(hlHudSystem.metadata.title).. tostring(hlHudSystem.metadata.version).. tostring(hlHudSystem.metadata.author).. "---")
		createFolder(getUserProfileAppPath().. "modSettings/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/languages/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/hud/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/pda/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/box/");
		loadScripts();		
		g_currentMission.hlHudSystem = hlHudSystem.new();
		g_currentMission.hlHudSystem.hlHud = hlHud;
		g_currentMission.hlHudSystem.hlPda = hlPda;
		g_currentMission.hlHudSystem.hlBox = hlBox;
		hlHudSystemXml:load(hlHudSystem.metadata.title);
		if g_currentMission.hlHudSystem.timer.autoSave ~= nil and g_currentMission.hlHudSystem.timer.autoSave ~= 0 then
			g_currentMission.hlUtils.addTimer( {delay=g_currentMission.hlHudSystem.timer.autoSave or g_currentMission.hlHudSystem.timer.autoSaveDefault, name="hlHudSystem_autoSave", repeatable=true, ms=false, action=hlHudSystem.autoSave} );
		end;
		g_currentMission.hlUtils.addTimer( {delay=g_currentMission.hlHudSystem.timer.firstInfo or 80, name="hlHudSystem_firstInfo", repeatable=1, ms=false, action=hlHudSystem.firstInfo} );
		---enable this hud bsp. only for testing, then deactivate it again---
		--local hud = hlHud.generate( {name="hlHudSystem_OwnHud", info="HL Hud System Own Bsp. Hud\nReal Time Day by HappyLooser"} );
		--hud.onDraw = hlHudOwnDraw.setHud; --own hud
		--hud.onClick = hlHudOwnMouseKeyEvents.onClick; --own hud			
		--hud.onSaveXml = hlHudOwnXml.onSaveXml; --own hud
		--hlHudOwnXml:onLoadXml(hud, hud:getXml()); --own hud load over Xml		
		---enable this hud bsp. only for testing, then deactivate it again---		
	end;
end;

function hlHudSystem:delete()
	if hlHudSystem:getDetiServer() then return;end;
end;

function hlHudSystem:deleteMap()
	if hlHudSystem:getDetiServer() then return;end;
	hlHudSystemXml:save(); --save all Hud/Pda/Box
	hlHudSystemOverlays:deleteMap();
end;

function hlHudSystem:mouseEvent(posX, posY, isDown, isUp, button)
	if hlHudSystem:getDetiServer() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;	
	hlHudSystemMouseKeyEvents:setKeyMouse(nil, nil, nil, nil, posX, posY, isDown, isUp, button);
end;

function hlHudSystem:keyEvent(unicode, sym, modifier, isDown)	
	if hlHudSystem:getDetiServer() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	hlHudSystemMouseKeyEvents:setKeyMouse(unicode, sym, modifier, isDown, nil, nil, nil, nil, nil);
end;

function hlHudSystem:update(dt)	
	if hlHudSystem:getDetiServer() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	if not g_currentMission.hlUtils.isMouseCursor then g_currentMission.hlHudSystem.clickAreas = {};end;
	if g_currentMission.hlHudSystem.infoDisplay.firstStart and g_currentMission.hlUtils.isMouseCursor then hlHudSystem.firstInfo();end;
end;

function hlHudSystem:draw()	
	if hlHudSystem:getDetiServer() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	--respect settings for other mods (not every mod) that's why
	setTextAlignment(0);
	setTextLineBounds(0, 0);
	setTextWrapWidth(0);
	setTextColor(1, 1, 1, 1);
	setTextBold(false);
	--respect settings for other mods	
	
	hlHudSystemDraw.showHuds();
		
	if #g_currentMission.hlHudSystem.testString > 0 then
		setTextBold(true);		
		for a=1, #g_currentMission.hlHudSystem.testString do
			local posY = 0.25-(a/100);
			renderText(0.5, posY, 0.010, "-S ".. tostring(a).. "- ".. tostring(g_currentMission.hlHudSystem.testString[a]));
		end;
	end;
	--respect settings for other mods
	setTextAlignment(0);
	setTextLineBounds(0, 0);
	setTextWrapWidth(0);
	setTextColor(1, 1, 1, 1);
	setTextBold(false);
	--respect settings for other mods	
end;

function hlHudSystem.new()	
	local hlHudSystem_mt = Class(hlHudSystem);
	local self = {};

	setmetatable(self, hlHudSystem_mt);
	
	self.hud = {};
	self.pda = {};
	self.box = {};
	self.other = {};
	
	self.settingsDir = getUserProfileAppPath().. "modSettings/HL/HudSystem/";	
	self.modDir = hlHudSystem.modDir;	
	self.metadata = hlHudSystem.metadata;
	self.screen = hlHudSystemScreen.new( {typ="hud", master=true} );
	self.overlays = hlHudSystemOverlays.new( {loadDefaultIcons=true, screen=self.screen, typ="hud", master=true} );	
	self.isSetting = {hud=false,pda=false,box=false,other=false,viewFrame=false};
	self.infoDisplay = {on=true, where="", firstStart=true, autoSave=true};	
	self.ownData = {mpOff=false,isHidden=false,moh=g_modIsLoaded["MultiOverlayV4"] and _G["MultiOverlayV4"] ~= nil};
	self.autoAlign = hlHudSystemAutoAlign:getTables();
	self.drawIsIngameMapLarge = true;
	self.language = "_".. string.lower(g_languageShort);
	self.isSave = true;
	self.timer = {autoSaveDefault=600, autoSave=600, firstInfo=80};
	self.callbacks = {};
	self.testString = {};
	self.clickAreas = {};
	self.areas = {}; --own for Setting Icons etc.
	self.alreadyExistsXml = {hud={}, pda={}, box={}};
	self.isAlreadyExistsXml = function(typ, name) return self.alreadyExistsXml[typ][name];end;	
	self.setMapHotspot = function(objects, color, blinking, insert)	g_currentMission.hlUtils.generateObjectMapHotspot( {objects=objects, color=color, file=g_currentMission.hlHudSystem.modDir.. "hlHudSystem/icons/icons.dds", fileFormat={64, 512, 1024, 15}, blinking=blinking, insert=insert} );end;
	
	return self;
end;

function loadScripts()		
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemAutoAlign.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemXml.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemScreen.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemOverlays.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHud.lua");		
	source(hlHudSystem.modDir.."hlHudSystem/hlPda/hlPda.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlBox/hlBox.lua");	
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemMouseKeyEvents.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemDraw.lua");	
end;

function hlHudSystem:getDetiServer()	
	return g_dedicatedServer ~= nil;
end;

function hlHudSystem.autoSave()
	if g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission.hlHudSystem.ownData.mpOff then return;end;
	hlHudSystemXml:save(true);
	if g_currentMission.hlHudSystem.infoDisplay.on and g_currentMission.hlHudSystem.infoDisplay.autoSave then
		g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, "HL Hud System INFO: ".. g_i18n:getText("ui_autosave", "Auto Save"), 2500);
	end;
end;

function hlHudSystem.firstInfo()
	if not g_currentMission.hlHudSystem.infoDisplay.firstStart then return;end;
	g_currentMission.hlHudSystem.infoDisplay.firstStart = false;
	hlHudSystem:setFirstInfo();
end;

function hlHudSystem:setFirstInfo()
	g_currentMission.hlUtils.deleteTextDisplay(); --delete Info
	g_currentMission.hud:showInGameMessage("HL Hud System Info",  g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_firstStart"), -1); 
end;

function hlHudSystem:setClickArea(args) --free onClick areas somewhere on screen	
	if args == nil or type(args) ~= "table" or args.whatClick == nil or type(args.whatClick) ~= "string" or args.onClick == nil or type(args.onClick) ~= "function" then return;end;
	if not g_currentMission.hlUtils.isMouseCursor then 
		self.clickAreas = {};
		return;
	end;
	if self.clickAreas[args.whatClick] == nil then self.clickAreas[args.whatClick] = {};end;
	self.clickAreas[args.whatClick][#self.clickAreas[args.whatClick]+1] = {
		args[1]; --posX needs
		args[2]; --posX1 needs
		args[3]; --posY needs
		args[4]; --posY1 needs		
		whatClick = args.whatClick; --needs	a string		
		whereClick = args.whereClick; --optional or use ownTable		
		areaClick = args.areaClick; --optional
		overlay = args.overlay; --optional
		ownTable = args.ownTable; --optional
		onClick = args.onClick; --needs for mouse click area callback
	};	
end;

function hlHudSystem:searchFilter(typ, resetBounds, dialogTxt)
	local text = g_i18n:getText("button_apply"); 
	local confirmText = g_i18n:getText("helpLine_FarmingBasics_MapFilters_filters_title").. "/".. g_i18n:getText("button_apply");
	local backText = g_i18n:getText("button_close").. "/".. g_i18n:getText("button_delete")
	local dialogText = dialogTxt or "Search (min. 1 Letter)\n* first + min. 1 Letter\nBsp: *hor -> w -> ha -> *ors ...";
	g_gui:showTextInputDialog({
		text = text,
		defaultText = typ.searchFilter,
		callback = function (result, yes)
			if yes then
				if result:len() < 1 or (result:len() == 1 and string.find(result, "*")) then
					typ:setSearchFilter("", false);					
				else
					typ:setSearchFilter(tostring(result), resetBounds);														
				end;				
			else
				typ:setSearchFilter("", resetBounds);
			end;			
		end,
		dialogPrompt = dialogText,
		imePrompt = g_i18n:getText("modHub_search"),
		confirmText = confirmText,
		backText = backText;
		maxCharacters = 30,
		disableFilter = true		
	})
end;													
addModEventListener(hlHudSystem);