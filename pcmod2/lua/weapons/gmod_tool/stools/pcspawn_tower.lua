if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "Computer Tower"
TOOL.Class = "pcspawn_tower"
TOOL.Desc = "Spawns a computer tower"
TOOL.Inst = {
	{ "Spawn a computer tower" }
}

TOOL.ModelList = {
	"models/props_lab/harddrive02.mdl",
	"models/props/cs_office/computer_case.mdl"
}

TOOL.Type = "spawner"
TOOL.SpawnType = "Hardware"

TOOL.EntName = "Tower"
TOOL.EntClass = "pcmod_tower"
TOOL.DefaultMax = 8
TOOL.Model = "models/props_lab/harddrive02.mdl"

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
		local pf = "Tool_pcspawn_tower_"
	
		// Header
		panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		// Model select
		panel:AddControl( "PropSelect", { Label = "Model:",
							ConVar = "pcspawn_tower_model",
							Category = "pcmod",
							Models = list.Get( "mdls_pcspawn_tower" ) } )
							
		// OS select
		panel:AddControl( "ComboBox", { Label = "Operating System:",
							ConVar = "pcspawn_tower_os",
							Category = "pcmod",
							Options = {
								Personal = { pcspawn_tower_os = "personal" },
								Server = { pcspawn_tower_os = "server" }
							} } )
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn