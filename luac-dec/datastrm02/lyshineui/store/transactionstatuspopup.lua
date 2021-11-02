local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local TransactionStatusPopup = {
  Properties = {
    NoButton = {
      default = EntityId()
    },
    YesButton = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    ButtonsContainer = {
      default = EntityId()
    },
    TransactionStatusText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TransactionStatusPopup)
function TransactionStatusPopup:OnInit()
  BaseElement.OnInit(self)
  self.NoButton:SetCallback(self.OnNo, self)
  self.NoButton:SetButtonStyle(self.NoButton.BUTTON_STYLE_DEFAULT)
  self.NoButton:SetText("@ui_no")
  self.YesButton:SetButtonStyle(self.YesButton.BUTTON_STYLE_DEFAULT)
  self.YesButton:SetEnabled(true)
  self.YesButton:SetText("@ui_yes")
  self.YesButton:SetCallback(self.OnYes, self)
  self.FrameHeader:SetText("@ui_transaction_status")
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.CloseButton:SetCallback(self.OnClose, self)
end
function TransactionStatusPopup:OnShutdown()
end
function TransactionStatusPopup:OnYes()
  self.onRetryCallback(self.context)
end
function TransactionStatusPopup:OnNo()
  self.onNoCallback(self.context)
end
function TransactionStatusPopup:OnClose()
  self:SetIsEnabled(false)
end
function TransactionStatusPopup:SetTransactionInProgress()
  UiTextBus.Event.SetTextWithFlags(self.Properties.TransactionStatusText, "@ui_transaction_in_progress", eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.YesButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.NoButton, false)
end
function TransactionStatusPopup:SetTransactionSuccess()
  self:SetIsEnabled(false)
end
function TransactionStatusPopup:SetTransactionFailed(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TransactionStatusText, text, eUiTextSet_SetLocalized)
  self.NoButton:SetText("@ui_close")
  UiElementBus.Event.SetIsEnabled(self.Properties.NoButton, true)
end
function TransactionStatusPopup:SetTransactionTimedOut()
  UiTextBus.Event.SetTextWithFlags(self.Properties.TransactionStatusText, "@ui_transaction_timed_out", eUiTextSet_SetLocalized)
  self.NoButton:SetText("@ui_no")
  UiElementBus.Event.SetIsEnabled(self.Properties.YesButton, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.NoButton, true)
end
function TransactionStatusPopup:Invoke(context, onCloseCallback, onRetryCallback, onNoCallback)
  self.context = context
  self.onCloseCallback = onCloseCallback
  self.onRetryCallback = onRetryCallback
  self.onNoCallback = onNoCallback
  self:SetTransactionInProgress()
  self:SetIsEnabled(true)
end
function TransactionStatusPopup:IsEnabled()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function TransactionStatusPopup:SetIsEnabled(isEnabled)
  if self:IsEnabled() == isEnabled then
    return
  end
  if isEnabled then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
  else
    if self.context and type(self.onCloseCallback) == "function" then
      self.onCloseCallback(self.context)
    end
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.15, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.1, {opacity = 1, y = 0}, {
      opacity = 0,
      y = -10,
      ease = "QuadOut",
      delay = 0.15,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
  end
end
return TransactionStatusPopup
