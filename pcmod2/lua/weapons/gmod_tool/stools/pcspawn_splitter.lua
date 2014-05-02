if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "Splitter"
TOOL.Class = "pcspawn_splitter"
TOOL.Desc = "Spawns a splitter"
TOOL.Inst = {
	{ "Spawn a splitter" }
}

TOOL.ModelList = {
	"models/props_lab/tpplug.mdl"
}

TOOL.Type = "spawner"
TOOL.SpawnType = "Hardware"

TOOL.EntName = "Splitter"
TOOL.EntClass = "pcmod_splitter"
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
		local pf = "Tool_pcspawn_splitter_"
	
		// Header
		panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		// Model select
		panel:AddControl( "PropSelect", { Label = "Model:",
							ConVar = "pcspawn_splitter_model",
							Category = "pcmod",
							Models = list.Get( "mdls_pcspawn_splitter" ) } )
							
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn