local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local EscapeMenu = {
  Properties = {
    EscapeMenuHolder = {
      default = EntityId()
    },
    EscapeHolderNoEntitlements = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    SupportButtonsContainer = {
      default = EntityId()
    },
    ExitButtonsContainer = {
      default = EntityId()
    },
    ButtonFeedback = {
      default = EntityId()
    },
    ButtonRespawn = {
      default = EntityId()
    },
    ButtonUnstuck = {
      default = EntityId()
    },
    ButtonExitMainNemu = {
      default = EntityId()
    },
    ButtonExitDesktop = {
      default = EntityId()
    },
    ButtonDefects = {
      default = EntityId()
    },
    ButtonGameExtra = {
      default = EntityId()
    },
    ButtonHelp = {
      default = EntityId()
    },
    ShopLabel = {
      default = EntityId()
    },
    DisabledContainer = {
      default = EntityId()
    },
    StoreButtonHolder = {
      default = EntityId()
    },
    FrameLarge = {
      default = EntityId()
    },
    FrameSmall = {
      default = EntityId()
    },
    InputBlocker = {
      default = EntityId()
    },
    WorldNameHolder = {
      default = EntityId()
    },
    WorldName = {
      default = EntityId()
    }
  },
  mRecallToWatchtowerPopupTitle = "@ui_watchtower_fast_travel",
  mRecallToWatchtowerPopupMessage = "@ui_watchtower_recall_from_esc_popup_confirm",
  mRecallToInnPopupTitle = "@ui_inn_fast_travel",
  mRecallToInnPopupMessage = "@ui_inn_recall_from_esc_popup_confirm",
  mQuitPopupTitle = "@ui_quitpopup_title",
  mQuitDesktopPopupMessage = "@ui_quitdesktoppopup_message",
  mQuitMainMenuPopupMessage = "@ui_quitmainmenupopup_message",
  mPopupProceedToNewWorldTitle = "@ui_proceed_to_new_world_popup_title",
  mPopupProceedToNewWorldMessage = "@ui_proceed_to_new_world_popup_message",
  mPopupRespawnEventId = "Popup_Respawn",
  mPopupQuitToDesktopEventId = "Popup_QuitToDesktop",
  mPopupQuitToMainMenuEventId = "Popup_QuitToMainMenu",
  mPopupProceedToNewWorldEventId = "Popup_ProceedToNewWorld",
  mLeaveOutpostRushId = "Popup_LeaveOutpostRush",
  outpostRushStateId = "State",
  outpostRushTimeLeftDataPath = "Timer_" .. tostring(2400096598),
  adjustedMenuHeight = false,
  isChanneling = false,
  cooldownTimer = 0,
  cooldownTimerTick = 1
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(EscapeMenu)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local fastTravelCommon = RequireScript("LyShineUI._Common.FastTravelCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function EscapeMenu:OnInit()
  BaseScreen.OnInit(self)
  self.timeHelpers = timeHelpers
  self.dataLayer:RegisterOpenEvent("EscapeMenu", self.canvasId)
  self.fastTravelErrorToText = fastTravelCommon.fastTravelErrorToText
  local shrinkMenu = true
  shrinkMenu = not self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableEntitlements")
  if shrinkMenu then
    self.enableSmallFrame = true
    UiElementBus.Event.SetIsEnabled(self.Properties.StoreButtonHolder, false)
    local positionX = UiTransformBus.Event.GetLocalPositionX(self.Properties.EscapeMenuHolder)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.EscapeMenuHolder, positionX + 400)
    local escapeHolderNoEntitlementsWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.EscapeHolderNoEntitlements)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.InputBlocker, escapeHolderNoEntitlementsWidth)
    UiElementBus.Event.SetIsEnabled(self.Properties.EscapeHolderNoEntitlements, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.FrameLarge, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ShopLabel, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldNameHolder, false)
  end
  self.supportSectionPositionYOriginal = UiTransformBus.Event.GetLocalPositionY(self.Properties.SupportButtonsContainer)
  self.exitSectionPositionYOriginal = UiTransformBus.Event.GetLocalPositionY(self.Properties.ExitButtonsContainer)
  self.menuHeightOriginal = UiTransform2dBus.Event.GetLocalHeight(self.Properties.EscapeHolderNoEntitlements)
  self.buttonHeightOriginal = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ButtonRespawn)
  self.outerFrameHeightOriginal = self.FrameLarge:GetHeight()
  self.outerFrameSmallHeightOriginal = self.FrameSmall:GetHeight()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
    if rootPlayerId then
      self.rootPlayerId = rootPlayerId
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    if isDead == nil then
      return
    end
    self.isDead = isDead
    self.ButtonFeedback:SetEnabled(not isDead)
    self.ButtonUnstuck:SetEnabled(not isDead)
    self.ButtonRespawn:SetEnabled(not isDead)
    local tooltip = isDead and "@ui_button_disabled_dead" or ""
    self.ButtonFeedback:SetTooltip(tooltip)
    self.ButtonUnstuck:SetTooltip(tooltip)
    self.ButtonRespawn:SetTooltip(tooltip)
    self.StoreButtonHolder:SetIsHandlingEvents(not isDead and not FtueSystemRequestBus.Broadcast.IsFtue())
  end)
  self.ButtonFeedback:SetText("@ui_escapemenu_submit_feedback")
  self.ButtonRespawn:SetText("@ui_inn_fast_travel")
  self.ButtonUnstuck:SetText("@ui_escapemenu_unstuck")
  self.ButtonExitMainNemu:SetText("@ui_escapemenu_exit_to_main_menu")
  self.ButtonExitDesktop:SetText("@ui_escapemenu_exit_to_desktop")
  self.ButtonDefects:SetText("@ui_escapemenu_defect_reports")
  self.ButtonGameExtra:SetText("@ui_escapemenu_proceed_to_new_world")
  self.ButtonHelp:SetText("@ui_escapemenu_help")
  self.ButtonFeedback:SetTextAlignment(self.ButtonFeedback.TEXT_ALIGN_LEFT)
  self.ButtonRespawn:SetTextAlignment(self.ButtonRespawn.TEXT_ALIGN_LEFT)
  self.ButtonUnstuck:SetTextAlignment(self.ButtonUnstuck.TEXT_ALIGN_LEFT)
  self.ButtonExitMainNemu:SetTextAlignment(self.ButtonExitMainNemu.TEXT_ALIGN_LEFT)
  self.ButtonExitDesktop:SetTextAlignment(self.ButtonExitDesktop.TEXT_ALIGN_LEFT)
  self.ButtonDefects:SetTextAlignment(self.ButtonDefects.TEXT_ALIGN_LEFT)
  self.ButtonGameExtra:SetTextAlignment(self.ButtonGameExtra.TEXT_ALIGN_LEFT)
  self.ButtonHelp:SetTextAlignment(self.ButtonHelp.TEXT_ALIGN_LEFT)
  self.ButtonFeedback:SetCallback(self.OnSubmitFeedbackPressed, self)
  self.ButtonRespawn:SetCallback(self.OnRespawnPressed, self)
  self.ButtonUnstuck:SetCallback(self.OnUnstuckPressed, self)
  self.ButtonExitMainNemu:SetCallback(self.OnExitPressed, self)
  self.ButtonExitDesktop:SetCallback(self.OnQuitPressed, self)
  self.ButtonDefects:SetCallback(self.OnDefectReporterPressed, self)
  self.ButtonGameExtra:SetCallback(self.OnProceedToNewWorldPressed, self)
  self.ButtonHelp:SetCallback(self.OnHelpPressed, self)
  self.ButtonFeedback:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
  self.ButtonHelp:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
  self.ButtonRespawn:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
  self.ButtonUnstuck:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
  self.ButtonExitMainNemu:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
  self.ButtonExitDesktop:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
  self.ButtonDefects:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
  self.ButtonGameExtra:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
  UiTextBus.Event.SetTextWithFlags(self.Properties.WorldName, LyShineManagerBus.Broadcast.GetWorldName(), eUiTextSet_SetAsIs)
  self.StoreButtonHolder:SetInGame(true)
  DynamicBus.AbilityChannelNotifications.Connect(self.entityId, self)
