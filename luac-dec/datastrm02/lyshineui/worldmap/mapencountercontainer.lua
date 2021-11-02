local MapEncounterContainer = {
  Properties = {
    AdjustmentContainer = {
      default = EntityId()
    },
    LabelText = {
      default = EntityId()
    },
    StatusText = {
      default = EntityId()
    },
    ViewStatusButton = {
      default = EntityId()
    },
    SignupDesc = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    }
  },
  BATTLE_TYPE_NONE = 0,
  BATTLE_TYPE_WAR = 1,
  BATTLE_TYPE_INVASION = 2,
  STATE_SIGNUP = 0,
  STATE_STANDBY = 1,
  STATE_SELECTED = 2
}
BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MapEncounterContainer)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
function MapEncounterContainer:OnInit()
  BaseElement.OnInit(self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.battleType = self.BATTLE_TYPE_NONE
  self.initialLabelPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.LabelText)
  self.initialAdjustmentContainerPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.AdjustmentContainer)
  self.ViewStatusButton:SetCallback(self.OnViewStatusButtonClick, self)
  self.ViewStatusButton:SetTextStyle(self.UIStyle.FONT_STYLE_MAP_ENCOUNTER_BUTTON)
  self.ButtonClose:SetCallback(self.OnEncounterContainerClose, self)
end
function MapEncounterContainer:OnShutdown()
  self.socialDataHandler:OnDeactivate()
end
function MapEncounterContainer:SetEncounterData(settlementId, ownerData)
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 1})
  self.settlementId = settlementId
  if self.raidSetupHandler then
    self:BusDisconnect(self.raidSetupHandler)
    self.raidSetupHandler = nil
  end
  if self.settlementId ~= nil and ownerData then
    self.guildId = ownerData.guildId
    local signupStatus = RaidSetupRequestBus.Broadcast.GetSignupStatus(self.settlementId)
    self:UpdateEncounterData(signupStatus)
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", function(self, warId)
      if not warId then
        return
      end
      local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
      if warDetails and warDetails:GetTerritoryId() == self.settlementId then
        local signupStatus = RaidSetupRequestBus.Broadcast.GetSignupStatus(self.settlementId)
        self:UpdateEncounterData(signupStatus)
      end
    end)
  end
end
function MapEncounterContainer:OnSignupStatusChanged(territoryId, signupStatus)
  if territoryId == self.settlementId then
    self:UpdateEncounterData(signupStatus)
  end
