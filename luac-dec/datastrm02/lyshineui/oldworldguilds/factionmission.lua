local FactionMission = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    },
    InfluenceText = {
      default = EntityId()
    },
    InfluenceIcon = {
      default = EntityId()
    },
    TokensText = {
      default = EntityId()
    },
    TokensIcon = {
      default = EntityId()
    },
    WarInfluenceText = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    },
    BottomContainer = {
      default = EntityId()
    },
    TimeText = {
      default = EntityId()
    },
    TimeLabel = {
      default = EntityId()
    },
    InProgress = {
      default = EntityId()
    },
    InProgressEffect = {
      default = EntityId()
    },
    RewardContainer = {
      default = EntityId()
    },
    CompleteContainer = {
      default = EntityId()
    },
    CompleteEffect = {
      default = EntityId()
    },
    UnavailableContainer = {
      default = EntityId()
    },
    AvailableContainer = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    HoverHash = {
      default = EntityId()
    },
    ActionText = {
      default = EntityId()
    },
    ActionButtonGlow = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    },
    InnerFrame = {
      default = EntityId()
    }
  },
  STATE_AVAILABLE = 0,
  STATE_ACTIVE = 1,
  STATE_CANCOMPLETE = 2,
  STATE_COMPLETE = 3,
  STATE_CANREPLACE = 4,
  guildIdToFaction = {
    [1459346962] = eFactionType_Faction1,
    [1410032581] = eFactionType_Faction2,
    [4109074679] = eFactionType_Faction3
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FactionMission)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local ObjectivesDataHandler = RequireScript("LyShineUI._Common.ObjectivesDataHandler")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
function FactionMission:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.influenceEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-territory-faction-influence")
  self.isEnabled = true
end
function FactionMission:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
  if self.glowTimeline ~= nil then
    self.glowTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.glowTimeline)
  end
end
function FactionMission:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function FactionMission:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function FactionMission:GetHorizontalSpacing()
  return 15
end
function FactionMission:SetMissionData(owGuildId, objectiveParams)
  self.owGuildId = owGuildId
  if not objectiveParams then
    self.isEnabled = false
    UiElementBus.Event.SetIsEnabled(self.Properties.UnavailableContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.AvailableContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.InProgress, false)
    return
  end
  local faction = self.guildIdToFaction[self.owGuildId]
  local reputationImagePath = "lyshineui/images/icons/objectives/reward_factionreputation" .. tostring(faction) .. ".dds"
  UiImageBus.Event.SetSpritePathname(self.Properties.InfluenceIcon, reputationImagePath)
  local tokensImagePath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(faction) .. ".dds"
  UiImageBus.Event.SetSpritePathname(self.Properties.TokensIcon, tokensImagePath)
  local taskData = TerritoryDataHandler:GetGoalDataFromObjectiveParams(objectiveParams, true)
  local objectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveData(taskData.missionObjectiveId)
  taskData.objectiveData = objectiveData
  function taskData:GetFactionStanding()
    local successRewardData = ObjectiveDataHelper:GetGameEventDataWithObjectiveRewardData(self:GetSuccessRewardId(), Math.CreateCrc32(self.objectiveData.id))
    local modifiers = GameEventRequestBus.Broadcast.GetFactionControlModifiers(eFactionControlBufType_Rewards_FactionMission_Modifier)
    return tostring(math.floor(successRewardData.factionReputation * modifiers.categoricalProgressionRewardModifier))
  end
  function taskData:GetFactionTokens()
    local successRewardData = ObjectiveDataHelper:GetGameEventDataWithObjectiveRewardData(self:GetSuccessRewardId(), Math.CreateCrc32(self.objectiveData.id))
    local modifiers = GameEventRequestBus.Broadcast.GetFactionControlModifiers(eFactionControlBufType_Rewards_FactionMission_Modifier)
    return tostring(math.floor(successRewardData.factionTokens * modifiers.categoricalProgressionRewardModifier))
  end
  taskData.playerEntityId = self.playerEntityId
  function taskData:IsInProgress()
    return ObjectivesComponentRequestBus.Event.HasObjectiveInstanceId(self.playerEntityId, self.objectiveInstanceId)
  end
  taskData.isInfluenceEnabled = self.influenceEnabled
  function taskData:IsAvailable()
    if not self.isInfluenceEnabled and self.isPvpMission then
      return false
    end
    return self.objectiveParams.available
  end
  self:SetTaskData(taskData)
end
function FactionMission:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
end
function FactionMission:SetTaskData(taskData, callbackSelf, taskStartCallback, taskCompleteCallback, taskCancelCallback)
  self.callbackSelf = callbackSelf
  self.taskStartCallback = taskStartCallback
  self.taskCompleteCallback = taskCompleteCallback
  self.taskCancelCallback = taskCancelCallback
  self.taskData = taskData
  if taskData then
    local isAvailable = taskData:IsAvailable()
    local isInProgress = taskData:IsInProgress()
    local isReadyToComplete = taskData:IsReadyToComplete()
    UiTextBus.Event.SetTextWithFlags(self.Properties.InfluenceText, taskData:GetFactionStanding(), eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TokensText, taskData:GetFactionTokens(), eUiTextSet_SetAsIs)
    self.canGainInfluence = false
    if self.Properties.WarInfluenceText:IsValid() then
      local faction = self.guildIdToFaction[self.owGuildId]
      local factionStyles = factionCommon.factionInfoTable[faction]
      UiTextBus.Event.SetTextWithFlags(self.Properties.WarInfluenceText, taskData:GetFactionWarInfluence(), eUiTextSet_SetAsIs)
      UiTextBus.Event.SetColor(self.Properties.WarInfluenceText, factionStyles.crestBgColor)
      UiImageBus.Event.SetSpritePathname(self.Properties.FactionIcon, factionStyles.crestFgSmall)
      UiImageBus.Event.SetColor(self.Properties.FactionIcon, factionStyles.crestBgColor)
      self.canGainInfluence = taskData:GetFactionWarInfluence() ~= ""
      UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, self.canGainInfluence)
      UiLayoutCellBus.Event.SetTargetWidth(self.Properties.FactionIcon, self.canGainInfluence and 32 or 0)
      local containerPadding = UiLayoutRowBus.Event.GetPadding(self.Properties.BottomContainer)
      containerPadding.right = self.canGainInfluence and 30 or 0
      UiLayoutRowBus.Event.SetPadding(self.Properties.BottomContainer, containerPadding)
    end
    local faction = self.guildIdToFaction[self.owGuildId]
    self.faction = faction
    local influenceIconSize = 32
    local spacing = 14
    local influenceTextSize = UiTextBus.Event.GetTextSize(self.Properties.InfluenceText).x
    local warInfluenceTextSize = 0
    if self.Properties.WarInfluenceText:IsValid() then
      warInfluenceTextSize = spacing + UiTextBus.Event.GetTextSize(self.Properties.WarInfluenceText).x
    end
    local totalTextSize = 2 * (influenceIconSize + influenceTextSize + spacing) - 11
    if self.canGainInfluence then
      totalTextSize = spacing + totalTextSize + spacing + warInfluenceTextSize + 11
    end
    local centeredPos = totalTextSize / 2
    UiElementBus.Event.SetIsEnabled(self.Properties.CompleteContainer, isReadyToComplete)
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardContainer, not isReadyToComplete)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, taskData.image)
    if taskData:GetTypeDisplayName() == "@ui_gather" then
      self.ScriptedEntityTweener:Set(self.Properties.Icon, {
        w = 338,
        h = 168,
        y = 90
      })
    else
      self.ScriptedEntityTweener:Set(self.Properties.Icon, {
        w = 282,
        h = 364,
        y = 0
      })
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, taskData.title, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Description, taskData.description, eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.InProgress, isInProgress)
    if isInProgress and not isReadyToComplete then
      UiElementBus.Event.SetIsEnabled(self.Properties.InProgressEffect, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.CompleteEffect, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ActionText, "@ui_cancel_mission", eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.ActionText, true)
    elseif isReadyToComplete then
      UiElementBus.Event.SetIsEnabled(self.Properties.CompleteEffect, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.InProgressEffect, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ActionText, "@ui_complete", eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.ActionText, true)
    elseif isAvailable then
      UiElementBus.Event.SetIsEnabled(self.Properties.CompleteEffect, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ActionText, "@ui_start_mission", eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.ActionText, true)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.ActionText, false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.UnavailableContainer, not isAvailable and not isInProgress)
    UiElementBus.Event.SetIsEnabled(self.Properties.AvailableContainer, isAvailable or isReadyToComplete or isInProgress)
    UiElementBus.Event.SetIsEnabled(self.Properties.InProgress, isInProgress)
    if not isAvailable and not isInProgress and not isReadyToComplete then
      self.isEnabled = false
    else
      self.isEnabled = true
    end
    local difficultyText = taskData.groupSize > 1 and "@ui_group" or "@ui_solo"
    local difficultyLabel = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@objective_difficulty_label")
    local difficultyTextFormatted = "<font face=\"lyshineui/fonts/nimbus_semibold.font\">" .. difficultyLabel .. "</font> " .. "<font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_WHITE) .. ">" .. difficultyText .. "</font>"
    local location = taskData:GetPoiDestinationDisplayName()
    local enemyRangeStr = taskData:GetEnemyLevelRange()
    local distanceStr = taskData:GetDestinationDistance()
    self.detailsList = {
      difficultyText = difficultyTextFormatted,
      location = location,
      enemyRangeStr = enemyRangeStr,
      distanceStr = distanceStr
    }
  end
end
function FactionMission:OnFocus()
  if not self.isEnabled then
    return
  end
  if not self.taskData then
    return
  end
  self:ShowFlyoutMenu()
  if self.taskData:IsAvailable() or self.taskData:IsInProgress() then
    self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0}, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.Icon, 0.1, {opacity = 1}, {opacity = 0.5})
    UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TokensText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, false)
    self.audioHelper:PlaySound(self.audioHelper.Screen_TerritoryStandingHover)
    if not self.timeline then
      self.timeline = self.ScriptedEntityTweener:TimelineCreate()
      self.timeline:Add(self.Properties.HoverHash, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
      self.timeline:Add(self.Properties.HoverHash, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
      self.timeline:Add(self.Properties.HoverHash, self.UIStyle.DURATION_TIMELINE_HOLD, {
        opacity = 1,
        onComplete = function()
          self.timeline:Play()
        end
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.HoverHash, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.HoverHash, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = 1,
      delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
      onComplete = function()
        self.timeline:Play()
      end
    })
    if not self.glowTimeline then
      self.glowTimeline = self.ScriptedEntityTweener:TimelineCreate()
      self.glowTimeline:Add(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
      self.glowTimeline:Add(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
      self.glowTimeline:Add(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
        opacity = 1,
        onComplete = function()
          self.glowTimeline:Play()
        end
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ActionButtonGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = 1,
      delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
      onComplete = function()
        self.glowTimeline:Play()
      end
    })
  end
end
function FactionMission:OnUnfocus()
  if not self.taskData then
    return
  end
  if self.taskData:IsAvailable() or self.taskData:IsInProgress() then
    self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 1}, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.Properties.Icon, 0.1, {opacity = 0.5}, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.Divider, {y = 270})
    self.ScriptedEntityTweener:Play(self.Properties.ActionButtonGlow, 0.1, {opacity = 0})
    UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TokensText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, self.canGainInfluence)
    self.ScriptedEntityTweener:Play(self.Properties.HoverHash, 0.1, {opacity = 0, ease = "QuadIn"})
  end
end
function FactionMission:OnClick()
  if not self.isEnabled or not self.taskData then
    return
  end
  local isInProgress = self.taskData:IsInProgress()
  local isAvailable = self.taskData:IsAvailable()
  local isReadyToComplete = self.taskData:IsReadyToComplete()
  if isInProgress and not isReadyToComplete then
    self:OnCancelMission()
  elseif isReadyToComplete then
    self:OnCompleteMission()
  elseif isAvailable then
    self:OnStartMission()
  end
  self.ScriptedEntityTweener:Play(self.entityId, 0.05, {
    scaleX = 0.9,
    scaleY = 0.9,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut",
    delay = 0.05
  })
  UiElementBus.Event.SetIsEnabled(self.Properties.Glow, true)
  self.ScriptedEntityTweener:Play(self.Properties.Glow, 1, {
    scaleX = 1,
    scaleY = 1,
    opacity = 1
  }, {
    scaleX = 1.5,
    scaleY = 1.5,
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.Glow, false)
    end
  })
  self.ScriptedEntityTweener:Set(self.Properties.Hover, {opacity = 0})
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  self:OnUnfocus()
end
function FactionMission:RequestPvpMissionSelection()
  ObjectiveInteractorRequestBus.Broadcast.RequestPvpMissionSelection(self.taskData.missionId)
