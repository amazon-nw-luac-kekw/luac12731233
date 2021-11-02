local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local SelectPaymentOptionPopup = {
  Properties = {
    CloseButton = {
      default = EntityId()
    },
    ConfirmButton = {
      default = EntityId()
    },
    AmountDue = {
      default = EntityId()
    },
    PersonalWalletCheck = {
      default = EntityId()
    },
    CompanyWalletCheck = {
      default = EntityId()
    },
    PersonalWalletFrameButton = {
      default = EntityId()
    },
    CompanyWalletFrameButton = {
      default = EntityId()
    },
    PersonalBalance = {
      default = EntityId()
    },
    CompanyBalance = {
      default = EntityId()
    },
    PersonalNewBalance = {
      default = EntityId()
    },
    CompanyNewBalance = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    PersonalWalletCheckContainer = {
      default = EntityId()
    },
    CompanyWalletCheckContainer = {
      default = EntityId()
    },
    PersonalWalletText = {
      default = EntityId()
    },
    CompanyWalletText = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SelectPaymentOptionPopup)
function SelectPaymentOptionPopup:OnInit()
  BaseElement.OnInit(self)
  self.CloseButton:SetCallback(self.OnClose, self)
  self.ConfirmButton:SetCallback(self.OnConfirm, self)
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  self.originalMoneyColor = UiTextBus.Event.GetColor(self.Properties.PersonalBalance)
end
function SelectPaymentOptionPopup:UpdateAmountDue(amount)
  self.amount = amount
  UiTextBus.Event.SetText(self.Properties.AmountDue, GetLocalizedCurrency(self.amount))
  self.personalAmount = 0
  self.companyAmount = 0
  UiElementBus.Event.SetIsEnabled(self.Properties.PersonalWalletCheck, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompanyWalletCheck, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PersonalWalletCheckContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompanyWalletCheckContainer, false)
  UiTextBus.Event.SetColor(self.Properties.PersonalWalletText, self.UIStyle.COLOR_TAN)
  UiTextBus.Event.SetColor(self.Properties.CompanyWalletText, self.UIStyle.COLOR_TAN)
  UiTextBus.Event.SetText(self.Properties.AmountDue, GetLocalizedCurrency(self.amount))
  UiTextBus.Event.SetText(self.Properties.PersonalBalance, GetLocalizedCurrency(self.personalAmount))
  UiTextBus.Event.SetText(self.Properties.PersonalNewBalance, GetLocalizedCurrency(self.personalAmount))
  UiTextBus.Event.SetText(self.Properties.CompanyBalance, GetLocalizedCurrency(self.companyAmount))
  UiTextBus.Event.SetText(self.Properties.CompanyNewBalance, GetLocalizedCurrency(self.companyAmount))
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PersonalWalletFrameButton, false)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.CompanyWalletFrameButton, false)
  self.ConfirmButton:SetText("@ui_select_payment_option")
  self.ConfirmButton:SetEnabled(false)
  UiTextBus.Event.SetColor(self.Properties.PersonalBalance, self.UIStyle.COLOR_INSUFFICIENT_QUANTITY)
  UiTextBus.Event.SetColor(self.Properties.CompanyBalance, self.UIStyle.COLOR_INSUFFICIENT_QUANTITY)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", function(self, amount)
    self.personalAmount = amount or 0
    UiTextBus.Event.SetText(self.Properties.PersonalBalance, GetLocalizedCurrency(self.personalAmount))
    UiTextBus.Event.SetText(self.Properties.PersonalNewBalance, GetLocalizedCurrency(self.personalAmount))
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PersonalWalletFrameButton, self.personalAmount >= self.amount)
    if self.personalAmount >= self.amount then
      UiTextBus.Event.SetColor(self.Properties.PersonalBalance, self.originalMoneyColor)
      self.ScriptedEntityTweener:Set(self.Properties.PersonalWalletFrameButton, {opacity = 1})
    else
      self.ScriptedEntityTweener:Set(self.Properties.PersonalWalletFrameButton, {opacity = 0.3})
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, socialEntityId)
    if socialEntityId then
      self:BusConnect(GuildNotificationsBus, socialEntityId)
    end
  end)
  SocialDataHandler:GetTreasuryData_ServerCall(self, function(self, treasuryData)
    if treasuryData then
      self:SetupTreasuryButton(treasuryData.currentFunds)
    end
  end, nil)
