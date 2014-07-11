local colors = {
	head = Color(192, 57, 43, 255),
	back = Color(236, 240, 241, 255),
	text = Color(255, 255, 255, 255),
	text_blue = Color(52, 152, 219, 255),
	btn = Color(52, 73, 94, 255),
	btn_hover = Color(44, 62, 80, 255),
	btn_disabled = Color(52, 73, 94, 150),
	open = Color(46, 204, 113, 255),
	open_hover = Color(39, 174, 96, 255),
	open_disabled = Color(46, 2014, 113, 150),
	cancel = Color(231, 76, 60, 255),
	cancel_hover = Color(192, 57, 43, 255),
	bar = Color(189, 195, 199, 255),
	barup = Color(127, 140, 141, 255),
	closed = Color(230, 126, 34, 255),
	closed_hover = Color(211, 84, 0, 255),
	info_back = Color(189, 195, 199, 255),
}

surface.CreateFont("drivebyBtm", {font = "coolvetica", size = 30, weight = 500})
surface.CreateFont("drivebyBtmSmall", {font = "coolvetica", size = 15, weight = 500})


local panel = nil;
net.Receive("DriveBy_OpenMenu", function()
	local f = vgui.Create("DFrame");
	f:SetPos(ScrW() - 200, 0);
	f:SetSize(200, 200);
	f:SetVisible(true);
	f:ShowCloseButton(false);
	f:SetTitle(" ");
	f.Paint = function()
		draw.RoundedBox(0, 0, 0, f:GetWide(), f:GetTall(), colors.back);
		draw.RoundedBox(0, 0, 0, f:GetWide(), 50, colors.head);
		draw.SimpleText("Drive By", "drivebyBtm", f:GetWide() / 2, 10, colors.text, TEXT_ALIGN_CENTER)
	end
	panel = f;

	local togg = vgui.Create("DButton", f);
	togg:SetText("");
	togg:SetSize(150, 100);
	togg:SetPos(25, 75);
	if (!LocalPlayer():CanDriveBy()) then togg:SetDisabled(true); end
	togg.DoClick = function()
		net.Start("Driveby_Toggle");
		net.SendToServer();
	end
	local ba = false; 
	function togg:OnCursorEntered() ba = true; end
	function togg:OnCursorExited() ba = false; end
	togg.Paint = function()
		if (togg:GetDisabled()) then
			draw.RoundedBox(0, 0, 0, togg:GetWide(), togg:GetTall(), colors.open_disabled);
		else
			if (ba) then
				draw.RoundedBox(0, 0, 0, togg:GetWide(), togg:GetTall(), colors.open_hover);
			else
				draw.RoundedBox(0, 0, 0, togg:GetWide(), togg:GetTall(), colors.open);
			end
		end

		local txt = "On";
		if (LocalPlayer():GetNWBool("DriveByState", false)) then
			txt = "Off";
		end
		draw.SimpleText("Toggle "..txt, "drivebyBtm", togg:GetWide() / 2, 35, colors.text, TEXT_ALIGN_CENTER);
	end

end)

net.Receive("DriveBy_CloseMenu", function()
	if (panel) then panel:Close(); end
end)