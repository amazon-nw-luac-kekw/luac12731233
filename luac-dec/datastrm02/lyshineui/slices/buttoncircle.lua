local ButtonCircle = {
  Properties = {
    ButtonIcon = {
      default = EntityId()
    },
    ButtonGlow = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    }
  },
  isActive = false,
  isHovered = false,
  isEnabled = true,
  mWidth = 24,
  mHeight = 24,
  mIsUsingTooltip = false,
  mIsUsingGlow = false,
  BUTTON_STYLE_DEFAULT = 1,
  BUTTON_STYLE_QUESTION_MARK = 2,
  BUTTON_STYLE_NAV_BUTTON = 3,
  BUTTON_STYLE_QUESTION_MARK_DEFAULT_SIZE = 20,
  BUTTON_STYLE_QUESTION_MARK_BG = "LyShineUI/Images/Icons/Misc/icon_question.dds",
  BUTTON_STYLE_NAV_BUTTON_DEFAULT_WIDTH = 32,
  BUTTON_STYLE_NAV_BUTTON_DEFAULT_HEIGHT = 32,
  mButtonStyle = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ButtonCircle)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function ButtonCircle:OnInit()
  BaseElement.OnInit(self)
  self.backgroundColorUnfocused = self.UIStyle.COLOR_TAN
  self.backgroundColorFocused = self.UIStyle.COLOR_WHITE
  self.iconColorUnfocused = self.UIStyle.COLOR_GRAY_80
  self.iconColorFocused = self.UIStyle.COLOR_WHITE
  self:SetSize(self.mWidth, self.mHeight)
  self:SetButtonStyle(self.BUTTON_STYLE_DEFAULT)
end
function ButtonCircle:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function ButtonCircle:SetFocusCallback(command, table)
  self.focusCallback = command
  self.focusCallbackTable = table
end
function ButtonCircle:SetUnfocusCallback(command, table)
  self.unfocusCallback = command
  self.unfocusCallbackTable = table
end
function ButtonCircle:SetSize(width, height)
  self.mWidth = width
  if height == nil then
    self.mHeight = width
  else
    self.mHeight = height
  end
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function ButtonCircle:SetIsUsingGlow(enable)
  self.mIsUsingGlow = enable
end
function ButtonCircle:SetTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.mIsUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function ButtonCircle:SetButtonStyle(style)
  self.mButtonStyle = style
  if self.mButtonStyle == self.BUTTON_STYLE_QUESTION_MARK then
    self:SetSize(self.BUTTON_STYLE_QUESTION_MARK_DEFAULT_SIZE)
    self:SetBackgroundPathname(self.BUTTON_STYLE_QUESTION_MARK_BG)
    self:SetIconPathname(false)
    self:SetBackgroundColor(self.UIStyle.COLOR_QUESTION_MARK)
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0.5})
  elseif self.mButtonStyle == self.BUTTON_STYLE_NAV_BUTTON then
    self:SetSize(self.BUTTON_STYLE_NAV_BUTTON_DEFAULT_WIDTH, self.BUTTON_STYLE_NAV_BUTTON_DEFAULT_HEIGHT)
    self:SetIconPathname(false)
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0.95})
  end
end
function ButtonCircle:OnHover()
  if self.isEnabled then
    if self.mButtonStyle == self.BUTTON_STYLE_DEFAULT then
      if self.Properties.ButtonGlow:IsValid() and self.mIsUsingGlow then
        if self.timeline == nil then
          self.timeline = self.ScriptedEntityTweener:TimelineCreate()
          self.timeline:Add(self.ButtonGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
          self.timeline:Add(self.ButtonGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
          self.timeline:Add(self.ButtonGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
            opacity = 1,
            onComplete = function()
              self.timeline:Play()
            end
          })
        end
        self.ScriptedEntityTweener:Play(self.Properties.ButtonGlow, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(self.Properties.ButtonGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
          opacity = 1,
          delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
          onComplete = function()
            self.timeline:Play()
          end
        })
      end
    elseif self.mButtonStyle == self.BUTTON_STYLE_QUESTION_MARK then
      if self.timeline == nil then
        self.timeline = self.ScriptedEntityTweener:TimelineCreate()
        self.timeline:Add(self.entityId, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
        self.timeline:Add(self.entityId, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
        self.timeline:Add(self.entityId, self.UIStyle.DURATION_TIMELINE_HOLD, {
          opacity = 1,
          onComplete = function()
            self.timeline:Play()
          end
        })
      end
      self.ScriptedEntityTweener:Play(self.entityId, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.entityId, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
        opacity = 1,
        delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
        onComplete = function()
          self.timeline:Play()
        end
      })
      self.ScriptedEntityTweener:Play(self.entityId, self.UIStyle.DURATION_BUTTON_FADE_IN, {
        scaleX = 1.2,
        scaleY = 1.2,
        ease = "QuadOut"
      })
    elseif self.mButtonStyle == self.BUTTON_STYLE_NAV_BUTTON then
      self.ScriptedEntityTweener:Play(self.entityId, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
    end
    self:SetFocused(true)
    self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
  end
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  self.isHovered = true
  if self.focusCallbackTable and type(self.focusCallback) == "function" then
    self.focusCallback(self.focusCallbackTable)
  end
end
function ButtonCircle:OnUnhover()
  if self.isEnabled then
    if self.mButtonStyle == self.BUTTON_STYLE_DEFAULT then
      if self.Properties.ButtonGlow:IsValid() then
        self.ScriptedEntityTweener:Play(self.Properties.ButtonGlow, 0.15, {opacity = 0, ease = "QuadOut"})
      end
    elseif self.mButtonStyle == self.BUTTON_STYLE_QUESTION_MARK then
      self.ScriptedEntityTweener:Play(self.entityId, self.UIStyle.DURATION_BUTTON_FADE_OUT, {opacity = 0.5, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.entityId, self.UIStyle.DURATION_BUTTON_FADE_OUT, {
        scaleX = 1,
        scaleY = 1,
        ease = "QuadOut"
      })
    elseif self.mButtonStyle == self.BUTTON_STYLE_NAV_BUTTON then
      self.ScriptedEntityTweener:Play(self.entityId, self.UIStyle.DURATION_BUTTON_FADE_OUT, {opacity = 0.95, ease = "QuadOut"})
    end
    self:SetFocused(false)
  end
  self.isHovered = false
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if self.unfocusCallbackTable and type(self.unfocusCallback) == "function" then
    self.unfocusCallback(self.unfocusCallbackTable)
  end
end
function ButtonCircle:OnClick()
  if not self.isEnabled then
    return
  end
  if self.callbackTable and type(self.callback) == "function" then
    self.callback(self.callbackTable)
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function ButtonCircle:SetBackgroundColor(color)
  self:SetBackgroundColorFocused(color)
  self:SetBackgroundColorUnfocused(color)
end
function ButtonCircle:SetBackgroundColorUnfocused(color)
  self.backgroundColorUnfocused = color
  if not self.isFocused then
    UiImageBus.Event.SetColor(self.entityId, color)
  end
end
function ButtonCircle:SetBackgroundColorFocused(color)
  self.backgroundColorFocused = color
  if self.isFocused then
    UiImageBus.Event.SetColor(self.entityId, color)
  end
end
function ButtonCircle:SetIconColorUnfocused(color)
  self.iconColorUnfocused = color
  if not self.isFocused then
    UiImageBus.Event.SetColor(self.Properties.ButtonIcon, color)
  end
end
function ButtonCircle:SetIconColorFocused(color)
  self.iconColorFocused = color
  if self.isFocused then
    UiImageBus.Event.SetColor(self.Properties.ButtonIcon, color)
  end
end
function ButtonCircle:SetBackgroundPathname(pathname)
  UiImageBus.Event.SetSpritePathname(self.entityId, pathname)
end
function ButtonCircle:SetIconPathname(pathname, size)
  if not pathname then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIcon, false)
    return
  end
  if size ~= nil then
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ButtonIcon, size)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonIcon, size)
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.ButtonIcon, pathname)
end
function ButtonCircle:SetIsActive(isActive)
  self.isActive = isActive
  self:SetFocused(isActive or self.isHovered)
  if self.isActive then
    self.isEnabled = true
  end
end
function ButtonCircle:SetFocused(isFocused)
  if self.isActive then
    isFocused = true
  end
  if isFocused ~= self.isFocused then
    local iconColor = isFocused and self.iconColorFocused or self.iconColorUnfocused
    local backgroundColor = isFocused and self.backgroundColorFocused or self.backgroundColorUnfocused
    self.ScriptedEntityTweener:Play(self.entityId, self.UIStyle.DURATION_BUTTON_FADE_IN, {imgColor = backgroundColor, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonIcon, self.UIStyle.DURATION_BUTTON_FADE_IN, {imgColor = iconColor, ease = "QuadOut"})
    self.isFocused = isFocused
  end
end
function ButtonCircle:SetEnabled(isEnabled)
  self.isEnabled = isEnabled
  UiFaderBus.Event.SetFadeValue(self.entityId, self.isEnabled and 1 or 0.6)
  if not self.isEnabled then
    self.isActive = false
    self:SetFocused(false)
  end
end
function ButtonCircle:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return ButtonCircle
