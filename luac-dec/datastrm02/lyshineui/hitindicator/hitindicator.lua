local HitIndicator = {
  Properties = {
    EdgeHitIndicatorsLowDamage = {
      default = {
        EntityId()
      },
      description = "Set of hit indicators to show on edge of screen on damage"
    },
    EdgeHitIndicatorsMediumDamage = {
      default = {
        EntityId()
      },
      description = "Set of hit indicators to show on edge of screen on damage"
    },
    EdgeHitIndicatorsHighDamage = {
      default = {
        EntityId()
      },
      description = "Set of hit indicators to show on edge of screen on damage"
    },
    RadialHitIndicators = {
      default = {
        EntityId()
      },
      description = "Set of hit indicators that always point to source of damage"
    },
    ShowMultipleRadialHits = {default = false},
    ScreenPos = {
      default = EntityId(),
      description = "(DEBUGGING) Displays screen position of damage source, may be offscreen"
    },
    EdgeIndicatorScreenClampEnabled = {default = false},
    EdgeIndicatorScreenEdgeBleed = {
      default = 0,
      description = "How many pixels edge indicators should bleed off the screen"
    }
  },
  FadeTarget = 0,
  FadeStartTime = 0.25,
  FadeDuration = 1.5,
  indicatorsToUpdate = {},
  nextEdgeIndicator = 1,
  nextRadialIndicator = 1
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(HitIndicator)
function HitIndicator:HideAllIndicators(indicatorsToHide)
  for i = 1, #indicatorsToHide do
    UiElementBus.Event.SetIsEnabled(indicatorsToHide[i], false)
  end
end
function HitIndicator:SetupEdgeIndicators(indicators)
  local edgeIndicators = {}
  for _, entityId in pairs(indicators) do
    table.insert(edgeIndicators, entityId)
  end
  return edgeIndicators
end
function HitIndicator:OnInit()
  BaseScreen.OnInit(self)
  self.edgeIndicators = {}
  self.edgeIndicators.low = {
    indicators = self:SetupEdgeIndicators(self.EdgeHitIndicatorsLowDamage),
    currentIndex = 1
  }
  self.edgeIndicators.medium = {
    indicators = self:SetupEdgeIndicators(self.EdgeHitIndicatorsMediumDamage),
    currentIndex = 1
  }
  self.edgeIndicators.high = {
    indicators = self:SetupEdgeIndicators(self.EdgeHitIndicatorsHighDamage),
    currentIndex = 1
  }
  self.radialIndicators = {}
  self.allIndicatorsByEntityId = {}
  for _, entityId in pairs(self.RadialHitIndicators) do
    table.insert(self.radialIndicators, entityId)
    self.allIndicatorsByEntityId[entityId.value] = {
      entityId = entityId,
      imageEntityId = UiElementBus.Event.GetChild(entityId, 0),
      worldPos = Vector3(0, 0, 0)
    }
  end
  for k, indicators in pairs(self.edgeIndicators) do
    self:HideAllIndicators(indicators.indicators)
  end
  self:HideAllIndicators(self.radialIndicators)
  self.nextRadialIndicator = #self.radialIndicators
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, vitalsId)
    if vitalsId then
      if self.vitalsNotificationHandler then
        self:BusDisconnect(self.vitalsNotificationHandler)
      end
      self.vitalsNotificationHandler = self:BusConnect(VitalsComponentNotificationBus, vitalsId)
    end
  end)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self:BusConnect(DynamicBus.UITickBus)
end
function HitIndicator:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    self.canvasSize = UiCanvasBus.Event.GetCanvasSize(self.canvasId)
    self.maxCanvasDimension = math.max(self.canvasSize.x, self.canvasSize.y)
  end
