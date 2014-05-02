if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "Monitor"
TOOL.Class = "pcspawn_monitor"
TOOL.Desc = "Spawns a monitor"
TOOL.Inst = {
	{ "Spawn a monitor" }
}

TOOL.ModelList = {
	"models/props/cs_office/computer_monitor.mdl",
	"models/props_lab/monitor01a.mdl"
}

TOOL.Type = "spawner"
TOOL.SpawnType = "Hardware"

TOOL.EntName = "Monitor"
TOOL.EntClass = "pcmod_monitor"
TOOL.DefaultMax = 8
TOOL.Model = TOOL.ModelList[1]

local dat = PCTool.RegisterSTool( TOOL )
table.Merge( TOOL, dat )

if (SERVER) then

	function TOOL:BuildSetupData()
		return {}
	end

end

if (CLIENT) then

	function TOOL.BuildCPanel( panel )
		local pf = "Tool_pcspawn_monitor_"
	
		// Header
		panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		// Model select
		panel:AddControl( "PropSelect", { Label = "Model:",
							ConVar = "pcspawn_monitor_model",
							Category = "pcmod",
							Models = list.Get( "mdls_pcspawn_monitor" ) } )
							
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn