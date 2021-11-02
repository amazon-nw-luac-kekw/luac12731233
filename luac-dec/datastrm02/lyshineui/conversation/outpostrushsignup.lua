local OutpostRushSignUp = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    GameModeIcon = {
      default = EntityId()
    },
    JoinFlow = {
      Panel = {
        default = EntityId(),
        order = 1
      },
      JoinSoloButton = {
        default = EntityId()
      },
      JoinGroupButton = {
        default = EntityId()
      },
      PenaltyTimer = {
        default = EntityId()
      },
      PenaltyIcon = {
        default = EntityId()
      }
    },
    QueuedFlow = {
      Panel = {
        default = EntityId(),
        order = 1
      },
      ElapsedTime = {
        default = EntityId()
      },
      ExitScreenButton = {
        default = EntityId()
      },
      LeaveQueueButton = {
        default = EntityId()
      },
      Rune1 = {
        default = EntityId()
      },
      Rune2 = {
        default = EntityId()
      },
      Rune3 = {
        default = EntityId()
      }
    }
  },
  LOCK_ICON = "lyshineui/images/conversation/outpostrush/iconlock.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OutpostRushSignUp)
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function OutpostRushSignUp:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    if self.playerEntityId then
      local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
      self.requiredLevel = gameModeData.requiredLevel
      if gameModeData.iconPath then
        UiImageBus.Event.SetSpritePathname(self.Properties.GameModeIcon, gameModeData.iconPath)
      end
    end
  end)
  self:SetVisualElements()
end
function OutpostRushSignUp:SetVisualElements()
  self.ScreenHeader:SetText("@Topic_Prompt_Join_Outpost_Rush")
  self.ScreenHeader:SetHintCallback(self.OnExit, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  self.JoinFlow.JoinSoloButton:SetText("@ui_outpost_rush_signup_joinsolo")
  self.JoinFlow.JoinSoloButton:SetCallback(self.OnJoinSolo, self)
  self.JoinFlow.JoinGroupButton:SetText("@ui_outpost_rush_signup_joingroup")
  self.JoinFlow.JoinGroupButton:SetCallback(self.OnJoinGroup, self)
  self.QueuedFlow.ExitScreenButton:SetText("@ui_exit")
  self.QueuedFlow.ExitScreenButton:SetCallback(self.OnExit, self)
  self.QueuedFlow.LeaveQueueButton:SetText("@ui_outpost_rush_signup_leave_queue")
  self.QueuedFlow.LeaveQueueButton:SetCallback(self.OnLeaveQueue, self)
end
function OutpostRushSignUp:SetRunesActive(isActive)
  if isActive then
    local animDuration = 60
    self.ScriptedEntityTweener:Play(self.Properties.QueuedFlow.Rune1, animDuration, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:Play(self.Properties.QueuedFlow.Rune2, animDuration, {rotation = 0}, {timesToPlay = -1, rotation = -359})
    self.ScriptedEntityTweener:Play(self.Properties.QueuedFlow.Rune3, animDuration, {rotation = 0}, {timesToPlay = -1, rotation = -359})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.QueuedFlow.Rune1)
    self.ScriptedEntityTweener:Stop(self.Properties.QueuedFlow.Rune2)
    self.ScriptedEntityTweener:Stop(self.Properties.QueuedFlow.Rune3)
  end
end
function OutpostRushSignUp:DisableButtons()
  self.JoinFlow.JoinSoloButton:SetEnabled(false)
  self.JoinFlow.JoinGroupButton:SetEnabled(false)
  self.QueuedFlow.LeaveQueueButton:SetEnabled(true)
end
function OutpostRushSignUp:UpdateElements()
  local buttonStyle = self.canJoinSolo and self.JoinFlow.JoinSoloButton.BUTTON_STYLE_CTA or self.JoinFlow.JoinSoloButton.BUTTON_STYLE_BLOCKED
  self.JoinFlow.JoinSoloButton:SetButtonStyle(buttonStyle)
  self.JoinFlow.JoinSoloButton:SetEnabled(self.canJoinSolo)
  if self.isInAnyQueue then
    self.JoinFlow.JoinSoloButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinSoloButton:SetTooltip("@ui_outpost_rush_signup_failqueue")
  elseif self.isInGroup then
    self.JoinFlow.JoinSoloButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinSoloButton:SetTooltip("@ui_outpost_rush_signup_failsolo")
  elseif self.hasPendingInvite then
    self.JoinFlow.JoinSoloButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinSoloButton:SetTooltip("@ui_outpost_rush_signup_failgroupinvite")
  elseif self.isInImminentWar then
    self.JoinFlow.JoinSoloButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinSoloButton:SetTooltip("@ui_outpost_rush_signup_failwar")
  elseif self.isInDungeonQueue then
    self.JoinFlow.JoinSoloButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinSoloButton:SetTooltip("@ui_outpost_rush_signup_faildungeon")
  elseif self.playerLevel < self.requiredLevel then
    self.JoinFlow.JoinSoloButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinSoloButton:SetTooltip(GetLocalizedReplacementText("@ui_outpost_rush_signup_faillevel", {
      levelRequirement = tostring(self.requiredLevel)
    }))
  else
    self.JoinFlow.JoinSoloButton:SetIconPath()
    self.JoinFlow.JoinSoloButton:SetTooltip("")
  end
  buttonStyle = self.canJoinGroup and self.JoinFlow.JoinGroupButton.BUTTON_STYLE_DEFAULT or self.JoinFlow.JoinGroupButton.BUTTON_STYLE_BLOCKED
  self.JoinFlow.JoinGroupButton:SetButtonStyle(buttonStyle)
  self.JoinFlow.JoinGroupButton:SetEnabled(self.canJoinGroup)
  if self.isInDungeonQueue then
    self.JoinFlow.JoinGroupButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinGroupButton:SetTooltip("@ui_outpost_rush_signup_faildungeon")
  elseif not self.isInGroup then
    self.JoinFlow.JoinGroupButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinGroupButton:SetTooltip("@ui_outpost_rush_signup_failgroup")
  elseif self.isInAnyQueue then
    self.JoinFlow.JoinGroupButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinGroupButton:SetTooltip("@ui_outpost_rush_signup_failqueue")
  elseif self.hasPendingInvite then
    self.JoinFlow.JoinGroupButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinGroupButton:SetTooltip("@ui_outpost_rush_signup_failgroupinvite")
  elseif self.isInImminentWar then
    self.JoinFlow.JoinGroupButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinGroupButton:SetTooltip("@ui_outpost_rush_signup_failwar")
  elseif self.playerLevel < self.requiredLevel then
    self.JoinFlow.JoinGroupButton:SetIconPath(self.LOCK_ICON)
    self.JoinFlow.JoinGroupButton:SetTooltip(GetLocalizedReplacementText("@ui_outpost_rush_signup_faillevel", {
      levelRequirement = tostring(self.requiredLevel)
    }))
  else
    self.JoinFlow.JoinGroupButton:SetIconPath()
    self.JoinFlow.JoinGroupButton:SetTooltip()
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.JoinFlow.PenaltyTimer, self.isPenalized)
  self.QueuedFlow.ExitScreenButton:SetEnabled(true)
  self.QueuedFlow.LeaveQueueButton:SetEnabled(true)
  UiElementBus.Event.SetIsEnabled(self.Properties.JoinFlow.Panel, not self.isInOutpostRushQueue)
  UiElementBus.Event.SetIsEnabled(self.Properties.QueuedFlow.Panel, self.isInOutpostRushQueue)
