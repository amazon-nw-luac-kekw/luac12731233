local PopupScreen = {
  Properties = {
    PopupHolder = {
      default = EntityId()
    },
    PopupIcon = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    PopupMessage = {
      default = EntityId()
    },
    MessageSpacer = {
      default = EntityId()
    },
    ScreenScrim = {
      default = EntityId()
    },
    PopupContents = {
      default = EntityId()
    },
    Currency = {
      default = EntityId()
    },
    CustomParts = {
      default = EntityId()
    },
    CustomPartsHolder = {
      default = EntityId()
    },
    ButtonHolderYesNo = {
      default = EntityId()
    },
    ButtonYes = {
      default = EntityId()
    },
    ButtonNo = {
      default = EntityId()
    },
    ButtonHolderOk = {
      default = EntityId()
    },
    ButtonOk = {
      default = EntityId()
    },
    AmountDueContainer = {
      default = EntityId()
    },
    AmountDueLabel = {
      default = EntityId()
    },
    AmountDueText = {
      default = EntityId()
    },
    TextInputContainer = {
      default = EntityId()
    },
    TextInput = {
      default = EntityId()
    },
    RemainingTimeContainer = {
      default = EntityId()
    },
    RemainingTime = {
      default = EntityId()
    },
    RemainingTimeDivider = {
      default = EntityId()
    },
    AmountDueDivider = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    EnableExitSurveyCheckbox = {
      default = EntityId()
    },
    SelectionContainer = {
      default = EntityId()
    },
    SimpleGridItemList = {
      default = EntityId()
    },
    SelectionPrototype = {
      default = EntityId()
    },
    ServerMOTDContainer = {
      default = EntityId()
    },
    ServerMOTDTitle = {
      default = EntityId()
    },
    ServerMOTDMessage = {
      default = EntityId()
    },
    ServerMOTDScrollbox = {
      default = EntityId()
    },
    GlobalAnnouncementContainer = {
      default = EntityId()
    },
    GlobalAnnouncementTitle = {
      default = EntityId()
    },
    GlobalAnnouncementMessage = {
      default = EntityId()
    },
    GlobalAnnouncementScrollbox = {
      default = EntityId()
    },
    ServerDivider = {
      default = EntityId()
    },
    GlobalAnnouncementDivider = {
      default = EntityId()
    },
    QueueContainer = {
      default = EntityId()
    },
    QueueEstimatedTimeHeader = {
      default = EntityId()
    },
    QueueEstimatedTime = {
      default = EntityId()
    },
    QueuePositionHeader = {
      default = EntityId()
    },
    QueuePosition = {
      default = EntityId()
    },
    QueueStatus = {
      default = EntityId()
    },
    QueueDivider = {
      default = EntityId()
    }
  },
  mPopupType = "",
  mEventId = nil,
  buttonActivationDelay = 0,
  buttonActivationTimer = 0,
  estimatedQueueEndTime = 0,
  isLoginQueue = false,
  queueHeight = 0,
  additionalHeight = 0,
  bottomPadding = 0,
  timeBetweenWorldUpdates = 60,
  lastWorldUpdateSecs = 0
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(PopupScreen)
local QuitGamePopup = RequireScript("LyShineUI.Popup.QuitGamePopup")
QuitGamePopup:AttachQuitGamePopup(PopupScreen)
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local UIErrors = RequireScript("LyShineUI.Popup.UIErrors")
local CanvasCommon = RequireScript("LyShineUI._Common.CanvasCommon")
local invalidEntityId = EntityId()
function PopupScreen:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(UiPopupBus)
  self.dataLayer:OnChange(self, "UIFeatures.showQueueTimes", function(self, showQueueTimeDataNode)
    if showQueueTimeDataNode then
      local showQueueTime = showQueueTimeDataNode:GetData()
      UiElementBus.Event.SetIsEnabled(self.Properties.QueueEstimatedTimeHeader, showQueueTime)
      UiElementBus.Event.SetIsEnabled(self.Properties.QueueEstimatedTime, showQueueTime)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.QueuePositionHeader, showQueueTime and 12 or -130)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.QueuePosition, showQueueTime and 12 or -130)
      UiElementBus.Event.SetIsEnabled(self.Properties.QueueDivider, showQueueTime)
    end
  end)
  SetTextStyle(self.Properties.PopupMessage, self.UIStyle.FONT_STYLE_BODY_NEW)
  SetTextStyle(self.Properties.ServerMOTDMessage, self.UIStyle.FONT_STYLE_POPUP_MESSAGE)
  SetTextStyle(self.Properties.GlobalAnnouncementMessage, self.UIStyle.FONT_STYLE_POPUP_MESSAGE)
  SetTextStyle(self.Properties.ServerMOTDTitle, self.UIStyle.FONT_STYLE_POPUP_MESSAGE_TITLE)
  SetTextStyle(self.Properties.GlobalAnnouncementTitle, self.UIStyle.FONT_STYLE_POPUP_MESSAGE_TITLE)
  SetTextStyle(self.Properties.QueueEstimatedTimeHeader, self.UIStyle.FONT_STYLE_QUEUE_POPUP_HEADER)
  SetTextStyle(self.Properties.QueuePositionHeader, self.UIStyle.FONT_STYLE_QUEUE_POPUP_HEADER)
  SetTextStyle(self.Properties.QueueStatus, self.UIStyle.FONT_STYLE_QUEUE_POPUP_STATUS)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.QueueStatus, true)
  self.ButtonYes:SetText("@ui_yes")
  self.ButtonNo:SetText("@ui_no")
  self.ButtonOk:SetText("@ui_ok")
  self.ButtonYes:SetCallback(self.OnYes, self)
  self.ButtonNo:SetCallback(self.OnNo, self)
  self.ButtonOk:SetCallback(self.OnOk, self)
  self.ButtonClose:SetCallback(self.OnClose, self)
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.ButtonOk:SetButtonStyle(self.ButtonOk.BUTTON_STYLE_CTA)
  self.ButtonYes:SetButtonStyle(self.ButtonYes.BUTTON_STYLE_CTA)
  self.ButtonNo:SetButtonStyle(self.ButtonNo.BUTTON_STYLE_DEFAULT)
  local alpha = 0.5
  self.ScriptedEntityTweener:Set(self.AmountDueDivider.entityId, {
    opacity = alpha - 0.2
  })
  self.ScriptedEntityTweener:Set(self.RemainingTimeDivider.entityId, {
    opacity = alpha - 0.2
  })
  UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, false)
  UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, false)
  DynamicBus.PopupScreenRequestsBus.Connect(self.entityId, self)
  self.customPopupData = {}
  self.customPopupData.TextLabelAndValue = {
    entityId = self.Properties.AmountDueContainer,
    SetData = function(value, label)
      UiTextBus.Event.SetTextWithFlags(self.Properties.AmountDueLabel, label, eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.AmountDueText, value, eUiTextSet_SetLocalized)
    end
  }
  self.customPopupData.RemainingTime = {
    entityId = self.Properties.RemainingTimeContainer,
    SetData = function(value)
      self.RemainingTime:SetTimeSeconds(value, true)
    end
  }
  self.customPopupData.TextInput = {
    entityId = self.Properties.TextInputContainer,
    SetData = function(value, label)
      self.TextInput:SetLabel(label)
      self.TextInput:SetOnChangeCallback(self, function(callerSelf, inputText)
        value.onChangeCallback(value.callerSelf, self, inputText)
      end)
      if self.TextInput:GetInputValue() ~= "" then
        self.TextInput:SetInputValue("")
      else
        value.onChangeCallback(value.callerSelf, self, self.TextInput:GetInputValue())
      end
      self.TextInput:SetPreviewText(value.placeholderText)
    end
  }
  self.SimpleGridItemList:Initialize(self.SelectionPrototype)
  self.SimpleGridItemList:OnListDataSet(nil)
  self.customPopupData.SelectionOptions = {
    entityId = self.Properties.SelectionContainer,
    SetData = function(selections, label)
      self.SimpleGridItemList:SetHeaderText(label)
      self.SimpleGridItemList:OnListDataSet(selections)
    end
  }
  self.customPopupData.Queue = {
    entityId = self.Properties.QueueContainer,
    SetData = function(value, label)
      return
    end
  }
  self.customPopupData.ServerMOTD = {
    entityId = self.Properties.ServerMOTDContainer,
    SetData = function(value)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ServerMOTDMessage, value, eUiTextSet_SetLocalized)
    end
  }
  self.customPopupData.GlobalAnnouncement = {
    entityId = self.Properties.GlobalAnnouncementContainer,
    SetData = function(value, label)
      UiTextBus.Event.SetTextWithFlags(self.Properties.GlobalAnnouncementTitle, label, eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.GlobalAnnouncementMessage, value, eUiTextSet_SetLocalized)
    end
  }
  self.EnableExitSurveyCheckbox:SetText("@ui_options_take_exit_survey")
  self.EnableExitSurveyCheckbox:SetTextSize(self.UIStyle.FONT_SIZE_BODY_NEW)
  self.EnableExitSurveyCheckbox:SetCallback(self, self.OnEnableExitSurveyChanged)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "javelin.enable-exit-survey", function(self, exitSurveyEnabled)
    self.exitSurveyEnabled = exitSurveyEnabled
  end)
  self:BusConnect(UiMarkupButtonNotificationsBus, self.Properties.PopupMessage)
end
function PopupScreen:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.PopupScreenRequestsBus.Disconnect(self.entityId, self)
end
function PopupScreen:OnWorldCMSDataSet(worldCMSData)
  local motd
  local worldId = LyShineDataLayerBus.Broadcast.GetDataFromNode("WorldInfo.WorldId") or ""
  if worldCMSData and #worldCMSData.worldDescriptions > 0 then
    for i = 1, #worldCMSData.worldDescriptions do
      local world = worldCMSData.worldDescriptions[i]
      if worldId == world.worldId then
        motd = world.motd
      end
    end
  end
  if motd then
    LyShineManagerBus.Broadcast.SetServerMOTD(motd)
  end
end
function PopupScreen:SetPopupResponseHandler(t)
  self.popupResponseHandler = t
end
function PopupScreen:OnTick(deltaTime, timePoint)
  if self.buttonActivationDelay > 0 then
    self.buttonActivationTimer = self.buttonActivationTimer - deltaTime
    if 0 >= self.buttonActivationTimer then
      self.ButtonOk:SetEnabled(true)
      self.ButtonClose:SetEnabled(true)
      self.buttonActivationDelay = 0
      self.ButtonOk:SetText("@ui_cancel")
    else
      local buttonText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_cancelin", tostring(math.ceil(self.buttonActivationTimer)))
      self.ButtonOk:SetText(buttonText)
    end
  end
  if 0 < self.estimatedQueueEndTime then
    self.lastWorldUpdateSecs = self.lastWorldUpdateSecs + deltaTime
    if self.lastWorldUpdateSecs > self.timeBetweenWorldUpdates then
      self.lastWorldUpdateSecs = 0
      DynamicContentBus.Broadcast.RetrieveCMSData(eCMSDataType_Worlds, true)
    end
    local now = os.time()
    if now < self.estimatedQueueEndTime then
      local estimatedTimeRemaining = self.estimatedQueueEndTime - now
      if estimatedTimeRemaining ~= self.displayTime then
        self.displayTime = estimatedTimeRemaining
      end
    else
      self.displayTime = 0
    end
    self:UpdateLoginQueueInfo(self.statusMessage, self.position, self.displayTime)
  end
end
function PopupScreen:OnTransitionIn(stateName, levelName)
  self.cryActionCancelNotificationHandler = self:BusConnect(CryActionNotificationsBus, "ui_cancel")
  self.cryActionConfirmNotificationHandler = self:BusConnect(CryActionNotificationsBus, "ui_start_pause")
  self.ScriptedEntityTweener:Play(self.Properties.PopupHolder, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  self.ScriptedEntityTweener:Play(self.ScreenScrim, 0.5, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
  self.AmountDueDivider:SetVisible(true, 1.5, {delay = 0.2})
  self.RemainingTimeDivider:SetVisible(true, 1.5, {delay = 0.2})
  self.QueueDivider:Reset()
  self.QueueDivider:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.QueueDivider:SetVisible(true, 1, {delay = 0.5})
end
function PopupScreen:OnTransitionOut(stateName, levelName)
  self:BusDisconnect(self.cryActionCancelNotificationHandler)
  self:BusDisconnect(self.cryActionConfirmNotificationHandler)
  DynamicBus.ConfirmationPopup.Broadcast.HideConfirmationPopup()
  self.AmountDueDivider:SetVisible(false, 0.1)
  self.RemainingTimeDivider:SetVisible(false, 0.1)
  self:StopTick()
end
function PopupScreen:OnCryAction(actionName)
  if self.buttonActivationDelay <= 0 then
    if actionName == "ui_cancel" then
      self:OnClose()
    elseif actionName == "ui_start_pause" then
      if self.mButtonsType == ePopupButtons_YesNo then
        self:OnYes()
      else
        self:OnOk()
      end
    end
  end
end
function PopupScreen:ClearCustomParts()
  local childElements = UiElementBus.Event.GetChildren(self.Properties.CustomParts)
  for i = 1, #childElements do
    UiElementBus.Event.Reparent(childElements[i], self.Properties.CustomPartsHolder, invalidEntityId)
  end
  self.isLoginQueue = false
  self.additionalHeight = 0
  self.bottomPadding = 0
  self.queueHeight = 0
  self.closeWithOnOk = nil
  UiLayoutCellBus.Event.SetMinHeight(self.Properties.MessageSpacer, 100)
  UiLayoutCellBus.Event.SetMinHeight(self.Properties.PopupMessage, 50)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.PopupMessage, 24)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.CustomParts, 0)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.PopupIcon, 0)
  UiElementBus.Event.SetIsEnabled(self.Properties.Currency, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.EnableExitSurveyCheckbox, false)
  self.ButtonYes:SetText("@ui_yes")
  self.ButtonNo:SetText("@ui_no")
  self.ButtonOk:SetText("@ui_ok")
  self.ButtonYes:SetEnabled(true)
