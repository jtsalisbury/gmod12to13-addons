include("player_infocard.lua")

//surface.CreateFont("coolvetica", 20, 500, true, false, "ScoreboardPlayerName")
surface.CreateFont("ScoreboardPlayerName", {
	font = "coolvetica",
	size = 20,
	weight = 500,
})

local texGradient = surface.GetTextureID("gui/center_gradient")
local texRatings = {}

texRatings[ 'none' ] 		= surface.GetTextureID("gui/silkicons/user")
texRatings[ 'smile' ] 		= surface.GetTextureID("gui/silkicons/emoticon_smile")
texRatings[ 'friendly' ] 	= surface.GetTextureID("gui/silkicons/group")
texRatings[ 'love' ] 		= surface.GetTextureID("gui/silkicons/heart")
texRatings[ 'artistic' ] 	= surface.GetTextureID("gui/silkicons/palette")
texRatings[ 'star' ] 		= surface.GetTextureID("gui/silkicons/star")
texRatings[ 'builder' ] 	= surface.GetTextureID("gui/silkicons/wrench")

surface.GetTextureID("gui/silkicons/emoticon_smile")
local PANEL = {}

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
	if not IsValid(self.Player) then return end

	local color = team.GetColor(self.Player:Team())

	if self.Armed then
		color = team.GetColor(self.Player:Team())
	end

	if self.Selected then
		color = team.GetColor(self.Player:Team())
	end

	if self.Player:Team() == TEAM_CONNECTING then
		color = Color(200, 120, 50, 255)
	elseif self.Player:IsAdmin() then
		color = team.GetColor(self.Player:Team())
	end

	if self.Open or self.Size != self.TargetSize then
		draw.RoundedBox(4, 0, 16, self:GetWide(), self:GetTall() - 16, color)
		draw.RoundedBox(4, 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2, Color(250, 250, 245, 255))

		surface.SetTexture(texGradient)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(2, 16, self:GetWide()-4, self:GetTall() - 16 - 2)
	end

	draw.RoundedBox(4, 0, 0, self:GetWide(), 24, color)

	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 50)
	surface.DrawTexturedRect(0, 0, self:GetWide(), 24)

	surface.SetTexture(self.texRating)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(4, 4, 16, 16)

	return true
end

/*---------------------------------------------------------
Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer(ply)
	if not IsValid(ply) then return end
	self.Player = ply
	self.infoCard:SetPlayer(ply)
	self:UpdatePlayerData()
end

function PANEL:CheckRating(name, count)
	if not IsValid(self.Player) then return end

	if (self.Player.DarkRPVars["Rating."..name] or 0) > count then
		count = self.Player.DarkRPVars["Rating."..name] or 0
		self.texRating = texRatings[ name ]
	end

	return count
end

/*---------------------------------------------------------
Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()
	if not IsValid(self.Player) then return end
	local Team = LocalPlayer():Team()
	self.lblName:SetText(self.Player:Name())
	self.lblName:SizeToContents()
	self.lblJob:SetText(self.Player.DarkRPVars.job or team.GetName(self.Player:Team()) or "")
	self.lblJob:SizeToContents()
	self.lblPing:SetText(self.Player:Ping())
	self.lblWarranted:SetImage("gui/silkicons/exclamation")
	if self.Player.DarkRPVars.wanted then
		self.lblWarranted:SetVisible(true)
	elseif not self.Player.DarkRPVars.wanted then
		self.lblWarranted:SetVisible(false)
	end

	-- Work out what icon to draw
	self.texRating = surface.GetTextureID("gui/silkicons/emoticon_smile")

	self.texRating = texRatings[ 'none' ]
	local count = 0

	count = self:CheckRating('smile', count)
	count = self:CheckRating('love', count)
	count = self:CheckRating('artistic', count)
	count = self:CheckRating('star', count)
	count = self:CheckRating('builder', count)
	count = self:CheckRating('friendly', count)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()
	self.Size = 24
	self:OpenInfo(false)
	self.infoCard = vgui.Create("RPScorePlayerInfoCard", self)
	self.lblName = vgui.Create("DLabel", self)
	self.lblJob = vgui.Create("DLabel", self)
	self.lblPing = vgui.Create("DLabel", self)
	self.lblWarranted = vgui.Create("DImage", self)
	self.lblWarranted:SetSize(16,16)

	-- If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled(false)
	self.lblJob:SetMouseInputEnabled(false)
	self.lblPing:SetMouseInputEnabled(false)
	self.lblWarranted:SetMouseInputEnabled(false)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	self.lblName:SetFont("ScoreboardPlayerName")
	self.lblJob:SetFont("ScoreboardPlayerName")
	self.lblPing:SetFont("ScoreboardPlayerName")

	self.lblName:SetFGColor(color_white)
	self.lblJob:SetFGColor(color_white)
	self.lblPing:SetFGColor(color_white)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:DoClick()
	if self.Open then
		surface.PlaySound("ui/buttonclickrelease.wav")
	else
		surface.PlaySound("ui/buttonclick.wav")
	end

	self:OpenInfo(not self.Open)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo(bool)
	if bool then
		self.TargetSize = 150
	else
		self.TargetSize = 24
	end

	self.Open = bool
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()
	if self.Size != self.TargetSize then
		self.Size = math.Approach(self.Size, self.TargetSize, (math.abs(self.Size - self.TargetSize) + 1) * 10 * FrameTime())
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	end

	if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
	end
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	self:SetSize(self:GetWide(), self.Size)
	self.lblName:SizeToContents()
	self.lblName:SetPos(24, 2)

	local COLUMN_SIZE = 50

	self.lblPing:SetPos(self:GetWide() - COLUMN_SIZE * 1, 0)
	self.lblJob:SetPos(self:GetWide() - COLUMN_SIZE * 7, 1)
	self.lblWarranted:SetPos(self:GetWide() - COLUMN_SIZE * 8.8, 5)

	if self.Open or self.Size != self.TargetSize then
		self.infoCard:SetVisible(true)
		self.infoCard:SetPos(4, self.lblName:GetTall() + 10)
		self.infoCard:SetSize(self:GetWide() - 8, self:GetTall() - self.lblName:GetTall() - 10)
	else
		self.infoCard:SetVisible(false)
	end
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower(row)
	if not IsValid(row.Player) or not IsValid(self.Player) then return false end

	if self.Player:Team() == TEAM_CONNECTING then return false end
	if row.Player:Team() == TEAM_CONNECTING then return true end

	if team.GetName(self.Player:Team()) == team.GetName(row.Player:Team()) then
		return team.GetName(self.Player:Team()) < team.GetName(row.Player:Team())
	end

	return team.GetName(self.Player:Team()) < team.GetName(row.Player:Team())
end

vgui.Register("RPScorePlayerRow", PANEL, "Button")
