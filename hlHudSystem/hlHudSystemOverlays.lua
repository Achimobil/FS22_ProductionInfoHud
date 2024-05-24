hlHudSystemOverlays = {};

local hlHudSystemOverlays_mt = Class(hlHudSystemOverlays);

function hlHudSystemOverlays.new(args)	
	
	local self = {};

	setmetatable(self, hlHudSystemOverlays_mt);
		
	if args.screen == nil then args.screen = g_currentMission.hlHudSystem.screen;end;
	self.bg = hlHudSystemOverlays:insertOverlay( {name="background", screen=args.screen, width=args.width, height=args.height, iconPos=120} );
	self.bgFrame = hlHudSystemOverlays:insertOverlay( {name="background", color=hlHudSystemOverlays.color.backgroundSetting, screen=args.screen, width=args.width, height=args.height, iconPos=120} );
	self.state = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, color="blackInactive" ,iconPos=114, setStateInArea=true} );
	self.statePercent = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, color="blackInactive", iconPos=113, setStateInArea=true} );
	self.bgLine = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=127, setStateInArea=true} );	
	self.bgLine.visible = false; --hidden line for marker/select click areas or ....
	if args.typ == "hud" then
		self.separator = hlHudSystemOverlays:insertOverlay( {name="separator", screen=args.screen, iconPos=120} );		
		self.inArea = hlHudSystemOverlays:insertOverlay( {name="inArea", screen=args.screen, width=args.width, iconPos=120} ); 
		self.selectArea = hlHudSystemOverlays:insertOverlay( {name="selectArea", screen=args.screen, width=args.width, iconPos=120} );
	end;	
	self.settingIcons = {};
	self.settingIcons.bgBlack = hlHudSystemOverlays:insertOverlay( {name="backgroundSetting", color="black", screen=args.screen, iconPos=120, setStateInArea=true} );
	setOverlayColor(self.settingIcons.bgBlack.overlayId, 0, 0, 0, 1); --problem with default color option and black ? set here color
	self.settingIcons.bgRoundBlack = hlHudSystemOverlays:insertOverlay( {name="backgroundSetting", color="black", screen=args.screen, iconPos=119, setStateInArea=true} );
	setOverlayColor(self.settingIcons.bgRoundBlack.overlayId, 0, 0, 0, 1); --problem with default color option and black ? set here color
	self.settingIcons.dragDrop = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=55, setStateInArea=true} );	
	self.settingIcons.sizeWidthHeight = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=54, setStateInArea=true} );
	self.settingIcons.setting = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=20, setStateInArea=true} );	
	self.settingIcons.settingO = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=58, setStateInArea=true} );
	self.settingIcons.leftRight = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.text, screen=args.screen, iconPos=56, setStateInArea=true} ); --speziale small		
	self.settingIcons.view = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=35, setStateInArea=true} );
	self.settingIcons.save = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=17, setStateInArea=true} );
	self.settingIcons.help = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=13, setStateInArea=true} );
	self.settingIcons.info = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=30, setStateInArea=true} );
	self.settingIcons.search = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=59, setStateInArea=true} );
	self.settingIcons.search.visible = false; --default hidden
	if args.typ == "pda" or args.typ == "box" then		
		self.settingIcons.markerWidthHeight = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=53, setStateInArea=true} );
		self.settingIcons.autoClose = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.notActive, screen=args.screen, iconPos=42, setStateInArea=true} );
		self.settingIcons.close = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.off, screen=args.screen, iconPos=50, setStateInArea=true} );
		self.settingIcons.up = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.text, screen=args.screen, iconPos=3, setStateInArea=true} );
		self.settingIcons.up.visible = false; --default hidden
		self.settingIcons.down = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.text, screen=args.screen, iconPos=2, setStateInArea=true} );
		self.settingIcons.down.visible = false; --default hidden
	end;
	if args.loadDefaultIcons ~= nil and args.loadDefaultIcons then
		self.icons = {byName={}};
		g_currentMission.hlUtils.insertIcons( {xmlTagName="hlHudSystem.loadIcons", modDir=g_currentMission.hlHudSystem.modDir, iconFile="hlHudSystem/icons/icons.dds", xmlFile="hlHudSystem/icons/icons.xml", modName="defaultIcons", groupName=tostring(args.typ), fileFormat={64,512,1024}, setStateInArea=true, iconTable=self.icons} );
	end;
	self.modIcons = {byName={}}; --optional insert Mods Icons here (with g_currentMission.hlUtils.insertIcons(....) ) or set new table ( !Attention! mod delete not new table)
		
	return self;
