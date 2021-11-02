local SignUp = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    ChooseSideContainer = {
      default = EntityId()
    },
    RaidInfoContainer = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    },
    WarDateText = {
      default = EntityId()
    },
    WarTimeText = {
      default = EntityId()
    },
    LocationText = {
      default = EntityId()
    },
    LeftButton = {
      default = EntityId()
    },
    RightButton = {
      default = EntityId()
    },
    LeftSignUpCountText = {
      default = EntityId()
    },
    RightSignUpCountText = {
      default = EntityId()
    },
    ServerTimeText = {
      default = EntityId()
    },
    MyFactionText = {
      default = EntityId()
    },
    MyFactionIcon = {
      default = EntityId()
    },
    MyFactionLabel = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    InvasionContainer = {
      default = EntityId()
    }
  },
  epoch = WallClockTimePoint(),
  territoryId = 0,
  isInvasion = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(SignUp)
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function SignUp:OnInit()
  BaseScreen.OnInit(self)
  self.ScreenHeader:SetText("@ui_siege_signup_war_title")
  self.ScreenHeader:SetHintCallback(self.OnExit, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  self.ChooseSideContainer:SetCallbacks(self.OnSelectAttackers, self.OnSelectDefenders, self)
  self.RaidInfoContainer:SetExitCallback(self.OnExit, self)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.factionInfoTable = factionCommon.factionInfoTable
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, faction)
    if not faction or not self.factionInfoTable[faction] then
      return
    end
    local factionName = self.factionInfoTable[faction].factionName
    local factionBgColor = self.factionInfoTable[faction].crestBgColor
    local factioCrestBgSmall = self.factionInfoTable[faction].crestBgSmall
    UiTextBus.Event.SetTextWithFlags(self.Properties.MyFactionText, factionName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.MyFactionText, factionBgColor)
    UiImageBus.Event.SetColor(self.Properties.MyFactionIcon, factionBgColor)
    UiImageBus.Event.SetSpritePathname(self.Properties.MyFactionIcon, factioCrestBgSmall)
    if faction == 0 then
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MyFactionLabel, 0)
    else
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MyFactionLabel, -34)
    end
  end)
  self.LeftButton:SetEnabled(false)
  self.RightButton:SetEnabled(false)
  self.LeftButton:SetText("@ui_signup_not_available")
  self.RightButton:SetText("@ui_signup_not_available")
end
function SignUp:OnShutdown()
  BaseScreen.OnShutdown(self)
