ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Category 			= "EGM (Entity GameModes)"
ENT.PrintName			= "EGM"
ENT.Author			= "James"
ENT.Contact			= ""
ENT.Purpose			= "Loads mini gamemodes"
ENT.Instructions		= "Walk up to and hit USE"
ENT.Spawnable			= false
ENT.AdminSpawnable		= true

EGMINFO = {};
function RegisterNewGamemode(Name, Filename, Description, Launcher)	
	table.insert(EGMINFO, {NAME = Name, FILENAME = Filename, DESCRIPTION = Description, LAUNCH = Launcher})
	//print("ADDED!")
end
//print("ENDED");
