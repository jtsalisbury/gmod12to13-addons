
// Plugin for DarkRP

PLUGIN.Name = "DarkRP"
PLUGIN.Author = "[GU]thomasfn"
PLUGIN.Version = "1.0.0"

PLUGIN.JobDesc = [[You are a specialised computer technician.
	You help other people setup their computers.
	You buy computer equipment for other people.
	Use '!pcbuy' to purchase equipment.
	Use your install disk to install software.
	Charge other people for your services!]];
PLUGIN.JobSweps = { "pcmod_pwcrack", "pcmod_hdcopier", "pcmod_wireswep", "pcmod_unwireswep" }
PLUGIN.JobSalary = 80
PLUGIN.JobColour = Color( 100, 100, 0, 255 )


function PLUGIN:IsDarkRP()
	
	// Is the gamemode DarkRP?
	if (SERVER) then
		return true//(GAMEMODE.Name == "DarkRP");
	end
	if (CLIENT) then
		return ((DrawPlayerInfo) && (DrawPriceInfo) && (DrawShipmentInfo))
	end
end

timer.Simple(10, function()
	PLUGIN:AfterLoad();
end)

function PLUGIN:BeforeLoad()
	PCMod.Msg( ">> DarkRP 2.3.5 PCMod Plugin " .. PLUGIN.Version .. " Pre-Loaded! <<" )
end

function PLUGIN:AfterLoad()
	if (!PLUGIN:IsDarkRP()) then return; end
	
	if (SERVER) then
		PCMod.RP.GetMoney = function( ply )
			PCMod.Msg( "About to retrieve money...", true )
			return tonumber( ply:getDarkRPVar("money") )
		end
		PCMod.RP.CanBuy = function( ply, entclass )
			PCMod.Msg( "About to determine CanBuy()...", true )
			return (ply:Team() == TEAM_COMPTECH)
		end
		PCMod.RP.CanBuyPack = function( ply, entclass )
			PCMod.Msg( "About to determine CanBuyPack()...", true )
			return (ply:Team() == TEAM_COMPTECH)
		end
		PCMod.RP.DeductMoney = function( ply, amount )
			PCMod.Msg( "Deducting '" .. amount .. "' from '" .. ply:Nick() .. "'!", true )
			ply:addMoney( -amount )
		end
	end
	
	TEAM_COMPTECH = AddExtraTeam("Computer Technician", {
		color = PLUGIN.JobColour,
		model = "models/player/eli.mdl",
		description = PLUGIN.JobDesc,
		weapons = PLUGIN.JobSweps,
		command = "comptech",
		max = 2,
		salary = PLUGIN.JobSalary,
		admin = 0,
		vote = false
	});
	PCMod.Cfg.RPMode = true
	PCMod.Msg( ">> DarkRP 2.3.5 PCMod Plugin " .. PLUGIN.Version .. " Post-Loaded! <<" )
	

end

