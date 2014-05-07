--Super Simple Deathmatch

--Admin vars
KillLimit = 10 -- How many kills before round is up
NumRounds = 3 -- How many rounds total

-- DO NOT EDIT BELOW-------------------------------------------------------

TotalRounds = 1;
TotalKills = 0;
DMLeaderName = "";
DMLeaderScore = 0;

--Gamemode Information
RegisterNewGamemode("Super Simple Deathmatch", "SuperSimpleDeathmatch.lua", "A simple deathmatch", function() DeathMatchStart() end);

if(SERVER) then
	
	function DeathMatchStart()
		
		TheScore = {};
		for k,v in pairs(player.GetAll()) do
			TheScore[v:Nick()] = 0;
		end
		       		
		StartRound();
		
	end
	
	function StartRound()
		if(TotalRounds > NumRounds) then
			TotalRounds = 1;
			ResetScore();
			ACTIVEGAMEMODE = false;
		else
			for k,v in pairs(player.GetAll()) do
				v:PrintMessage( HUD_PRINTTALK , "This is round #" ..TotalRounds.." out of a possible " .. NumRounds..	"!");
				v:PrintMessage( HUD_PRINTTALK  , "First to " .. KillLimit .. " wins!" );
				
				for k,v in pairs(player.GetAll()) do
					v:KillSilent();
					v:Spawn();
				end
			end
		end
	end
	
	function ScoreKeeper(victim,inflictor,killer)
	if not(ACTIVEGAMEMODE == "Super Simple Deathmatch") then return end
	
	--if(killer == victim) then return end
	
		TotalKills = TotalKills + 1;

		if(TotalKills == KillLimit) then
		
			TotalRounds = TotalRounds + 1;
			
			for k,v in pairs(player.GetAll()) do
				v:PrintMessage( HUD_PRINTTALK , DMLeaderName .." wins the round!");
			end
					
			ResetScore();
			StartRound();
		else
			
			for k,v in pairs(player.GetAll()) do
				if(killer:Nick() == v:Nick()) then
					TheScore[v:Nick()] = TheScore[v:Nick()] + 1;
				end
			end
			
			for k,v in pairs(TheScore) do	
				if(v > DMLeaderScore)then
					DMLeaderScore = v;
							
					if(DMLeaderName == k) then
						
						for _,ply in pairs(player.GetAll()) do
							ply:PrintMessage( HUD_PRINTTALK , DMLeaderName .." is in the lead with " .. DMLeaderScore .. " kill(s)!");
						end
					else	
						DMLeaderName = k;
					
						for _,pls in pairs(player.GetAll()) do
							pls:PrintMessage( HUD_PRINTTALK , DMLeaderName .." takes the lead with " .. DMLeaderScore .. " kill(s)!");
						end
					end
				end
			end
		end
	end
	hook.Add("PlayerDeath","KeepingScore",ScoreKeeper)
	
	function ResetScore()
		for k,v in pairs(TheScore) do
			TheScore[k] = 0;
		end
		DMLeaderName = "";
		DMLeaderScore = 0;
		TotalKills = 0;
	end
	
	function GiveWeps()
	if not(ACTIVEGAMEMODE == "Super Simple Deathmatch") then return end
		
		for k,v in pairs(player.GetAll())do
			v:Give("weapon_smg1");
			v:GiveAmmo(100, "smg1");
			v:Give("weapon_crowbar");
		end
	end
	hook.Add( "PlayerSpawn", "GiveSomeWeps", GiveWeps )
	
	function SSDMAdminEnd(ply,cmd,args)
		if(ply:IsAdmin() or !ply:IsValid())then
			TotalRounds = 1;
			ResetScore();
			ACTIVEGAMEMODE = false;
		end
	end
	concommand.Add("EndSSDM", SSDMAdminEnd)
end