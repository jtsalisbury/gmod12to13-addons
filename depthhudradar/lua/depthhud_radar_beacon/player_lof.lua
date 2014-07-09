BEACON.Name = "Player LOF"
BEACON.DefaultOff  = true

BEACON.angle = nil
BEACON.dist  = nil
BEACON.isup  = nil

BEACON.spriteScale = 16
BEACON.spriteColor = Color(255,255,255,192)
BEACON.spriteColorTm = nil
BEACON.sprite      = dhradar_GetTexture("measureline")
BEACON.spriteAngle = nil

BEACON.name = ""

function BEACON:FindFunction( entities , myTrashTable )
	for k,ent in pairs(entities) do
		if ent:IsPlayer() and ent != LocalPlayer() then
			table.insert(myTrashTable,ent)
		end
	end
	return myTrashTable
end

function BEACON:DrawFunction( ent )
	self.angle, self.dist, self.isup = dhradar_CalcGetPolar( ent:GetPos() )
	
	if self.dist >= 1 then return end
	
	self.spriteAngle = ent:GetAngles().y - dhradar_Angles().y + 90
	
	self.theoScale = 16
	self.spriteScale = self.theoScale * (1.0 - self.dist * (1-(1-((math.cos( math.rad( self.angle + ent:GetAngles().y) )+1)*0.5))^5))
	
	self.spriteColorTm = team.GetColor(ent:Team())
	self.spriteColorTm.a = 64
	
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColorTm or self.spriteColor, self.spriteScale, self.spriteAngle, true, 0)
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColor, self.spriteScale, self.spriteAngle, true, 0)
	
	return true
end
