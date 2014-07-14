hook.Add("HUDPaint", "DrawVoiceToggle", function()
	local status = LocalPlayer():GetNWInt("GroupChatActivated", 0);
	if (status == 1) then status = "Voice Team Chat Status: On"; else status = " "; end

	draw.SimpleText(status, "Default", ScrW() - 100, ScrH() - 100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER);
end)