local ConversationScreen = {
  Properties = {
    DOFTweenDummyElement = {
      default = EntityId()
    },
    MainWindow = {
      default = EntityId()
    },
    Background = {
      default = EntityId()
    },
    HeaderBg = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    SubheaderText = {
      default = EntityId()
    },
    DialogueContainer = {
      default = EntityId()
    },
    BodyText = {
      default = EntityId()
    },
    BodyTextMask = {
      default = EntityId()
    },
    BodyTextContainer = {
      default = EntityId()
    },
    ButtonsCache = {
      default = EntityId()
    },
    ButtonsContainer = {
      default = EntityId()
    },
    ButtonsContent = {
      default = EntityId()
    },
    ButtonsScrollbox = {
      default = EntityId()
    },
    BigOption = {
      default = EntityId()
    },
    LeaveOption = {
      default = EntityId()
    },
    SimpleOptions = {
      default = {
        EntityId()
      }
    },
    ObjectiveDetails = {
      default = EntityId()
    },
    FactionInfoPanel = {
      default = EntityId()
    },
    FactionSelectionPanel = {
      default = EntityId()
    },
    FactionSelection1 = {
      default = EntityId()
    },
    FactionSelection2 = {
      default = EntityId()
    },
    FactionSelection3 = {
      default = EntityId()
    },
    FactionSelectionPopup = {
      Panel = {
        default = EntityId()
      },
      Title = {
        default = EntityId()
      },
      ConfirmButton = {
        default = EntityId()
      },
      CancelButton = {
        default = EntityId()
      },
      FactionCrest = {
        default = EntityId()
      }
    },
    OutpostRushPanel = {
      default = EntityId()
    },
    CelebrationSkipButton = {
      default = EntityId()
    },
    WhooshTweener = {
      default = EntityId()
    }
  },
  MAX_OPTIONS_HEIGHT = 350,
  targetDOFDistance = 15,
  nullCrc32 = 0,
  bodyTextMaskStartOffset = -160,
  celebrationAnimDuration = 3,
  contentFadeOutDuration = 0.2,
  rewardCelebrationPlayed = false,
  skipCelebration = false,
  NUM_DIALOGUE_OPTION_KEYS = 10,
  VOID_OVER_DELAY = 0.3,
  factionIdToName = {
    "@ui_faction_name1",
    "@ui_faction_name2",
    "@ui_faction_name3"
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
BaseScreen:CreateNewScreen(ConversationScreen)
function ConversationScreen:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(ConversationEventsBus, self.entityId)
  self.dataLayer:RegisterOpenEvent("ConversationScreen", self.canvasId)
  AdjustElementToCanvasSize(self.entityId, self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.factionInfoTable = FactionCommon.factionInfoTable
  self.FactionSelection1:SetupFactionOption(eFactionType_Faction1, self.SelectFaction, self)
  self.FactionSelection2:SetupFactionOption(eFactionType_Faction2, self.SelectFaction, self)
  self.FactionSelection3:SetupFactionOption(eFactionType_Faction3, self.SelectFaction, self)
  self.FactionSelectionPopup.CancelButton:SetText("@owg_faction_select_no")
  self.FactionSelectionPopup.ConfirmButton:SetCallback(self.ConfirmFaction, self)
  self.FactionSelectionPopup.CancelButton:SetCallback(self.CancelFaction, self)
  self.FactionInfoPanel:OnConfirmButton(self.WillShowFactionPopup, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", function(self, playerName)
    self.playerName = playerName
  end)
  self.voTag = nil
  SetTextStyle(self.Properties.HeaderText, self.UIStyle.FONT_STYLE_HEADER)
  SetTextStyle(self.Properties.SubheaderText, self.UIStyle.FONT_STYLE_SUBHEADER)
  SetTextStyle(self.Properties.BodyText, self.UIStyle.FONT_STYLE_DIALOGUE)
  self.LeaveOption:SetHint("toggleMenuComponent", true)
  self.rewardCelebrationPlayed = false
end
function ConversationScreen:GetFactionAlignmentLoc(factionType)
  local factionLoc = self.factionIdToName[factionType]
  factionLoc = factionLoc or "@ui_faction_unaligned"
  return factionLoc
end
function ConversationScreen:RequestConversationOption(optionType, optionId)
  local canRequest = true
  if optionType == eConversationOptionType_AcceptObjective then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    canRequest = ObjectivesComponentRequestBus.Event.HasRoomForObjective(playerEntityId, optionId)
    if not canRequest then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_objective_type_full"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end
  if canRequest then
    local isItemRewardShowing = self.ObjectiveDetails.isItemRewardShowing
    if optionType == eConversationOptionType_CompleteObjective and isItemRewardShowing then
      if self.interactEntityId ~= nil and self.voTag ~= nil then
        DynamicBus.npcDialogueBus.Event.OnDialogueStopped(self.interactEntityId, self.voTag)
      end
      self:SetConversationContentVisible(false)
      self.ObjectiveDetails:PlayRewardCelebration()
      local showAnimLength = self.ObjectiveDetails.showAnimLength
      self.ScriptedEntityTweener:PlayC(self.Properties.WhooshTweener, showAnimLength, tweenerCommon.scaleTo1, 0, function()
        if not self.skipCelebration then
          local playWhoosh = true
          self.ObjectiveDetails:HideCelebration(playWhoosh)
        end
      end)
      self.ScriptedEntityTweener:PlayC(self.Properties.WhooshTweener, self.celebrationAnimDuration, tweenerCommon.fadeInQuadOut, 0, function()
        self:SetConversationContentVisible(true)
      end)
      self.rewardCelebrationPlayed = true
      ConversationRequestBus.Broadcast.RequestConversationOption(optionType, optionId)
    else
      ConversationRequestBus.Broadcast.RequestConversationOption(optionType, optionId)
    end
  end
  if optionType == eConversationOptionType_ObjectiveDetails then
    self.audioHelper:PlaySound(self.audioHelper.ObjectiveDetails)
  elseif optionType == eConversationOptionType_AcceptObjective then
    self.audioHelper:PlaySound(self.audioHelper.AcceptObjective)
  elseif optionType == eConversationOptionType_ChooseFaction then
    self.audioHelper:PlaySound(self.audioHelper.ChooseFaction)
  elseif optionType == eConversationOptionType_CompleteObjective then
    self.audioHelper:PlaySound(self.audioHelper.CompleteObjective)
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_Objective_Completed)
  end
end
function ConversationScreen:ShowFactionSelection()
  self.FactionInfoPanel:StartTutorial(self.CancelFactionSelection, self)
  UiElementBus.Event.SetIsEnabled(self.Properties.MainWindow, false)
end
function ConversationScreen:CancelFactionSelection()
  self.FactionInfoPanel:StopTutorial()
  UiElementBus.Event.SetIsEnabled(self.Properties.MainWindow, true)
end
function ConversationScreen:SelectFaction(factionType)
  self.FactionSelection1:ClearSelected()
  self.FactionSelection2:ClearSelected()
  self.FactionSelection3:ClearSelected()
  self.selectedFaction = factionType
  self.FactionInfoPanel:EnableConfirmButton(true)
end
function ConversationScreen:WillShowFactionPopup()
  self:ShowFactionPopup(true)
end
function ConversationScreen:ShowFactionPopup(enabled)
  if enabled then
    local title = "@owg_faction_select_title"
    local confirmation = "@owg_faction_select_confirm"
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, title, confirmation, "confirmFactionPopup", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        self:ConfirmFaction()
      end
    end)
  end
end
function ConversationScreen:ConfirmFaction()
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Faction", self.OnUpdateFaction)
  self.FactionSelectionPopup.ConfirmButton:SetEnabled(false)
  self.FactionSelectionPopup.CancelButton:SetEnabled(false)
  FactionRequestBus.Event.RequestSetFaction(playerEntityId, self.selectedFaction)
end
function ConversationScreen:CancelFaction()
  self:ShowFactionPopup(false)
end
function ConversationScreen:OnUpdateFaction(data)
  self:RequestConversationOption(eConversationOptionType_RefreshConversation, self.nullCrc32)
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Faction")
  self:ShowFactionPopup(false)
  self:CancelFactionSelection()
end
function ConversationScreen:ShowOutpostRushSignUp()
  self.outpostRushPanelOpen = true
  UiElementBus.Event.SetIsEnabled(self.Properties.MainWindow, false)
  self.OutpostRushPanel:Show(self.CancelOutpostRushSignUp, self)
end
function ConversationScreen:CancelOutpostRushSignUp()
  self.outpostRushPanelOpen = false
  UiElementBus.Event.SetIsEnabled(self.Properties.MainWindow, true)
end
function ConversationScreen:GetAvailableOption()
  for _, option in pairs(self.SimpleOptions) do
    if not option.isVisible then
      return option
    end
  end
  Debug.Log("ConversationScreen:GetAvailableOption Warning: no more options available. Increase simple options cache.")
end
function ConversationScreen:ResetConversationOption(button)
  UiElementBus.Event.Reparent(button.entityId, self.ButtonsCache, EntityId())
  button:SetupConversationOption(nil)
end
function ConversationScreen:ReplaceBigOption(optionData, forceReplace, typeOverride)
  if self.BigOption.isVisible and self.BigOption.optionType == eConversationOptionType_ObjectiveDetails then
    local currentData = {
      optionType = self.BigOption.optionType,
      text = self.BigOption.optionText,
      dataId = self.BigOption.optionId
    }
    local optionButton = self:GetAvailableOption()
    if optionButton then
      optionButton:SetupConversationOption(currentData, self.RequestConversationOption, self, typeOverride)
    end
    self.BigOption:SetupConversationOption(nil)
  end
  if not self.BigOption.isVisible or forceReplace then
    self.BigOption:SetupConversationOption(optionData, self.RequestConversationOption, self, typeOverride)
    return true
  end
  return false
end
function ConversationScreen:OnConversationStateChange(stateData)
  self.stateData = stateData
  local numOptions = #stateData.options
  if (stateData.responseType == eConversationResponseType_Acceptance or stateData.responseType == eConversationResponseType_Completion) and (stateData.dialogue == nil or stateData.dialogue == "") then
    self:CloseScreen()
  elseif 0 < numOptions then
    local delayTime = self.rewardCelebrationPlayed and self.celebrationAnimDuration - self.contentFadeOutDuration or 0
    if self.skipCelebration then
      delayTime = 0
    end
    self.ScriptedEntityTweener:PlayC(self.Properties.CelebrationSkipButton, delayTime, tweenerCommon.scaleTo1, 0, function()
      self.interactEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.InteractEntityId")
      local currentLocText = stateData.dialogue
      self.voTag = LyShineScriptBindRequestBus.Broadcast.GetAttributeValueForKey(currentLocText, "VO")
      if self.voTag ~= nil then
        TimingUtils:StopDelay(self)
        TimingUtils:Delay(self.VOID_OVER_DELAY, self, function(self)
          local characterName = LyShineScriptBindRequestBus.Broadcast.GetAttributeValueForKey(currentLocText, "name")
          DynamicBus.npcDialogueBus.Event.OnDialogueTriggered(self.interactEntityId, self.voTag, characterName)
        end)
      end
      local npcFaction, npcTitle
      local npcName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.InteractName")
      local rootEntityId = TransformBus.Event.GetRootId(self.interactEntityId)
      if rootEntityId then
        local npcData = NpcComponentRequestBus.Event.GetNpcData(rootEntityId)
        if npcData then
          npcFaction = self:GetFactionAlignmentLoc(npcData.GetNpcFactionAlignment(npcData.id))
          if npcData.genericName and npcData.genericName ~= "" then
            npcName = npcData.genericName
          end
          if npcData.title and npcData.title ~= "" then
            npcTitle = npcData.title
          end
        end
      end
      UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, npcName, eUiTextSet_SetLocalized)
      if not npcTitle then
        UiElementBus.Event.SetIsEnabled(self.Properties.SubheaderText, false)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.HeaderText, 91)
        UiTextBus.Event.SetVerticalTextAlignment(self.Properties.HeaderText, self.UIStyle.TEXT_VALIGN_CENTER)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.SubheaderText, true)
        UiTextBus.Event.SetTextWithFlags(self.Properties.SubheaderText, npcTitle, eUiTextSet_SetLocalized)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.HeaderText, 62)
        UiTextBus.Event.SetVerticalTextAlignment(self.Properties.HeaderText, self.UIStyle.TEXT_VALIGN_BOTTOM)
      end
      local factionLoc = self:GetFactionAlignmentLoc(self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction"))
      local factionName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(factionLoc)
      local bodytext = GetLocalizedReplacementText(stateData.dialogue, {
        playerName = self.playerName,
        playerFaction = factionName,
        npcFaction = npcFaction
      })
      UiTextBus.Event.SetText(self.Properties.BodyText, bodytext)
      UiElementBus.Event.SetIsEnabled(self.Properties.BodyText, false)
      TimingUtils:DelayFrames(2, self, function()
        local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.BodyText)
        local bodyTextMaskStartPos = -textHeight / 2 + self.bodyTextMaskStartOffset
        local bodyTextMaskBuffer = 36
        local bodyTextMaskEndPos = textHeight / 2 + bodyTextMaskBuffer
        self.ScriptedEntityTweener:Play(self.Properties.BodyTextMask, 0.2, {y = bodyTextMaskStartPos}, {y = bodyTextMaskEndPos, ease = "Linear"})
        UiElementBus.Event.SetIsEnabled(self.Properties.BodyText, true)
      end)
      self:ResetConversationOption(self.BigOption)
      self:ResetConversationOption(self.LeaveOption)
      for _, option in pairs(self.SimpleOptions) do
        self:ResetConversationOption(option)
      end
      for i = 1, numOptions do
        local optionData = stateData.options[i]
        if optionData.optionType == eConversationOptionType_AcceptObjective or optionData.optionType == eConversationOptionType_CompleteObjective or optionData.optionType == eConversationOptionType_ChooseFaction or optionData.optionType == eConversationOptionType_ContinueDialogue then
          local typeOverride
          if optionData.optionType == eConversationOptionType_ContinueDialogue then
            if stateData.responseType == eConversationResponseType_Acceptance or stateData.responseType == eConversationResponseType_Proposal then
              typeOverride = eConversationOptionType_AcceptObjective
            elseif stateData.responseType == eConversationResponseType_Completion or stateData.responseType == eConversationResponseType_CompletionAvailable then
              typeOverride = eConversationOptionType_CompleteObjective
            end
          end
          if not self:ReplaceBigOption(optionData, optionData.optionType == eConversationOptionType_ContinueDialogue, typeOverride) then
            Debug.Log("ConversationScreen:OnConversationStateChange Error: attempted to show multiple big options in one conversation state at a time.")
          end
        elseif optionData.optionType == eConversationOptionType_ConversationTopic and optionData.dataId ~= stateData.dialogueId or optionData.optionType == eConversationOptionType_OpenFactionBoard or optionData.optionType == eConversationOptionType_OpenCommunityBoard or optionData.optionType == eConversationOptionType_OpenInn or optionData.optionType == eConversationOptionType_JoinOutpostRush or optionData.optionType == eConversationOptionType_RefreshConversation or optionData.optionType == eConversationOptionType_ObjectiveDetails and optionData.dataId ~= stateData.dialogueId and stateData.responseType ~= eConversationResponseType_CompletionAvailable then
          if not self.BigOption.isVisible and optionData.optionType == eConversationOptionType_ObjectiveDetails then
            self.BigOption:SetupConversationOption(optionData, self.RequestConversationOption, self)
          else
            local optionButton = self:GetAvailableOption()
            if optionButton then
              optionButton:SetupConversationOption(optionData, self.RequestConversationOption, self)
            end
          end
        elseif optionData.optionType == eConversationOptionType_Leave and not FtueSystemRequestBus.Broadcast.IsFtue() then
          self.LeaveOption:SetupConversationOption(optionData, self.RequestConversationOption, self)
          self.LeaveOption:SetIconPath("lyshineui/images/icons/misc/icon_exit.dds")
        end
      end
      local buttonIndex = 1
      if self.BigOption.isVisible then
        UiElementBus.Event.Reparent(self.Properties.BigOption, self.ButtonsContent, EntityId())
        self.BigOption:SetIndex(buttonIndex)
        buttonIndex = buttonIndex + 1
      end
      for _, option in pairs(self.SimpleOptions) do
        if option.isVisible and option.optionType == eConversationOptionType_ObjectiveDetails then
          UiElementBus.Event.Reparent(option.entityId, self.ButtonsContent, EntityId())
          option:SetIndex(buttonIndex)
          buttonIndex = buttonIndex + 1
        end
      end
      for _, option in pairs(self.SimpleOptions) do
        if option.isVisible and (option.optionType == eConversationOptionType_OpenFactionBoard or option.optionType == eConversationOptionType_OpenCommunityBoard or option.optionType == eConversationOptionType_OpenInn or option.optionType == eConversationOptionType_JoinOutpostRush or option.optionType == eConversationOptionType_RefreshConversation) then
          UiElementBus.Event.Reparent(option.entityId, self.ButtonsContent, EntityId())
          option:SetIndex(buttonIndex)
          buttonIndex = buttonIndex + 1
        end
      end
      if stateData.responseType ~= eConversationResponseType_Acceptance and stateData.responseType ~= eConversationResponseType_CompletionAvailable then
        for _, option in pairs(self.SimpleOptions) do
          if option.isVisible and option.optionType == eConversationOptionType_ConversationTopic then
            UiElementBus.Event.Reparent(option.entityId, self.ButtonsContent, EntityId())
            option:SetIndex(buttonIndex)
            buttonIndex = buttonIndex + 1
          end
        end
      end
      if self.LeaveOption.isVisible then
        UiElementBus.Event.Reparent(self.Properties.LeaveOption, self.ButtonsContent, EntityId())
        self.LeaveOption:SetIndex(buttonIndex, true)
      end
      if self.BigOption.optionType == eConversationOptionType_ContinueDialogue then
        self.ObjectiveDetails:SetIsVisible(false)
      else
        self.ObjectiveDetails:ResetObjectiveDetailsElement()
        self.ObjectiveDetails:SetConversationState(stateData)
        local playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
        local minLevelToShow = 8
        local difficultyLevel = 0
        if self.BigOption.optionType == eConversationOptionType_AcceptObjective then
          local objectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveData(stateData.dialogueId)
          if objectiveData and objectiveData.id ~= "" then
            difficultyLevel = objectiveData.difficultyLevel
          end
        end
        if minLevelToShow <= difficultyLevel and playerLevel < difficultyLevel then
          self.BigOption:SetDifficultyLevel(difficultyLevel)
        else
          self.BigOption:SetDifficultyLevel(nil)
        end
      end
      if not self.isConvoActive then
        LyShineManagerBus.Broadcast.SetState(1101180544)
      end
      self.isConvoActive = true
      self.rewardCelebrationPlayed = false
    end)
  else
    self:CloseScreen()
  end
end
function ConversationScreen:CloseScreen()
  if self.isConvoActive then
    LyShineManagerBus.Broadcast.SetState(2702338936)
    self.isConvoActive = false
  end
end
function ConversationScreen:GetNpcLookAtPosition()
  local npcPosition = TransformBus.Event.GetWorldTranslation(self.interactEntityId)
  local rightOffsetDir = Vector3(1, 0, 0)
  local vecFromPlayerToNpc = Vector3(0, 1, 0)
  local upOffset = 1.5
  local rightOffset = 0.25
  local forwardOffset = 1
  local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  if playerPosition then
    local npcPositionWithZMod = Vector3(npcPosition.x, npcPosition.y, npcPosition.z - 1)
    vecFromPlayerToNpc = npcPositionWithZMod - playerPosition
    Vector3.Normalize(vecFromPlayerToNpc)
    rightOffsetDir = Vector3.CrossZAxis(vecFromPlayerToNpc)
    Vector3.Normalize(rightOffsetDir)
  end
  local lookAtPos = npcPosition
  lookAtPos.z = lookAtPos.z + upOffset
  lookAtPos = lookAtPos + rightOffsetDir * rightOffset
  lookAtPos = lookAtPos + vecFromPlayerToNpc * forwardOffset
  return lookAtPos
end
function ConversationScreen:SetScreenVisible(isVisible)
  if isVisible == self.isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
    JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_Conversation", 0.4)
    if self.interactEntityId then
      local lookAtPos = self:GetNpcLookAtPosition()
      JavCameraControllerRequestBus.Broadcast.SetCameraLookAt(lookAtPos, false)
    end
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
    self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
    self.targetDOFDistance = 5
    self.targetDOFBlur = 0.8
    self.ScriptedEntityTweener:Play(self.Properties.DOFTweenDummyElement, 0.25, {
      opacity = 1,
      onUpdate = function(currentValue, currentProgressPercent)
        self:UpdateDepthOfField(currentValue)
      end
    })
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:Set(self.Properties.HeaderText, {opacity = 0})
    self.ScriptedEntityTweener:PlayC(self.Properties.HeaderText, 0.2, tweenerCommon.fadeInQuadOut)
    self.audioHelper:PlaySound(self.audioHelper.Conversation_Screen_Open)
    self.audioHelper:onUIStateChanged(self.audioHelper.UIState_QuestScreen)
    self:SetConversationContentVisible(true)
    self.ObjectiveDetails:ResetObjectiveDetailsElement()
  else
    local fromConversationService = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ConversationServiceOpen")
    if not fromConversationService then
      JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
      JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
      JavCameraControllerRequestBus.Broadcast.ClearCameraLookAt()
      self.ScriptedEntityTweener:Play(self.Properties.DOFTweenDummyElement, 0.3, {
        opacity = 0,
        onUpdate = function(currentValue, currentProgressPercent)
          self:UpdateDepthOfField(currentValue)
        end,
        onComplete = function()
          JavCameraControllerRequestBus.Broadcast.MakeActiveView(4, 2, 5)
          JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
        end
      })
    end
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.2, tweenerCommon.fadeOutQuadOut, nil, function()
      self:OnTransitionOutCompleted()
    end)
    self.audioHelper:PlaySound(self.audioHelper.Conversation_Screen_Close)
    self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Default)
  end
end
function ConversationScreen:UpdateDepthOfField(currentValue)
  if not self.previousDOFDistance then
    return
  end
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, 10)
end
function ConversationScreen:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  UiElementBus.Event.SetIsEnabled(self.Properties.MainWindow, true)
  self:SetScreenVisible(true)
  self.escapeKeyHandler = CryActionNotificationsBus.Connect(self, "toggleMenuComponent")
  self.outpostRushPanelOpen = false
  local vitalsId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  self.vitalsNotification = self:BusConnect(VitalsComponentNotificationBus, vitalsId)
end
function ConversationScreen:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self:SetScreenVisible(false)
  self:ShowFactionPopup(false)
  self.OutpostRushPanel:Hide()
  self.FactionInfoPanel:StopTutorial()
  self.FactionSelection1:ClearSelected()
  self.FactionSelection2:ClearSelected()
  self.FactionSelection3:ClearSelected()
  self.FactionInfoPanel:EnableConfirmButton(false)
  self:BusDisconnect(self.vitalsNotification)
  self:BusDisconnect(self.escapeKeyHandler)
  self.escapeKeyHandler = nil
  self:BusDisconnect(self.interactKeyHandler)
  self.interactKeyHandler = nil
  for key, handler in pairs(self.optionKeyHandlers) do
    self:BusDisconnect(handler)
    self.optionKeyHandlers[key] = nil
  end
  self.rewardCelebrationPlayed = false
