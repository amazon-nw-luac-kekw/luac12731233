local Treasury_DailyLimitPopup = {
  Properties = {
    PopupHolder = {
      default = EntityId(),
      order = 1
    },
    CurrentLimitLabel = {
      default = EntityId(),
      order = 2
    },
    CurrentLimitAmount = {
      default = EntityId(),
      order = 3
    },
    CurrentLimitInfinityIcon = {
      default = EntityId(),
      order = 4
    },
    NewLimitLabel = {
      default = EntityId(),
      order = 5
    },
    NewLimitInput = {
      default = EntityId(),
      order = 6
    },
    NewLimitInfinityIcon = {
      default = EntityId(),
      order = 7
    },
    NoLimitCheckbox = {
      default = EntityId(),
      order = 8
    },
    Frame = {
      default = EntityId(),
      order = 9
    },
    FrameHeader = {
      default = EntityId(),
      order = 10
    },
    ScreenScrim = {
      default = EntityId(),
      order = 11
    },
    ButtonAccept = {
      default = EntityId(),
      order = 12
    },
    ButtonCancel = {
      default = EntityId(),
      order = 13
    },
    ButtonClose = {
      default = EntityId(),
      order = 14
    }
  },
  inputTextPreviousValue = "0",
  inputTextMaxDigits = 15
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Treasury_DailyLimitPopup)
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function Treasury_DailyLimitPopup:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  socialDataHandler:OnActivate()
  UiTextInputBus.Event.SetTextSelectionColor(self.NewLimitInput, self.UIStyle.COLOR_INPUT_SELECTION)
  self.ButtonAccept:SetText("@ui_accept")
  self.ButtonAccept:SetCallback(self.OnAccept, self)
  self.ButtonAccept:SetButtonStyle(self.ButtonAccept.BUTTON_STYLE_CTA)
  self.ButtonCancel:SetText("@ui_cancel")
  self.ButtonCancel:SetCallback(self.OnCancel, self)
  self.ButtonClose:SetCallback(self.OnCancel, self)
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.FrameHeader:SetText("@ui_treasury_popup_setdailylimit_title")
  self.NoLimitCheckbox:SetText("@ui_treasury_popup_setdailylimit_nolimit")
  self.NoLimitCheckbox:SetCallback(self, self.OnCheckboxChanged)
  self.CurrentLimitInfinityIcon:SetIcon("lyshineui/images/icons/misc/infinity_tan.png", self.UIStyle.COLOR_WHITE)
  self.NewLimitInfinityIcon:SetIcon("lyshineui/images/icons/misc/infinity_tan.png", self.UIStyle.COLOR_WHITE)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self.playerWalletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-player")
end
function Treasury_DailyLimitPopup:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.Properties.ScreenScrim, self.canvasId)
  end
end
function Treasury_DailyLimitPopup:OnShutdown()
  socialDataHandler:OnDeactivate()
end
function Treasury_DailyLimitPopup:SetDailyLimitPopupData(treasuryData)
  UiElementBus.Event.SetIsEnabled(self.NewLimitInfinityIcon.entityId, false)
  UiTextInputBus.Event.SetText(self.NewLimitInput, GetLocalizedCurrency(0))
  UiElementBus.Event.SetIsEnabled(self.NewLimitInput, true)
  self.ScriptedEntityTweener:Set(self.NewLimitInput, {opacity = 1})
  self.NoLimitCheckbox:SetState(false)
  self:UpdateDailyLimit(treasuryData)
  socialDataHandler:GetTreasuryData_ServerCall(self, function(self, treasuryData)
    self:UpdateDailyLimit(treasuryData)
  end, nil)
  self:SetVisibility(true)