end
function OutpostRushSignUp:GatherPlayerInformation()
  if self.playerEntityId then
    self.playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
    self.localPlayerGroupId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
    PopupWrapper:KillPopup("OR_GROUP_POPUP")
    self.isInAnyQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForAnyGameMode(self.playerEntityId)
    self.isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
    self.isInImminentWar = TerritoryInteractorRequestBus.Event.IsSignedUpForImminentWar(self.playerEntityId)
    self.isInDungeonQueue = false
    if self.groupBusHandler and self.groupId:IsValid() then
      local dungeonState = GroupDataRequestBus.Event.GetGroupDungeonInstanceState(self.groupId)
      if dungeonState == DungeonInstanceState_Queued or dungeonState == DungeonInstanceState_WaitingEntry then
        self.isInDungeonQueue = true
      end
    end
    local eligibility = GameModeParticipantComponentRequestBus.Event.GetGameModeQueueEligibility(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH, false)
    self.joinQueueTime = GameModeParticipantComponentRequestBus.Event.GetQueueJoinTimeForGameMode(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
    self.penaltyEndTime = GameModeParticipantComponentRequestBus.Event.GetQueueEligibleTimeForGameMode(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
    self.isPenalized = eligibility == eGameModeQueueEligibilityReason_Ineligible_Rejoin_Penalty
    self.hasPendingInvite = eligibility == eGameModeQueueEligibilityReason_Ineligible_Group_Invite
    self.elapsedQueueTime = 0
    self.remainingPenaltyTime = 0
    self.waitingForQueueResponse = false
    local isEligible = eligibility == eGameModeQueueEligibilityReason_Eligible
    self.isInGroup = self.localPlayerGroupId and self.localPlayerGroupId:IsValid()
    self.canJoinSolo = isEligible and not self.isInGroup and not self.isInDungeonQueue
    self.canJoinGroup = isEligible and self.isInGroup and not self.isInDungeonQueue
    self:UpdateElements()
    if self.isInOutpostRushQueue or self.isPenalized then
      if not self.tickHandler then
        self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
      end
    elseif self.tickHandler then
      self:BusDisconnect(self.tickHandler)
      self.tickHandler = nil
    end
  end
end
function OutpostRushSignUp:Show(cancelCallback, cancelCallbackTable)
  self.callback = cancelCallback
  self.callingTable = cancelCallbackTable
  if self.playerEntityId then
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
      if self.groupId and groupId == self.groupId then
        return
      end
      self.groupId = groupId
      if self.groupBusHandler then
        self:BusDisconnect(self.groupBusHandler)
        self.groupBusHandler = nil
      end
      if self.groupId and self.groupId:IsValid() then
        self.groupBusHandler = self:BusConnect(GroupDataNotificationBus, self.groupId)
      end
      self:GatherPlayerInformation()
    end)
    self.gameModeHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, self.playerEntityId)
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self:SetRunesActive(true)
  else
    self:OnExit()
  end
end
function OutpostRushSignUp:Hide()
  if self.gameModeHandler then
    self:BusDisconnect(self.gameModeHandler)
    self.gameModeHandler = nil
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self:SetRunesActive(false)
end
function OutpostRushSignUp:OnJoinSolo()
  local joinSuccessful = GameModeParticipantComponentRequestBus.Event.JoinQueueForGameMode(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH, false)
  if joinSuccessful then
    self.waitingForQueueResponse = true
    self:DisableButtons()
  end
end
function OutpostRushSignUp:OnJoinGroup()
  PopupWrapper:RequestPopupWithParams({
    title = "@ui_outpost_rush_signup_joingroup",
    message = "@ui_outpost_rush_signup_joingroup_desc",
    eventId = "OR_GROUP_POPUP",
    callerSelf = self,
    callback = function(self, result, eventId)
      if result == ePopupResult_Yes then
        local joinSuccessful = GameModeParticipantComponentRequestBus.Event.JoinQueueForGameMode(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH, true)
        if joinSuccessful then
          self.waitingForQueueResponse = true
          self:DisableButtons()
        end
      end
    end,
    buttonsYesNo = true,
    yesButtonText = "@ui_outpost_rush_signup_joingroup_accept",
    noButtonText = "@ui_outpost_rush_signup_joingroup_cancel"
  })
