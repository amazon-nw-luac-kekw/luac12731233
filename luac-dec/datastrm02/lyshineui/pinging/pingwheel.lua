local PingWheel = {
  Properties = {
    WheelSectionContainer = {
      default = EntityId()
    },
    ShoutPingOverlay = {
      default = EntityId()
    },
    ShoutPingEffect = {
      default = EntityId()
    },
    PingTarget = {
      default = EntityId()
    },
    PingWheelSelector = {
      default = EntityId()
    },
    PingWheelCommandText = {
      default = EntityId()
    },
    PingHintHolder = {
      default = EntityId()
    },
    PingHintCancel = {
      default = EntityId()
    },
    PingHintCancelText = {
      default = EntityId()
    },
    PingHintCancelIcon = {
      default = EntityId()
    },
    PingHintShout = {
      default = EntityId()
    },
    PingHintShoutText = {
      default = EntityId()
    },
    PingHintShoutIcon = {
      default = EntityId()
    }
  },
  isShoutPingEnabled = false,
  hintTargetWidthShout = 0,
  hintTargetWidthCancel = 0,
  hintSpacing = 35,
  selectionAccelerationFactor = 1,
  pingThrottleTime = 0.5
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PingWheel)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function PingWheel:OnInit()
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("pingwheel", false)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasSizeNotificationBus)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  local wheelSectionData = {
    {
      pingType = ePingType_Move,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeMove.png",
      text = "@ui_ping_type_Move",
      color = self.UIStyle.COLOR_YELLOW_GOLD
    },
    {
      pingType = ePingType_Attack,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeAttack.png",
      text = "@ui_ping_type_Attack",
      color = self.UIStyle.COLOR_RED_DARK
    },
    {
      pingType = ePingType_Someone,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeSomeonesHere.png",
      text = "@ui_ping_type_Someone",
      color = self.UIStyle.COLOR_YELLOW_GOLD
    },
    {
      pingType = ePingType_NeedHelp,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeNeedHelp.png",
      text = "@ui_ping_type_NeedHelp",
      color = self.UIStyle.COLOR_YELLOW_GOLD
    },
    {
      pingType = ePingType_NeedHealing,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeNeedHeals.png",
      text = "@ui_ping_type_NeedHealing",
      color = self.UIStyle.COLOR_YELLOW_GOLD
    },
    {
      pingType = ePingType_Loot,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeLoot.png",
      text = "@ui_ping_type_Loot",
      color = self.UIStyle.COLOR_YELLOW_GOLD
    },
    {
      pingType = ePingType_Repair,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeRepair.png",
      text = "@ui_ping_type_Repair",
      color = self.UIStyle.COLOR_YELLOW_GOLD
    },
    {
      pingType = ePingType_Defend,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeDefend.png",
      text = "@ui_ping_type_Defend",
      color = self.UIStyle.COLOR_YELLOW_GOLD
    },
    {
      pingType = ePingType_Caution,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeCaution.png",
      text = "@ui_ping_type_Caution",
      color = self.UIStyle.COLOR_YELLOW_GOLD
    },
    {
      pingType = ePingType_Danger,
      iconPath = "lyshineui/images/icons/pingtypes/pingTypeDanger.png",
      text = "@ui_ping_type_Danger",
      color = self.UIStyle.COLOR_RED_DARK
    }
  }
  local sections = UiElementBus.Event.GetChildren(self.Properties.WheelSectionContainer)
  self.numSections = #sections
  self.wheelSections = {}
  for i = 1, self.numSections do
    local wheelEntity = sections[i]
    local pos = UiTransformBus.Event.GetViewportPosition(wheelEntity)
    local normalizedAngle = self:GetNormalizedAngle(pos, self.canvasCenter)
    local sectionTable = self.registrar:GetEntityTable(wheelEntity)
    sectionTable:SetSectionData(wheelSectionData[i])
    table.insert(self.wheelSections, {angle = normalizedAngle, section = sectionTable})
  end
  self:BusConnect(CryActionNotificationsBus, "target_tag_shout")
  self.virtualCursorPos = {x = 0, y = 0}
  self:SetVisualElements()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.IsGroupLeader", function(self, isLeader)
    self:SetIsShoutEnabled(isLeader)
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
    if not groupId:IsValid() then
      self:SetIsShoutEnabled(false)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_pingingThrottle", function(self, pingThrottleTime)
    if pingThrottleTime then
      self.pingThrottleTime = pingThrottleTime
    end
  end)