end
function PopupScreen:ShowPopup(buttons, title, message, eventId)
  self:ClearCustomParts()
  self.mEventId = eventId
  self.mPopupType = ""
  self.mButtonsType = buttons
  self.FrameHeader:SetText(title)
  self:UpdatePopupMessage(message)
  if buttons == ePopupButtons_Cancel then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, false)
    self.ButtonOk:SetText("@ui_cancel")
    self.ButtonOk:SetCallback("OnCancel", self)
  elseif buttons == ePopupButtons_YesNo then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, false)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, true)
    self.ButtonYes:SetText("@ui_yes")
    self.ButtonNo:SetText("@ui_no")
    self.buttonActivationDelay = 0
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, false)
    self.ButtonClose:SetEnabled(true)
    self.ButtonOk:SetEnabled(true)
    self.ButtonOk:SetText("@ui_ok")
    self.ButtonOk:SetCallback("OnOk", self)
    self.buttonActivationDelay = 0
  end
  LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
end
function PopupScreen:ShowError(errorId, timepoint, additionalInfo, eventId)
  local errorData = UIErrors.errors[errorId]
  if not errorData then
    Debug.Log("Trying to show error (" .. tostring(errorId) .. ") with no data! Add data to UiErrors.lua. Ignoring error message..")
    return
  end
  self:ClearCustomParts()
  self.mEventId = eventId
  self.mPopupType = ""
  self.mButtonsType = errorData.buttonType
  local errorTitle = errorData.title
  local errorMessage = errorData.body
  local delayOverride = 0.1
  if errorId >= UIError_banned and errorId < UIError_banned_max then
    delayOverride = 0.5
    if not timepoint:IsZero() then
      errorTitle = "@error_temp_ban"
      errorMessage = GetLocalizedReplacementText("@error_banned", {
        message = GetLocalizedReplacementText("@mm_loginservices_Banned_temporary", {
          duration = LyShineScriptBindRequestBus.Broadcast.LocalizeText(timeHelpers:ConvertToLargestTimeEstimate(timepoint:Subtract(timeHelpers:ServerNow()):ToSeconds(), false)),
          dateandtime = timeHelpers:GetLocalizedDateTime(timepoint:Subtract(WallClockTimePoint()):ToSecondsRoundedUp(), true)
        }),
        reason = errorData.body
      })
    else
      errorTitle = "@error_perm_ban"
      errorMessage = GetLocalizedReplacementText("@error_banned", {
        message = "@mm_loginservices_Banned_permanent",
        reason = errorData.body
      })
    end
  elseif additionalInfo and additionalInfo ~= "" then
    errorMessage = errorMessage .. "\n" .. additionalInfo
  end
  if errorData.addCoc then
    errorMessage = errorMessage .. UIErrors.cocString
  end
  if errorData.addAppeal then
    errorMessage = errorMessage .. UIErrors.appealString
  end
  self.FrameHeader:SetText(errorTitle)
  self:UpdatePopupMessage(errorMessage, delayOverride)
  if errorData.buttonType == ePopupButtons_Cancel then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, false)
    self.ButtonOk:SetText(errorData.buttonYesText)
    self.ButtonOk:SetCallback(self.OnCancel, self)
  elseif errorData.buttonType == ePopupButtons_YesNo then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, false)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, true)
    self.ButtonYes:SetText(errorData.buttonYesText)
    self.ButtonNo:SetText(errorData.buttonNoText)
    self.buttonActivationDelay = 0
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, false)
    self.ButtonClose:SetEnabled(true)
    self.ButtonOk:SetEnabled(true)
    self.ButtonOk:SetText(errorData.buttonYesText)
    self.ButtonOk:SetCallback(self.OnOk, self)
    self.buttonActivationDelay = 0
  end
  LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
