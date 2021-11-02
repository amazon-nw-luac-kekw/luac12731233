local AttributeThresholdIcon = {
  Properties = {
    ActiveFrame = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    },
    OuterCircleMask = {
      default = EntityId()
    },
    OuterCircle = {
      default = EntityId()
    },
    ExpandingGlow = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    }
  },
  outerCirclePath = "LyShineUI/Images/Attributes/attributeOuterCircle.dds",
  STATE_NEUTRAL = 0,
  STATE_PENDING = 1,
  STATE_ACTIVE = 2,
  currentState = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AttributeThresholdIcon)
function AttributeThresholdIcon:OnInit()
  BaseElement.OnInit(self)
  UiImageBus.Event.SetSpritePathname(self.Properties.OuterCircle, self.outerCirclePath)
  self.ScriptedEntityTweener:Set(self.Properties.Glow, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.OuterCircleMask, {scaleX = 0.8, scaleY = 0.8})
end
function AttributeThresholdIcon:SetThresholdIconData(data, posX)
  self.threshold = data.value
  self.activeText = data.activeText
  self.inactiveText = data.inactiveText
end
function AttributeThresholdIcon:SetThresholdIconState(state, color, justBecameActive)
  if state == self.STATE_PENDING then
    UiElementBus.Event.SetIsEnabled(self.Properties.ActiveFrame, true)
    UiImageBus.Event.SetColor(self.Properties.ActiveFrame, self.UIStyle.COLOR_ATTRIBUTE_POINT_PENDING)
    if not self.timeline then
      self.timeline = self.ScriptedEntityTweener:TimelineCreate()
      self.timeline:Add(self.Properties.ActiveFrame, self.UIStyle.DURATION_TIMELINE_FADE_IN, {
        imgColor = self.UIStyle.COLOR_ATTRIBUTE_POINT_PENDING
      })
      self.timeline:Add(self.Properties.ActiveFrame, self.UIStyle.DURATION_TIMELINE_HOLD, {
        imgColor = self.UIStyle.COLOR_ATTRIBUTE_POINT_PENDING
      })
      self.timeline:Add(self.Properties.ActiveFrame, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
        imgColor = self.UIStyle.COLOR_GREEN_40,
        onComplete = function()
          self.timeline:Play()
        end
      })
    end
    self.timeline:Play()
  elseif state == self.STATE_ACTIVE then
    UiElementBus.Event.SetIsEnabled(self.Properties.ActiveFrame, true)
    UiImageBus.Event.SetColor(self.Properties.ActiveFrame, color)
    if self.timeline ~= nil then
      self.timeline:Stop()
    end
    if justBecameActive then
      self.ScriptedEntityTweener:Play(self.Properties.Glow, 1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
      local outerCircleDuration = 0.6
      self.ScriptedEntityTweener:Play(self.Properties.OuterCircleMask, outerCircleDuration, {scaleX = 2, scaleY = 2}, {
        scaleX = 0.8,
        scaleY = 0.8,
        ease = "QuadOut"
      })
      UiImageBus.Event.SetColor(self.Properties.OuterCircle, color)
      self.ScriptedEntityTweener:Play(self.Properties.OuterCircle, outerCircleDuration, {
        imgColor = self.UIStyle.COLOR_TAN,
        opacity = 0.8
      }, {
        imgColor = color,
        opacity = 0,
        ease = "QuadOut"
      })
      UiImageBus.Event.SetColor(self.Properties.ExpandingGlow, color)
      self.ScriptedEntityTweener:Play(self.Properties.ExpandingGlow, outerCircleDuration, {
        scaleX = 2,
        scaleY = 2,
        imgColor = self.UIStyle.COLOR_WHITE
      }, {
        scaleX = 3,
        scaleY = 3,
        imgColor = color,
        ease = "QuadOut"
      })
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ActiveFrame, false)
  end
  self.currentState = state
end
function AttributeThresholdIcon:OnFocus()
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.3, {opacity = 1, ease = "QuadOut"})
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
  if flyoutVisible and flyoutMenu.invokingEntityId == self.entityId then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetIgnoreHoverExit(true)
  flyoutMenu:SetAllowResetOfIgnoreHoverExit(false)
  local rows = {}
  local description = self.currentState == self.STATE_ACTIVE and self.activeText or self.inactiveText
  local thresholdColor = self.currentState == self.STATE_ACTIVE and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_RED_MEDIUM
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_AttributeThreshold,
    description = description,
    threshold = self.threshold,
    thresholdColor = thresholdColor
  })
  if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
    flyoutMenu:SetOpenLocation(self.entityId)
    flyoutMenu:SetSourceHoverOnly(true)
    flyoutMenu:DockToCursor(12)
    flyoutMenu:SetRowData(rows)
  end
end
function AttributeThresholdIcon:OnUnfocus()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  flyoutMenu:SetIgnoreHoverExit(false)
  flyoutMenu:SetAllowResetOfIgnoreHoverExit(true)
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.2, {opacity = 0, ease = "QuadOut"})
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
end
function AttributeThresholdIcon:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return AttributeThresholdIcon