end;

function hlHudSystemOverlays:insertOverlay(args)	
	local iconFilePath = Utils.getFilename(args.fileName or "hlHudSystem/icons/icons.dds", args.modDir or g_currentMission.hlHudSystem.modDir);
	if iconFilePath == nil then return nil;end;
	local height = 0; 
	local color = args.color or hlHudSystemOverlays.color[args.name] 
	if color == nil then color = hlHudSystemOverlays.color["background"];end;
	local width = 0;
	if args.height ~= nil and args.screen ~= nil then
		height = args.screen.pixelH*args.height;
	elseif args.screen ~= nil then
		if args.name ~= nil and args.name == "background" then
			height = args.screen.size.background[2];
		end;
	elseif args.height ~= nil then
		height = g_currentMission.hlHudSystem.screen.pixelH*args.height;
	end;
	if args.width ~= nil and args.screen ~= nil then
		width = args.screen.pixelW*args.width;
	elseif args.screen ~= nil then		
		if args.name ~= nil and args.name == "background" then
			width = args.screen.size.background[1];
		end;
	elseif args.width ~= nil then
		width = g_currentMission.hlHudSystem.screen.pixelW*args.width;
	end;
	local overlay = Overlay.new(iconFilePath, 0, 0, width, height);
	local formatO = 64;
	local sW = 512;
	local sH = 1024;
	local iconPos = 1;
	if args.iconPos ~= nil and type(args.iconPos) == "number" then
		iconPos = args.iconPos or 1;
		if args.fileFormat ~= nil then
			formatO = args.fileFormat[1] or 0;
			sW = args.fileFormat[2] or 0;
			sH = args.fileFormat[3] or 0;
		end;	
	end;
	g_currentMission.hlUtils.setOverlayUVsPx(overlay, unpack(g_currentMission.hlUtils.getNormalUVs(formatO, sW, sH, iconPos)));
	overlay.mouseInArea = false;
	if args.setStateInArea ~= nil and args.setStateInArea then g_currentMission.hlUtils.setStateInArea(overlay);end;
	
	g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(color, true));
	
	if args.name ~= nil and args.name == "background" and args.screen ~= nil then
		args.screen.width = width;
		args.screen.height = height;
	end;
	return overlay;
end;
	
hlHudSystemOverlays.color = {
	background = "blackDisabled";
	backgroundSetting = "black";
	separator = "whiteInactive";	
	inArea = "ls15";
	selectArea = "ls22";
	isShow = "ls22";
	icon = "darkGray";
	notActive = "darkGray";
	title = "ls22";
	text = "white";
	columTitle = "gold";
	columText1 = "khaki";
	columText2 = "mangenta";
	on = "green";
	off = "red";
	warning = "yellow";
	globalSettingOn = "ls22";
	globalSettingOff = "darkGray";
	settingOn = "ls22";
	settingOff = "darkGray";	
};

