if (!PCTool) then include( "pcmod/sh_tool.lua" ) end

TOOL.Name = "Speaker"
TOOL.Class = "pcspawn_speaker"
TOOL.Desc = "Spawns a speaker"
TOOL.Inst = {
	{ "Spawn a speaker" }
}

TOOL.ModelList = {
	"models/props_junk/MetalBucket01a.mdl",
	"models/Chipstiks_PCMod_Models/Speakers/StandardSpeakerMetal.mdl"
}

TOOL.Type = "spawner"
TOOL.SpawnType = "Hardware"

TOOL.EntName = "Speaker"
TOOL.EntClass = "pcmod_speaker"
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
		local pf = "Tool_pcspawn_speaker_"
	
		// Header
		panel:AddControl( "Header", { Text = "#" .. pf .. "name", Description = "#" .. pf .. "desc" } )
		
		// Model select
		panel:AddControl( "PropSelect", { Label = "Model:",
							ConVar = "pcspawn_speaker_model",
							Category = "pcmod",
							Models = list.Get( "mdls_pcspawn_speaker" ) } )
							
	end
	
end

// I suggest any people looking to learn to make STools do NOT look and learn from this code, it is not the conventional way of doing it. -thomasfn