end
function SelectPaymentOptionPopup:SetupTreasuryButton(amount)
  self.companyAmount = amount
  UiTextBus.Event.SetText(self.Properties.CompanyBalance, GetLocalizedCurrency(self.companyAmount))
  UiTextBus.Event.SetText(self.Properties.CompanyNewBalance, GetLocalizedCurrency(self.companyAmount))
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.CompanyWalletFrameButton, self.companyAmount >= self.amount)
  if self.companyAmount >= self.amount then
    UiTextBus.Event.SetColor(self.Properties.CompanyBalance, self.originalMoneyColor)
    self.ScriptedEntityTweener:Set(self.Properties.CompanyWalletFrameButton, {opacity = 1})
  else
    UiTextBus.Event.SetColor(self.Properties.CompanyBalance, self.UIStyle.COLOR_INSUFFICIENT_QUANTITY)
    self.ScriptedEntityTweener:Set(self.Properties.CompanyWalletFrameButton, {opacity = 0.3})
    if self.useCompanyWallet then
      self.useCompanyWallet = false
      self.ConfirmButton:SetText("@ui_select_payment_option")
      self.ConfirmButton:SetEnabled(false)
      UiElementBus.Event.SetIsEnabled(self.Properties.CompanyWalletCheck, false)
    end
  end
end
function SelectPaymentOptionPopup:OnGuildTreasuryChanged(newAmount)
  self:SetupTreasuryButton(newAmount)
end
function SelectPaymentOptionPopup:ShowPaymentOptionPopup(amount, callback, context)
  self.amount = amount
  self.callback = callback
  self.context = context
  self:UpdateAmountDue(amount)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function SelectPaymentOptionPopup:OnPaymentSelected(useCompanyWallet)
  self.useCompanyWallet = useCompanyWallet
  self.ConfirmButton:SetEnabled(true)
  self.ConfirmButton:SetText("@ui_confirm")
  if self.useCompanyWallet then
    UiTextBus.Event.SetText(self.Properties.CompanyNewBalance, GetLocalizedCurrency(self.companyAmount - self.amount))
    UiTextBus.Event.SetText(self.Properties.PersonalNewBalance, GetLocalizedCurrency(self.personalAmount))
  else
    UiTextBus.Event.SetText(self.Properties.CompanyNewBalance, GetLocalizedCurrency(self.companyAmount))
    UiTextBus.Event.SetText(self.Properties.PersonalNewBalance, GetLocalizedCurrency(self.personalAmount - self.amount))
  end
end
function SelectPaymentOptionPopup:OnSelectPersonal()
  UiElementBus.Event.SetIsEnabled(self.Properties.PersonalWalletCheck, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompanyWalletCheck, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PersonalWalletCheckContainer, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompanyWalletCheckContainer, false)
  UiTextBus.Event.SetColor(self.Properties.PersonalWalletText, self.UIStyle.COLOR_WHITE)
  UiTextBus.Event.SetColor(self.Properties.CompanyWalletText, self.UIStyle.COLOR_TAN)
  self:OnPaymentSelected(false)
end
function SelectPaymentOptionPopup:OnSelectCompany()
  UiElementBus.Event.SetIsEnabled(self.Properties.PersonalWalletCheck, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompanyWalletCheck, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PersonalWalletCheckContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CompanyWalletCheckContainer, true)
  UiTextBus.Event.SetColor(self.Properties.PersonalWalletText, self.UIStyle.COLOR_TAN)
  UiTextBus.Event.SetColor(self.Properties.CompanyWalletText, self.UIStyle.COLOR_WHITE)
  self:OnPaymentSelected(true)
end
function SelectPaymentOptionPopup:OnClose()
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
  self.dataLayer:UnregisterObservers(self)
end
function SelectPaymentOptionPopup:OnConfirm()
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
  self.dataLayer:UnregisterObservers(self)
  self.callback(self.context, self.useCompanyWallet)
end
function SelectPaymentOptionPopup:OnHoverStart(entityId)
  local hover = UiElementBus.Event.FindChildByName(entityId, "Hover")
  self.ScriptedEntityTweener:Play(hover, 0.1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function SelectPaymentOptionPopup:OnHoverEnd(entityId)
  local hover = UiElementBus.Event.FindChildByName(entityId, "Hover")
  self.ScriptedEntityTweener:Play(hover, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
return SelectPaymentOptionPopup
