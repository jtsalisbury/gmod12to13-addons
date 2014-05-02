if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "Backbone Router"
TOOL.Class = "pcspawn_brouter"
TOOL.Desc = "Spawns a backbone router"
TOOL.Inst = {
	{ "Spawn a backbone router" }
}

TOOL.ModelList = {
	"models/props_lab/reciever01a.mdl"
}

TOOL.Type = "spawner"
TOOL.SpawnType = "Networking"

TOOL.EntName = "Backbone Router"
TOOL.EntClass = "pcmod_brouter"
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
		local pf = "Tool_pcspawn_brouter_"
	
		// Header
		panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		// Model select
		panel:AddControl( "PropSelect", { Label = "Model:",
							ConVar = "pcspawn_brouter_model",
							Category = "pcmod",
							Models = list.Get( "mdls_pcspawn_brouter" ) } )
							
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn