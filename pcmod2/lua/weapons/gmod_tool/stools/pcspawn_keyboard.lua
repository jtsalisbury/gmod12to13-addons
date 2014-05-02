if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "Keyboard"
TOOL.Class = "pcspawn_keyboard"
TOOL.Desc = "Spawns a keyboard"
TOOL.Inst = {
	{ "Spawn a keyboard" }
}

TOOL.ModelList = {
	"models/props_c17/computer01_keyboard.mdl",
	"models/props/cs_office/computer_keyboard.mdl"
}

TOOL.Type = "spawner"
TOOL.SpawnType = "Hardware"

TOOL.EntName = "Keyboard"
TOOL.EntClass = "pcmod_keyboard"
TOOL.DefaultMax = 8
TOOL.Model = TOOL.ModelList[ 1 ]

local dat = PCTool.RegisterSTool( TOOL )
table.Merge( TOOL, dat )

if (SERVER) then

	function TOOL:BuildSetupData()
		return {}
	end

end

if (CLIENT) then

	function TOOL.BuildCPanel( panel )
		local pf = "Tool_pcspawn_keyboard_"
	
		// Header
		panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		// Model select
		panel:AddControl( "PropSelect", { Label = "Model:",
							ConVar = "pcspawn_keyboard_model",
							Category = "pcmod",
							Models = list.Get( "mdls_pcspawn_keyboard" ) } )
							
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn