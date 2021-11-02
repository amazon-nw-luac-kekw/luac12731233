local Inventory_BoxOpeningPopup_NextBoxButton = {
  Properties = {
    ButtonIcon = {
      default = EntityId()
    },
    ButtonText = {
      default = EntityId()
    }
  },
  ButtonSize = 120
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Inventory_BoxOpeningPopup_NextBoxButton)
function Inventory_BoxOpeningPopup_NextBoxButton:OnInit()
  BaseElement.OnInit(self)
  self.soundOnFocus = self.audioHelper.OnHover_ButtonSimpleText
  self.soundOnPress = self.audioHelper.Accept
end
function Inventory_BoxOpeningPopup_NextBoxButton:SetGridItemData(gridItemData)
  UiElementBus.Event.SetIsEnabled(self.entityId, gridItemData ~= nil)
  if gridItemData then
    self.itemInstanceId = gridItemData.itemInstanceId
    local iconPath = "LyShineUI/Images/Icons/Items/Resource/" .. gridItemData.iconPath .. ".dds"
    local stacksize = tostring(gridItemData.stackSize)
    self:SetIconPath(iconPath)
    self:SetText(stacksize)
    self.pressCallback = gridItemData.onClickCallback
    self.pressTable = gridItemData.callbackSelf
  end
end
function Inventory_BoxOpeningPopup_NextBoxButton:SetText(value)
  UiTextBus.Event.SetText(self.Properties.ButtonText, value)
end
function Inventory_BoxOpeningPopup_NextBoxButton:SetIconPath(value)
  UiImageBus.Event.SetSpritePathname(self.Properties.ButtonIcon, value)
end
function Inventory_BoxOpeningPopup_NextBoxButton:OnFocus()
  self.ScriptedEntityTweener:Play(self.Properties.ButtonIcon, 0.15, {
    scaleX = 1.1,
    scaleY = 1.1,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.soundOnFocus)
end
function Inventory_BoxOpeningPopup_NextBoxButton:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.ButtonIcon, 0.15, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadIn"
  })
end
function Inventory_BoxOpeningPopup_NextBoxButton:OnPress()
  if self.pressCallback then
    self.pressCallback(self.pressTable, self)
  end
  self.audioHelper:PlaySound(self.soundOnPress)
end
return Inventory_BoxOpeningPopup_NextBoxButton
