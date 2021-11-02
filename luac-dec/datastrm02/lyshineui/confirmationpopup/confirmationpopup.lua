local ConfirmationPopup = {
  Properties = {
    Container = {
      default = EntityId()
    },
    ScreenScrim = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    ConfirmationButton = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    Slider = {
      default = EntityId()
    }
  },
  isShowing = false,
  CONFIRM_ACTION_NAME = "ui_interact"
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ConfirmationPopup)
local CryActionCommon = RequireScript("LyShineUI._Common.CryActionCommon")
function ConfirmationPopup:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterOpenEvent("ConfirmationPopup", self.canvasId)
  DynamicBus.ConfirmationPopup.Connect(self.entityId, self)
  self.ConfirmationButton:SetText("@ui_confirm")
  self.ConfirmationButton:SetTextAlignment(self.ConfirmationButton.TEXT_ALIGN_CENTER)
  self.ConfirmationButton:SetHint(self.CONFIRM_ACTION_NAME, true)
  self.ConfirmationButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_CTA)
  self.ConfirmationButton:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_CTA)
  self.ConfirmationButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
  self.ConfirmationButton:SetButtonBgTexture(self.ConfirmationButton.BG_TEXTURE_STYLE_COLOR_BACKGROUND)
  self.CancelButton:SetText("@ui_cancel")
  self.Slider:SetSliderMinValue(1)
  self.Slider:HideCrownIcons()
  self.Slider:SetCallback(self.OnSliderChange, self)
  SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_CONFIRMATION_POPUP_TITLE)
  SetTextStyle(self.Properties.Description, self.UIStyle.FONT_STYLE_CONFIRMATION_POPUP_TEXT)
  self.initialDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  self.initialDescriptionColor = self.UIStyle.COLOR_GRAY_80
end
function ConfirmationPopup:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.ConfirmationPopup.Disconnect(self.entityId, self)
  self.isShowing = false
end
function ConfirmationPopup:ShowConfirmationPopup(positionVector, confirmationData)
  if self.isShowing then
    return
  end
  PositionEntityOnScreen(self.Properties.Container, positionVector, {
    right = 12,
    top = 48,
    bottom = 48
  })
  self.drawOrderOverride = confirmationData.drawOrderOverride
  if self.drawOrderOverride then
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.drawOrderOverride)
  end
  self.hintDisabled = confirmationData.disableHint
  if self.hintDisabled then
    self.ConfirmationButton:SetHint()
    self.ConfirmationButton:SetTextAlignment(self.ConfirmationButton.TEXT_ALIGN_CENTER, 0)
  end
  self.confirmCallback = confirmationData.confirmCallback
  self.confirmCallbackTable = confirmationData.confirmCallbackTable
  self.ConfirmationButton:SetCallback(self.OnConfirmPress, self)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, confirmationData.title, eUiTextSet_SetLocalized)
  self.CancelButton:SetCallback(self.HideConfirmationPopup, self)
  CryActionCommon:RegisterActionListener(self, self.CONFIRM_ACTION_NAME, 1, self.OnCryAction)
  self.sliderEnabled = confirmationData.sliderMax ~= nil
  local height = self.sliderEnabled and 180 or 150
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Container, height)
  UiElementBus.Event.SetIsEnabled(self.Properties.Slider, self.sliderEnabled)
  if self.sliderEnabled then
    self.salvageMin = confirmationData.salvageMin
    self.salvageMax = confirmationData.salvageMax
    self.salvageItemName = confirmationData.salvageItemName
    self.Slider:SetSliderMaxValue(confirmationData.sliderMax)
    self.Slider:SetSliderValue(1)
    local salvageData = confirmationData.salvageData
    if salvageData and 1 < #salvageData then
      for i = 1, #salvageData do
        if confirmationData.salvageGuaranteedIndex ~= i then
          local itemData = ItemDataManagerBus.Broadcast.GetItemData(Math.CreateCrc32(salvageData[i].itemId))
          self.gemMessage = GetLocalizedReplacementText("@inv_salvage_tooltip_additional_item", {
            itemData.displayName
          })
        end
      end
    else
      self.gemMessage = ""
    end
    self:UpdateDescriptionForSliderValue(1)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.Description, confirmationData.description, eUiTextSet_SetLocalized)
    self:UpdateHeight()
  end
  local descriptionColor = confirmationData.descriptionColorOverride and confirmationData.descriptionColorOverride or self.initialDescriptionColor
  UiTextBus.Event.SetColor(self.Properties.Description, descriptionColor)
  if confirmationData.closeFlyout then
    DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
  end
  self.dataLayer:SetScreenEnabled("ConfirmationPopup", true)
  self.isShowing = true
