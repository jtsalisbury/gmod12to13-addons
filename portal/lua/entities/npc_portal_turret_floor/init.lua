AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.PrecacheModel( "models/props/turret_01.mdl")

function ENT:Initialize( )
	self.turret = ents.Create( "npc_turret_floor" )
	self.turret:SetModel( "models/props/turret_01.mdl" )
	self.turret:SetPos(self:GetPos())
	self.turret:SetAngles(self:GetAngles())
	self.turret:Spawn()
	self.turret:Activate()
	self:SetParent(self.turret)
end

function ENT:SpawnFunction( pl , tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal

	local turret = ents.Create( "npc_turret_floor" )
	turret:SetModel( "models/props/turret_01.mdl" )
	turret:SetPos( SpawnPos )
	turret:Spawn()
	turret:Activate()

	return turret
end

function ENT:OnRemove( )
end

function ENT:Think( )
end