end
function ConversationScreen:OnTransitionOutCompleted()
  UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  local fromConversationService = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ConversationServiceOpen")
  if not fromConversationService then
    local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    if interactorEntity then
      UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
    end
  end
end
function ConversationScreen:OnCryAction(actionName, value)
  local wasKeyPress = 0 < value
  if wasKeyPress then
    if actionName == "ui_interact" then
      actionName = "dialogueOption1"
    end
    if actionName == "toggleMenuComponent" then
      if self.outpostRushPanelOpen then
        self.OutpostRushPanel:OnExit()
      elseif self.rewardCelebrationPlayed then
        self:SkipCelebration()
      else
        LyShineDataLayerBus.Broadcast.Delete("Hud.LocalPlayer.ConversationServiceOpen")
        self:CloseScreen()
      end
    elseif UiElementBus.Event.IsEnabled(self.Properties.MainWindow) then
      local buttonIndex = tonumber(string.sub(actionName, -1))
      if buttonIndex ~= nil then
        if buttonIndex == 0 then
          buttonIndex = 10
        end
        local buttonEntityId = UiElementBus.Event.GetChild(self.Properties.ButtonsContent, buttonIndex - 1)
        if buttonEntityId then
          local button = self.registrar:GetEntityTable(buttonEntityId)
          if button and button.OnPress then
            button:OnPress()
          end
        end
      end
    end
  end
