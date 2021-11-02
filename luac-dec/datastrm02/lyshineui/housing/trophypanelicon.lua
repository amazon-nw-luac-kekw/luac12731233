local TrophyPanelIcon = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Foreground = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    Tier = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Separator = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TrophyPanelIcon)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function TrophyPanelIcon:OnInit()
  BaseElement.OnInit(self)
end
function TrophyPanelIcon:SetForegroundVisibility(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Foreground, isVisible)
end
function TrophyPanelIcon:SetIcon(path, color)
  self.color = color
  self.Icon:SetIcon(path, self.color)
  self:SetFrameColor(self.color)
end
function TrophyPanelIcon:SetFrameColor(color)
  UiImageBus.Event.SetColor(self.Properties.Frame, color)
end
function TrophyPanelIcon:SetSeparatorVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Separator, isVisible)
end
function TrophyPanelIcon:SetTier(tierNumber)
  UiTextBus.Event.SetText(self.Properties.Tier, GetRomanFromNumber(tierNumber))
  UiTextBus.Event.SetColor(self.Properties.Tier, self.color)
end
function TrophyPanelIcon:SetEnabled(enabled)
  if enabled then
    if self.color then
      self.Icon:SetColor(self.color)
      self:SetFrameColor(self.color)
    end
    self.ScriptedEntityTweener:Set(self.Foreground, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Background, {opacity = 1})
  else
    self.Icon:SetColor(self.UIStyle.COLOR_GRAY_80)
    self:SetFrameColor(self.UIStyle.COLOR_GRAY_30)
    self.ScriptedEntityTweener:Set(self.Foreground, {opacity = 0.7})
    self.ScriptedEntityTweener:Set(self.Background, {opacity = 0.7})
  end
end
return TrophyPanelIcon
