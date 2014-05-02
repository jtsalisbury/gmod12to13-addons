if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "I/O Device"
TOOL.Class = "pcspawn_iodevice"
TOOL.Desc = "Spawns a I/O device"
TOOL.Inst = {
	{ "Spawn a I/O device" }
}

TOOL.ModelList = {
	"models/props_lab/reciever01d.mdl"
}

TOOL.Type = "spawner"
TOOL.SpawnType = "Hardware"

TOOL.EntName = "I/O Device"
TOOL.EntClass = "pcmod_iodevice"
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
		local pf = "Tool_pcspawn_iodevice_"
	
		// Header
		panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		// Model select
		panel:AddControl( "PropSelect", { Label = "Model:",
							ConVar = "pcspawn_iodevice_model",
							Category = "pcmod",
							Models = list.Get( "mdls_pcspawn_iodevice" ) } )
							
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn