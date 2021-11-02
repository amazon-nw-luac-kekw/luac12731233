local AfflictionsScreen = {
  Properties = {
    AfflictionsContainer = {
      default = EntityId()
    }
  },
  afflictionBarSlicePath = "LyShineUI\\Afflictions\\AfflictionBar",
  barHeight = 54,
  barMargin = 24,
  barMinScale = 0.85,
  repositionTime = 0.3,
  positionFromBottom = true,
  DEBUG_KeyBinds = false,
  defaultPosX = 0,
  inventoryPosX = 529,
  threeColumnPosX = 235,
  abilityCooldownOffset = -84,
  Y_NO_RADIAL_COOLDOWNS = 588,
  Y_RADIAL_COOLDOWNS = 496
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(AfflictionsScreen)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(AfflictionsScreen)
function AfflictionsScreen:OnInit()
  BaseScreen.OnInit(self)
  self.screenStatePositions = {
    [2972535350] = self.inventoryPosX,
    [3349343259] = self.threeColumnPosX,
    [2552344588] = self.threeColumnPosX,
    [1809891471] = self.threeColumnPosX
  }
  self.defaultPosX = UiTransformBus.Event.GetLocalPositionX(self.Properties.AfflictionsContainer)
  self.afflictionBars = {}
  self.afflictionBarOrder = {}
  self.skipPositionAnimation = {}
  self.containerHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.AfflictionsContainer)
  self:BusConnect(UiSpawnerNotificationBus, self.AfflictionsContainer)
  DynamicBus.AbilityChannelNotifications.Connect(self.entityId, self)
  local afflictionIds = DamageDataBus.Broadcast.GetAfflictionRowKeys()
  self.totalSpawnCount = #afflictionIds
  for i = 1, self.totalSpawnCount do
    local afflictionId = afflictionIds[i]
    self.skipPositionAnimation[afflictionId] = true
    self:SpawnSlice(self.AfflictionsContainer, self.afflictionBarSlicePath, self.OnAfflictionBarSpawned, {afflictionId = afflictionId})
  end
  self.originalContainerYPos = UiTransformBus.Event.GetLocalPositionY(self.Properties.AfflictionsContainer)
  if self.DEBUG_KeyBinds then
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F01", "lc_playerDoAfflictionDamage AfflictionPoison 25")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F02", "lc_playerDoAfflictionDamage AfflictionFrostbite 25")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F03", "lc_playerDoAfflictionDamage AfflictionDisease 25")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F04", "lc_playerDoAfflictionDamage AfflictionBleed 25")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F05", "lc_playerDoAfflictionDamage AfflictionCurse 25")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F06", "lc_playerDoAfflictionDamage AfflictionDrowning 5")
  end
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Video.HudShowAbilityRadials", function(self, showAbilityRadials)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.AfflictionsContainer, showAbilityRadials and self.Y_RADIAL_COOLDOWNS or self.Y_NO_RADIAL_COOLDOWNS)
  end)
end
function AfflictionsScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  local posX = self.screenStatePositions[toState] or self.defaultPosX
  if toState == 3349343259 and self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop") then
    posX = self.inventoryPosX
  end
  self.ScriptedEntityTweener:Play(self.Properties.AfflictionsContainer, 0.3, {x = posX, ease = "QuadOut"})
end
function AfflictionsScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.screenStatePositions[fromState] and not self.screenStatePositions[toState] then
    local currentPosX = UiTransformBus.Event.GetLocalPositionX(self.Properties.AfflictionsContainer)
    if currentPosX ~= self.defaultPosX then
      self.ScriptedEntityTweener:Play(self.Properties.AfflictionsContainer, 0.3, {
        x = self.defaultPosX,
        ease = "QuadOut"
      })
    end
  end
end
function AfflictionsScreen:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.AbilityChannelNotifications.Disconnect(self.entityId, self)
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
end
function AfflictionsScreen:OnAfflictionBarSpawned(entity, data)
  local afflictionId = data.afflictionId
  if entity and afflictionId then
    if self.afflictionBars[afflictionId] then
      Debug.Log("Warning: Spawned an affliction bar that already exists! Deleting old bar.")
      UiElementBus.Event.DestroyElement(self.afflictionBars[afflictionId].entityId)
    end
    self.afflictionBars[afflictionId] = entity
    entity:SetAfflictionById(afflictionId, self.AddAffliction, self.RemoveAffliction, self)
    self:UpdateAfflictionBarPositions(0)
  end
end
function AfflictionsScreen:AddAffliction(entity)
  local isEnabled = UiElementBus.Event.IsEnabled(entity.entityId)
  if not isEnabled or entity:IsAnimatingOut() then
    UiElementBus.Event.SetIsEnabled(entity.entityId, true)
    entity:AnimateIn()
    self.skipPositionAnimation[entity.afflictionId] = true
  end
  local isInOrder = false
  for i = 1, #self.afflictionBarOrder do
    if self.afflictionBarOrder[i] == entity.afflictionId then
      isInOrder = true
      break
    end
  end
  if not isInOrder then
    table.insert(self.afflictionBarOrder, entity.afflictionId)
  end
  self:UpdateAfflictionBarPositions()
end
function AfflictionsScreen:RemoveAffliction(entity)
  local isEnabled = UiElementBus.Event.IsEnabled(entity.entityId)
  if isEnabled and not entity:IsAnimatingOut() then
    entity:AnimateOut(function()
      UiElementBus.Event.SetIsEnabled(entity.entityId, false)
      for i = 1, #self.afflictionBarOrder do
        if self.afflictionBarOrder[i] == entity.afflictionId then
          table.remove(self.afflictionBarOrder, i)
          break
        end
      end
      self:UpdateAfflictionBarPositions()
    end)
  end
  self:UpdateAfflictionBarPositions()
end
function AfflictionsScreen:UpdateAfflictionBarPositions()
  if #self.afflictionBarOrder > 0 then
    if not self.isEnabled then
      UiCanvasBus.Event.SetEnabled(self.canvasId, true)
      self.isEnabled = true
    end
    local scale = Math.Clamp(self.containerHeight / (#self.afflictionBarOrder * (self.barHeight + self.barMargin) - self.barMargin), self.barMinScale, 1)
    for i = 1, #self.afflictionBarOrder do
      local afflictionId = self.afflictionBarOrder[i]
      local barY = (i - 1) * (self.barHeight + self.barMargin) * scale
      if self.positionFromBottom then
        barY = self.containerHeight - barY
      end
      local duration = self.repositionTime
      if self.skipPositionAnimation[afflictionId] then
        duration = 0
        self.skipPositionAnimation[afflictionId] = nil
      end
      self.ScriptedEntityTweener:Play(self.afflictionBars[afflictionId].entityId, duration, {
        y = barY,
        scaleX = scale,
        scaleY = scale
      })
    end
  elseif self.isEnabled then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
    self.isEnabled = false
  end
end
function AfflictionsScreen:OnAbilityStarted()
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.AfflictionsContainer, self.originalContainerYPos + self.abilityCooldownOffset)
end
function AfflictionsScreen:OnAbilityEnded()
  UiCanvasBus.Event.SetEnabled(self.canvasId, self.isEnabled)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.AfflictionsContainer, self.originalContainerYPos)
end
function AfflictionsScreen:SetElementVisibleForFtue(isVisible)
  UiCanvasBus.Event.SetEnabled(self.canvasId, isVisible == true)
end
return AfflictionsScreen
