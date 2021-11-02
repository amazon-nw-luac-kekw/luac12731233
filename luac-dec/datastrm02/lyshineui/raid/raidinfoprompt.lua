local RaidInfoPrompt = {
  Properties = {
    Panel = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    BackgroundImage = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    DescriptionText = {
      default = EntityId()
    },
    CompanyOrFortNameText = {
      default = EntityId()
    },
    CompanyEmblem = {
      default = EntityId()
    },
    SignUpCountText = {
      default = EntityId()
    },
    FactionNameText = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    },
    PopupGlow = {
      default = EntityId()
    },
    ViewStatusButton = {
      default = EntityId()
    },
    SignUpButton = {
      default = EntityId()
    },
    CloseButtonResult = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    WarContainer = {
      default = EntityId()
    },
    InvasionContainer = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    InvasionTimeDate = {
      default = EntityId()
    },
    InvasionLocation = {
      default = EntityId()
    },
    InvasionSignUpButton = {
      default = EntityId()
    },
    InvasionDescription = {
      default = EntityId()
    },
    BodyMask = {
      default = EntityId()
    },
    SignUpSuccessfulContainer = {
      default = EntityId()
    },
    InstructionDesc1 = {
      default = EntityId()
    },
    InstructionDesc2 = {
      default = EntityId()
    },
    InstructionDesc3 = {
      default = EntityId()
    },
    SideLabel = {
      default = EntityId()
    },
    SideIcon = {
      default = EntityId()
    },
    HowDoesWarWorkText = {
      default = EntityId()
    },
    Instructions = {
      default = EntityId()
    },
    ResultBackgroundImage = {
      default = EntityId()
    },
    MyFactionText = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  },
  onLeaveOtherWarEventId = "Popup_OnLeaveOtherWar",
  warSide = eRaidSide_None
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RaidInfoPrompt)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function RaidInfoPrompt:OnInit()
  BaseElement.OnInit(self)
  self.SignUpButton:SetCallback(self.ViewSignUpResult, self)
  self.InvasionSignUpButton:SetCallback(self.ViewSignUpResult, self)
  self.ViewStatusButton:SetCallback(self.ViewStatus, self)
  self.CloseButtonResult:SetCallback(self.OnExit, self)
  self.SignUpButton:SetText("@ui_siege_signup")
  self.InvasionSignUpButton:SetText("@ui_siege_signup")
  self.ViewStatusButton:SetText("@ui_siege_signup_viewmystatus")
  self.SignUpButton:SetButtonStyle(self.SignUpButton.BUTTON_STYLE_CTA)
  self.InvasionSignUpButton:SetButtonStyle(self.InvasionSignUpButton.BUTTON_STYLE_CTA)
  self.ViewStatusButton:SetButtonStyle(self.ViewStatusButton.BUTTON_STYLE_CTA)
  self.CloseButtonResult:SetText("@ui_close")
  self.CloseButton:SetCallback(self.TransitionOutRaidInfo, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Social.DataSynced", function(self, synced)
    if synced then
      self.siegeDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Conquest):ToSeconds()
      self.minutesBeforeSiegeToSendInvites = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.minutes-before-siege-to-send-invites")
    end
  end)