end
function OutpostRushSignUp:OnExit()
  if not self.waitingForQueueResponse then
    if self.groupBusHandler then
      self:BusDisconnect(self.groupBusHandler)
      self.groupBusHandler = nil
    end
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Group.Id")
    self:Hide()
    self.callback(self.callingTable)
  end
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function OutpostRushSignUp:OnLeaveQueue()
  GameModeParticipantComponentRequestBus.Event.LeaveQueueForGameMode(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  self:OnExit()
end
function OutpostRushSignUp:OnMemberAdded(index, characterId, characterName, characterIcon, joinedNewGroup)
  self:GatherPlayerInformation()
end
function OutpostRushSignUp:OnMemberRemoved(index, characterId)
  self:GatherPlayerInformation()
end
function OutpostRushSignUp:OnJoinedQueueForGameMode(gameModeData)
  self:GatherPlayerInformation()
end
function OutpostRushSignUp:OnLeftQueueForGameMode(gameModeId)
  self:GatherPlayerInformation()
end
function OutpostRushSignUp:OnQueueForGameModeFailed(reason)
  local failMessage = "@ui_outpost_rush_signup_failgrouptimeout"
  if reason == eGameModeQueueEligibilityReason_Ineligible_Offline then
    failMessage = "@ui_outpost_rush_signup_failgroupoffline"
  elseif reason == eGameModeQueueEligibilityReason_Ineligible_Timeout then
    failMessage = "@ui_outpost_rush_signup_failgrouptimeout"
  elseif reason == eGameModeQueueEligibilityReason_Ineligible_Dead then
    failMessage = "@ui_outpost_rush_signup_failgroupdead"
  elseif reason == eGameModeQueueEligibilityReason_Ineligible_Level then
    failMessage = GetLocalizedReplacementText("@ui_outpost_rush_signup_failgrouplevel", {
      levelRequirement = tostring(self.requiredLevel)
    })
  elseif reason == eGameModeQueueEligibilityReason_Ineligible_Timeout then
    failMessage = "@ui_outpost_rush_signup_failgrouptimeout"
  elseif reason == eGameModeQueueEligibilityReason_Ineligible_Conflicting_Event then
    failMessage = "@ui_outpost_rush_signup_failgroupqueue"
  elseif reason == eGameModeQueueEligibilityReason_Ineligible_Rejoin_Penalty then
    failMessage = "@ui_outpost_rush_signup_failgrouppenalty"
  end
  PopupWrapper:RequestPopup(ePopupButtons_OK, "@ui_outpost_rush_signup_failgrouptitle", failMessage, "or_fail_id", self, function(self, result, eventId)
    self:GatherPlayerInformation()
  end)
end
function OutpostRushSignUp:OnQueueEligibleTimeChangedForGameMode(gameModeId, newTime)
  self:GatherPlayerInformation()
end
function OutpostRushSignUp:OnTick(deltaTime, timePoint)
  if self.isInOutpostRushQueue then
    local now = self.joinQueueTime:Now()
    local elapsedTime = now:Subtract(self.joinQueueTime):ToSeconds()
    if self.elapsedTime ~= elapsedTime then
      local timeText = GetLocalizedReplacementText("@ui_outpost_rush_signup_timer_prompt", {
        time = TimeHelpers:ConvertToShorthandString(elapsedTime, true)
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.QueuedFlow.ElapsedTime, timeText, eUiTextSet_SetLocalized)
      self.elapsedTime = elapsedTime
    end
  elseif self.isPenalized then
    local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
    local remainingTime = self.penaltyEndTime:Subtract(now):ToSeconds()
    if remainingTime <= 0 then
    elseif self.remainingPenaltyTime ~= remainingTime then
      local timeText = GetLocalizedReplacementText("@ui_outpost_rush_signup_penaltytimer", {
        time = TimeHelpers:ConvertToShorthandString(remainingTime, true)
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.JoinFlow.PenaltyTimer, timeText, eUiTextSet_SetLocalized)
      self.remainingPenaltyTime = remainingTime
    end
  end
end
function OutpostRushSignUp:OnShutdown()
  self:SetRunesActive(false)
end
return OutpostRushSignUp
