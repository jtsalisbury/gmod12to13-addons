
// Plugin for DarkRP

PLUGIN.Name = "PCMod Version Checker"
PLUGIN.Author = "crazyscouter"
PLUGIN.Version = "1.0.0"

function PLUGIN:BeforeLoad()
	PCMod.Msg( ">> PCMod version checker pre-loaded! <<" )
end

function PLUGIN:AfterLoad()
	if (!file.Exists("addons/pcmod2/version.txt", "GAME")) then 
		PCMod.Msg("+-+-+-+-+-+-+-+-+-   ERROR   -+-+-+-+-+-+-+-+-+")  
		PCMod.Msg("Could not find  PCMod version text file! Please make sure your addon is named: pcmod2 & the version file is name version.txt!")  
		PCMod.Msg("+-+-+-+-+-+-+-+-+- END ERROR -+-+-+-+-+-+-+-+-+")  
	else
	
		local vers = file.Read("addons/pcmod2/version.txt", "GAME");
		
		http.Fetch("https://raw.githubusercontent.com/crazyscouter/GMod-Addons/master/pcmod2/version.txt",
			function(body, len, headers, code)
				if (vers != body) then
					PCMod.Msg("+-+-+-+-+-+-+-+-+-   WARNING   -+-+-+-+-+-+-+-+-+")  
					PCMod.Msg("There is a new version of PCMod2 out! Update now at: https://github.com/crazyscouter/GMod-Addons")  
					PCMod.Msg("+-+-+-+-+-+-+-+-+- END WARNING -+-+-+-+-+-+-+-+-+")  
				else
					PCMod.Msg( ">> PCMod is fully updated! <<" )
				end
			end,
			function(err)
				PCMod.Msg("+-+-+-+-+-+-+-+-+-   ERROR   -+-+-+-+-+-+-+-+-+")  
				PCMod.Msg(""..err.."")  
				PCMod.Msg("+-+-+-+-+-+-+-+-+- END ERROR -+-+-+-+-+-+-+-+-+")  
				return;
			end
		);
	end
end