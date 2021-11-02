local DifficultyItem = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    IconCross = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DifficultyItem)
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function DifficultyItem:OnInit()
  self.textLeft = UiTransformBus.Event.GetLocalPositionX(self.Properties.Text)
  SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_BANNER_DIFFICULTY_LABEL)
  self:SetIsMet(false)
end
function DifficultyItem:SetText(text)
  UiTextBus.Event.SetText(self.Properties.Text, text)
end
function DifficultyItem:SetIsMet(isMet)
  if self.isMet == isMet then
    return
  end
  self.isMet = isMet
  if self.isMet then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, "")
    UiImageBus.Event.SetColor(self.Properties.Icon, self.UIStyle.COLOR_GREEN)
    UiTextBus.Event.SetColor(self.Properties.Text, self.UIStyle.COLOR_GREEN)
    UiElementBus.Event.SetIsEnabled(self.Properties.IconCross, false)
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, "lyshineui/images/common/1pxframe_64x64.sprite")
    UiImageBus.Event.SetColor(self.Properties.Icon, self.UIStyle.COLOR_RED_DARK)
    UiTextBus.Event.SetColor(self.Properties.Text, self.UIStyle.COLOR_RED_MEDIUM)
    UiElementBus.Event.SetIsEnabled(self.Properties.IconCross, true)
  end
end
function DifficultyItem:GetWidth()
  return self.textLeft + UiTextBus.Event.GetTextWidth(self.Properties.Text)
end
function DifficultyItem:AnimateIn(delay)
  delay = delay or 0
  self.ScriptedEntityTweener:Set(self.Properties.Icon, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.Text, {
    opacity = 0,
    x = self.textLeft - 4
  })
  if not self.isMet then
    self.ScriptedEntityTweener:Set(self.Properties.IconCross, {opacity = 0})
  end
  TimingUtils:Delay(delay, self, function()
    self.ScriptedEntityTweener:PlayC(self.Properties.Icon, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:Play(self.Properties.Text, 0.3, {
      opacity = 1,
      x = self.textLeft,
      delay = 0.1,
      ease = "QuadOut"
    })
    if not self.isMet then
      self.ScriptedEntityTweener:PlayC(self.Properties.IconCross, 0.15, tweenerCommon.difficultyItemCross1, 0.15)
      self.ScriptedEntityTweener:PlayC(self.Properties.IconCross, 0.4, tweenerCommon.difficultyItemCross2, 0.4)
    end
  end)
end
function DifficultyItem:AnimateOut()
  self.ScriptedEntityTweener:PlayC(self.Properties.Icon, 0.3, tweenerCommon.fadeOutQuadIn)
  self.ScriptedEntityTweener:PlayC(self.Properties.Text, 0.3, tweenerCommon.fadeOutQuadIn)
end
return DifficultyItem
