local FiltersListItem = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonFocusGlow = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    }
  },
  mInputType = nil,
  mWidth = 315,
  mHeight = 40,
  mPressCallback = nil,
  mPressTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FiltersListItem)
function FiltersListItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.ButtonText, self.UIStyle.FONT_STYLE_MAP_FILTERITEM)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function FiltersListItem:SetInputType(value)
  self.mInputType = value
end
function FiltersListItem:GetInputType()
  return self.mInputType
end
function FiltersListItem:SetCallback(command, table)
  self.mPressCallback = command
  self.mPressTable = table
end
function FiltersListItem:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function FiltersListItem:GetWidth()
  return self.mWidth
end
function FiltersListItem:GetHeight()
  return self.mHeight
end
function FiltersListItem:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.ButtonText, value, eUiTextSet_SetLocalized)
end
function FiltersListItem:GetText()
  return UiTextBus.Event.GetText(self.ButtonText)
end
function FiltersListItem:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.ButtonText, 0.01, {textColor = color})
end
function FiltersListItem:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.ButtonText, value)
end
function FiltersListItem:GetFontSize()
  return UiTextBus.Event.GetFontSize(self.ButtonText)
end
function FiltersListItem:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.ButtonText, value)
end
function FiltersListItem:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.ButtonText)
end
function FiltersListItem:SetTextStyle(value)
  SetTextStyle(self.ButtonText, value)
end
function FiltersListItem:OnFocus()
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_IN
  local animDuration2 = 0.2
  local animDuration3 = 0.45
  local animDuration4 = 0.9
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration1, {opacity = 0.9, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Hover, animDuration1, {opacity = 1, ease = "QuadOut"})
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.8})
    self.timeline:Add(self.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = animDuration1,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover)
end
function FiltersListItem:OnUnfocus()
  local animDuration1 = 0.15
  local animDuration2 = 0.1
  self.ScriptedEntityTweener:Play(self.Properties.Hover, animDuration1, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.ButtonFocusGlow, animDuration1, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration1, {opacity = 0, ease = "QuadIn"})
end
function FiltersListItem:OnPress()
  if self.mPressCallback ~= nil and self.mPressTable ~= nil then
    if type(self.mPressCallback) == "function" then
      self.mPressCallback(self.mPressTable, self.entityId)
    else
      self.mPressTable[self.mPressCallback](self.mPressTable, self.entityId)
    end
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
function FiltersListItem:On()
  self.ScriptedEntityTweener:Play(self.ButtonText, 0.01, {opacity = 1})
  self.ScriptedEntityTweener:Play(self.Icon, 0.01, {opacity = 1})
  self:SetTextColor(self.UIStyle.COLOR_TAN)
  UiImageBus.Event.SetSpritePathname(self.Icon, "lyshineui/images/icons/worldmap/worldmap_iconVisible.png")
end
function FiltersListItem:Off()
  self:SetTextColor(self.UIStyle.COLOR_GRAY_50)
  self.ScriptedEntityTweener:Play(self.ButtonText, 0.01, {opacity = 0.5})
  self.ScriptedEntityTweener:Play(self.Icon, 0.01, {opacity = 0.5})
  UiImageBus.Event.SetSpritePathname(self.Icon, "lyshineui/images/icons/worldmap/worldmap_iconInvisible.png")
end
function FiltersListItem:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return FiltersListItem
