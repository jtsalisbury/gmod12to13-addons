if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "Laptop"
TOOL.Class = "pcspawn_laptop"
TOOL.Desc = "Spawns a laptop"
TOOL.Inst = {
	{ "Spawn a laptop" }
}

TOOL.ModelList = {
	"models/pcmod/eeepc.mdl"
}

TOOL.Type = "spawner"
TOOL.SpawnType = "Hardware"

TOOL.EntName = "Laptop"
TOOL.EntClass = "pcmod_laptop"
TOOL.DefaultMax = 8
TOOL.Model = TOOL.ModelList[1]

local dat = PCTool.RegisterSTool( TOOL )
table.Merge( TOOL, dat )

TOOL.ClientConVar[ "os" ] = "personal"

if (SERVER) then

	function TOOL:BuildSetupData()
		local tmp = {}
			local OS = self:GetClientInfo( "os" )
			if ((OS == "personal") || (OS == "server")) then
				tmp.OS = OS
				tmp.BootCommand = "os:instance\nos:launch"
			else
				tmp.OS = ""
				tmp.BootCommand = "waitcommand"
			end	
		return tmp
	end

end

if (CLIENT) then

	function TOOL.BuildCPanel( panel )
		local pf = "Tool_pcspawn_laptop_"
	
		// Header
		panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		// Model select
		panel:AddControl( "PropSelect", { Label = "Model:",
							ConVar = "pcspawn_laptop_model",
							Category = "pcmod",
							Models = list.Get( "mdls_pcspawn_laptop" ) } )
							
		// OS select
		panel:AddControl( "ComboBox", { Label = "Operating System:",
							ConVar = "pcspawn_laptop_os",
							Category = "pcmod",
							Options = {
								Personal = { pcspawn_laptop_os = "personal" },
								Server = { pcspawn_laptop_os = "server" }
							} } )
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn