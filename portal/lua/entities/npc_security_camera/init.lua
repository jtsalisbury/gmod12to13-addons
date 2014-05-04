AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.PrecacheModel( "models/props/security_camera.mdl")

ENT.Pitch = 0

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetModel("models/props/security_camera.mdl")
	
	local phys = self:GetPhysicsObject()
	
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end
end

function ENT:SpawnFunction( pl , tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal

	local turret = ents.Create( "npc_security_camera" )
	turret:SetPos(SpawnPos)
	turret:Spawn()
	turret:Activate()

	return turret
end

function ENT:OnRemove( )
end

function ENT:GetClosestPlayer()
	local Target
	for k, v in pairs(player:GetAll()) do
		if (v:IsPlayer() and v:Alive()) then
			if !Target then
				Target = v
			else
				if v:GetPos():Distance(self:GetPos()) < Target:GetPos():Distance(self:GetPos()) then
					Target = v
				end
			end
		end
	end
	return Target
end

function ENT:Think()

	local ply = self:GetClosestPlayer()
	
	self:SetPlaybackRate( 0.5 )
	
	if ply and ply:IsValid() then
		
		local goodpos = self:WorldToLocal( ply:GetPos() ):Angle()
		
		goodpos.p = 340 -goodpos.p
		if goodpos.p < 0 then
			goodpos.p = 340 + goodpos.p
		end
		
		goodpos.p = goodpos.p + 120
		if goodpos.p > 170 then
			goodpos.p = (340 -goodpos.p) *-1
		end
		
		if goodpos.y < 0 then
			goodpos.y = 360 + goodpos.y
		end
		
		if goodpos.y > 180 then
			goodpos.y = goodpos.y - 360
		end
		
		--print(self.Pitch,goodpos.y)
		
		self:SetPoseParameter( "aim_pitch", goodpos.p )
		self:SetPoseParameter( "aim_yaw", goodpos.y )
		
	end

end
