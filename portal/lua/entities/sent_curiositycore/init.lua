//Precache the sounds in use.
util.PrecacheSound("Portal.Glados_core.Death")


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


// This is the spawn function. It's called when a client calls the entity to be spawned.
// If you want to make your SENT spawnable you need one of these functions to properly create the entity
//
// ply is the name of the player that is spawning it
// tr is the trace from the player's eyes 
//
function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "sent_curiositycore" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.SayTimer = CurTime()

	self.Entity:SetModel( "models/props_bts/glados_ball_reference.mdl" )
	self.Entity:SetMaterial( "models/props_bts/glados_ball_02.vtf" )
	
	local curiosity = self.Entity:LookupSequence("look_02")
	self.Entity:ResetSequence(curiosity)
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
end


/*---------------------------------------------------------
   Name: PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide( data, physobj )
//Nothing here
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
//Nothing here
end


/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use( activator, caller, Player )
//Nothing here
end

/*---------------------------------------------------------
   Name: OnRemove
---------------------------------------------------------*/
function ENT:OnRemove( )
	self.Entity:EmitSound("Portal.Glados_core.Death")
end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
ENT.Sounds = {"Portal.Glados_core.Curiosity_1", "Portal.Glados_core.Curiosity_2", "Portal.Glados_core.Curiosity_3", "Portal.Glados_core.Curiosity_4",
"Portal.Glados_core.Curiosity_5", "Portal.Glados_core.Curiosity_6", "Portal.Glados_core.Curiosity_7", "Portal.Glados_core.Curiosity_8",
"Portal.Glados_core.Curiosity_9", "Portal.Glados_core.Curiosity_10", "Portal.Glados_core.Curiosity_11", "Portal.Glados_core.Curiosity_12",
"Portal.Glados_core.Curiosity_13", "Portal.Glados_core.Curiosity_15", "Portal.Glados_core.Curiosity_16",
"Portal.Glados_core.Curiosity_17", "Portal.Glados_core.Curiosity_18"}

ENT.SoundLengths = {1.3, 0.8, 0.9, 0.9, 1.1, 2.1, 2.1, 1.6, 0.8, 1.1, 3, 1, 0.8, 1.4, 0.9, 2.5, 1.5}

for k,v in pairs(ENT.Sounds) do 
util.PrecacheSound(v)
end

local LastRandom = 0
function ENT:Think()
if self.SayTimer > CurTime() then return end
local r = math.Round(math.Rand(1,17))
if r == LastRandom then
r = math.Round(math.Rand(1,17))
end
LastRandom = r
self.Entity:EmitSound(self.Sounds[r])
self.SayTimer = self.SayTimer + self.SoundLengths[r]
end
