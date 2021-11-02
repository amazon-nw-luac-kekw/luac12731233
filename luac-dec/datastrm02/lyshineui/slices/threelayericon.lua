local ThreeLayerIcon = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Midground = {
      default = EntityId()
    },
    Foreground = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ThreeLayerIcon)
function ThreeLayerIcon:OnInit()
  BaseElement.OnInit(self)
end
function ThreeLayerIcon:SetBackground(path, color)
  self.Background:SetIcon(path, color)
end
function ThreeLayerIcon:SetMidground(path, color)
  self.Midground:SetIcon(path, color)
end
function ThreeLayerIcon:SetForeground(path, color)
  self.Foreground:SetIcon(path, color)
end
function ThreeLayerIcon:SetIcon(icon)
  self:SetBackground(icon.backgroundImagePath, self.UIStyle.COLOR_WHITE)
  self:SetMidground(icon.midgroundImagePath, self.UIStyle.COLOR_WHITE)
  self:SetForeground(icon.foregroundImagePath, self.UIStyle.COLOR_WHITE)
end
return ThreeLayerIcon