function hlHudSystemOverlays:deleteMap()
	function deleteOverlays(typ, debugPrint, txt)		
		g_currentMission.hlUtils.deleteOverlays(typ.overlays.settingIcons, debugPrint, txt.. " settingIcons");		
		g_currentMission.hlUtils.deleteOverlays(typ.overlays, debugPrint, txt.. " default");
		if typ.overlays.icons ~= nil then
			for modName,groupTable in pairs (typ.overlays.icons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(typ.overlays.icons[modName][groupName], debugPrint, txt.. " icons");						
					end;
				end;
			end;
		end;
		if typ.overlays.modIcons ~= nil then
			for modName,groupTable in pairs (typ.overlays.modIcons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(typ.overlays.modIcons[modName][groupName], debugPrint, txt.. " modIcons");						
					end;
				end;
			end;
		end;
		if typ.menue ~= nil and #typ.menue > 0 then
			for m=1, #typ.menue do
				if typ.menue[m].icon ~= nil then
					if typ.menue[m].icon.bg ~= nil and typ.menue[m].icon.bg.overlayId ~= nil then typ.menue[m].icon.bg:delete();end;
					if typ.menue[m].icon.close ~= nil and typ.menue[m].icon.close.overlayId ~= nil then typ.menue[m].icon.close:delete();end;
					if typ.menue[m].icon.bgLine ~= nil and typ.menue[m].icon.bgLine.overlayId ~= nil then typ.menue[m].icon.bgLine:delete();end;
				end;
			end;
		end;
	end;
	if g_currentMission.hlHudSystem.hud ~= nil and #g_currentMission.hlHudSystem.hud > 0 then
		for h=1, #g_currentMission.hlHudSystem.hud do
			deleteOverlays(g_currentMission.hlHudSystem.hud[h], false, "Hud ".. tostring(h));
		end;		
	end;
	if g_currentMission.hlHudSystem.pda ~= nil and #g_currentMission.hlHudSystem.pda > 0 then
		for p=1, #g_currentMission.hlHudSystem.pda do
			deleteOverlays(g_currentMission.hlHudSystem.pda[p], false, "Pda ".. tostring(p));
		end;
	end;
	if g_currentMission.hlHudSystem.box ~= nil and #g_currentMission.hlHudSystem.box > 0 then
		for b=1, #g_currentMission.hlHudSystem.box do
			deleteOverlays(g_currentMission.hlHudSystem.box[b], false, "Box ".. tostring(b));
		end;
	end;
	deleteOverlays(g_currentMission.hlHudSystem, false, "HL Hud System");
end;

function hlHudSystemOverlays:generateBgMenue(typ, args) --optional generate simple background(menue) with close button and title, better generate new box/pda and disabled ...canSave and visible icons save,dragdrop etc.
	if typ == nil or args == nil or type(args) ~= "table" then return;end;	
	local iconFilePath = Utils.getFilename("hlHudSystem/icons/icons.dds", g_currentMission.hlHudSystem.modDir);
	typ.menue[#typ.menue+1] = {show=false,title=Utils.getNoNil(args.title, ""),size=Utils.getNoNil(args.size, 0.010),icon={}};
	local width = Utils.getNoNil(args.width, 200);
	local height = Utils.getNoNil(args.height, 35);
	local menue = typ.menue[#typ.menue];
	menue.icon.bg = Overlay.new(iconFilePath, 0.5-((typ.screen.pixelW*width)/2), 0.3, typ.screen.pixelW*width, typ.screen.pixelH*height);
	g_currentMission.hlUtils.setOverlayUVsPx(menue.icon.bg, unpack(g_currentMission.hlUtils.getNormalUVs(64, 512, 1024, 120)));	
	g_currentMission.hlUtils.setBackgroundColor(menue.icon.bg, g_currentMission.hlUtils.getColor("blackDisabled", true));
	g_currentMission.hlUtils.setStateInArea(menue.icon.bg);
	local posX = menue.icon.bg.x+menue.icon.bg.width-(typ.screen.pixelW*10);
	local posY = menue.icon.bg.y+menue.icon.bg.height-(typ.screen.pixelH*10)
	menue.icon.close = Overlay.new(iconFilePath, posX, posY, typ.screen.pixelW*10, typ.screen.pixelH*10);
	g_currentMission.hlUtils.setOverlayUVsPx(menue.icon.close, unpack(g_currentMission.hlUtils.getNormalUVs(64, 512, 1024, 50)));
	g_currentMission.hlUtils.setBackgroundColor(menue.icon.close, g_currentMission.hlUtils.getColor("red", true));
	g_currentMission.hlUtils.setStateInArea(menue.icon.close);
	menue.icon.bgLine = Overlay.new(iconFilePath, menue.icon.bg.x+menue.icon.close.width, menue.icon.bg.y+menue.icon.bg.height-(menue.icon.close.height*2), menue.icon.bg.width-(menue.icon.close.width*2), typ.screen.pixelH*10);
	g_currentMission.hlUtils.setOverlayUVsPx(menue.icon.bgLine, unpack(g_currentMission.hlUtils.getNormalUVs(64, 512, 1024, 127)));
	g_currentMission.hlUtils.setStateInArea(menue.icon.bgLine);
	menue.icon.bgLine.visible = false;
end;