driveby = {};

driveby.AllowedUserGroups = {
	//use * for all. EX: "*",
	"superadmin",
	"admin",
	"donator",
	"vip"
}

local Player = FindMetaTable("Player");
function Player:CanDriveBy()
	for k,v in pairs(driveby.AllowedUserGroups) do
		if (v == "*") then return true; end
		if (self:IsUserGroup(v)) then return true; end
	end
	return false;
end