end
function EscapeMenu:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.AbilityChannelNotifications.Disconnect(self.entityId, self)
end
function EscapeMenu:StartTick()
  if not self.tickHandler then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function EscapeMenu:StopTick()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function EscapeMenu:OnTick(delta, timePoint)
  self.cooldownTimer = self.cooldownTimer + delta
  if self.cooldownTimer >= self.cooldownTimerTick then
    self.cooldownTimer = self.cooldownTimer - self.cooldownTimerTick
    local recallToInnTooltip = self:GetRecallToInnCooldownText()
    if recallToInnTooltip then
      self.ButtonRespawn:SetTooltip(recallToInnTooltip)
    else
      local fastTravelResult = PlayerHousingClientRequestBus.Broadcast.CanFastTravelToTerritory(self.homePointTerritoryId, true, false)
      local enabled = fastTravelResult == eCanFastTravelToSettlementResults_Success
      if not enabled then
        recallToInnTooltip = self.fastTravelErrorToText[fastTravelResult]
      end
      self.ButtonRespawn:SetEnabled(enabled)
      self.ButtonRespawn:SetTooltip(recallToInnTooltip)
      self:StopTick()
    end
  end
end
function EscapeMenu:GetRecallToInnCooldownText()
  local cooldownTime = fastTravelCommon:GetCurrentlySetInnCooldownTime()
  if cooldownTime == 0 then
    return
  end
  return GetLocalizedReplacementText("@ui_fast_travel_error_description_inCooldown_with_time", {
    time = timeHelpers:ConvertToShorthandString(math.floor(cooldownTime), true)
  })
end
function EscapeMenu:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  UiElementBus.Event.SetIsEnabled(self.entityId, not self.invokedFromPurchasesState)
  self.ScriptedEntityTweener:Play(self.Properties.EscapeMenuHolder, 0.25, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  local isRespawnState = toState == 921475099
  local exitToMainMenuEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_exitToMainMenu")
  local defectReporterEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableDefectReporter")
  local dugeonGameModeId = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(self.rootPlayerId)
  self.isInDungeon = dugeonGameModeId ~= 0
  self.isInArena = PlayerArenaRequestBus.Event.IsInArena(self.rootPlayerId)
  self.isInDuel = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.rootPlayerId, 2612307810)
  self.isInOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.rootPlayerId, 2444859928)
  local isFtue = FtueSystemRequestBus.Broadcast.IsFtue() or GameRequestsBus.Broadcast.IsInDungeonGameMode() and dugeonGameModeId == 0
  local isAtWar = WarDataClientRequestBus.Broadcast.IsInSiegeWarfare()
  if self.isInOutpostRush then
    self.ButtonGameExtra:SetText("@ui_outpost_rush_leave")
    self.ButtonGameExtra:SetCallback(self.OnLeaveOutpostRush, self)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonGameExtra, isFtue or self.isInOutpostRush)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonDefects, defectReporterEnabled)
  local menuHeight = self.menuHeightOriginal
  local buttonHeight = self.buttonHeightOriginal
  local outerFrameHeight = self.outerFrameHeightOriginal
  local outerFrameSmallHeight = self.outerFrameSmallHeightOriginal
  local supportSectionPositionY = self.supportSectionPositionYOriginal
  local exitSectionPositionY = self.exitSectionPositionYOriginal
  if not isFtue and not self.isInOutpostRush then
    supportSectionPositionY = supportSectionPositionY - buttonHeight
    exitSectionPositionY = exitSectionPositionY - buttonHeight
    menuHeight = menuHeight - buttonHeight
    outerFrameHeight = outerFrameHeight - buttonHeight
    outerFrameSmallHeight = outerFrameSmallHeight - buttonHeight
  end
  if not defectReporterEnabled then
    exitSectionPositionY = exitSectionPositionY - buttonHeight
    menuHeight = menuHeight - buttonHeight
    outerFrameHeight = outerFrameHeight - buttonHeight
    outerFrameSmallHeight = outerFrameSmallHeight - buttonHeight
  end
  UiTransformBus.Event.SetLocalPositionY(self.Properties.SupportButtonsContainer, supportSectionPositionY)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ExitButtonsContainer, exitSectionPositionY)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.EscapeHolderNoEntitlements, menuHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.InputBlocker, menuHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.EscapeMenuHolder, menuHeight)
  self.FrameLarge:SetHeight(outerFrameHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.WorldNameHolder, outerFrameHeight)
  if self.enableSmallFrame then
    self.FrameSmall:SetHeight(outerFrameSmallHeight)
  end
  local lastEnabledButton = self:SetButtonEnabled(self.Properties.ButtonGameExtra, isFtue or self.isInOutpostRush, EntityId())
  lastEnabledButton = self:SetButtonEnabled(self.Properties.ButtonDefects, defectReporterEnabled and not isRespawnState, lastEnabledButton)
  lastEnabledButton = self:SetButtonEnabled(self.Properties.ButtonExitDesktop, true, lastEnabledButton)
  lastEnabledButton = self:SetButtonEnabled(self.Properties.ButtonExitMainNemu, exitToMainMenuEnabled and not isRespawnState, lastEnabledButton)
  lastEnabledButton = self:SetButtonEnabled(self.Properties.ButtonRespawn, not isRespawnState and not isFtue and not isAtWar, lastEnabledButton)
  lastEnabledButton = self:SetButtonEnabled(self.Properties.ButtonUnstuck, not isRespawnState, lastEnabledButton)
  lastEnabledButton = self:SetButtonEnabled(self.Properties.ButtonFeedback, not isRespawnState, lastEnabledButton)
  self.audioHelper:PlaySound(self.audioHelper.OnShow)
  UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
  self.StoreButtonHolder:OnSetVisible(true)
  self.StoreButtonHolder:SetIsHandlingEvents(not self.isDead and not FtueSystemRequestBus.Broadcast.IsFtue())
  local warDetails
  local localPlayerRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  if localPlayerRaidId and localPlayerRaidId:IsValid() then
    warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(localPlayerRaidId)
  end
  local isWarActive = warDetails and warDetails:IsValid() and warDetails:IsWarActive()
  local fastTravelResult
  self.isHomePointAnInn = false
  self.homePointTerritoryId = fastTravelCommon:GetCurrentlySetInnTerritoryId()
  if self.homePointTerritoryId ~= 0 then
    fastTravelResult = PlayerHousingClientRequestBus.Broadcast.CanFastTravelToTerritory(self.homePointTerritoryId, true, false)
    self.isHomePointAnInn = true
  else
    self.homePointTerritoryId = fastTravelCommon:GetCurrentlySetStartingBeachHomePointTerritoryId()
    fastTravelResult = PlayerHousingClientRequestBus.Broadcast.CanFastTravelToTerritory(self.homePointTerritoryId, true, false)
  end
  local recallButtonText
  if self.isInDungeon then
    recallButtonText = "@ui_dungeon_leave"
  elseif self.isInArena then
    recallButtonText = "@ui_arena_leave"
  elseif self.isInDuel then
    recallButtonText = "@ui_duel_forfeit_title"
  elseif self.isHomePointAnInn then
    recallButtonText = "@ui_inn_fast_travel"
  else
    recallButtonText = "@ui_watchtower_fast_travel"
  end
  local recallButtonEnabled = not isFtue and not isWarActive and not self.isInOutpostRush and not self.isChanneling and fastTravelResult == eCanFastTravelToSettlementResults_Success
  local recallButtonTooltip
  if fastTravelResult ~= eCanFastTravelToSettlementResults_Success then
    if fastTravelResult == eCanFastTravelToSettlementResults_InCooldown then
      self.cooldownTimer = 0
      self:StartTick()
      recallButtonTooltip = self:GetRecallToInnCooldownText()
    elseif self.isInOutpostRush then
      recallButtonTooltip = "@ui_cannot_travel_outpost_rush"
    else
      recallButtonTooltip = self.fastTravelErrorToText[fastTravelResult]
    end
  end
  self.ButtonRespawn:SetText(recallButtonText)
  self.ButtonRespawn:SetEnabled(recallButtonEnabled)
  self.ButtonRespawn:SetTooltip(recallButtonTooltip)