end
function PopupScreen:ShowCustomPopup(params)
  self:ClearCustomParts()
  self.mEventId = params.eventId
  self.mPopupType = ""
  self.mButtonsType = params.buttons
  if params.closeWithOnOk ~= nil then
    self.closeWithOnOk = params.closeWithOnOk
  elseif params.buttonsYesNo or params.buttonText then
    self.closeWithOnOk = true
  end
  self.FrameHeader:SetText(params.title)
  UiTextBus.Event.SetTextWithFlags(self.PopupMessage, params.message, eUiTextSet_SetLocalized)
  if params.iconPath then
    UiImageBus.Event.SetSpritePathname(self.Properties.PopupIcon, params.iconPath)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.PopupIcon, 45)
  end
  if params.buttonsYesNo then
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, false)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, true)
    if params.yesButtonText then
      self.ButtonYes:SetText(params.yesButtonText)
    end
    if params.noButtonText then
      self.ButtonNo:SetText(params.noButtonText)
    end
    self.buttonActivationDelay = 0
    if not self.mButtonsType then
      self.mButtonsType = ePopupButtons_YesNo
    end
  end
  if params.buttonText then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, false)
    self.ButtonOk:SetEnabled(true)
    self.ButtonClose:SetEnabled(true)
    self.ButtonOk:SetText(params.buttonText)
    self.ButtonOk:SetCallback(self.OnOk, self)
    self.buttonActivationDelay = 0
  end
  self.isLoginQueue = params.isLoginQueue
  if params.isLoginQueue then
    UiLayoutCellBus.Event.SetMinHeight(self.Properties.MessageSpacer, 10)
    UiLayoutCellBus.Event.SetMinHeight(self.Properties.PopupMessage, 0)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.PopupMessage, 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderOk, true)
    UiElementBus.Event.SetIsEnabled(self.ButtonHolderYesNo, false)
    self.ButtonOk:SetText("@ui_cancel")
    self.ButtonOk:SetCallback(self.OnLoginQueueShowConfirmation, self)
    self.ButtonClose:SetCallback(self.OnLoginQueueShowConfirmation, self)
  end
  if params.showCloseButton ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonClose, params.showCloseButton)
  end
  local additionalHeight = params.additionalHeight or 0
  self.bottomPadding = params.bottomPadding or 0
  if params.customData then
    local showingServerMessage = false
    local showingGlobalMessage = false
    for _, popupDetail in ipairs(params.customData) do
      local detailData = self.customPopupData[popupDetail.detailType]
      detailData.SetData(popupDetail.value, popupDetail.label)
      UiElementBus.Event.Reparent(detailData.entityId, self.Properties.CustomParts, invalidEntityId)
      local detailHeight = UiTransform2dBus.Event.GetLocalHeight(detailData.entityId)
      if popupDetail.detailType == "Queue" then
        local margin = 150
        local statusTextHeight = 0
        local bottomMargin = 0
        local statusText = UiTextBus.Event.GetText(self.Properties.QueueStatus)
        if statusText ~= "" then
          statusTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.QueueStatus)
          bottomMargin = 10
        end
        detailHeight = statusTextHeight + margin + bottomMargin
        self.queueHeight = detailHeight
        UiLayoutCellBus.Event.SetTargetHeight(self.Properties.QueueContainer, detailHeight)
      elseif popupDetail.detailType == "ServerMOTD" then
        showingServerMessage = true
        local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.ServerMOTDMessage)
        local scrollboxHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ServerMOTDScrollbox)
        textHeight = math.min(textHeight, scrollboxHeight)
        local margin = 84
        local bottomMargin = 10
        detailHeight = textHeight + margin + bottomMargin
        UiLayoutCellBus.Event.SetTargetHeight(self.Properties.ServerMOTDContainer, detailHeight)
      elseif popupDetail.detailType == "GlobalAnnouncement" then
        showingGlobalMessage = true
        local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.GlobalAnnouncementMessage)
        local scrollboxHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.GlobalAnnouncementScrollbox)
        textHeight = math.min(textHeight, scrollboxHeight)
        local margin = 60
        detailHeight = textHeight + margin
        UiLayoutCellBus.Event.SetTargetHeight(self.Properties.GlobalAnnouncementContainer, detailHeight)
      end
      additionalHeight = additionalHeight + detailHeight
    end
    local serverDividerPositionY = 0
    if showingServerMessage and not showingGlobalMessage then
      serverDividerPositionY = 23
    end
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ServerDivider, serverDividerPositionY)
    self.additionalHeight = additionalHeight
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.CustomParts, additionalHeight)
  end
  local showCurrency = params.showCurrency == true
  UiElementBus.Event.SetIsEnabled(self.Properties.Currency, showCurrency)
  if showCurrency then
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.Currency, 60)
    additionalHeight = additionalHeight + 60
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonHolderOk, -10)
  else
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.Currency, 45)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonHolderOk, 16)
  end
  local showExitSurvey = self.exitSurveyEnabled and params.showExitSurvey == true
  UiElementBus.Event.SetIsEnabled(self.Properties.EnableExitSurveyCheckbox, showExitSurvey)
  if showExitSurvey then
    local state = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Misc.ExitSurveyEnabled")
    self.EnableExitSurveyCheckbox:SetState(state)
  end
  self:ResizePopup()
  LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