end
function PingWheel:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    self.canvasSize = UiCanvasBus.Event.GetCanvasSize(self.canvasId)
    self.canvasCenter = Vector2(self.canvasSize.x / 2, self.canvasSize.y / 2)
    self.virtualCursorBounds = {
      minX = GetMaxNum(),
      maxX = 0,
      minY = GetMaxNum(),
      maxY = 0
    }
    local sections = UiElementBus.Event.GetChildren(self.Properties.WheelSectionContainer)
    for i = 1, #sections do
      local wheelEntity = sections[i]
      local pos = UiTransformBus.Event.GetViewportPosition(wheelEntity)
      if pos.x < self.virtualCursorBounds.minX then
        self.virtualCursorBounds.minX = pos.x
      end
      if pos.x > self.virtualCursorBounds.maxX then
        self.virtualCursorBounds.maxX = pos.x
      end
      if pos.y < self.virtualCursorBounds.minY then
        self.virtualCursorBounds.minY = pos.y
      end
      if pos.y > self.virtualCursorBounds.maxY then
        self.virtualCursorBounds.maxY = pos.y
      end
    end
  end
end
function PingWheel:OnTick(deltaTime, timePoint)
  local cursorPos = CursorBus.Broadcast.GetCursorPosition()
  local xDelta = (cursorPos.x - self.canvasCenter.x) * self.selectionAccelerationFactor
  local yDelta = (cursorPos.y - self.canvasCenter.y) * self.selectionAccelerationFactor
  self.virtualCursorPos.x = Clamp(self.virtualCursorPos.x + xDelta, self.virtualCursorBounds.minX, self.virtualCursorBounds.maxX)
  self.virtualCursorPos.y = Clamp(self.virtualCursorPos.y + yDelta, self.virtualCursorBounds.minY, self.virtualCursorBounds.maxY)
  local normalizedAngle = self:GetNormalizedAngle(self.virtualCursorPos, self.canvasCenter)
  local section, index = self:GetSectionFromAngle(normalizedAngle)
  if section and normalizedAngle ~= 0 then
    self.desiredSection = section
    self.desiredSectionIndex = index
  end
  if self.selectedSectionIndex ~= self.desiredSectionIndex and normalizedAngle ~= 0 then
    self:SetPingWheelSelectorVisible(true)
    if self.selectedSection then
      self.selectedSection:OnSectionUnfocus()
    end
    self.selectedSection = self.desiredSection
    self.selectedSectionIndex = self.desiredSectionIndex
    self.selectedSection:OnSectionFocus()
    UiTextBus.Event.SetTextWithFlags(self.Properties.PingWheelCommandText, self.selectedSection:GetSelectionText(), eUiTextSet_SetLocalized)
  end
  CursorBus.Broadcast.SetCursorPosition(self.canvasCenter)
end
function PingWheel:SetVisualElements()
  UiTextBus.Event.SetTextWithFlags(self.Properties.PingHintShoutText, "@ui_shout", eUiTextSet_SetLocalized)
  self.PingHintShoutIcon:SetActionMap("pingwheel")
  self.PingHintShoutIcon:SetKeybindMapping("target_tag_shout")
  UiTextBus.Event.SetTextWithFlags(self.Properties.PingHintCancelText, "@ui_cancel", eUiTextSet_SetLocalized)
  self.PingHintCancelIcon:SetKeybindMapping("enable_grid")
  local hintSpacing = 10
  local shoutTextWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.PingHintShoutText)
  local shoutHintWidth = self.PingHintShoutIcon:GetWidth()
  self.hintTargetWidthShout = hintSpacing + shoutTextWidth + shoutHintWidth
  UiLayoutCellBus.Event.SetTargetWidth(self.Properties.PingHintShout, self.hintTargetWidthShout)
  local cancelTextWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.PingHintCancelText)
  local cancelHintWidth = self.PingHintCancelIcon:GetWidth()
  self.hintTargetWidthCancel = hintSpacing + cancelTextWidth + cancelHintWidth
  UiLayoutCellBus.Event.SetTargetWidth(self.Properties.PingHintCancel, self.hintTargetWidthCancel)
end
function PingWheel:SetPingWheelSelectorVisible(isVisible)
  if isVisible and not self.isPingWheelSelectorVisible then
    self.isPingWheelSelectorVisible = true
    self.ScriptedEntityTweener:Play(self.Properties.PingWheelSelector, 0.3, {opacity = 1, ease = "QuadOut"})
  elseif not isVisible and self.isPingWheelSelectorVisible then
    self.isPingWheelSelectorVisible = false
    self.ScriptedEntityTweener:Set(self.Properties.PingWheelSelector, {opacity = 0})
  end
end
function PingWheel:GetNormalizedAngle(position, originPos)
  local y = position.y - originPos.y
  local x = position.x - originPos.x
  local angle = math.deg(math.atan2(y, x))
  UiTransformBus.Event.SetZRotation(self.Properties.PingWheelSelector, angle)
  return angle / (360 / self.numSections)
end
function PingWheel:GetSectionFromAngle(normalizedAngle)
  if not normalizedAngle then
    return nil
  end
  local closestSection, closestSectionIndex
  local currentClosestVal = GetMaxNum()
  for index, sectionData in ipairs(self.wheelSections) do
    local currentVal = math.abs(sectionData.angle - normalizedAngle)
    if currentClosestVal > currentVal then
      closestSection = sectionData.section
      closestSectionIndex = index
      currentClosestVal = currentVal
    end
  end
  return closestSection, closestSectionIndex
