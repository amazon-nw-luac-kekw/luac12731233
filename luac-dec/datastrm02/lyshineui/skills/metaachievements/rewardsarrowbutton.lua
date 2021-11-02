local RewardsArrowButton = {
  Properties = {
    ArrowButtonIcon = {
      default = EntityId()
    }
  },
  ImagePaths = {
    normal = "LyShineUI/Images/Skills/Achievements/paging_arrow.png",
    hover = "LyShineUI/Images/Skills/Achievements/paging_arrow_hover.png"
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RewardsArrowButton)
function RewardsArrowButton:OnInit()
  BaseElement.OnInit(self)
end
function RewardsArrowButton:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function RewardsArrowButton:OnHover()
  UiImageBus.Event.SetSpritePathname(self.Properties.ArrowButtonIcon, self.ImagePaths.hover)
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function RewardsArrowButton:OnUnhover()
  UiImageBus.Event.SetSpritePathname(self.Properties.ArrowButtonIcon, self.ImagePaths.normal)
end
function RewardsArrowButton:OnPress()
  if self.callbackTable and type(self.callback) == "function" then
    self.callback(self.callbackTable)
  end
  self.ScriptedEntityTweener:Play(self.Properties.ArrowButtonIcon, 0.02, {scaleX = 1, scaleY = 1}, {scaleX = 0.9, scaleY = 0.9})
  self.ScriptedEntityTweener:Play(self.Properties.ArrowButtonIcon, 0.1, {scaleX = 0.9, scaleY = 0.9}, {
    scaleX = 1,
    scaleY = 1,
    delay = 0.02
  })
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return RewardsArrowButton