end
function ConversationScreen:OnDamage(attackerEntityId, healthPercentageLost, positionOfAttack, damageAngle, isSelfDamage, damageByType, isFromStatusEffect, cancelTargetHoming)
  if healthPercentageLost < GetEpsilon() then
    return
  end
  if positionOfAttack ~= nil then
    LyShineDataLayerBus.Broadcast.Delete("Hud.LocalPlayer.ConversationServiceOpen")
    self:CloseScreen()
  end
end
function ConversationScreen:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.entityId, self.canvasId)
  end
end
function ConversationScreen:SetConversationContentVisible(isVisible)
  if isVisible then
    local duration = self.isVisible and self.contentFadeOutDuration or 0
    self.ScriptedEntityTweener:PlayC(self.Properties.SubheaderText, duration, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.HeaderText, duration, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.Background, duration, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.HeaderBg, duration, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.BodyTextContainer, duration, tweenerCommon.fadeInQuadOut)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonsContainer, true)
    self.ScriptedEntityTweener:PlayC(self.Properties.ButtonsContainer, duration, tweenerCommon.fadeInQuadOut)
    UiElementBus.Event.SetIsEnabled(self.Properties.CelebrationSkipButton, false)
    if self.isVisible then
      self.interactKeyHandler = CryActionNotificationsBus.Connect(self, "ui_interact")
      self.optionKeyHandlers = {}
      local actionNamePrefix = "dialogueOption"
      for i = 1, self.NUM_DIALOGUE_OPTION_KEYS do
        self.optionKeyHandlers[i] = CryActionNotificationsBus.Connect(self, actionNamePrefix .. i)
      end
    end
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.SubheaderText, self.contentFadeOutDuration, tweenerCommon.fadeOutQuadOut, 0.15)
    self.ScriptedEntityTweener:PlayC(self.Properties.HeaderText, self.contentFadeOutDuration, tweenerCommon.fadeOutQuadOut, 0.15)
    self.ScriptedEntityTweener:PlayC(self.Properties.Background, self.contentFadeOutDuration, tweenerCommon.fadeOutQuadOut, 0.15)
    self.ScriptedEntityTweener:PlayC(self.Properties.HeaderBg, self.contentFadeOutDuration, tweenerCommon.fadeOutQuadOut, 0.15)
    self.ScriptedEntityTweener:PlayC(self.Properties.BodyTextContainer, self.contentFadeOutDuration, tweenerCommon.fadeOutQuadOut, 0.15)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonsContainer, false)
    self.ScriptedEntityTweener:PlayC(self.Properties.ButtonsContainer, self.contentFadeOutDuration, tweenerCommon.fadeOutQuadOut, 0.15, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.CelebrationSkipButton, true)
    end)
    if self.interactKeyHandler then
      self:BusDisconnect(self.interactKeyHandler)
      self.interactKeyHandler = nil
    end
    for key, handler in pairs(self.optionKeyHandlers) do
      self:BusDisconnect(handler)
      self.optionKeyHandlers[key] = nil
    end
  end
end
function ConversationScreen:SkipCelebration()
  self:SetConversationContentVisible(true)
  local playWhoosh = false
  local fadeOutDuration = 0.2
  self.ObjectiveDetails:HideCelebration(playWhoosh, fadeOutDuration)
  self.ScriptedEntityTweener:Stop(self.Properties.CelebrationSkipButton)
  self.ScriptedEntityTweener:Stop(self.Properties.WhooshTweener)
  self.skipCelebration = true
  if self.stateData ~= nil then
    self:OnConversationStateChange(self.stateData)
    self.skipCelebration = false
  end
end
return ConversationScreen
