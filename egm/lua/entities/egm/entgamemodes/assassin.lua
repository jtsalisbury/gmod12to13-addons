--DO NOT EDIT BELOW------------------------------------------------------------

RegisterNewGamemode("Assassin", "Assassin.lua", "Hide from the assassin!", function() AssassinStart() end)

-------------------------------------------------------------------------------

--Admin vars
NumberRounds = 3 -- How many rounds?
RoundTime = 180 -- How long in seconds does the round take?
HideTime = 10 -- how long do the players have to hide?

--DO NOT EDIT BELOW------------------------------------------------------------
Assassin = nil;
CurrentRound = 0;
AssassinKills = 0;

if (SERVER) then

	function AssassinStart()
		if(CurrentRound >= NumberRounds) then
		
			ACTIVEGAMEMODE = false;
			Assassin = nil;
			CurrentRound = 0;
				
			for _,v in pairs(player.GetAll()) do
				v:Freeze(false);
				v:KillSilent()
				v:Spawn()
			end

		else
				
			AssassinKills = 0;
			CurrentRound = CurrentRound + 1;
			
			local RandomNum = math.random(1, #player.GetAll());
			for k,v in pairs(player.GetAll()) do
			
				v:Freeze(false); -- unfreeze any people from previous rounds
				v:PrintMessage( HUD_PRINTCENTER, "This is Round #" ..CurrentRound.." of a total "..NumberRounds);
				
				if(k == RandomNum) then
					Assassin = v;
				end
			end
		
			AssassinINIT();
			PlayerINIT();
			timer.Create("RoundTimer", RoundTime, 0 , AssassinLost);
		end
	end

	function AssassinINIT()
		Assassin:KillSilent();
		Assassin:Freeze( true );
		Assassin:PrintMessage( HUD_PRINTTALK, "You are the assassin! You have " ..RoundTime.." seconds to find and kill all the players!" );
		Assassin:PrintMessage( HUD_PRINTTALK, "Please wait for "..HideTime.." seconds to give the players time to hide." );
		Assassin:SetColor(255,0,0,255);
		timer.Create("AssassinPause", HideTime , 1 , function()
		
		Assassin:Freeze( false )
		Assassin:Spawn()
		
		end
		);
	end
	
	function PlayerINIT()
		for k,v in pairs(player.GetAll()) do
			if (v != Assassin) then
				v:KillSilent();
				v:Spawn();
				v:PrintMessage( HUD_PRINTTALK, Assassin:Nick().." is the assassin! You have " ..RoundTime.." seconds to stay alive!" );
				v:PrintMessage( HUD_PRINTTALK, "Quickly you have "..HideTime.." seconds hide!" );
			end
		end
				
	end
	
	function AssasinKill(victim,inflictor,killer)
	if not(ACTIVEGAMEMODE == "Assassin") then return end
		
		if(AssassinKills >= #player.GetAll()) then
			
			for _,v in pairs(player.GetAll()) do
				v:PrintMessage( HUD_PRINTTALK, Assassin:Nick().." wins!");
			end
			timer.Destroy("RoundTimer");
			AssassinStart();
			
		else
		
			if(victim != Assassin) then
				AssassinKills = AssassinKills + 1;
				victim:Freeze(true);
				victim:PrintMessage( HUD_PRINTTALK, "Sorry! You'll have to wait until the end of the round to spawn!" );
			end
		end
	end
	hook.Add("PlayerDeath","AssassinKill",AssasinKill)
	
	function OnSpawn()
	if not(ACTIVEGAMEMODE == "Assassin") then return end
		
		for _,v in pairs(player.GetAll()) do
			
			if(v == Assassin) then
				v:Give("weapon_crossbow");
				v:GiveAmmo(#player.GetAll(), "xbowbolt");
			else
				v:StripWeapons();
			end
		end
		
	end
	hook.Add( "PlayerSpawn", "OnAssassinSpawn", OnSpawn)
	
	function AssassinLost()
		for _,v in pairs(player.GetAll()) do
			v:PrintMessage( HUD_PRINTTALK, Assassin:Nick().." looses!");
		end
		timer.Destroy("RoundTimer");
		AssassinStart();
	end
	
	function AssassinAdminEnd(ply,cmd,args)
		if(ply:IsAdmin() or !ply:IsValid())then
			ACTIVEGAMEMODE = false;
			Assassin = nil;
			CurrentRound = 0;
			for _,v in pairs(player.GetAll()) do
				v:Freeze(false);
				v:KillSilent();
				v:Spawn();
			end
		end
	end
	concommand.Add("EndAssassin",AssassinAdminEnd)
end