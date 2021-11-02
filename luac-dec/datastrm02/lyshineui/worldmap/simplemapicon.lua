BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local SimpleMapIcon = {
  Properties = {
    PinIcon = {
      default = EntityId()
    }
  },
  FLYOUT_CONTEXT = "SimpleMapIcon"
}
BaseElement:CreateNewElement(SimpleMapIcon)
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
function SimpleMapIcon:OnInit()
  BaseElement.OnInit(self)
end
function SimpleMapIcon:OnHoverStart()
  self.audioHelper:PlaySound(self.audioHelper.MapIconOnHover)
  hoverIntentDetector:OnHoverDetected(self, self.ShowFlyoutMenu)
end
function SimpleMapIcon:OnHoverEnd()
  hoverIntentDetector:StopHoverDetected(self)
end
function SimpleMapIcon:ShowFlyoutMenu()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu.openingContext == self.FLYOUT_CONTEXT and flyoutMenu:ExitHover() then
    return
  end
  local rows = {}
  if self.flyoutMenuOverrideCaller then
    self.flyoutMenuOverrideFn(self.flyoutMenuOverrideCaller, rows, self.iconData)
  else
    table.insert(rows, {
      type = flyoutMenu.ROW_TYPE_PointOfInterest,
      header = self.iconData.titleText,
      subtext = self.iconData.descriptionText
    })
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:SetOpenLocation(self.entityId)
  flyoutMenu:EnableFlyoutDelay(false)
  flyoutMenu:SetFadeInTime(0.05)
  flyoutMenu:SetFadeOutTime(0.05)
  flyoutMenu:SetSourceHoverOnly(not self.flyoutMenuOverrideCaller)
  flyoutMenu:SetRowData(rows)
end
function SimpleMapIcon:OnRightClick()
  DynamicBus.MagicMap.Broadcast.MapRightClick()
end
function SimpleMapIcon:SetAnchorsPosition(anchors, position)
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, anchors)
  if self.iconData then
    self.iconData.anchors = anchors
    self.iconData.worldPosition = position
  end
end
function SimpleMapIcon:SetData(iconData)
  if iconData then
    self.iconData = iconData
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.markersLayer = iconData.dataManager.markersLayer
    self:SetMapIconImage(iconData.imageFGPath, true)
    UiImageBus.Event.SetColor(self.entityId, iconData.imageFGColor or self.UIStyle.COLOR_WHITE)
    self:SetAnchorsPosition(iconData.anchors, iconData.worldPosition)
    self:SetPinEnabled(iconData.isPinned == true)
  end
end
function SimpleMapIcon:SetMapIconImage(imageFGPath, force)
  if self.iconData and (force or self.iconData.imageFGPath ~= imageFGPath) then
    UiImageBus.Event.SetSpritePathname(self.entityId, imageFGPath)
    self.iconData.imageFGPath = imageFGPath
  end
end
function SimpleMapIcon:SetPinEnabled(isEnabled)
  if not self.Properties.PinIcon:IsValid() then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.PinIcon, isEnabled)
end
function SimpleMapIcon:SetFlyoutMenuOverride(callerTable, callerFunction)
  self.flyoutMenuOverrideFn = callerFunction
  self.flyoutMenuOverrideCaller = callerTable
end
function SimpleMapIcon:SetScale(scale)
  UiTransformBus.Event.SetScale(self.entityId, Vector2(scale, scale))
end
function SimpleMapIcon:Reset()
  self.iconData = nil
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
return SimpleMapIcon