end
function RaidInfoPrompt:SetWarRaidInfo(territoryId, chosenSide, guildData, siegeWindow, siegeStartTime)
  self.warSide = chosenSide
  self.territoryId = territoryId
  self.hasSignedUp = false
  self.isInvasion = false
  local isAttacker = self.warSide == eRaidSide_Attacker
  local chosenSideText = isAttacker and "@ui_siege_signup_as_attacker" or "@ui_siege_signup_as_defender"
  local sideLabelText = isAttacker and "@ui_siege_attackers_side" or "@ui_siege_defenders_side"
  local descriptionText = isAttacker and "@ui_siege_signup_description_attackers" or "@ui_siege_signup_description_defenders"
  local icon = isAttacker and "lyshineui/images/icons/raid/icon_attacker.dds" or "lyshineui/images/icons/raid/icon_defender.dds"
  local bg = isAttacker and "lyshineui/images/raid/signup_imageAttacker.dds" or "lyshineui/images/raid/signup_imageDefender.dds"
  if self.warSide == eRaidSide_None then
    return
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, "@ui_siege_signup_war_title", eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.BackgroundImage, bg)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, icon)
  UiImageBus.Event.SetSpritePathname(self.Properties.SideIcon, icon)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, chosenSideText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SideLabel, sideLabelText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CompanyOrFortNameText, guildData.guildName, eUiTextSet_SetAsIs)
  self.CompanyEmblem:SetIcon(guildData.crestData)
  self.signUpCount = nil
  UiTextBus.Event.SetTextWithFlags(self.Properties.SignUpCountText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_signup_count", 0), eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.SignUpSuccessfulContainer, false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, descriptionText, eUiTextSet_SetLocalized)
  local warScheduleValueText = GetLocalizedReplacementText("@ui_siege_signup_warstart", {
    date = timeHelpers:GetLocalizedAbbrevDate(siegeStartTime),
    time = dominionCommon:GetSiegeWindowText(siegeWindow)
  })
  local inviteTime = siegeStartTime - self.minutesBeforeSiegeToSendInvites * timeHelpers.secondsInMinute
  local instructionDesc2Text = GetLocalizedReplacementText("@ui_signup_instruction_desc_2_war", {
    date = timeHelpers:GetLocalizedAbbrevDate(siegeStartTime),
    time = timeHelpers:GetLocalizedServerTime(inviteTime)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.InstructionDesc2, instructionDesc2Text, eUiTextSet_SetAsIs)
  local faction = guildData.faction
  local factionBgColor = FactionCommon.factionInfoTable[faction].crestBgColor
  local factionIcon = FactionCommon.factionInfoTable[faction].crestBg
  local factionName = FactionCommon.factionInfoTable[faction].factionName
  UiImageBus.Event.SetColor(self.Properties.FactionIcon, factionBgColor)
  UiImageBus.Event.SetSpritePathname(self.Properties.FactionIcon, factionIcon)
  UiTextBus.Event.SetColor(self.Properties.FactionNameText, factionBgColor)
  UiTextBus.Event.SetTextWithFlags(self.Properties.FactionNameText, factionName, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetColor(self.Properties.PopupGlow, factionBgColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarContainer, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvasionContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyFactionText, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.SideIcon, true)
  local signupResponse = RaidSetupRequestBus.Broadcast.CanSignUpForRaid(chosenSide)
  local canSignUp = signupResponse == eRaidSetupRequestFailureReason_None
  self.SignUpButton:SetEnabled(canSignUp)
  local tooltipText = ""
  if not canSignUp then
    tooltipText = self:GetRaidSetupFailureReasonText(signupResponse)
  end
  self.SignUpButton:SetTooltip(tooltipText)
end
function RaidInfoPrompt:TransitionInRaidInfo()
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.WarContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  self.audioHelper:PlaySound(self.audioHelper.Raid_Popup_Show)
end
function RaidInfoPrompt:TransitionOutRaidInfo()
  self.ScriptedEntityTweener:Play(self.Properties.WarContainer, 0.3, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.Raid_Popup_Hide)
end
function RaidInfoPrompt:ShowInvasionRaidInfo(territoryId, siegeWindow, siegeStartTime)
  self.territoryId = territoryId
  self.hasSignedUp = false
  self.warSide = eRaidSide_Defender
  self.siegeStartTime = siegeStartTime
  self.isInvasion = true
  local playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
  local minLevel = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.invasion-min-level") + 1
  if playerLevel < minLevel then
    local buttonText = GetLocalizedReplacementText("@ui_signup_level_requirement", {level = minLevel})
    self.InvasionSignUpButton:SetText(buttonText)
    self.InvasionSignUpButton:SetEnabled(false)
  else
    self.InvasionSignUpButton:SetText("@ui_siege_signup")
    self.InvasionSignUpButton:SetEnabled(true)
  end
  local fortressNameText = GetLocalizedReplacementText("@ui_siege_signup_fortressname", {
    territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryId)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.InvasionLocation, fortressNameText, eUiTextSet_SetAsIs)
  local descriptionText = GetLocalizedReplacementText("@ui_siege_signup_description_invasion", {
    territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryId)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.InvasionDescription, descriptionText, eUiTextSet_SetAsIs)
  local invasionDurationText = timeHelpers:ConvertToVerboseDurationString(self.siegeDuration, false, false)
  local invasionScheduleValueText = GetLocalizedReplacementText("@ui_siege_signup_warstart", {
    date = timeHelpers:GetLocalizedAbbrevDate(siegeStartTime),
    time = dominionCommon:GetSiegeWindowText(siegeWindow, true, false)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.InvasionTimeDate, invasionScheduleValueText, eUiTextSet_SetAsIs)
  local inviteTime = siegeStartTime - self.minutesBeforeSiegeToSendInvites * timeHelpers.secondsInMinute
  local instructionDesc2Text = GetLocalizedReplacementText("@ui_signup_instruction_desc_2_invasion", {
    date = timeHelpers:GetLocalizedAbbrevDate(siegeStartTime),
    time = timeHelpers:GetLocalizedServerTime(inviteTime, true)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.InstructionDesc2, instructionDesc2Text, eUiTextSet_SetAsIs)
  local timeRemainingText = dominionCommon:GetTimeToSiegeText(siegeStartTime)
  UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, "@ui_siege_signup_invasion_title", eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.SignUpSuccessfulContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvasionContainer, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyFactionText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SideIcon, false)
  self.ScriptedEntityTweener:Play(self.Properties.InvasionContainer, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.BodyMask, 1.5, {y = -400}, {
    y = 500,
    ease = "QuadOut",
    delay = 0
  })
end
function RaidInfoPrompt:SetSignUpCount(count)
  self.signUpCount = count
  UiTextBus.Event.SetTextWithFlags(self.Properties.SignUpCountText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_signup_count", tostring(count)), eUiTextSet_SetAsIs)
end
function RaidInfoPrompt:SetExitCallback(callback, callbackTable)
  self.exitCallback = callback
  self.exitCallbackTable = callbackTable
end
function RaidInfoPrompt:ViewStatus()
  if self.hasSignedUp then
    LyShineManagerBus.Broadcast.SetState(1468490675)
    DynamicBus.Raid.Broadcast.SetData(self.territoryId, self.warSide, true)
  end
end
function RaidInfoPrompt:ViewSignUpResult()
  local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.territoryId)
  local siegeTime = warDetails:GetConquestStartTime()
  local siegeDuration = dominionCommon:GetSiegeDuration()
  local territories = RaidSetupRequestBus.Broadcast.GetSignedUpTerritories()
  for i = 1, #territories do
    local otherWarDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(territories[i])
    local otherSiegeTime = otherWarDetails:GetConquestStartTime()
    if siegeDuration > math.abs(otherSiegeTime:Subtract(siegeTime):ToSeconds()) then
      self.territoryToLeaveFrom = territories[i]
      local confirmationText = GetLocalizedReplacementText("@ui_siege_signup_conquest_overlap_confirm", {
        territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryToLeaveFrom)
      })
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_siege_signup_conquest_overlap_title", confirmationText, self.onLeaveOtherWarEventId, self, self.OnPopupResult)
      return
    end
  end
  self:RequestSignup()
end
function RaidInfoPrompt:RequestSignup()
  RaidSetupRequestBus.Broadcast.RequestSignup(self.warSide)
end
function RaidInfoPrompt:OnPopupResult(result, eventId)
  if result ~= ePopupResult_Yes then
    return
  end
  if eventId == self.onLeaveOtherWarEventId then
    RaidSetupRequestBus.Broadcast.RequestLeave(self.territoryToLeaveFrom)
  end
end
function RaidInfoPrompt:OnSignupResult(success, failureReason)
  if success == true then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    local instructionDesc1 = self.isInvasion and "@ui_signup_instruction_desc_1_invasion" or "@ui_signup_instruction_desc_1_war"
    local instructionDesc3 = self.isInvasion and "@ui_signup_instruction_desc_3_invasion" or "@ui_signup_instruction_desc_3_war"
    local bgImagePath = self.isInvasion and "lyshineui/images/raid/signup_resultInvasion.dds" or "lyshineui/images/raid/signup_resultWar.dds"
    UiTextBus.Event.SetTextWithFlags(self.Properties.InstructionDesc1, instructionDesc1, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.InstructionDesc3, instructionDesc3, eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.ResultBackgroundImage, bgImagePath)
    if self.isInvasion then
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
      self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
      UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWorkText, "@ui_how_does_invasion_work", eUiTextSet_SetLocalized)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.Instructions, -28)
    else
      self.ScriptedEntityTweener:Play(self.Properties.WarContainer, 0.2, {
        opacity = 0,
        y = -10,
        ease = "QuadOut"
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWorkText, "@ui_how_does_war_work", eUiTextSet_SetLocalized)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.Instructions, 0)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.SignUpSuccessfulContainer, true)
    self.ScriptedEntityTweener:Play(self.Properties.SignUpSuccessfulContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.audioHelper:PlaySound(self.audioHelper.Banner_Achievement)
    if self.signUpCount then
      self:SetSignUpCount(self.signUpCount + 1)
    end
    self.hasSignedUp = true
  else
    Log("ERR - RaidInfoPrompt:OnSignupResult: Signup failed with reason " .. tostring(failureReason))
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = self:GetRaidSetupFailureReasonText(failureReason)
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function RaidInfoPrompt:GetRaidSetupFailureReasonText(failureReason)
  if failureReason == eRaidSetupRequestFailureReason_SignupToOpposingSide then
    return "@ui_siege_signup_failed_opposingside"
  elseif failureReason == eRaidSetupRequestFailureReason_SignupInvalidFaction then
    return "@ui_siege_signup_failed_invalidfaction"
  elseif failureReason == eRaidSetupRequestFailureReason_SignupFull then
    return "@ui_siege_signup_failed_full"
  elseif failureReason == eRaidSetupRequestFailureReason_ConquestTimeOverlaps then
    return "@ui_siege_signup_failed_conquestoverlaps"
  elseif failureReason == eRaidSetupRequestFailureReason_NotInFaction then
    return "@ui_siege_signup_failed_notinfaction"
  elseif failureReason == eRaidSetupRequestFailureReason_InvasionLevelRequiremenetNotMet then
    return GetLocalizedReplacementText("@ui_siege_signup_failed_invasionlevelrequirement", {
      minLevel = tostring(ConfigProviderEventBus.Broadcast.GetInt("javelin.social.invasion-min-level") + 1)
    })
  elseif failureReason == eRaidSetupRequestFailureReason_Banned then
    return "@ui_siege_signup_failed_banned"
  else
    return "@ui_siege_signup_failed"
  end
end
function RaidInfoPrompt:OnLeaveResult(territoryId, success, failureReason)
  if self.territoryToLeaveFrom and self.territoryToLeaveFrom == territoryId then
    self.territoryToLeaveFrom = nil
    if success == true then
      self:RequestSignup()
    else
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_siege_leave_failed"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end
end
function RaidInfoPrompt:OnExit()
  if self.exitCallback then
    self.exitCallback(self.exitCallbackTable)
  end
end
return RaidInfoPrompt
