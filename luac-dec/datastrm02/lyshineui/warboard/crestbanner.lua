local CrestBanner = {
  Properties = {
    FactionName = {
      default = EntityId()
    },
    EventResult = {
      default = EntityId()
    },
    CompanyNameLabel = {
      default = EntityId()
    },
    CompanyName = {
      default = EntityId()
    },
    EventRole = {
      default = EntityId()
    },
    CrestIcon = {
      default = EntityId()
    },
    AttackerIcon = {
      default = EntityId()
    },
    DefenderIcon = {
      default = EntityId()
    },
    InvasionIcon = {
      default = EntityId()
    },
    CrestRune = {
      default = EntityId()
    },
    CrestBanner = {
      default = EntityId()
    },
    CrestBannerMask = {
      default = EntityId()
    },
    CrestContainer = {
      default = EntityId()
    },
    BannerInfo = {
      default = EntityId()
    },
    InvasionInfo = {
      default = EntityId()
    },
    InvasionLabel = {
      default = EntityId()
    },
    InvasionLocation = {
      default = EntityId()
    },
    OutpostRushInfo = {
      default = EntityId()
    },
    TotalScore = {
      default = EntityId()
    },
    OutpostAPoints = {
      default = EntityId()
    },
    OutpostBPoints = {
      default = EntityId()
    },
    OutpostCPoints = {
      default = EntityId()
    },
    KillPoints = {
      default = EntityId()
    },
    OREventResult = {
      default = EntityId()
    },
    TeamName = {
      default = EntityId()
    }
  },
  isOutpostRush = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CrestBanner)
function CrestBanner:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.CompanyNameLabel, self.UIStyle.FONT_STYLE_WARBOARD_BANNER_COMPANYNAME_LABEL)
  SetTextStyle(self.Properties.EventResult, self.UIStyle.FONT_STYLE_WARBOARD_BANNER_EVENTRESULT)
  SetTextStyle(self.Properties.FactionName, self.UIStyle.FONT_STYLE_WARBOARD_BANNER_FACTION)
  SetTextStyle(self.Properties.CompanyName, self.UIStyle.FONT_STYLE_WARBOARD_BANNER_COMPANYNAME)
  SetTextStyle(self.Properties.EventRole, self.UIStyle.FONT_STYLE_WARBOARD_BANNER_EVENTROLE)
  SetTextStyle(self.Properties.InvasionLabel, self.UIStyle.FONT_STYLE_WARBOARD_INVASION_LABEL)
  SetTextStyle(self.Properties.InvasionLocation, self.UIStyle.FONT_STYLE_WARBOARD_INVASION_LOCATION)
end
function CrestBanner:OnShutdown()
end
function CrestBanner:SetResult(result, color)
  if self.isOutpostRush then
    UiTextBus.Event.SetTextWithFlags(self.Properties.OREventResult, result, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.OREventResult, color)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.EventResult, result, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.EventResult, color)
  end
end
function CrestBanner:SetFactionName(factionName, color)
  UiTextBus.Event.SetTextWithFlags(self.Properties.FactionName, factionName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.FactionName, color)
end
function CrestBanner:SetCompanyName(companyName)
  UiTextBus.Event.SetText(self.Properties.CompanyName, companyName)
end
function CrestBanner:SetRole(role)
  UiTextBus.Event.SetTextWithFlags(self.Properties.EventRole, role, eUiTextSet_SetLocalized)
end
function CrestBanner:UpdateIcon(crestData)
  self.CrestIcon:SetIcon(crestData)
end
function CrestBanner:SetAttackerIcon(enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.AttackerIcon, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.DefenderIcon, not enable)
end
function CrestBanner:DisableRoleIcon()
  UiElementBus.Event.SetIsEnabled(self.Properties.AttackerIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DefenderIcon, false)
end
function CrestBanner:SetRuneColor(color)
  UiImageBus.Event.SetColor(self.Properties.CrestRune, color)
end
function CrestBanner:SetBannerColor(color)
  UiImageBus.Event.SetColor(self.Properties.CrestBanner, color)
end
function CrestBanner:SetBannerVisible()
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.CrestBannerMask, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.CrestBannerMask)
end
function CrestBanner:SetupInvasionVisuals(enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.BannerInfo, not enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.OutpostRushInfo, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvasionInfo, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.CrestIcon, not enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvasionIcon, enable)
  if enable then
    self:SetBannerColor(self.UIStyle.COLOR_RED_DARK)
  end
end
function CrestBanner:SetupOutpostRushVisuals(enable, totalScore)
  if enable then
    UiTextBus.Event.SetText(self.Properties.TotalScore, totalScore)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.BannerInfo, not enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.CrestContainer, not enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.CrestRune, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvasionInfo, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.OutpostRushInfo, enable)
  self.isOutpostRush = enable
end
function CrestBanner:SetORPoints(aPoints, bPoints, cPoints, killsPoints)
  UiTextBus.Event.SetText(self.Properties.OutpostAPoints, aPoints)
  UiTextBus.Event.SetText(self.Properties.OutpostBPoints, bPoints)
  UiTextBus.Event.SetText(self.Properties.OutpostCPoints, cPoints)
  UiTextBus.Event.SetText(self.Properties.KillPoints, killsPoints)
end
function CrestBanner:SetInvasionLocationLocalized(locationName)
  UiTextBus.Event.SetTextWithFlags(self.Properties.InvasionLocation, locationName, eUiTextSet_SetAsIs)
end
function CrestBanner:SetTeamName(teamname)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TeamName, teamname, eUiTextSet_SetLocalized)
end
return CrestBanner
