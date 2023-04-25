pihSetGetForMoh = {cmd={}};

function pihSetGetForMoh:onStartLoad()
	pihSetGetForMoh:loadCmds();	
end;

function pihSetGetForMoh:loadCmds()
	
	--gernerate Cmd for Moh--
	local isGenerate, errorTxt = g_currentMission.multiOverlayV4.cmdFunction.generateCmd( { 
			modName = "ProductionInfoHud";
			cmdName = "output_pihMohSlotOutput_";
			groupName = "ProduktionInfoHud";			
			displayName = "ProductionInfoHud Anzeige";
			infoTxt = "ProductionInfoHud - Output Display over MultiOverlayV4 Slot";
			mouseClickAccepts = {true,true,true}; --by HappyLooser Info / schaltet die mause funktion frei /rechts/mitte/links mit dennen ein spieler in deiner anzeige agieren darf, der wert kommt als args.mouseClick == "MOUSE_BUTTON_LEFT" etc. beim callback mit
			ownTable = { showMissingAmount = false, filterForFillType = nil, filterForProduction = nil };	--by HappyLooser Info / Optional kannst du hier werte oder so hinterlegen dieses table wird dir immer mit übergeben beim callback, der wert kommt in args mit
			typ = {"output_"}; 
			actionCallback = pihOutputForMoh.giveOutputTable; --das output table welches der MOH anfragt bei dir, die anfrage kommt nur wenn der slot auf ist und deine anzeige innerhalb des scrollfensters ist	
		}
	);
	--print("-----Cmd isGenerate: ".. tostring(isGenerate).. " |errorTxt: ".. tostring(errorTxt))
	--gernerate Cmd for Moh--
	
end;