end
function SignUp:OnRaidSetupReady(territoryId, side)
  self.territoryId = territoryId
  self.side = side
  if self.territoryId == 0 then
    Log("ERR - SignUp:OnRaidSetupReady: Invalid territoryId")
    return
  end
  local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.territoryId)
  if not warDetails:IsValid() or not warDetails:IsWarActive() then
    Log("ERR - SignUp:OnRaidSetupReady: Invalid warDetails")
    LyShineManagerBus.Broadcast.ExitState(1319313135)
    local interactorEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntityId)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_siege_signup_no_war"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  self.isInvasion = warDetails:IsInvasion()
  self.attackerGuildData = nil
  self.defenderGuildData = nil
  self.siegeStartTime = warDetails:GetConquestStartTime():Subtract(self.epoch):ToSecondsRoundedUp()
  local warDateText = timeHelpers:GetLocalizedAbbrevDate(self.siegeStartTime)
  UiTextBus.Event.SetTextWithFlags(self.Properties.WarDateText, warDateText, eUiTextSet_SetAsIs)
  local governingCompanyText = GetLocalizedReplacementText("@ui_siege_signup_fortressname", {
    territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryId)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.LocationText, governingCompanyText, eUiTextSet_SetAsIs)
  if warDetails:GetAttackerGuildId():IsValid() then
    self:PopulateGuildData(warDetails:GetAttackerGuildId(), function(self, guildData)
      self.attackerGuildData = {
        guildName = guildData.guildName,
        crestData = guildData.crestData,
        faction = guildData.faction
      }
      self.ChooseSideContainer:SetGuildData(self.attackerGuildData, nil)
      self:OnGuildDataReceived()
      self:RefreshSignupButtons()
    end)
  end
  if warDetails:GetDefenderGuildId():IsValid() then
    self:PopulateGuildData(warDetails:GetDefenderGuildId(), function(self, guildData)
      self.defenderGuildData = {
        guildName = guildData.guildName,
        crestData = guildData.crestData,
        faction = guildData.faction
      }
      self.siegeWindow = guildData.siegeWindow
      local warTimeText = dominionCommon:GetSiegeWindowText(self.siegeWindow, true, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.WarTimeText, warTimeText, eUiTextSet_SetAsIs)
      if self.isInvasion then
        if not self.isSignedUp then
          self:SetSpinnerShowing(false)
          self:OnSelectInvasion()
        end
      else
        self.ChooseSideContainer:SetGuildData(nil, self.defenderGuildData)
        self:OnGuildDataReceived()
      end
      self:RefreshSignupButtons()
    end)
  end
  RaidSetupRequestBus.Broadcast.RequestSignupCount(eRaidSide_Attacker)
  RaidSetupRequestBus.Broadcast.RequestSignupCount(eRaidSide_Defender)
  if side == eRaidSide_Attacker or side == eRaidSide_Defender then
    if not self.isVisible then
      local signupStatus = RaidSetupRequestBus.Broadcast.GetSignupStatus(self.territoryId)
      self.isSignedUp = signupStatus and signupStatus.side ~= eRaidSide_None
      local canManage = RaidSetupRequestBus.Broadcast.HasManagePermission(self.territoryId)
      if self.isSignedUp or canManage then
        LyShineManagerBus.Broadcast.SetState(1468490675)
        DynamicBus.Raid.Broadcast.SetData(territoryId, side, true)
      else
        self.isVisible = true
        self:SetSignupButtonEnabled(self.RightButton, side == eRaidSide_Defender, "@ui_signup_restriction_tooltip")
        self:SetSignupButtonEnabled(self.LeftButton, side == eRaidSide_Attacker, "@ui_signup_restriction_tooltip")
      end
    end
  else
    self.isVisible = true
    self:SetSignupButtonEnabled(self.LeftButton, false)
    self:SetSignupButtonEnabled(self.RightButton, false)
    self:RefreshSignupButtons()
  end
end
function SignUp:RefreshSignupButtons()
  local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  local tooltipText = "@ui_signup_nofaction_tooltip"
  if faction ~= 0 then
    tooltipText = "@ui_signup_restriction_tooltip"
  end
  if self.defenderGuildData then
    self:SetSignupButtonEnabled(self.LeftButton, faction ~= 0 and self.defenderGuildData.faction ~= faction, tooltipText)
  end
  if self.attackerGuildData then
    self:SetSignupButtonEnabled(self.RightButton, faction ~= 0 and self.attackerGuildData.faction ~= faction, tooltipText)
  end
end
function SignUp:SetSignupButtonEnabled(buttonTable, isEnabled, tooltipText)
  buttonTable:SetButtonStyle(buttonTable.BUTTON_STYLE_CTA)
  if isEnabled then
    buttonTable:SetEnabled(true)
    buttonTable:SetText("@ui_siege_signup")
    buttonTable:SetTooltip(nil)
  else
    buttonTable:SetEnabled(false)
    buttonTable:SetText("@ui_signup_not_available")
    buttonTable:SetTooltip(tooltipText)
  end
end
function SignUp:PopulateGuildData(guildId, callback)
  socialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
    local guildData
    if 0 < #result then
      guildData = type(result[1]) == "table" and result[1].guildData or result[1]
    else
      Log("ERR - SignUp:OnRaidSetupReady: GuildData request for ID (" .. guildId:ToString() .. ") returned with no data")
      return
    end
    if guildData and guildData:IsValid() then
      callback(self, guildData)
    end
  end, nil, guildId)