end
function EscapeMenu:HideEscapeMenuHolder()
  self.invokedFromPurchasesState = true
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
function EscapeMenu:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.audioHelper:PlaySound(self.audioHelper.OnHide)
  self:StopTick()
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.StoreButtonHolder:OnSetVisible(false)
  self.invokedFromPurchasesState = false
end
function EscapeMenu:OnPopupResult(result, eventId)
  if self.popUpHandler then
    self.popUpHandler:Disconnect(eventId)
    self.popUpHandler = nil
  end
  if eventId == self.mPopupRespawnEventId then
    if result == ePopupResult_Yes then
      if self.isInDungeon then
        PlayerArenaRequestBus.Event.ForfeitArena(self.rootPlayerId, true)
        LyShineManagerBus.Broadcast.SetState(2702338936)
      elseif self.isInArena then
        PlayerArenaRequestBus.Event.ForfeitArena(self.rootPlayerId, false)
      elseif self.isInDuel then
        GameModeParticipantComponentRequestsBus.Event.SendClientEvent(self.rootPlayerId, 3166465118)
      elseif self.homePointTerritoryId ~= 0 then
        local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
        local numMissionsAbandonedOnFastTravel = ObjectivesComponentRequestBus.Event.GetNumObjectivesCannotFastTravel(playerEntityId)
        if numMissionsAbandonedOnFastTravel == 0 then
          PlayerHousingClientRequestBus.Broadcast.RequestFastTravelToTerritory(self.homePointTerritoryId, true, false)
        else
          do
            local confirmAbandonText = GetLocalizedReplacementText("@ui_fast_travel_mission_abandon_confirm", {count = numMissionsAbandonedOnFastTravel})
            local abandonMissionsId = "HousingFastTravelAbandon"
            popupWrapper:RequestPopup(ePopupButtons_YesNo, "@owg_action_abandon", confirmAbandonText, abandonMissionsId, self, function(self, result, eventId)
              if eventId == abandonMissionsId and result == ePopupResult_Yes then
                PlayerHousingClientRequestBus.Broadcast.RequestFastTravelToTerritory(self.homePointTerritoryId, true, false)
              end
            end)
          end
        end
      end
      LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
    end
  elseif eventId == self.mPopupQuitToDesktopEventId then
    if result == ePopupResult_Yes then
      GameRequestsBus.Broadcast.RequestDisconnect(eExitGameDestination_Desktop)
    end
  elseif eventId == self.mPopupQuitToMainMenuEventId then
    if result == ePopupResult_Yes then
      GameRequestsBus.Broadcast.RequestDisconnect(eExitGameDestination_MainMenu)
    end
  elseif eventId == self.mPopupProceedToNewWorldEventId then
    if result == ePopupResult_Yes then
      GameRequestsBus.Broadcast.ProceedToNewWorld(true)
    end
  elseif eventId == self.mLeaveOutpostRushId and result == ePopupResult_Yes then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    GameModeParticipantComponentRequestsBus.Event.SendClientEvent(playerEntityId, 2612035792)
    LyShineManagerBus.Broadcast.SetState(2702338936)
  end
