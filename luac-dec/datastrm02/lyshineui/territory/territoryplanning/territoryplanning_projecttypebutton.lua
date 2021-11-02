local TerritoryPlanning_ProjectTypeButton = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    LabelText = {
      default = EntityId()
    },
    SubLabelText = {
      default = EntityId()
    },
    ActiveText = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    IsActiveRing = {
      default = EntityId()
    },
    NumCompletedText = {
      default = EntityId()
    },
    PercentCompleteText = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    },
    Ring = {
      default = EntityId()
    },
    CircleContainer = {
      default = EntityId()
    },
    PercentBg = {
      default = EntityId()
    },
    PercentProgressBar = {
      default = EntityId()
    }
  },
  isClickable = true,
  isUsingTooltip = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_ProjectTypeButton)
function TerritoryPlanning_ProjectTypeButton:OnInit()
  BaseElement.OnInit(self)
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, canvasId)
  if self.Properties.Ring then
    self.ScriptedEntityTweener:Play(self.Properties.Ring, 40, {rotation = 0}, {timesToPlay = -1, rotation = -359})
  end
end
function TerritoryPlanning_ProjectTypeButton:OnShutdown()
  if self.Properties.Ring then
    self.ScriptedEntityTweener:Stop(self.Properties.Ring)
  end
end
function TerritoryPlanning_ProjectTypeButton:SetIsClickable(isClickable)
  if self.isClickable == isClickable then
    return
  end
  self.isClickable = isClickable
  local fadeValue = isClickable and 1 or 0.5
  UiFaderBus.Event.SetFadeValue(self.entityId, fadeValue)
end
function TerritoryPlanning_ProjectTypeButton:SetLabelText(value, skipLocalization)
  locFlag = skipLocalization == true and eUiTextSet_SetAsIs or eUiTextSet_SetLocalized
  UiTextBus.Event.SetTextWithFlags(self.Properties.LabelText, value, locFlag)
end
function TerritoryPlanning_ProjectTypeButton:SetSubLabelText(value, skipLocalization)
  locFlag = skipLocalization == true and eUiTextSet_SetAsIs or eUiTextSet_SetLocalized
  UiTextBus.Event.SetTextWithFlags(self.Properties.SubLabelText, value, locFlag)
end
function TerritoryPlanning_ProjectTypeButton:SetPercentCompleteText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PercentCompleteText, value, eUiTextSet_SetAsIs)
  if value == "" then
    UiElementBus.Event.SetIsEnabled(self.Properties.PercentBg, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.PercentBg, true)
  end
end
function TerritoryPlanning_ProjectTypeButton:SetPercentFill(value)
  UiImageBus.Event.SetFillAmount(self.Properties.PercentProgressBar, value)
end
function TerritoryPlanning_ProjectTypeButton:SetIconPath(path)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, path)
end
function TerritoryPlanning_ProjectTypeButton:SetPosition(pos)
  UiTransformBus.Event.SetLocalPosition(self.entityId, pos)
end
function TerritoryPlanning_ProjectTypeButton:SetProjectTypeActive(isActive)
  UiElementBus.Event.SetIsEnabled(self.Properties.IsActiveRing, isActive)
  UiElementBus.Event.SetIsEnabled(self.Properties.ActiveText, isActive)
  UiElementBus.Event.SetIsEnabled(self.Properties.SubLabelText, not isActive)
end
function TerritoryPlanning_ProjectTypeButton:SetNumComplete(numComplete)
  if not self.Properties.NumCompletedText:IsValid() then
    return
  end
  UiTextBus.Event.SetText(self.Properties.NumCompletedText, tostring(numComplete))
end
function TerritoryPlanning_ProjectTypeButton:SetTooltip(value)
  if self.tooltip == value then
    return
  end
  self.tooltip = value
  if value == nil or value == "" then
    self.isUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.isUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function TerritoryPlanning_ProjectTypeButton:SetCallback(callbackFn, callbackSelf)
  self.callbackFn = callbackFn
  self.callbackSelf = callbackSelf
end
function TerritoryPlanning_ProjectTypeButton:SetFocusCallback(callbackFn, callbackSelf)
  self.focusFn = callbackFn
  self.focusSelf = callbackSelf
end
function TerritoryPlanning_ProjectTypeButton:SetUnfocusCallback(callbackFn, callbackSelf)
  self.unfocusFn = callbackFn
  self.unfocusSelf = callbackSelf
end
function TerritoryPlanning_ProjectTypeButton:ExecuteCallback(callbackFn, callbackSelf)
  if callbackFn and callbackSelf then
    callbackFn(callbackSelf, self)
  end
end
function TerritoryPlanning_ProjectTypeButton:OnCanvasEnabledChanged(isEnabled)
  if isEnabled then
    self.ScriptedEntityTweener:Play(self.Properties.IsActiveRing, 4, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.IsActiveRing)
  end
end
function TerritoryPlanning_ProjectTypeButton:OnFocus()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  self:ExecuteCallback(self.focusFn, self.focusSelf)
  if not self.isClickable then
    return
  end
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {
    opacity = 0,
    scaleX = 1.1,
    scaleY = 1.1
  }, {
    opacity = 1,
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.CircleContainer, 0.1, {scaleX = 1, scaleY = 1}, {
    scaleX = 1.025,
    scaleY = 1.025,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Material_Hover)
end
function TerritoryPlanning_ProjectTypeButton:OnUnfocus()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  self:ExecuteCallback(self.unfocusFn, self.unfocusSelf)
  if not self.isClickable then
    return
  end
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.05, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.CircleContainer, 0.1, {scaleX = 1.025, scaleY = 1.025}, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
end
function TerritoryPlanning_ProjectTypeButton:OnClick()
  if not self.isClickable then
    return
  end
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  self:ExecuteCallback(self.callbackFn, self.callbackSelf)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return TerritoryPlanning_ProjectTypeButton
