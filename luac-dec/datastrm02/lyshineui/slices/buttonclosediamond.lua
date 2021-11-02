local ButtonCloseDiamond = {
  Properties = {
    CloseButtonIcon = {
      default = EntityId()
    }
  },
  ImageType = "default",
  ButtonTypes = {collapse = "collapse", default = "default"},
  ImagePaths = {
    collapse = {
      normal = "buttoncloseDiamondCollapse.png",
      focused = "buttoncloseDiamondCollapse_focus.png"
    },
    default = {
      normal = "buttoncloseDiamond.png",
      focused = "buttoncloseDiamond_focus.png"
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ButtonCloseDiamond)
function ButtonCloseDiamond:OnInit()
  BaseElement.OnInit(self)
  self:SetImageType()
end
function ButtonCloseDiamond:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function ButtonCloseDiamond:SetImageType(imageType)
  if imageType and imageType == self.ButtonTypes.collapse then
    self.ImageType = imageType
    self:OnUnhover()
  else
    self.ImageType = self.ButtonTypes.default
  end
end
function ButtonCloseDiamond:OnHover()
  local imagepath = "LyShineUI/Images/slices/ButtonCloseDiamond/" .. self.ImagePaths[self.ImageType].focused
  UiImageBus.Event.SetSpritePathname(self.Properties.CloseButtonIcon, imagepath)
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function ButtonCloseDiamond:OnUnhover()
  local imagepath = "LyShineUI/Images/slices/ButtonCloseDiamond/" .. self.ImagePaths[self.ImageType].normal
  UiImageBus.Event.SetSpritePathname(self.Properties.CloseButtonIcon, imagepath)
end
function ButtonCloseDiamond:OnPress()
  if self.callbackTable and type(self.callback) == "function" then
    self.callback(self.callbackTable)
  end
  self.ScriptedEntityTweener:Play(self.Properties.CloseButtonIcon, 0.02, {scaleX = 1, scaleY = 1}, {scaleX = 0.9, scaleY = 0.9})
  self.ScriptedEntityTweener:Play(self.Properties.CloseButtonIcon, 0.1, {scaleX = 0.9, scaleY = 0.9}, {
    scaleX = 1,
    scaleY = 1,
    delay = 0.02
  })
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return ButtonCloseDiamond