end
local ShowIndicatorLocals = {
  setRotationParams = {rotation = 0, opacity = 1},
  setOffscreenParams = {y = 0},
  playFadeParams = {
    delay = 0,
    ease = "QuintOut",
    opacity = 0
  }
}
function HitIndicator:ShowIndicator(damageAngle, trackAttacker, attackerWorldPos, healthPercentageLost)
  local hitIndicator
  if trackAttacker then
    hitIndicator = self.radialIndicators[self.nextRadialIndicator]
    self.nextRadialIndicator = self.nextRadialIndicator - 1
    if self.nextRadialIndicator < 1 then
      self.nextRadialIndicator = #self.radialIndicators
    end
    if not self.ShowMultipleRadialHits then
      self:HideAllIndicators(self.radialIndicators)
      ClearTable(self.indicatorsToUpdate)
    end
    self.indicatorsToUpdate[hitIndicator.value] = self.allIndicatorsByEntityId[hitIndicator.value]
    self.indicatorsToUpdate[hitIndicator.value].worldPos.x = attackerWorldPos.x
    self.indicatorsToUpdate[hitIndicator.value].worldPos.y = attackerWorldPos.y
    self.indicatorsToUpdate[hitIndicator.value].worldPos.z = attackerWorldPos.z
  else
    local edgeIndicatorToUse
    if healthPercentageLost < 0.1 then
      edgeIndicatorToUse = self.edgeIndicators.low
    elseif healthPercentageLost < 0.3 then
      edgeIndicatorToUse = self.edgeIndicators.medium
    else
      edgeIndicatorToUse = self.edgeIndicators.high
    end
    hitIndicator = edgeIndicatorToUse.indicators[edgeIndicatorToUse.currentIndex]
    edgeIndicatorToUse.currentIndex = edgeIndicatorToUse.currentIndex - 1
    if 1 > edgeIndicatorToUse.currentIndex then
      edgeIndicatorToUse.currentIndex = #edgeIndicatorToUse.indicators
    end
  end
  UiElementBus.Event.SetIsEnabled(hitIndicator, true)
  ShowIndicatorLocals.setRotationParams.rotation = damageAngle
  self.ScriptedEntityTweener:Set(hitIndicator, ShowIndicatorLocals.setRotationParams)
  ShowIndicatorLocals.playFadeParams.delay = self.FadeStartTime
  function ShowIndicatorLocals.playFadeParams.onComplete()
    UiElementBus.Event.SetIsEnabled(hitIndicator, false)
    if trackAttacker then
      self.indicatorsToUpdate[hitIndicator.value] = nil
    end
  end
  self.ScriptedEntityTweener:Play(hitIndicator, self.FadeDuration, ShowIndicatorLocals.playFadeParams)
  if not trackAttacker and self.Properties.EdgeIndicatorScreenClampEnabled then
    local hitIndicatorImage = self.allIndicatorsByEntityId[hitIndicator.value].imageEntityId
    ShowIndicatorLocals.setOffscreenParams.y = -1 * self.maxCanvasDimension
    self.ScriptedEntityTweener:Set(hitIndicatorImage, ShowIndicatorLocals.setOffscreenParams)
    local viewportPosition = UiTransformBus.Event.GetViewportPosition(hitIndicatorImage)
    viewportPosition.x = Clamp(viewportPosition.x, -1 * self.Properties.EdgeIndicatorScreenEdgeBleed, self.canvasSize.x + self.Properties.EdgeIndicatorScreenEdgeBleed)
    viewportPosition.y = Clamp(viewportPosition.y, -1 * self.Properties.EdgeIndicatorScreenEdgeBleed, self.canvasSize.y + self.Properties.EdgeIndicatorScreenEdgeBleed)
    UiTransformBus.Event.SetViewportPosition(hitIndicatorImage, viewportPosition)
  end
end
function HitIndicator:GetDamageAngle(worldPosition, screenPosToFill)
  local x, y
  local playerPos = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  local screenPos = LyShineManagerBus.Broadcast.ProjectToScreen(worldPosition, false, false)
  if playerPos then
    local playerScreenPos = LyShineManagerBus.Broadcast.ProjectToScreen(playerPos, false, false)
    x = playerScreenPos.x
    y = playerScreenPos.y
  else
    x = self.canvasSize.x / 2
    y = self.canvasSize.y / 2
  end
  if screenPosToFill then
    screenPosToFill.x = screenPos.x - x
    screenPosToFill.y = screenPos.y - y
  end
  x = screenPos.x - x
  y = screenPos.y - y
  return math.deg(math.atan2(y, x))
end
local OnTickLocals = {
  setRotationParams = {rotation = 0}
}
function HitIndicator:OnTick(deltaTime, timePoint)
  for _, hitIndicatorData in pairs(self.indicatorsToUpdate) do
    OnTickLocals.setRotationParams.rotation = self:GetDamageAngle(hitIndicatorData.worldPos)
    self.ScriptedEntityTweener:Set(hitIndicatorData.entityId, OnTickLocals.setRotationParams)
  end
end
function HitIndicator:OnShutdown()
  BaseScreen.OnShutdown(self)
end
function HitIndicator:OnDamage(attackerEntityId, healthPercentageLost, positionOfAttack, damageAngle, isSelfDamage, damageByType, isFromStatusEffect, cancelTargetHoming)
  if isFromStatusEffect or healthPercentageLost < GetEpsilon() or positionOfAttack.x + positionOfAttack.y + positionOfAttack.z < 0.5 then
    return
  end
  if positionOfAttack ~= nil then
    self:ShowIndicator(damageAngle, false, positionOfAttack, healthPercentageLost)
    if not isSelfDamage then
      self:ShowIndicator(damageAngle, true, positionOfAttack, healthPercentageLost)
    end
  end
end
return HitIndicator
