local GuildWarListItem = {
  Properties = {
    CrestIcon = {
      default = EntityId()
    },
    GuildNameText = {
      default = EntityId()
    },
    PhaseList = {
      default = {
        EntityId()
      }
    },
    FactionName = {
      default = EntityId()
    },
    TerritoryName = {
      default = EntityId()
    },
    TerritoryNameInvasion = {
      default = EntityId()
    },
    LocationName = {
      default = EntityId()
    },
    WarDateText = {
      default = EntityId()
    },
    WarTimeText = {
      default = EntityId()
    },
    WarTimeLabel = {
      default = EntityId()
    },
    ManageButton = {
      default = EntityId()
    },
    TimeZoneText = {
      default = EntityId()
    },
    InvasionContainer = {
      default = EntityId()
    },
    WarContainer = {
      default = EntityId()
    },
    ResolutionText = {
      default = EntityId()
    },
    HowDoesWarWorkContainer = {
      default = EntityId()
    },
    HowDoesWarWork = {
      default = EntityId()
    }
  },
  guildData = nil,
  warId = nil,
  lastWarTimeRemainingSeconds = -1,
  lastConquestTimeRemainingSeconds = -1,
  warDuration = -1,
  conquestDuration = -1,
  resolutionDuration = -1,
  lastActivePhase = -1,
  warCalendar = nil,
  HAS_PERMISSION_POS_Y = -34,
  NO_PERMISSION_POS_Y = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(GuildWarListItem)
local warDeclarationPopupHelper = RequireScript("LyShineUI.WarDeclaration.WarDeclarationPopupHelper")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function GuildWarListItem:OnInit()
  BaseElement.OnInit(self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Social.DataSynced", function(self, synced)
    if synced then
      self.preWarDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_PreWar):ToSeconds()
      self.warDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_War):ToSeconds()
      self.conquestDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Conquest):ToSeconds()
      self.resolutionDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Resolution):ToSeconds()
    end
  end)
  local coinIconPath = "LyShineUI\\Images\\Icon_Crown"
  local coinIconXPadding = 5
  self.coinImgText = string.format("<img src=\"%s\" xPadding=\"%d\" yOffset=\"3\"></img>", coinIconPath, coinIconXPadding)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", function(self, warId)
    if warId and self.guildData and warId == self.warId then
      self:UpdatePhases(false)
    end
  end)
end
function GuildWarListItem:SetData(guildData)
  self.guildData = guildData
  self.warId = guildData.warId
  self.lastActivePhase = -1
  self.territoryId = guildData.territoryId
  self.isInvasion = guildData.isInvasion
  if self.isInvasion then
    UiElementBus.Event.SetIsEnabled(self.Properties.InvasionContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.WarContainer, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWork, "@ui_how_does_invasion_work", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.WarTimeLabel, "@ui_siege_signup_invasiontime", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ResolutionText, "@ui_fortressinfo_resolvinginvasion", eUiTextSet_SetLocalized)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.InvasionContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.WarContainer, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWork, "@ui_how_does_war_work", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.WarTimeLabel, "@ui_wartime", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ResolutionText, "@ui_fortressinfo_resolveingwarlabel", eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ManageButton, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.HowDoesWarWorkContainer, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ResolutionText, false)
  local factionData = guildData.faction
  local factionName = FactionCommon.factionInfoTable[factionData].factionName
  local factionBgColor = self.UIStyle["COLOR_FACTION_BG_" .. tostring(factionData)]
  UiTextBus.Event.SetColor(self.Properties.FactionName, factionBgColor)
  UiTextBus.Event.SetTextWithFlags(self.Properties.FactionName, factionName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryName, guildData.territoryName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryNameInvasion, guildData.territoryName, eUiTextSet_SetLocalized)
  local locationText = GetLocalizedReplacementText("@ui_siege_signup_fortressname", {
    territoryName = guildData.territoryName
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.LocationName, locationText, eUiTextSet_SetAsIs)
  local warDateText = timeHelpers:GetLocalizedAbbrevDate(guildData.siegeStartTime)
  UiTextBus.Event.SetTextWithFlags(self.Properties.WarDateText, warDateText, eUiTextSet_SetAsIs)
  local warTimeText = dominionCommon:GetSiegeWindowText(guildData.siegeWindow, true, false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.WarTimeText, warTimeText, eUiTextSet_SetAsIs)
  local timeZoneText = timeHelpers:GetLocalTimeZoneName()
  UiTextBus.Event.SetTextWithFlags(self.Properties.TimeZoneText, timeZoneText, eUiTextSet_SetAsIs)
  self.CrestIcon:SetIcon(guildData.crestData)
  UiTextBus.Event.SetText(self.Properties.GuildNameText, guildData.guildName)
  local hasPermission = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_WarRaid_Manage)
  self.ManageButton:SetButtonStyle(self.ManageButton.BUTTON_STYLE_CTA)
  self.ManageButton:SetCallback(self.OnManageButtonClick, self)
  self.ManageButton:SetEnabled(hasPermission)
  self.ManageButton:SetText("@ui_manage_army")
  self.ManageButton:SetTooltip(hasPermission and "" or "@ui_siege_set_roster_failed_not_permitted")
  self:UpdatePhases(false)
