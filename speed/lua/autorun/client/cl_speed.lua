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

surface.CreateFont("speedBtn", {font = "coolvetica", size = 30, weight = 500})
surface.CreateFont("speedBtnSmall", {font = "coolvetica", size = 20, weight = 500})

local function OpenGui()
	local walks = LocalPlayer():GetWalkSpeed();
	local runs = LocalPlayer():GetRunSpeed();

	local f = vgui.Create("DFrame");
	f:SetPos(0, 0);
	f:SetSize(200, 300);
	f:SetVisible(true);
	f:Center();
	f:ShowCloseButton(false);
	f:SetTitle(" ");
	f:MakePopup();
	f.Paint = function()
		draw.RoundedBox(0, 0, 0, f:GetWide(), f:GetTall(), colors.back);
		draw.RoundedBox(0, 0, 0, f:GetWide(), 50, colors.head);
		draw.SimpleText("Adjust Speed", "speedBtn", f:GetWide() / 2, 10, colors.text, TEXT_ALIGN_CENTER);
	
		draw.SimpleText("Walk Speed( Def: 200 ):", "speedBtnSmall", 10, 60, colors.text_blue, TEXT_ALIGN_LEFT);

		draw.SimpleText("Run Speed( Def: 400 ):", "speedBtnSmall", 10, 120, colors.text_blue, TEXT_ALIGN_LEFT);
	end

	local walk = vgui.Create("DTextEntry", f);
	walk:SetPos(10, 80);
	walk:SetSize(f:GetWide() - 20, 30);
	walk:SetText(LocalPlayer():GetWalkSpeed());
	walk.OnTextChanged = function()
		walks = walk:GetValue();
	end

	local run = vgui.Create("DTextEntry", f);
	run:SetPos(10, 140);
	run:SetSize(f:GetWide() - 20, 30);
	run:SetText(LocalPlayer():GetRunSpeed());
	run.OnTextChanged = function()
		walks = run:GetValue();
	end

	local togg = vgui.Create("DButton", f);
	togg:SetText("");
	togg:SetSize(f:GetWide() - 20, 50);
	togg:SetPos(10, f:GetTall() - 120);
	togg.DoClick = function()
		net.Start("Speed_Adjust");
			net.WriteString(walks);
			net.WriteString(runs);
		net.SendToServer();
		f:Close();
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
		draw.SimpleText("Adjust", "speedBtn", togg:GetWide() / 2, 10, colors.text, TEXT_ALIGN_CENTER);
	end

	f.Think = function()
		if (string.len(walks) < 1 or string.len(runs) < 1) then togg:SetDisabled(true); 
		else togg:SetDisabled(false); end
	end

	local close = vgui.Create("DButton", f);
	close:SetText("");
	close:SetSize(f:GetWide() - 20, 50);
	close:SetPos(10, f:GetTall() - 60);
	close.DoClick = function()
		f:Close();
	end
	local ca = false; 
	function close:OnCursorEntered() ca = true; end
	function close:OnCursorExited() ca = false; end
	close.Paint = function()
		if (ca) then
			draw.RoundedBox(0, 0, 0, close:GetWide(), close:GetTall(), colors.cancel_hover);
		else
			draw.RoundedBox(0, 0, 0, close:GetWide(), close:GetTall(), colors.cancel);
		end
		draw.SimpleText("Cancel", "speedBtn", close:GetWide() / 2, 10, colors.text, TEXT_ALIGN_CENTER);
	end
end

hook.Add("OnPlayerChat", "OpenSpeedGUI", function(ply, text)
	if (text == "!speed" or text == "!sa") then
		OpenGui();
	end
end)