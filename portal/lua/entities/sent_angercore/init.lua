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
	
	local ent = ents.Create( "sent_angercore" )
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
	self.Entity:SetMaterial( "models/props_bts/glados_ball_03.vtf" )
	
	local anger = self.Entity:LookupSequence("look_03")
	self.Entity:ResetSequence(anger)
	
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
ENT.Sounds = {"Portal.Glados_core.Aggressive_00", "Portal.Glados_core.Aggressive_01", "Portal.Glados_core.Aggressive_02", "Portal.Glados_core.Aggressive_03",
"Portal.Glados_core.Aggressive_05", "Portal.Glados_core.Aggressive_06", "Portal.Glados_core.Aggressive_07", "Portal.Glados_core.Aggressive_08",
"Portal.Glados_core.Aggressive_09", "Portal.Glados_core.Aggressive_10", "Portal.Glados_core.Aggressive_11", "Portal.Glados_core.Aggressive_12",
"Portal.Glados_core.Aggressive_13", "Portal.Glados_core.Aggressive_14", "Portal.Glados_core.Aggressive_15", "Portal.Glados_core.Aggressive_16",
"Portal.Glados_core.Aggressive_17", "Portal.Glados_core.Aggressive_18", "Portal.Glados_core.Aggressive_19", "Portal.Glados_core.Aggressive_20",
"Portal.Glados_core.Aggressive_21"}

ENT.SoundLengths = {1.2, 1.5, 0.7, 0.6, 1, 0.9, 0.6, 1, 0.6, 0.8, 1.1, 0.8, 0.5, 1.3, 0.8, 0.7, 0.7, 0.7, 0.8, 1, 0.8}

ENT.SoundsOnFire = {"Portal.Glados_core.Aggressive_panic_01", "Portal.Glados_core.Aggressive_panic_02"}

ENT.SoundNearFireLengths = {0.4, 0.5}

for k,v in pairs(ENT.Sounds) do 
util.PrecacheSound(v)
end

for k,v in pairs(ENT.SoundsOnFire) do 
util.PrecacheSound(v)
end

local LastRandom = 0
function ENT:Think()
if self.SayTimer > CurTime() then return end
local r = math.Round(math.Rand(1,21))
if r == LastRandom then
r = math.Round(math.Rand(1,21))
end
LastRandom = r
self.Entity:EmitSound(self.Sounds[r])
self.SayTimer = self.SayTimer + self.SoundLengths[r]
if self.Entity:IsOnFire() then
local r = math.Round(math.Rand(1,2))
self.Entity:EmitSound(self.SoundsOnFire[r])
self.SayTimer = self.SayTimer + self.SoundNearFireLengths[r]
end
end