end
function EscapeMenu:SetButtonEnabled(entityId, isEnabled, insertBeforeEntityId)
  if isEnabled then
    if UiElementBus.Event.GetParent(entityId) == self.Properties.DisabledContainer then
      UiElementBus.Event.Reparent(entityId, self.Properties.ButtonContainer, insertBeforeEntityId)
    end
    return entityId
  elseif UiElementBus.Event.GetParent(entityId) == self.Properties.ButtonContainer then
    UiElementBus.Event.Reparent(entityId, self.Properties.DisabledContainer, EntityId())
  end
  return insertBeforeEntityId
end
function EscapeMenu:OnSubmitFeedbackPressed()
  LyShineDataLayerBus.Broadcast.SetData("UserFeedback.InvokedFrom", "@ui_feedback_general")
end
function EscapeMenu:OnHelpPressed()
  OptionsDataBus.Broadcast.OpenHelpInBrowser()
end
function EscapeMenu:OnResumePressed(entityId, actionName)
  LyShineManagerBus.Broadcast.SetState(2702338936)
  self.audioHelper:PlaySound(self.audioHelper.OnHover)
end
function EscapeMenu:OnQuitPressed(entityId, actionName)
  local showExitSurvey = true
  DynamicBus.PopupScreenRequestsBus.Broadcast.ShowQuitGamePopup(ePopupButtons_YesNo, self.mQuitPopupTitle, self.mQuitDesktopPopupMessage, self.mPopupQuitToDesktopEventId, showExitSurvey)
  self.popUpHandler = UiPopupNotificationsBus.Connect(self, self.mPopupQuitToDesktopEventId)
end
function EscapeMenu:OnExitPressed(entityId, actionName)
  UiPopupBus.Broadcast.ShowQuitGamePopup(ePopupButtons_YesNo, self.mQuitPopupTitle, self.mQuitMainMenuPopupMessage, self.mPopupQuitToMainMenuEventId)
  self.popUpHandler = UiPopupNotificationsBus.Connect(self, self.mPopupQuitToMainMenuEventId)