end
function FactionMission:OnStartMission(data)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local canRequest = ObjectivesComponentRequestBus.Event.HasRoomForObjectiveType(playerEntityId, eObjectiveType_Mission)
  if not canRequest then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_objective_type_full"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  if self.taskData.isPvpMission then
    local result = ObjectiveInteractorRequestBus.Broadcast.CanSelectPvpMission(self.taskData.missionId)
    if result == eCanSelectPvpMissionResults_Success then
      local isPvpEnabled = FactionRequestBus.Event.IsPvpFlaggedOrPending(playerEntityId)
      if not isPvpEnabled then
        do
          local popupId = "accept_pvp_mission"
          PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@owg_pvp_acceptmission_title", "@owg_pvp_acceptmission_prompt", popupId, self, function(self, result, eventId)
            if eventId ~= popupId then
              return
            end
            if result == ePopupResult_Yes then
              self:RequestPvpMissionSelection()
            end
          end)
        end
      else
        self:RequestPvpMissionSelection()
      end
    else
      local popupId = "accept_pvp_mission_blocked"
      local message
      if result == eConversationResponseType_PvPFlag_IsInGroup then
        message = "@owg_pvp_cannotacceptmission_ingroup"
      elseif result == eConversationResponseType_PvPFlag_HasPendingNewGroupInvite then
        message = "@owg_pvp_cannotacceptmission_pendinggroupinvite"
      elseif result == eConversationResponseType_PvPFlag_NotInAFaction then
        message = "@owg_pvp_cannotacceptmission_nofaction"
      elseif result == eConversationResponseType_PvPFlag_NotInASanctuary then
        message = "@owg_pvp_cannotacceptmission_nosanctuary"
      elseif result == eConversationResponseType_MissionTypeBlocked then
        message = "@owg_pvp_cannotacceptmission_typeblocked"
      else
        message = "@owg_pvp_cannotacceptmission_unknown"
      end
      PopupWrapper:RequestPopup(ePopupButtons_OK, "@owg_pvp_cannotacceptmission_title", message, popupId)
    end
  else
    ObjectiveInteractorRequestBus.Broadcast.RequestMissionSelectionById(self.taskData.missionId)
  end
end
function FactionMission:OnCancelMission(data)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local popupId = "abandonMission"
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@owg_action_abandon", "@owg_abandonpopup_body", popupId, self, function(self, result, eventId)
    if popupId ~= eventId then
      return
    end
    if result == ePopupResult_Yes and self.taskData then
      ObjectivesComponentRequestBus.Event.AbandonObjective(self.playerEntityId, self.taskData.objectiveInstanceId)
      self.taskData = nil
    end
  end)
end
function FactionMission:OnCompleteMission(data)
  if self.canGainInfluence then
    DynamicBus.OWGDynamicRequestBus.Broadcast.OnInfluenceFactionMissionTurnedIn()
  end
  ObjectiveInteractorRequestBus.Broadcast.RequestMissionCompletion(self.taskData.objectiveInstanceId)
  self.taskData = nil
end
function FactionMission:ShowFlyoutMenu()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu:IsLocked() then
    return
  end
  local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
  if flyoutVisible and flyoutMenu.invokingEntityId == self.entityId then
    return
  end
  local rows = {}
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_FactionMission,
    task = self.taskData,
    detailsList = self.detailsList,
    faction = self.faction,
    callbackSelf = self,
    callbackOnCancel = self.OnCancelMission,
    callbackOnStart = self.OnStartMission,
    callbackOnComplete = self.OnCompleteMission
  })
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:EnableFlyoutDelay(false)
  flyoutMenu:SetFadeInTime(0.1)
  flyoutMenu:SetOpenLocation(self.entityId)
  flyoutMenu:DockToCursor(10)
  flyoutMenu:Unlock()
  flyoutMenu:SetRowData(rows)
  flyoutMenu:SetSourceHoverOnly(true)
  flyoutMenu.openingContext = nil
end
return FactionMission