end
function SignUp:OnSignupCountReceived(side, count)
  self.RaidInfoContainer:SetSignUpCount(count)
  if side == 1 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.LeftSignUpCountText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_signup_count", tostring(count)), eUiTextSet_SetAsIs)
  elseif side == 2 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.RightSignUpCountText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_signup_count", tostring(count)), eUiTextSet_SetAsIs)
  end
end
function SignUp:OnSignupResponseReceived(success, failureReason)
  if self.isVisible then
    self.isSignedUp = success
    self.RaidInfoContainer:OnSignupResult(success, failureReason)
  end
end
function SignUp:OnLeaveResponseReceived(territoryId, success, failureReason)
  if self.isVisible then
    self.RaidInfoContainer:OnLeaveResult(territoryId, success, failureReason)
  end
end
function SignUp:OnGuildDataReceived()
  if not self.attackerGuildData or not self.defenderGuildData then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ChooseSideContainer, true)
  self:SetSpinnerShowing(false)
end
function SignUp:SetSpinnerShowing(isShowing)
  if self.spinnerIsShowing == isShowing then
    return
  end
  self.spinnerIsShowing = isShowing
  UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, isShowing)
  if isShowing then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
  end
end
function SignUp:OnSelectAttackers()
  self.RaidInfoContainer:SetWarRaidInfo(self.territoryId, eRaidSide_Attacker, self.attackerGuildData, self.siegeWindow, self.siegeStartTime)
  RaidSetupRequestBus.Broadcast.RequestSignupCount(eRaidSide_Attacker)
  self.RaidInfoContainer:TransitionInRaidInfo()
  self:OnSelectOneOfTheSides()
end
function SignUp:OnSelectDefenders()
  self.RaidInfoContainer:SetWarRaidInfo(self.territoryId, eRaidSide_Defender, self.defenderGuildData, self.siegeWindow, self.siegeStartTime)
  RaidSetupRequestBus.Broadcast.RequestSignupCount(eRaidSide_Defender)
  self.RaidInfoContainer:TransitionInRaidInfo()
  self:OnSelectOneOfTheSides()
end
function SignUp:OnSelectOneOfTheSides()
  self.RaidInfoContainer:TransitionInRaidInfo()
end
function SignUp:OnSelectInvasion()
  self.RaidInfoContainer:ShowInvasionRaidInfo(self.territoryId, self.siegeWindow, self.siegeStartTime)
end
function SignUp:OnExit()
  LyShineManagerBus.Broadcast.ExitState(1319313135)
  local interactorEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntityId)
end
function SignUp:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.isSignedUp = false
  if self.raidSetupBusHandler then
    self:BusDisconnect(self.raidSetupBusHandler)
    self.raidSetupBusHandler = nil
  end
  self.raidSetupBusHandler = self:BusConnect(RaidSetupNotificationBus)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ChooseSideContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RaidInfoContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvasionContainer, false)
  self:SetSpinnerShowing(true)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_SignUp", 0.5)
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Intro)
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 3
  self.targetDOFBlur = 0.75
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 1.2,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  self.ChooseSideContainer:OnTransitionIn()
end
function SignUp:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.raidSetupBusHandler then
    self:BusDisconnect(self.raidSetupBusHandler)
    self.raidSetupBusHandler = nil
  end
  self.isVisible = false
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_SignUp", 0.5)
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  UiElementBus.Event.SetIsEnabled(self.Properties.RaidInfoContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
  self.ScriptedEntityTweener:Set(self.Properties.PopupBackground, {opacity = 0})
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  if toState ~= 1468490675 then
    local interactorEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntityId)
  end
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  self:SetSpinnerShowing(false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function SignUp:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function SignUp:OnShowWarTutorial()
  local gameMode = self.isInvasion and GameModeCommon.GAMEMODE_INVASION or GameModeCommon.GAMEMODE_WAR
  DynamicBus.WarTutorialPopup.Broadcast.ShowWarTutorialPopup(gameMode)
end
return SignUp
