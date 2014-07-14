util.AddNetworkString("Speed_Adjust");

net.Receive("Speed_Adjust", function(len, client)
	local walk = net.ReadString();
	local run  = net.ReadString();

	local walk = tonumber(walk);
	local run  = tonumber(run);

	client:SetWalkSpeed(walk);
	client:SetRunSpeed(run);
end)