end
function GuildWarListItem:UpdatePhases(timeOnly)
  if self.guildData ~= nil and self.warId ~= nil then
    local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(self.warId)
    if not warDetails:IsWarActive() then
      return
    end
    local isAttacker = not warDetails:IsAttackingGuild(self.guildData.guildId)
    local currentActivePhase = warDetails:GetWarPhase()
    if self.lastActivePhase ~= currentActivePhase then
      if not timeOnly then
        self.warCalendar = warDetails:GetRemainingWarSchedule()
      end
      if currentActivePhase == eWarPhase_Resolution then
        UiElementBus.Event.SetIsEnabled(self.Properties.ManageButton, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.HowDoesWarWorkContainer, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.ResolutionText, true)
      end
    end
    for i = 0, #self.PhaseList do
      if i + 1 > #self.warCalendar then
        UiElementBus.Event.SetIsEnabled(self.PhaseList[i].entityId, false)
      else
        local warPhase = self.warCalendar[i + 1]:GetWarPhase()
        local phaseEndTime = self.warCalendar[i + 1]:GetPhaseEndTime()
        local phaseDuration = self.warCalendar[i + 1]:GetPhaseDuration()
        local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
        local phaseTimeRemaining = phaseEndTime:SubtractSeconds(now):ToSeconds()
        local nowSeconds = timeHelpers:ServerSecondsSinceEpoch()
        if self.lastActivePhase ~= warPhase then
          self.lastActivePhase = warPhase
          timeOnly = false
        end
        if not timeOnly then
          local localEndTime = nowSeconds + phaseTimeRemaining
          if warPhase == eWarPhase_Conquest then
            self.resolutionStartTime = phaseEndTime
          end
          self.PhaseList[i]:SetPhase(warPhase, isAttacker, false)
          self.PhaseList[i]:SetEndTime(localEndTime)
          UiElementBus.Event.SetIsEnabled(self.PhaseList[i].entityId, true)
          self.PhaseList[i]:SetIsActivePhase(i == 0)
        end
        if self.PhaseList[i].isActivePhase then
          local phaseProgress = 1
          phaseProgress = Math.Clamp(1 - phaseTimeRemaining / phaseDuration:ToSeconds(), 0, 1)
          self.PhaseList[i]:SetTimeFill(phaseProgress)
          self.PhaseList[i]:UpdateTimeRemaining()
        end
      end
    end
  else
    for i = 0, #self.PhaseList do
      UiElementBus.Event.SetIsEnabled(self.PhaseList[i].entityId, false)
    end
  end
end
function GuildWarListItem:OnShutdown()
  self.socialDataHandler:OnDeactivate()
end
function GuildWarListItem:OnSetConquestWindow()
  warDeclarationPopupHelper:ShowWarDeclarationPopup(self.guildData.guildId, self.guildData.guildName, self.guildData.crestData, 0)
end
function GuildWarListItem:OnManageButtonClick()
  LyShineManagerBus.Broadcast.SetState(1319313135)
  RaidSetupRequestBus.Broadcast.RequestRemoteInteract(self.territoryId)
  DynamicBus.Raid.Broadcast.SetIsRemoteInteract(true)
end
function GuildWarListItem:OnShowWarTutorial()
  local gameMode = self.isInvasion and GameModeCommon.GAMEMODE_INVASION or GameModeCommon.GAMEMODE_WAR
  DynamicBus.WarTutorialPopup.Broadcast.ShowWarTutorialPopup(gameMode)
end
return GuildWarListItem