end
function EscapeMenu:OnRespawnPressed(entityId, actionName)
  local popupTitle, popupMessage
  local buttonStyle = ePopupButtons_YesNo
  if self.isInDungeon then
    local dungeonWillClose = true
    popupTitle = "@ui_exit_dungeon_title"
    popupMessage = dungeonWillClose and "@ui_exit_dungeon_will_close_desc" or "@ui_exit_dungeon_desc"
    local isInCombat = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CombatStatus.IsInCombat")
    local inCombatDurationSeconds = -1
    if isInCombat then
      inCombatDurationSeconds = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CombatStatus.InCombatTimePoint"):Subtract(TimePoint:Now()):ToSeconds()
      popupTitle = "@ui_quitpopup_incombat_title"
      popupMessage = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_exit_dungeon_incombat", timeHelpers:ConvertSecondsToHrsMinSecString(inCombatDurationSeconds))
      buttonStyle = ePopupButtons_OK
    end
  elseif self.isInArena then
    popupTitle = "@ui_exit_arena_title"
    popupMessage = "@ui_exit_arena_desc"
  elseif self.isInDuel then
    popupTitle = "@ui_duel_forfeit_title"
    popupMessage = "@ui_duel_forfeit_confirm"
  elseif self.homePointTerritoryId ~= 0 then
    local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.homePointTerritoryId)
    if self.isHomePointAnInn then
      popupTitle = self.mRecallToInnPopupTitle
      popupMessage = GetLocalizedReplacementText(self.mRecallToInnPopupMessage, {territoryName = territoryName})
    else
      popupTitle = self.mRecallToWatchtowerPopupTitle
      popupMessage = GetLocalizedReplacementText(self.mRecallToWatchtowerPopupMessage, {territoryName = territoryName})
    end
  end
  if popupTitle then
    popupWrapper:RequestPopup(buttonStyle, popupTitle, popupMessage, self.mPopupRespawnEventId, self, self.OnPopupResult)
  end
end
function EscapeMenu:OnUnstuckPressed(entityId, actionName)
  LocalPlayerComponentRequestBus.Broadcast.RequestUnstuck()
end
function EscapeMenu:OnDefectReporterPressed(entityId, actionName)
  if self.dataLayer:GetDataNode("UIFeatures.g_uiEnableDefectReporter"):GetData() == true then
    CloudGemDefectReporterRequestBus.Broadcast.TriggerUserReportEditing()
  end
end
function EscapeMenu:OnProceedToNewWorldPressed(entityId, actionName)
  UiPopupBus.Broadcast.ShowQuitGamePopup(ePopupButtons_YesNo, self.mPopupProceedToNewWorldTitle, self.mPopupProceedToNewWorldMessage, self.mPopupProceedToNewWorldEventId)
  self.popUpHandler = UiPopupNotificationsBus.Connect(self, self.mPopupProceedToNewWorldEventId)
end
function EscapeMenu:OnLeaveOutpostRush(entityId, actionName)
  local modeEntityId = GameModeParticipantComponentRequestBus.Event.GetGameModeEntityId(self.rootPlayerId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  local penaltyInSeconds = GameModeComponentRequestBus.Event.GetGameModeRejoinPenaltyTimeSec(modeEntityId)
  local description = "@ui_outpost_rush_leave_desc"
  if 0 < penaltyInSeconds then
    local timeRemainingString = timeHelpers:ConvertToTwoLargestTimeEstimate(penaltyInSeconds, false)
    description = GetLocalizedReplacementText("@ui_outpost_rush_leave_desc_time", {time = timeRemainingString})
  end
  UiPopupBus.Broadcast.ShowQuitGamePopup(ePopupButtons_YesNo, "@ui_outpost_rush_leave_title", description, self.mLeaveOutpostRushId)
  self.popUpHandler = UiPopupNotificationsBus.Connect(self, self.mLeaveOutpostRushId)
end
function EscapeMenu:OnAbilityStarted()
  self.isChanneling = true
  self.ButtonRespawn:SetEnabled(not self.isChanneling)
end
function EscapeMenu:OnAbilityEnded()
  self.isChanneling = false
  self.ButtonRespawn:SetEnabled(not self.isChanneling)
end
return EscapeMenu
