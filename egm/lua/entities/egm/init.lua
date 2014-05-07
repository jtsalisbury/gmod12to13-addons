-- Simple Gamemode ENT

-- DO NOT EDIT BELOW---------------------------------------------
GamemodeTable = {};
ACTIVEGAMEMODE = false;

include('shared.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

local gamemodes = file.Find( "entities/egm/entgamemodes/*.lua", "LUA");
for _ , file in pairs(gamemodes) do
	AddCSLuaFile("entities/egm/entgamemodes/"..file);
	include("entities/egm/entgamemodes/"..file);
	print("entities/egm/entgamemodes/"..file);
	GamemodeTable[file] = 0;
end
//PrintTable(EGMINFO);
-------------------------------------------------------------------
--Global Vars For Admins, edit only after the '=' character:

VoteTime = 20 --default 10 seconds
TheModel = "models/props_lab/monitor02.mdl" -- model of the entity, don't forget the quotes!
PlayerCanSpawn = false -- Can a normal client spawn it? true/false only

--DO NOT EDIT BELOW------------------------------------------------

function ENT:Initialize()
		
	self.Entity:SetModel( TheModel );
	self.Entity:PhysicsInit( SOLID_VPHYSICS );
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	self.Entity:SetUseType(SIMPLE_USE);
		
end

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
    local ent = ents.Create("EGM");
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 );
    ent:Spawn();
    ent:Activate();
 
    return ent;
end

function ENT:Use()
	if (ACTIVEGAMEMODE) then return end
	StartGUI();
end


function addvotes(ply,cmd,args)
	local NumVotes = 0;
	for k,v in pairs(GamemodeTable) do
		if (k == args[1]) then
			GamemodeTable[k] = GamemodeTable[k] + 1;
		end
	end
	NumVotes = NumVotes + 1;
	if (NumVotes == #player.GetAll()) then
		GetResults();
	end
end
concommand.Add( "AddVotes", addvotes )
	
function GetResults()
	timer.Destroy("TimeOut");
	CurrentLeaderName = "";
	CurrentLeaderScore = 0;

	for k,v in pairs(GamemodeTable) do
		if(v > CurrentLeaderScore)then
			CurrentLeaderScore = v;
			CurrentLeaderName = k;
		end
	end
	
	if (CurrentLeaderScore > 0) then
	
		local rp = RecipientFilter();
		rp:AddAllPlayers();
	
		umsg.Start("Results", rp);
			umsg.String(CurrentLeaderName);
		umsg.End();
		
		ResetVotes();
		
		StartGameMode(CurrentLeaderName);
	
	else
	
		local rp = RecipientFilter();
		rp:AddAllPlayers();
	
		umsg.Start("Results", rp);
			umsg.String("None, no one voted :(");
		umsg.End();
		
		ResetVotes();
	
	end
		
end

function ResetVotes()
	for k,v in pairs(GamemodeTable) do
		GamemodeTable[k] = 0;
	end
end

function StartGameMode(Gamemode)
	for _,v in pairs(EGMINFO) do
		if(v.FILENAME == Gamemode) then
			ACTIVEGAMEMODE = v.NAME;
			v.LAUNCH()
		end
	end
end

function StartGUI()
--[[
	tbl = {}
	for k,v in pairs (EGMINFO) do
		table.insert(tbl, v.NAME)
	end
]]
    local rp = RecipientFilter()
    rp:AddAllPlayers()          
 
    umsg.Start("IncomingTable", rp)
       --[[ 
		umsg.Long( #tbl )
        for i=1, #tbl do
            umsg.String( tbl[i] )
        end
		]]
    umsg.End()
	
	timer.Create("TimeOut", VoteTime, 1, GetResults)
end