end
function Treasury_DailyLimitPopup:UpdateDailyLimit(treasuryData)
  if not treasuryData then
    UiElementBus.Event.SetIsEnabled(self.CurrentLimitInfinityIcon.entityId, false)
    UiElementBus.Event.SetIsEnabled(self.CurrentLimitAmount, true)
    UiTextBus.Event.SetText(self.CurrentLimitAmount, "-")
    return
  end
  if treasuryData.dailyWithdrawalLimit == self.dailyWithdrawalLimit then
    return
  end
  self.dailyWithdrawalLimit = treasuryData.dailyWithdrawalLimit
  UiElementBus.Event.SetIsEnabled(self.CurrentLimitInfinityIcon.entityId, treasuryData.dailyWithdrawalLimit == 0)
  UiElementBus.Event.SetIsEnabled(self.CurrentLimitAmount, treasuryData.dailyWithdrawalLimit > 0)
  if treasuryData.dailyWithdrawalLimit > 0 then
    UiTextBus.Event.SetText(self.CurrentLimitAmount, GetLocalizedCurrency(treasuryData.dailyWithdrawalLimit))
  end
end
function Treasury_DailyLimitPopup:SetVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.PopupHolder, 0.8, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.ScreenScrim, 0.5, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
  else
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
  end
end
function Treasury_DailyLimitPopup:IsVisible()
  return self.isVisible
end
function Treasury_DailyLimitPopup:ShowErrorNotification(message)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = message
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function Treasury_DailyLimitPopup:OnTextInputChange()
  local currentText = UiTextInputBus.Event.GetText(self.NewLimitInput)
  local value = 0
  local success = false
  value, success = GetCurrencyValueFromLocalized(currentText)
  if not (currentText == "" or success) or string.find(currentText, " ") or #currentText > self.inputTextMaxDigits or value < 0 or value > self.playerWalletCap or string.find(currentText, "-") then
    UiTextInputBus.Event.SetText(self.NewLimitInput, self.inputTextPreviousValue)
    return
  end
  self.inputTextPreviousValue = currentText
end
function Treasury_DailyLimitPopup:OnTextInputStartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
end
function Treasury_DailyLimitPopup:OnTextInputEndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
  self:OnTextInputEnter()
end
function Treasury_DailyLimitPopup:OnTextInputEnter()
  local currentText = UiTextInputBus.Event.GetText(self.NewLimitInput)
  local value, success = GetValueFromLocalized(currentText, true)
  if not success then
    currentText = "0"
    UiTextInputBus.Event.SetText(self.NewLimitInput, GetLocalizedCurrency(currentText))
  end
end
function Treasury_DailyLimitPopup:OnCheckboxChanged(isChecked)
  local animDuration = 0.2
  if isChecked then
    UiElementBus.Event.SetIsEnabled(self.NewLimitInfinityIcon.entityId, true)
    self.ScriptedEntityTweener:Play(self.NewLimitInfinityIcon.entityId, animDuration, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.NewLimitInput, animDuration, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.NewLimitInput, isChecked)
      end
    })
  else
    self.ScriptedEntityTweener:Play(self.NewLimitInfinityIcon.entityId, animDuration, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.NewLimitInfinityIcon.entityId, isChecked)
      end
    })
    UiElementBus.Event.SetIsEnabled(self.NewLimitInput, true)
    self.ScriptedEntityTweener:Play(self.NewLimitInput, animDuration, {opacity = 1, ease = "QuadOut"})
  end
  if not isChecked then
    UiTextInputBus.Event.SetText(self.NewLimitInput, GetLocalizedCurrency(0))
  end
end
function Treasury_DailyLimitPopup:OnAccept()
  if not self.isVisible then
    return
  end
  if self.NoLimitCheckbox:GetState() then
    GuildsComponentBus.Broadcast.RequestSetGuildTreasuryWithdrawalLimit(0)
  else
    local currentText = UiTextInputBus.Event.GetText(self.NewLimitInput)
    local value, success = GetValueFromLocalized(currentText, true)
    if not success or value == 0 then
      self:ShowErrorNotification("@ui_treasury_popup_invalidamount")
      return
    end
    GuildsComponentBus.Broadcast.RequestSetGuildTreasuryWithdrawalLimit(value)
  end
  self:SetVisibility(false)
end
function Treasury_DailyLimitPopup:OnCancel()
  if not self.isVisible then
    return
  end
  self:SetVisibility(false)
end
return Treasury_DailyLimitPopup
