include('shared.lua')

local gamemodes = file.Find( "entities/egm/entgamemodes/*.lua", "LUA");
for _ , file in pairs(gamemodes) do
	//print(file)
	include("entities/egm/entgamemodes/"..file);
	//print("entities/egm/entgamemodes/"..file);
end


function DisplayVotePanel(um)
--[[
	tblcl = {}
	local indexes = um:ReadLong()
	for i=1, indexes do
		table.insert(tblcl, um:ReadString())
	end
	]]
	
	DermaPanel = vgui.Create( "DFrame" ) 
	DermaPanel:SetPos( ScrW() / 2 - 100, ScrH() / 2 - 175  )
	DermaPanel:SetSize( 600, 400)
	DermaPanel:SetTitle( "Choose Gamemode" ) 
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	
	local DListView = vgui.Create("DListView")
	DListView:SetParent(DermaPanel)
	DListView:SetPos(22.5, 50)
	DListView:SetSize(550, 300)
	DListView:SetMultiSelect(false)
	DListView:AddColumn("Gamemode Name")
	DListView:AddColumn("Gamemode Description")
	
	for _,v in pairs(EGMINFO) do
		DListView:AddLine(v.NAME, v.DESCRIPTION)
	end
		
	local DB = vgui.Create( "DButton", DermaPanel )
	DB:SetText("Vote!")
	DB:SetSize(150, 25)
	DB:SetPos(225, 360)
	DB.DoClick = function()
		for _,v in pairs(EGMINFO) do
			if(v.NAME == DListView:GetSelected()[1]:GetColumnText(1)) then
				LocalPlayer():ConCommand("AddVotes " .. v.FILENAME)
			end
		end
		DermaPanel:Close()
	end
end
usermessage.Hook("IncomingTable", DisplayVotePanel)
		
function DisplayResultPanel(um)

	local DermaPanelResult = vgui.Create( "DFrame" )
		DermaPanelResult:SetPos( ScrW() / 2 - 100, ScrH() / 2 - 300  )
		DermaPanelResult:SetSize( 250, 100) 
		DermaPanelResult:SetTitle( "Results" )
		DermaPanelResult:SetVisible( true )
		DermaPanelResult:SetDraggable( true )
		DermaPanelResult:ShowCloseButton( true )
		DermaPanelResult:MakePopup()
		
		local DP = vgui.Create( "DPanel", DermaPanelResult )
		DP:SetPos( 0, 22 )
		DP:SetSize( 250, 100 )
		DP.Paint = function()
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect( 0, 0, DP:GetWide(), DP:GetTall() )
		end

		
	local TXT = vgui.Create("DLabel", DP)
		TXT:SetText("The Winner is: " .. um:ReadString())
		TXT:SizeToContents()
		TXT:SetPos(5, 5)
end
usermessage.Hook("Results", DisplayResultPanel)