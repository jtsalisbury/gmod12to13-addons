util.AddNetworkString("Driveby_Toggle");
util.AddNetworkString("DriveBy_OpenMenu");
util.AddNetworkString("DriveBy_CloseMenu");

net.Receive("Driveby_Toggle", function(len, client)
	local curState = client.DriveByState or false;
	local newState = !curState;

	client:SetAllowWeaponsInVehicle(newState);

	client.DriveByState = newState;
	client:SetNWBool("DriveByState", newState);
end)

hook.Add("PlayerEnteredVehicle", "OpenDriveByMenu", function(ply, vehicle)
	net.Start("DriveBy_OpenMenu");
	net.Send(ply);
end)

hook.Add("PlayerLeaveVehicle", "CloseDriveByMenu", function(ply, vehicle)
	net.Start("DriveBy_CloseMenu");
	net.Send(ply);
end)