end
local zeroVec = Vector3(0, 0, 0)
function PingWheel:SetWheelVisibility(isVisible, isMapShowing)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  UiJavCanvasComponentBus.Event.SetOverridesActionMap(self.canvasId, "player", isVisible)
  UiJavCanvasComponentBus.Event.SetOverridesActionMap(self.canvasId, "camera", isVisible)
  if isVisible then
    if not self.tickBusHandler then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
      if isMapShowing then
        self.mapWorldPos = DynamicBus.MagicMap.Broadcast.GetCursorWorldPosition()
        DynamicBus.MagicMap.Broadcast.CenterToPosition(self.mapWorldPos, true)
        LyShineManagerBus.Broadcast.EnableMouse(false)
      end
      self.selectedSection = nil
      self.selectedSectionIndex = nil
      self.desiredSection = nil
      self.desiredSectionIndex = nil
      self:SetPingWheelSelectorVisible(false)
      self.gridHandler = self:BusConnect(CryActionNotificationsBus, "enable_grid")
      self.virtualCursorPos.x = self.canvasCenter.x
      self.virtualCursorPos.y = self.canvasCenter.y
      CursorBus.Broadcast.SetCursorPosition(self.canvasCenter)
      UiTextBus.Event.SetTextWithFlags(self.Properties.PingWheelCommandText, "@ui_ping_select", eUiTextSet_SetLocalized)
      self.audioHelper:PlaySound(self.audioHelper.Ping_Wheel_Open)
    end
  else
    if self.tickBusHandler then
      if self.desiredSection then
        local pingType = self.desiredSection:GetPingType()
        local worldPos = zeroVec
        if self.isMapShowing then
          local pingIconPath = self.desiredSection:GetPingIconPath()
          local pingColor = self.desiredSection:GetPingColor()
          worldPos = self.mapWorldPos
          DynamicBus.MagicMap.Broadcast.PingAtLocation(pingIconPath, pingColor, worldPos)
        end
        PingRequestBus.Broadcast.RequestPing(pingType, self.isShouting, self.pingThrottleTime, worldPos)
        self.desiredSection:OnSectionUnfocus()
      end
      self:SetPingWheelSelectorVisible(false)
      self:BusDisconnect(self.tickBusHandler)
      self.tickBusHandler = nil
      self:BusDisconnect(self.gridHandler)
      self.gridHandler = nil
    end
    if self.isMapShowing then
      LyShineManagerBus.Broadcast.ResetMouse()
    end
  end
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("pingwheel", isVisible)
  self.isMapShowing = isMapShowing
end
function PingWheel:OnCryAction(actionName, value)
  if actionName == "target_tag_shout" then
    local isPress = 0 < value
    self:SetIsShouting(isPress)
  elseif actionName == "enable_grid" then
    if self.desiredSection then
      self.desiredSection:OnSectionUnfocus()
      self.desiredSection = nil
      self.audioHelper:PlaySound(self.audioHelper.Ping_Wheel_Action)
    end
    self:SetWheelVisibility(false)
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  end
end
function PingWheel:SetIsShoutEnabled(isEnabled)
  self.isShoutPingEnabled = isEnabled
  local targetWidthShout = isEnabled and self.hintTargetWidthShout or 0
  UiElementBus.Event.SetIsEnabled(self.Properties.PingHintShout, isEnabled)
  UiLayoutCellBus.Event.SetTargetWidth(self.Properties.PingHintShout, targetWidthShout)
  UiLayoutCellBus.Event.SetTargetWidth(self.Properties.PingHintCancel, self.hintTargetWidthCancel)
  local hintSpacing = isEnabled and self.hintSpacing or 0
  UiLayoutRowBus.Event.SetSpacing(self.Properties.PingHintHolder, hintSpacing)
end
function PingWheel:SetIsShouting(isEnabled)
  if isEnabled and not self.isShoutPingEnabled then
    return
  end
  if self.isShouting ~= isEnabled then
    self.isShouting = isEnabled
    if self.isShouting then
      self.ScriptedEntityTweener:PlayC(self.Properties.ShoutPingOverlay, 0.3, tweenerCommon.fadeInQuadOut)
      UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.ShoutPingEffect, 0)
      UiFlipbookAnimationBus.Event.Start(self.Properties.ShoutPingEffect)
      self.audioHelper:PlaySound(self.audioHelper.Ping_ShoutWheelHold)
    else
      self.ScriptedEntityTweener:PlayC(self.Properties.ShoutPingOverlay, 0.2, tweenerCommon.fadeOutQuadOut)
      UiFlipbookAnimationBus.Event.Stop(self.Properties.ShoutPingEffect)
    end
  end
end
return PingWheel