end
function ConfirmationPopup:HideConfirmationPopup()
  if not self.isShowing then
    return
  end
  if self.drawOrderOverride then
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.initialDrawOrder)
  end
  if self.hintDisabled then
    self.ConfirmationButton:SetHint(self.CONFIRM_ACTION_NAME, true)
  end
  CryActionCommon:UnregisterActionListener(self, self.CONFIRM_ACTION_NAME)
  self.ConfirmationButton:SetCallback(nil, nil)
  self.dataLayer:SetScreenEnabled("ConfirmationPopup", false)
  self.isShowing = false
end
function ConfirmationPopup:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.ScriptedEntityTweener:Play(self.Properties.ScreenScrim, 0.3, {opacity = 0}, {opacity = 0.4, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Container, 0.3, {opacity = 0}, {opacity = 1})
end
function ConfirmationPopup:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.ScriptedEntityTweener:Play(self.Properties.Container, 0.3, {
    opacity = 0,
    onComplete = function()
      LyShineManagerBus.Broadcast.TransitionOutComplete()
    end
  })
end
function ConfirmationPopup:OnConfirmPress()
  local sliderValue
  if self.sliderEnabled then
    sliderValue = self.Slider:GetSliderValue()
  end
  self:ExecuteCallback(sliderValue)
  self:HideConfirmationPopup()
end
function ConfirmationPopup:ExecuteCallback(sliderValue)
  if self.confirmCallback and self.confirmCallbackTable then
    self.confirmCallback(self.confirmCallbackTable, sliderValue)
  end
end
function ConfirmationPopup:UpdateHeight()
  local height = self.sliderEnabled and 180 or 150
  local descriptionHeight = UiTextBus.Event.GetTextHeight(self.Properties.Description)
  local descriptionPadding = 5
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Container, height + descriptionHeight + descriptionPadding)
end
function ConfirmationPopup:OnCryAction(actionName, value)
  local canvasVisible = UiCanvasBus.Event.GetEnabled(self.canvasId)
  if self.isShowing and value == 1 and canvasVisible then
    self.ConfirmationButton:OnPress()
    self:HideConfirmationPopup()
  elseif not self.isShowing then
    self:HideConfirmationPopup()
  end
  return true
end
function ConfirmationPopup:OnSliderChange(slider)
  local value = slider:GetValue()
  self:UpdateDescriptionForSliderValue(value)
end
function ConfirmationPopup:UpdateDescriptionForSliderValue(value)
  local text
  if self.salvageMin ~= self.salvageMax then
    text = GetLocalizedReplacementText("@inv_salvage_tooltip_range", {
      min = self.salvageMin * value,
      max = self.salvageMax * value,
      itemName = self.salvageItemName,
      gemMessage = self.gemMessage
    })
  else
    text = GetLocalizedReplacementText("@inv_salvage_tooltip", {
      numItems = self.salvageMin * value,
      itemName = self.salvageItemName,
      gemMessage = self.gemMessage
    })
  end
  UiTextBus.Event.SetText(self.Properties.Description, text)
  self:UpdateHeight()
end
return ConfirmationPopup
