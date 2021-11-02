local DyeSelector = {
  Properties = {
    DyeColor = {
      default = EntityId()
    },
    Arrow = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    ClearButton = {
      default = EntityId()
    },
    ClearFrame = {
      default = EntityId()
    },
    ClearHighlight = {
      default = EntityId()
    }
  },
  index = 0,
  initialColor = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DyeSelector)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function DyeSelector:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClearButton, false)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.DyeColor, false)
  self.DyeColor:SetColor(0)
end
function DyeSelector:OnShutdown()
  if self.highlightTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.highlightTimeline)
  end
end
function DyeSelector:SetCallback(context, callback)
  self.context = context
  self.callback = callback
end
function DyeSelector:SetPicker(picker)
  self.picker = picker
end
function DyeSelector:GetColor()
  return self.index
end
function DyeSelector:GetInitialColor()
  return self.initialColor
end
function DyeSelector:OnFocus()
  if not self.highlightTimeline then
    self.highlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.15})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.3})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.3,
      onComplete = function()
        self.highlightTimeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, self.UIStyle.DURATION_BUTTON_FADE_IN, tweenerCommon.opacityTo60)
  self.ScriptedEntityTweener:PlayC(self.Properties.Arrow, self.UIStyle.DURATION_BUTTON_FADE_IN, tweenerCommon.imgToWhite)
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, true)
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.3, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.3,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.highlightTimeline:Play()
    end
  })
end
function DyeSelector:OnUnfocus()
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, 0.15, tweenerCommon.opacityTo20)
  self.ScriptedEntityTweener:PlayC(self.Properties.Arrow, 0.15, tweenerCommon.imgToTan)
  if self.highlightTimeline then
    self.highlightTimeline:Stop()
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, false)
end
function DyeSelector:OnPress()
  if not self.picker then
    return
  end
  self.picker:ToggleVisibilityAndSetCallback(self, self.ColorSelected, self.index)
  local itemWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  local itemHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  local itemPosition = UiTransformBus.Event.GetViewportPosition(self.entityId)
  itemPosition.x = itemPosition.x - itemWidth / 2
  itemPosition.y = itemPosition.y - itemHeight / 2
  itemPosition.y = itemPosition.y - 150
  PositionEntityOnScreen(self.picker.entityId, itemPosition)
end
function DyeSelector:OnCancelFocus()
  if not self.clearHighlightTimeline then
    self.clearHighlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.clearHighlightTimeline:Add(self.Properties.ClearHighlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.15})
    self.clearHighlightTimeline:Add(self.Properties.ClearHighlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.3})
    self.clearHighlightTimeline:Add(self.Properties.ClearHighlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.3,
      onComplete = function()
        self.clearHighlightTimeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.ClearFrame, self.UIStyle.DURATION_BUTTON_FADE_IN, tweenerCommon.opacityTo60)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClearHighlight, true)
  self.ScriptedEntityTweener:Play(self.Properties.ClearHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.3, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ClearHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.3,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.clearHighlightTimeline:Play()
    end
  })
end
function DyeSelector:OnCancelUnfocus()
  self.ScriptedEntityTweener:PlayC(self.Properties.ClearFrame, 0.15, tweenerCommon.opacityTo20)
  if self.clearHighlightTimeline then
    self.clearHighlightTimeline:Stop()
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ClearHighlight, false)
end
function DyeSelector:OnCancelPress()
  self:ColorSelected(0)
end
function DyeSelector:SetInitialColor(index)
  self.initialColor = index
  self:ColorSelectedInternal(index, true)
end
function DyeSelector:ColorSelected(index, keepPickerOpen)
  if self.picker and not keepPickerOpen then
    self.picker:SetVisible(false)
  end
  if not keepPickerOpen or self.index ~= index then
    do
      local confirmColor = not keepPickerOpen
      local replacingEntitledColor = confirmColor and self.lastConfirmedIndex == self.initialColor and self.picker:IsColorEntitlement(self.initialColor)
      if replacingEntitledColor then
        PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_overwrite_premium_dye_warning_title", "@ui_overwrite_premium_dye_warning_text", "confirmReplacePremiumColor", self, function(self, result, eventId)
          if result == ePopupResult_Yes then
            self:ColorSelectedInternal(index, confirmColor)
          else
            self:ColorSelectedInternal(self.initialColor, confirmColor)
          end
        end)
        return
      end
      self:ColorSelectedInternal(index, confirmColor)
    end
  end
end
function DyeSelector:ColorSelectedInternal(index, confirmColor)
  self.index = index
  if confirmColor then
    self.lastConfirmedIndex = index
  end
  self.DyeColor:SetColor(self.index)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClearButton, self.index > 0)
  if self.callback then
    self.callback(self.context)
  end
end
return DyeSelector
