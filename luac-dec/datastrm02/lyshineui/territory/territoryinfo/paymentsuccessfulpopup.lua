local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PaymentSuccessfulPopup = {
  Properties = {
    CloseButton = {
      default = EntityId()
    },
    PaidMessage = {
      default = EntityId()
    },
    AmountPaid = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PaymentSuccessfulPopup)
function PaymentSuccessfulPopup:OnInit()
  BaseElement.OnInit(self)
  self.CloseButton:SetCallback(self.OnClose, self)
  self.CloseButton:SetText("@ui_close")
  self.CloseButton:SetButtonStyle(self.CloseButton.BUTTON_STYLE_CTA)
end
function PaymentSuccessfulPopup:ShowPaymentSuccessfulPopup(territoryId, amount, viewLogsCallback, context)
  self.territoryId = territoryId
  self.amount = amount
  self.viewLogsCallback = viewLogsCallback
  self.context = context
  UiTextBus.Event.SetText(self.Properties.AmountPaid, GetLocalizedCurrency(amount))
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function PaymentSuccessfulPopup:OnClose()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 1, y = 0}, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
      self.IsClosing = false
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
function PaymentSuccessfulPopup:OnViewLogs()
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.viewLogsCallback(self.context)
end
return PaymentSuccessfulPopup
