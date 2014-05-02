if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "Printer"
TOOL.Class = "pcspawn_printer"
TOOL.Desc = "Spawns a printer"
TOOL.Inst = {
	{ "Spawn a printer" }
}

TOOL.ModelList = {
	"models/props_lab/plotter.mdl",
	"models/pcmod/kopierer.mdl"
}

TOOL.Type = "spawner"
TOOL.SpawnType = "Hardware"

TOOL.EntName = "Printer"
TOOL.EntClass = "pcmod_printer"
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
		local pf = "Tool_pcspawn_printer_"
	
		// Header
		panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		// Model select
		panel:AddControl( "PropSelect", { Label = "Model:",
							ConVar = "pcspawn_printer_model",
							Category = "pcmod",
							Models = list.Get( "mdls_pcspawn_printer" ) } )
							
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn