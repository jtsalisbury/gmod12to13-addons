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
	
	local ent = ents.Create( "sent_cakemixcore" )
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
	self.Entity:SetMaterial( "models/props_bts/glados_ball_04.vtf" )
	
	local cakemix = self.Entity:LookupSequence("look_04")
	self.Entity:ResetSequence(cakemix)
	
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
ENT.Sounds = {"Portal.Glados_core.Crazy_01", "Portal.Glados_core.Crazy_02", "Portal.Glados_core.Crazy_03", "Portal.Glados_core.Crazy_04", 
"Portal.Glados_core.Crazy_05", "Portal.Glados_core.Crazy_06", "Portal.Glados_core.Crazy_07", "Portal.Glados_core.Crazy_08",
"Portal.Glados_core.Crazy_09", "Portal.Glados_core.Crazy_10", "Portal.Glados_core.Crazy_11", "Portal.Glados_core.Crazy_12",
"Portal.Glados_core.Crazy_13", "Portal.Glados_core.Crazy_14", "Portal.Glados_core.Crazy_15", "Portal.Glados_core.Crazy_16",
"Portal.Glados_core.Crazy_17", "Portal.Glados_core.Crazy_18", "Portal.Glados_core.Crazy_19", "Portal.Glados_core.Crazy_20",
"Portal.Glados_core.Crazy_21", "Portal.Glados_core.Crazy_22", "Portal.Glados_core.Crazy_23", "Portal.Glados_core.Crazy_24",
"Portal.Glados_core.Crazy_25", "Portal.Glados_core.Crazy_26", "Portal.Glados_core.Crazy_27", "Portal.Glados_core.Crazy_28",
"Portal.Glados_core.Crazy_29", "Portal.Glados_core.Crazy_30", "Portal.Glados_core.Crazy_31", "Portal.Glados_core.Crazy_32",
"Portal.Glados_core.Crazy_33", "Portal.Glados_core.Crazy_34", "Portal.Glados_core.Crazy_35", "Portal.Glados_core.Crazy_36",
"Portal.Glados_core.Crazy_37", "Portal.Glados_core.Crazy_38", "Portal.Glados_core.Crazy_39", "Portal.Glados_core.Crazy_40",
"Portal.Glados_core.Crazy_41"}

ENT.SoundLengths = {4.7, 3.6, 2.7, 4.2, 2.9, 3.5, 2, 2.5, 1.3, 1.3, 1.8, 1.4, 1.9, 2.2, 5.9, 4.6, 1.7, 1.6, 3.2, 2.3, 3.3, 1.7,
3.8, 2.1, 4.7, 2.5, 3.2, 3.3, 3.3, 3.5, 1.8, 5.2, 3.1, 3, 2.8, 2.9, 2.1, 1.9, 1.3, 7.6, 3.7}

for k,v in pairs(ENT.Sounds) do 
util.PrecacheSound(v)
end

local LastRandom = 0
function ENT:Think()
if self.SayTimer > CurTime() then return end
local r = math.Round(math.Rand(1,41))
if r == LastRandom then
r = math.Round(math.Rand(1,41))
end
LastRandom = r
self.Entity:EmitSound(self.Sounds[r])
self.SayTimer = self.SayTimer + self.SoundLengths[r]
end
