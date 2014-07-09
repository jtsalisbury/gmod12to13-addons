BEACON.Name = "Farseer Own Cone"

BEACON.angle = nil
BEACON.dist  = nil
BEACON.isup  = nil

BEACON.spriteScale = 8
BEACON.spriteColor = Color(255,255,255,64)
BEACON.spriteColorTm = nil
BEACON.sprite      = dhradar_GetTexture("circle")
BEACON.spriteCone  = dhradar_GetTexture("cone")
BEACON.spriteAngle = nil

BEACON.name = ""

function BEACON:FindFunction( entities , myTrashTable )
	myTrashTable = { LocalPlayer() }
	return myTrashTable
end

function BEACON:DrawFunction( ent )
	self.angle, self.dist, self.isup = dhradar_CalcGetPolar( ent:GetPos() )
	
	if self.dist == 0 then return end
	
	self.spriteAngle = ent:GetAngles().y - dhradar_Angles().y + 90
	
	self.theoScale = 16
	self.spriteScale = ent:Alive() and (self.theoScale * self.dist - self.dist^10 * self.theoScale * 0.7) or 2
	
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColorTm or self.spriteColor, self.spriteScale, self.spriteAngle, false, 1)
	if ent:Alive() then dhradar_DrawPin(self.spriteCone, self.angle, self.dist, self.spriteColorTm or self.spriteColor, self.spriteScale*1.5, self.spriteAngle, true, 0, 20) end
	
	return true
end
