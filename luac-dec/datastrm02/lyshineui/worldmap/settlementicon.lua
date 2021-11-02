local SettlementIcon = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Tooltip = {
      default = EntityId()
    }
  },
  FLYOUT_CONTEXT = "PointOfInterestIcon"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SettlementIcon)
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
function SettlementIcon:OnInit()
  BaseElement.OnInit(self)
  UiInteractableBus.Event.SetHoverEnterEventHandlingScale(self.entityId, Vector2(0.8, 0.8))
end
function SettlementIcon:OnFocus()
  self.ScriptedEntityTweener:Play(self.Icon, 0.1, {
    scaleX = 1.2,
    scaleY = 1.2,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.MapIconOnHover)
  hoverIntentDetector:OnHoverDetected(self, self.ShowFlyoutMenu)
end
function SettlementIcon:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Icon, 0.1, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  hoverIntentDetector:StopHoverDetected(self)
  if self.unfocusCallback and self.flyoutMenuShowing then
    self.unfocusCallback(self.context, self)
  end
  self.flyoutMenuShowing = nil
end
function SettlementIcon:OnPress()
end
function SettlementIcon:SetStationIconInfo(name, desc, image, context, rightClickCallback, focusCallback, unfocusCallback)
  self.context = context
  self.rightClickCallback = rightClickCallback
  self.focusCallback = focusCallback
  self.unfocusCallback = unfocusCallback
  self.stationName = name
  self.stationDesc = desc
  self.tooltipBackground = image
end
function SettlementIcon:ShowFlyoutMenu()
  self.flyoutMenuShowing = true
  if self.focusCallback then
    self.focusCallback(self.context, self)
    return
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu.openingContext == self.FLYOUT_CONTEXT and flyoutMenu:ExitHover() then
    return
  end
  local rows = {}
  local headerText = self.stationName
  local subtextText = self.stationDesc
  local tooltipImage = self.tooltipBackground
  local openLocation = self.Properties.Icon
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PointOfInterest,
    header = headerText,
    subtext = subtextText,
    tooltipBackground = tooltipImage
  })
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:SetOpenLocation(openLocation)
  flyoutMenu:EnableFlyoutDelay(false)
  flyoutMenu:SetFadeInTime(0.05)
  flyoutMenu:SetFadeOutTime(0.05)
  flyoutMenu:SetRowData(rows)
  flyoutMenu:SourceHoverOnly()
end
function SettlementIcon:OnShutdown()
end
function SettlementIcon:OnRightClick()
  if self.context and self.rightClickCallback then
    self.rightClickCallback(self.context, self)
  end
end
return SettlementIcon