end
function PopupScreen:ShowTimedCancelPopup(title, message, eventId, buttonActivationDelay)
  self.buttonActivationDelay = buttonActivationDelay
  self.buttonActivationTimer = self.buttonActivationDelay
  local isDelay = self.buttonActivationDelay > 0
  self.ButtonOk:SetEnabled(not isDelay)
  self.ButtonClose:SetEnabled(not isDelay)
  self.estimatedQueueEndTime = 0
  self:StartTick()
  self:ShowPopup(ePopupButtons_Cancel, title, message, eventId)
end
function PopupScreen:UpdateLoginQueueInfo(statusMessage, position, estimatedTimeRemaining)
  if position < 0 then
    estimatedTimeRemaining = "@ui_unknown"
    position = "@ui_unknown"
  elseif estimatedTimeRemaining < 0 then
    estimatedTimeRemaining = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_queue_long", timeHelpers:ConvertToLargestTimeEstimate(estimatedTimeRemaining + 60, false, true))
  elseif estimatedTimeRemaining < 60 then
    estimatedTimeRemaining = "@ui_queue_soon_short"
  else
    estimatedTimeRemaining = timeHelpers:ConvertToLargestTimeEstimate(estimatedTimeRemaining + 60, false, true)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.QueueEstimatedTime, estimatedTimeRemaining, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.QueuePosition, position, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.QueueStatus, statusMessage, eUiTextSet_SetLocalized)
  local serverMessage = LyShineManagerBus.Broadcast.GetServerMOTD()
  local globalTitle = LyShineManagerBus.Broadcast.GetGlobalAnnouncementTitle()
  local globalMessage = LyShineManagerBus.Broadcast.GetGlobalAnnouncementMessage()
  UiTextBus.Event.SetTextWithFlags(self.Properties.ServerMOTDMessage, serverMessage, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GlobalAnnouncementTitle, globalTitle, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GlobalAnnouncementMessage, globalMessage, eUiTextSet_SetLocalized)
  self:ResizePopup()
