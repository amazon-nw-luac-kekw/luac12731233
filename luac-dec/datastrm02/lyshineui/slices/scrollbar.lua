local Scrollbar = {
  Properties = {
    ScrollbarBg = {
      default = EntityId()
    },
    ScrollbarHandle = {
      default = EntityId()
    }
  },
  isClicked = false
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Scrollbar)
function Scrollbar:OnInit()
  BaseElement.OnInit(self)
  UiImageBus.Event.SetColor(self.Properties.ScrollbarHandle, self.UIStyle.COLOR_ORANGE_SCROLLBAR)
end
function Scrollbar:OnScrollbarFocus()
  if self.Properties.ScrollbarHandle:IsValid() then
    self.ScriptedEntityTweener:PlayC(self.Properties.ScrollbarHandle, self.UIStyle.DURATION_BUTTON_FADE_IN, tweenerCommon.scrollbarFocus)
  end
end
function Scrollbar:OnScrollbarClicked()
  self.isClicked = true
end
function Scrollbar:OnScrollbarReleased()
  self.isClicked = false
  if not GetIsMouseOverEntity(self.entityId) then
    self:OnScrollbarUnfocus()
  end
end
function Scrollbar:OnScrollbarUnfocus()
  if self.isClicked then
    return
  end
  if self.Properties.ScrollbarHandle:IsValid() then
    self.ScriptedEntityTweener:PlayC(self.Properties.ScrollbarHandle, 0.3, tweenerCommon.scrollbarUnfocus)
  end
end
return Scrollbar
