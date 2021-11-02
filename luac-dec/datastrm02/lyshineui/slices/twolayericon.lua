local TwoLayerIcon = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Foreground = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TwoLayerIcon)
function TwoLayerIcon:OnInit()
  BaseElement.OnInit(self)
end
function TwoLayerIcon:SetBackground(path, color)
  self.Background:SetIcon(path, color)
end
function TwoLayerIcon:SetForeground(path, color)
  self.Foreground:SetIcon(path, color)
end
function TwoLayerIcon:SetIcon(icon)
  self:SetBackground(icon.backgroundImagePath, icon.backgroundColor)
  self:SetForeground(icon.foregroundImagePath, icon.foregroundColor)
end
function TwoLayerIcon:SetSmallIcon(icon)
  self:SetBackground(GetSmallImagePath(icon.backgroundImagePath), icon.backgroundColor)
  self:SetForeground(GetSmallImagePath(icon.foregroundImagePath), icon.foregroundColor)
end
function TwoLayerIcon:SetBackgroundVisibility(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Background, isVisible)
end
function TwoLayerIcon:SetForegroundVisibility(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Foreground, isVisible)
end
return TwoLayerIcon
