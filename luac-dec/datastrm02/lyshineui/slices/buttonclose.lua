local ButtonClose = {
  Properties = {
    CloseButtonIcon = {
      default = EntityId()
    }
  },
  BUTTON_STYLE_DIAMOND = 1,
  BUTTON_STYLE_REGULAR = 2,
  BUTTON_STYLE_DIAMOND_ICON_FOCUS = "LyShineUI/Images/slices/ButtonCloseDiamond/buttoncloseDiamond_focus.dds",
  BUTTON_STYLE_DIAMOND_ICON_UNFOCUS = "LyShineUI/Images/slices/ButtonCloseDiamond/buttoncloseDiamond.dds",
  BUTTON_STYLE_DIAMOND_ICON_DISABLED = "LyShineUI/Images/slices/ButtonCloseDiamond/buttoncloseDiamondDisabled.dds",
  BUTTON_STYLE_REGULAR_ICON = "LyShineUI/Images/Icons/Misc/icon_close.dds",
  buttonStyle = nil,
  isEnabled = true
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ButtonClose)
function ButtonClose:OnInit()
  BaseElement.OnInit(self)
  self:SetButtonStyle(self.BUTTON_STYLE_DIAMOND)
end
function ButtonClose:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function ButtonClose:SetButtonStyle(style)
  self.buttonStyle = style
  if self.buttonStyle == self.BUTTON_STYLE_DIAMOND then
    self:SetBackgroundColor(self.UIStyle.COLOR_WHITE)
    self:SetBackground(self.BUTTON_STYLE_DIAMOND_ICON_UNFOCUS)
  elseif self.buttonStyle == self.BUTTON_STYLE_REGULAR then
    self:SetBackgroundColor(self.UIStyle.COLOR_TAN)
    self:SetBackground(self.BUTTON_STYLE_REGULAR_ICON)
  end
end
function ButtonClose:SetBackground(path)
  UiImageBus.Event.SetSpritePathname(self.Properties.CloseButtonIcon, path)
end
function ButtonClose:SetBackgroundColor(color)
  UiImageBus.Event.SetColor(self.Properties.CloseButtonIcon, color)
end
function ButtonClose:OnHover()
  if not self.isEnabled then
    return
  end
  if self.buttonStyle == self.BUTTON_STYLE_DIAMOND then
    self:SetBackground(self.BUTTON_STYLE_DIAMOND_ICON_FOCUS)
  elseif self.buttonStyle == self.BUTTON_STYLE_REGULAR then
    self:SetBackgroundColor(self.UIStyle.COLOR_WHITE)
    self.ScriptedEntityTweener:Play(self.entityId, 0.1, {
      scaleX = 1.1,
      scaleY = 1.1,
      ease = "QuadOut"
    })
  end
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function ButtonClose:OnUnhover()
  if not self.isEnabled then
    return
  end
  if self.buttonStyle == self.BUTTON_STYLE_DIAMOND then
    self:SetBackground(self.BUTTON_STYLE_DIAMOND_ICON_UNFOCUS)
  elseif self.buttonStyle == self.BUTTON_STYLE_REGULAR then
    self:SetBackgroundColor(self.UIStyle.COLOR_TAN)
    self.ScriptedEntityTweener:Play(self.entityId, 0.1, {scaleX = 1, scaleY = 1})
  end
end
function ButtonClose:SetEnabled(isEnabled)
  if self.isEnabled == isEnabled then
    return
  end
  self.isEnabled = isEnabled
  if self.buttonStyle == self.BUTTON_STYLE_DIAMOND then
    if self.isEnabled == false then
      self:SetBackground(self.BUTTON_STYLE_DIAMOND_ICON_DISABLED)
    else
      self:SetBackground(self.BUTTON_STYLE_DIAMOND_ICON_UNFOCUS)
    end
  elseif self.buttonStyle == self.BUTTON_STYLE_REGULAR then
    if self.isEnabled == false then
      self:SetBackgroundColor(self.UIStyle.COLOR_GRAY_60)
    else
      self:SetBackgroundColor(self.UIStyle.COLOR_TAN)
    end
  end
end
function ButtonClose:OnPress()
  if not self.isEnabled then
    return
  end
  if self.callbackTable and type(self.callback) == "function" then
    self.callback(self.callbackTable)
  end
  self.ScriptedEntityTweener:Stop(self.Properties.CloseButtonIcon)
  self.ScriptedEntityTweener:Play(self.Properties.CloseButtonIcon, 0.02, {scaleX = 1, scaleY = 1}, {scaleX = 0.9, scaleY = 0.9})
  self.ScriptedEntityTweener:Play(self.Properties.CloseButtonIcon, 0.1, {scaleX = 0.9, scaleY = 0.9}, {
    scaleX = 1,
    scaleY = 1,
    delay = 0.02
  })
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return ButtonClose
