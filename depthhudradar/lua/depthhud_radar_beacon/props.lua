BEACON.Name = "Props"

BEACON.spriteScale = nil
BEACON.spriteColor = Color(255,255,0,64)
BEACON.isup        = nil
BEACON.sprite      = dhradar_GetTexture("square")
BEACON.spriteAngle = nil

BEACON.theoScale = nil

function BEACON:FindFunction( entities , myTrashTable )
	for k,ent in pairs(entities) do
		if string.find(ent:GetClass(),"prop_") and not string.find(ent:GetClass(),"vehicle") and not string.find(ent:GetClass(),"dynamic") then
			table.insert(myTrashTable,ent)
		end
	end
	return myTrashTable
end

function BEACON:DrawFunction( ent )
	self.angle, self.dist, self.isup = dhradar_CalcGetPolar( ent:GetPos() )
	//if (isup != 0) then return false end
	self.theoScale = math.Clamp(ent:BoundingRadius()/64,0.3,8)
	self.spriteScale = math.Clamp(self.theoScale * 10/math.Clamp(dhradar_GetStyleData("ui_scale") or 10,1,40),0.3,16)
	self.spriteColor.a = 64 + 191*(1 - self.theoScale/8)
	self.spriteAngle = ent:GetAngles().y - dhradar_Angles().y + 90
	
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColor, self.spriteScale, self.spriteAngle, true, 0.2)
	
	return true
end