end
function PopupScreen:ShowLoginQueuePopup(eventId, statusMessage, position, estimatedTimeRemaining, buttonActivationDelay)
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    local frontendLevelName = ConfigProviderEventBus.Broadcast.GetString("javelin.frontend-level-name")
    LyShineScriptBindRequestBus.Broadcast.ExecuteCommand("map " .. frontendLevelName)
    return
  end
  self.loginQueuePopupShowing = true
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, CanvasCommon.LOADING_SCREEN_DRAW_ORDER + 1)
  local isDelay = 0 < buttonActivationDelay
  self.ButtonOk:SetEnabled(not isDelay)
  self.ButtonClose:SetEnabled(not isDelay)
  self:StartTick()
  self.mainMenuBusHandler = self:BusConnect(UiMainMenuBus)
  self:SetupLoginQueuePopup(eventId, statusMessage, position, estimatedTimeRemaining, buttonActivationDelay)
end
function PopupScreen:UpdateLoginQueue(statusMessage, position, estimatedTimeRemaining)
  if not self.mEventId then
    self:SetupLoginQueuePopup("CancelLoginQueue", statusMessage, position, estimatedTimeRemaining, 5)
  else
    local now = os.time()
    if self.position == nil or self.position ~= position or self.estimatedTimeRemaining == nil or estimatedTimeRemaining ~= self.estimatedTimeRemaining then
      self.statusMessage = statusMessage
      self.position = position
      self.estimatedTimeRemaining = estimatedTimeRemaining
      self.estimatedQueueEndTime = now + estimatedTimeRemaining
      self:UpdateLoginQueueInfo(statusMessage, position, estimatedTimeRemaining)
    end
  end
end
function PopupScreen:SetupLoginQueuePopup(eventId, statusMessage, position, estimatedTimeRemaining, buttonActivationDelay)
  self.buttonActivationDelay = buttonActivationDelay
  self.buttonActivationTimer = self.buttonActivationDelay
  self.position = position
  self.estimatedQueueEndTime = os.time() + estimatedTimeRemaining
  self.lastWorldUpdateSecs = 0
  self.statusMessage = statusMessage
  local params = {
    title = "@mm_queuepopuptitle",
    eventId = eventId,
    isLoginQueue = true,
    customData = {}
  }
  table.insert(params.customData, {detailType = "Queue"})
  local serverMessage = LyShineManagerBus.Broadcast.GetServerMOTD()
  local globalTitle = LyShineManagerBus.Broadcast.GetGlobalAnnouncementTitle()
  local globalMessage = LyShineManagerBus.Broadcast.GetGlobalAnnouncementMessage()
  local hasServerMessage = serverMessage ~= ""
  local hasGlobalMessage = globalMessage ~= ""
  if hasServerMessage then
    table.insert(params.customData, {detailType = "ServerMOTD", value = serverMessage})
  end
  if hasGlobalMessage then
    table.insert(params.customData, {
      detailType = "GlobalAnnouncement",
      label = globalTitle,
      value = globalMessage
    })
  end
  self:UpdateLoginQueueInfo(statusMessage, position, estimatedTimeRemaining)
  self:ShowCustomPopup(params)
end
function PopupScreen:UpdatePopupMessage(message, delayOverride)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PopupMessage, message, eUiTextSet_SetLocalized)
  local bodyTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.PopupMessage)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.PopupMessage, bodyTextHeight)
  self:ResizePopup(delayOverride)
end
function PopupScreen:ResizePopup(delayOverride)
  local delay = delayOverride and delayOverride or 0.1
  timingUtils:Delay(delay, self, function()
    local minSize = 200
    local maxSize = 900
    if self.isLoginQueue then
      local detailHeight = 0
      local margin = 150
      local statusTextHeight = 0
      local bottomMargin = 0
      local statusText = UiTextBus.Event.GetText(self.Properties.QueueStatus)
      if statusText ~= "" then
        statusTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.QueueStatus)
        bottomMargin = 10
      end
      detailHeight = statusTextHeight + margin + bottomMargin
      local oldHeight = self.additionalHeight - self.queueHeight
      self.queueHeight = detailHeight
      local newHeight = oldHeight + self.queueHeight
      self.additionalHeight = newHeight
      UiLayoutCellBus.Event.SetTargetHeight(self.Properties.QueueContainer, self.queueHeight)
      UiLayoutCellBus.Event.SetTargetHeight(self.Properties.CustomParts, self.additionalHeight)
    end
    UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
    local height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.PopupContents)
    local popupSize = Math.Clamp(height + self.bottomPadding, minSize, maxSize)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.PopupHolder, popupSize)
  end)
end
function PopupScreen:HidePopup(eventId)
  if self.mEventId == eventId then
    self:OnForceClose()
  end
end
function PopupScreen:OnOk()
  self:SetPopupResult(ePopupResult_OK)
end
function PopupScreen:OnYes()
  self:SetPopupResult(ePopupResult_Yes)
end
function PopupScreen:OnNo()
  self:SetPopupResult(ePopupResult_No)
end
function PopupScreen:OnCancel()
  self:SetPopupResult(ePopupResult_Cancel)
end
function PopupScreen:OnLoginQueueShowConfirmation()
  local buttonRect = UiTransformBus.Event.GetViewportSpaceRect(self.Properties.ButtonOk)
  local confirmationPos = Vector2(buttonRect:GetCenterX(), buttonRect:GetCenterY() - 54)
  local confirmationDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId) + 1
  DynamicBus.ConfirmationPopup.Broadcast.ShowConfirmationPopup(confirmationPos, {
    title = "@mm_loginservices_leave_queue_title",
    description = "@mm_loginservices_leave_queue_message",
    confirmCallback = self.OnCancel,
    confirmCallbackTable = self,
    drawOrderOverride = confirmationDrawOrder,
    disableHint = true
  })
end
function PopupScreen:OnClose()
  if self.isLoginQueue then
    self:OnLoginQueueShowConfirmation()
  elseif self.closeWithOnOk then
    self:OnOk()
  elseif self.mButtonsType == ePopupButtons_YesNo then
    self:OnNo()
  elseif self.mButtonsType == ePopupButtons_OK then
    self:OnOk()
  else
    self:OnCancel()
  end
end
function PopupScreen:OnForceClose()
  self:SetPopupResult(ePopupResult_ForceClosed)
end
function PopupScreen:OnEnableExitSurveyChanged(isChecked)
  if not self.exitSurveyEnabled then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.ExitSurveyEnabled", isChecked)
  OptionsDataBus.Broadcast.SerializeOptions()
end
function PopupScreen:SetPopupResult(result)
  self:StopTick()
  self.position = nil
  self.estimatedTimeRemaining = nil
  local eventId = self.mEventId
  self.mEventId = nil
  self.mPopupType = ""
  LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
  if self.loginQueuePopupShowing then
    self.loginQueuePopupShowing = false
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, CanvasCommon.POPUP_DRAW_ORDER)
  end
  if self.mainMenuBusHandler then
    self:BusDisconnect(self.mainMenuBusHandler)
    self.mainMenuBusHandler = nil
  end
  UiPopupNotificationsBus.Event.OnPopupResult(eventId, result, eventId)
end
function PopupScreen:StartTick()
  if not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function PopupScreen:StopTick()
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function PopupScreen:OnReleased(clickableId, action, data)
  if data == "coc" then
    OptionsDataBus.Broadcast.OpenCodeOfConductInBrowser()
  elseif data == "appealban" then
    OptionsDataBus.Broadcast.OpenAppealBanInBrowser()
  end
end
return PopupScreen
