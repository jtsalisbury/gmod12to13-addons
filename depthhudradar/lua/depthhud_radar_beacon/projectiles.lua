BEACON.Name = "Projectiles"


BEACON.angle = nil
BEACON.dist  = nil
BEACON.isup  = nil

BEACON.spriteScale = 1
BEACON.spriteScaleCalc = 0
BEACON.spriteColor = nil
BEACON.sprite      = nil
BEACON.spriteAngle = nil
BEACON.spriteColorShadow = Color(0,0,0,128)
BEACON.drawShadow = false

BEACON.projectiles = {}
BEACON.projectiles.npc_grenade_frag = {
	function(ent) return dhradar_GetTexture("circle") end,
	Color(255,0,0,128),
	function(ent)
		local phase = (ent:EntIndex() % 0.3) * 0.7 + ent:EntIndex() * 0.2
		return BEACON.spriteScale * (1 + ((RealTime())*3+phase) % 1)
	end,
	true
}
BEACON.projectiles.crossbow_bolt = {
	function(ent) return dhradar_GetTexture("arrow") end,
	Color(255,220,0),
	function(ent)
		return BEACON.spriteScale
	end,
	true
}
BEACON.projectiles.hunter_flechette = {
	function(ent)
		if ent:GetVelocity():Length() < 16 then
			return dhradar_GetTexture("triangle")
		end
		return dhradar_GetTexture("arrow")
	end,
	Color(0,255,154),
	function(ent)
		if ent:GetVelocity():Length() < 16 then
			local phase = (ent:EntIndex() % 0.3) * 0.7 + ent:EntIndex() * 0.2
			return BEACON.spriteScale * (1 + (RealTime()*3+phase) % 1) * 0.7
		end
		return BEACON.spriteScale
	end,
	true
}
BEACON.projectiles.rpg_missile = {
	function(ent) return dhradar_GetTexture("arrow") end,
	Color(255,128,0),
	function(ent)
		local phase = (ent:EntIndex() % 0.3) * 0.7 + ent:EntIndex() * 0.2
		return BEACON.spriteScale * (1 + (RealTime()*3 + phase) % 1)
	end,
	true
}
BEACON.projectiles.prop_combine_ball = {
	function(ent) return dhradar_GetTexture("circle") end,
	Color(255,255,0,128),
	function(ent)
		local phase = (ent:EntIndex() % 0.3) * 0.7 + ent:EntIndex() * 0.2
		return BEACON.spriteScale * (1 + math.cos(math.rad((RealTime()*2+phase)*360))*0.3 + 0.3)
	end,
	false
}

function BEACON:FindFunction( entities , myTrashTable )
	for k,ent in pairs(entities) do
		if self.projectiles[ent:GetClass()] then
			table.insert(myTrashTable,ent)
		end
	end
	return myTrashTable
end

function BEACON:DrawFunction( ent )

	self.angle, self.dist, self.isup = dhradar_CalcGetPolar( ent:GetPos() )
	self.spriteAngle = ent:GetVelocity():Angle().y - dhradar_Angles().y /* + 90*/
	
	self.sprite =  self.projectiles[ent:GetClass()][1]( ent )
	self.spriteColor =  self.projectiles[ent:GetClass()][2]
	self.spriteScaleCalc = self.projectiles[ent:GetClass()][3]( ent )
	self.drawShadow = self.projectiles[ent:GetClass()][4]
	
	if self.drawShadow then
		self.spriteColorShadow.a = spriteColor.a*0.25
		dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColorShadow , 1.30*self.spriteScaleCalc, self.spriteAngle, true, 0.7)
	end
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColor       , 1.00*self.spriteScaleCalc, self.spriteAngle, true, 0.7)
	
	return true
end