end
function MapEncounterContainer:UpdateEncounterData(signupStatus)
  if not self.settlementId then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    return
  end
  local guildIdValid = self.guildId and self.guildId:IsValid()
  local validWarDetails
  if self.settlementId ~= 0 then
    local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.settlementId)
    if warDetails and warDetails:IsValid() and warDetails:IsWarActive() and warDetails:GetWarPhase() ~= eWarPhase_Resolution then
      validWarDetails = warDetails
    end
  end
  if validWarDetails then
    if validWarDetails:IsInvasion() then
      self.battleType = self.BATTLE_TYPE_INVASION
    else
      self.battleType = self.BATTLE_TYPE_WAR
    end
  else
    self.battleType = self.BATTLE_TYPE_NONE
  end
  local isAtWarOrInInvasion = self.battleType == self.BATTLE_TYPE_INVASION or self.battleType == self.BATTLE_TYPE_WAR
  if guildIdValid and isAtWarOrInInvasion then
    if not self.raidSetupHandler then
      self.raidSetupHandler = self:BusConnect(RaidSetupNotificationBus)
    end
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.status = self.STATE_SIGNUP
    local playerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
    local rank = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Rank")
    local isPartOfWarringGuilds = playerGuildId == validWarDetails:GetAttackerGuildId() or playerGuildId == validWarDetails:GetDefenderGuildId()
    local canManage = isPartOfWarringGuilds and GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_WarRaid_Manage)
    if signupStatus ~= nil then
      self.status = signupStatus.selected and self.STATE_SELECTED or signupStatus.side ~= eRaidSide_None and self.STATE_STANDBY or self.STATE_SIGNUP
      canManage = canManage or signupStatus.permission == eRaidPermission_Leader or signupStatus.permission == eRaidPermission_Assistant
    end
    local isSignUp = self.status == self.STATE_SIGNUP
    local manageOffsetY = 0
    if isSignUp then
      UiElementBus.Event.SetIsEnabled(self.Properties.SignupDesc, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.StatusText, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.Divider, true)
      if canManage then
        UiElementBus.Event.SetIsEnabled(self.Properties.ViewStatusButton, true)
        manageOffsetY = 34
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.ViewStatusButton, false)
        manageOffsetY = 0
      end
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.ViewStatusButton, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.SignupDesc, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.StatusText, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.Divider, false)
      local statusText = self.status == self.STATE_STANDBY and "@ui_encounter_statusstandby" or "@ui_encounter_statusselected"
      UiTextBus.Event.SetTextWithFlags(self.Properties.StatusText, statusText, eUiTextSet_SetLocalized)
    end
    UiTransformBus.Event.SetLocalPositionY(self.Properties.AdjustmentContainer, self.initialAdjustmentContainerPosY - manageOffsetY)
    local showStatusText = not isSignUp
    local labelOffsetY = showStatusText and 4 or 0
    UiTransformBus.Event.SetLocalPositionY(self.Properties.LabelText, self.initialLabelPosY - labelOffsetY)
    local height = 144 + labelOffsetY + manageOffsetY
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
    local isWarOngoing = false
    local labelText, descText
    local warPhase = validWarDetails:GetWarPhase()
    if warPhase == eWarPhase_PreWar or warPhase == eWarPhase_War then
      labelText = self.battleType == self.BATTLE_TYPE_WAR and "@ui_encounter_upcomingwar" or "@ui_encounter_upcominginvasion"
    elseif warPhase == eWarPhase_Conquest then
      labelText = self.battleType == self.BATTLE_TYPE_WAR and "@ui_encounter_ongoingwar" or "@ui_encounter_ongoinginvasion"
      isWarOngoing = true
    end
    descText = self.battleType == self.BATTLE_TYPE_WAR and "@ui_encounter_signupDesc_war" or "@ui_encounter_signupDesc_invasion"
    UiTextBus.Event.SetTextWithFlags(self.Properties.LabelText, labelText, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.SignupDesc, descText, eUiTextSet_SetLocalized)
    if canManage then
      self.ViewStatusButton:SetText("@ui_encounter_managebutton")
    else
      self.ViewStatusButton:SetText("@ui_encounter_viewstatusbutton_war")
    end
  else
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    if self.raidSetupHandler then
      self:BusDisconnect(self.raidSetupHandler)
      self.raidSetupHandler = nil
    end
  end
end
function MapEncounterContainer:UpdateSiegeWindow()
  UiTextBus.Event.SetText(self.Properties.StatusText, "-")
  UiTextBus.Event.SetColor(self.Properties.StatusText, self.UIStyle.COLOR_YELLOW_GOLD)
  self.socialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
    local guildData
    if 0 < #result then
      guildData = type(result[1]) == "table" and result[1].guildData or result[1]
    else
      Log("ERR - MapEncounterContainer:UpdateSiegeWindow: GuildData request returned with no data")
      return
    end
    if guildData and guildData:IsValid() and self.status == self.STATE_SIGNUP then
      local text = dominionCommon:GetSiegeWindowText(guildData.siegeWindow)
      UiTextBus.Event.SetText(self.Properties.StatusText, text)
    end
  end, self.GuildRequestFailed, self.guildId)
end
function MapEncounterContainer:OnViewStatusButtonClick()
  LyShineManagerBus.Broadcast.SetState(1319313135)
  RaidSetupRequestBus.Broadcast.RequestRemoteInteract(self.settlementId)
  DynamicBus.Raid.Broadcast.SetIsRemoteInteract(true)
end
function MapEncounterContainer:OnEncounterContainerClose()
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId")
  self.ScriptedEntityTweener:Play(self.entityId, 0.175, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
    end
  })
end
return MapEncounterContainer
