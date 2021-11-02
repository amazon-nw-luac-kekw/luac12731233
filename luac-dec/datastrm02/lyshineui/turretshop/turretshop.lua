local TurretShop = {
  Properties = {
    TitleText = {
      default = EntityId()
    },
    BackgroundHolder = {
      default = EntityId()
    },
    ExitButton = {
      default = EntityId()
    },
    DividerLine = {
      default = EntityId()
    },
    TurrentList = {
      default = EntityId()
    }
  },
  animOffsetPosX = 500
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(TurretShop)
function TurretShop:OnInit()
  BaseScreen.OnInit(self)
  self.turretNames = {}
  self.turretNames[eSiegeWeaponType_Ballista] = "@siege_turret_ballista"
  self.turretNames[eSiegeWeaponType_Repeater] = "@siege_turret_repeater"
  self.turretNames[eSiegeWeaponType_Explosive] = "@siege_turret_explosive"
  self.turretNames[eSiegeWeaponType_FireBarrel] = "@siege_turret_firebarrel"
  self.turretNames[eSiegeWeaponType_Horn] = "@siege_turret_hornofresilience"
  self.turretImages = {}
  self.turretImages[eSiegeWeaponType_Ballista] = "lyshineui/images/icons/siegewarfare/ballista"
  self.turretImages[eSiegeWeaponType_Repeater] = "lyshineui/images/icons/siegewarfare/repeater"
  self.turretImages[eSiegeWeaponType_Explosive] = "lyshineui/images/icons/siegewarfare/bomb"
  self.turretImages[eSiegeWeaponType_FireBarrel] = "lyshineui/images/icons/siegewarfare/barreldropper"
  self.turretImages[eSiegeWeaponType_Horn] = "lyshineui/images/icons/siegewarfare/horn"
  self.turretLevels = {}
  self.turretLevels[eSiegeWeaponType_Ballista] = {category = eSettlementProgressionCategory_BallistaUpgrade, level = 1}
  self.turretLevels[eSiegeWeaponType_Repeater] = {category = eSettlementProgressionCategory_RepeaterUpgrade, level = 1}
  self.turretLevels[eSiegeWeaponType_Explosive] = {category = eSettlementProgressionCategory_ExplosiveUpgrade, level = 1}
  self.turretLevels[eSiegeWeaponType_FireBarrel] = {category = eSettlementProgressionCategory_FireBarrelUpgrade, level = 1}
  self.turretLevels[eSiegeWeaponType_Horn] = {category = eSettlementProgressionCategory_HornUpgrade, level = 1}
  self:SetVisualElements()
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
end
function TurretShop:SetVisualElements()
  local titleTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 56,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.TitleText, titleTextStyle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, "@siege_turretshop_title", eUiTextSet_SetLocalized)
  self.DividerLine:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.ScriptedEntityTweener:Set(self.Properties.DividerLine, {opacity = 0.7})
  self.ExitButton:SetCallback("OnExit", self)
  self.ExitButton:SetKeybindMapping("toggleMenuComponent")
  self.ScriptedEntityTweener:Set(self.entityId, {
    x = self.animOffsetPosX,
    opacity = 0
  })
end
function TurretShop:SetScreenVisible(isVisible)
  self.ScriptedEntityTweener:Stop(self.entityId)
  if isVisible then
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {x = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 1, ease = "QuadOut"})
    self.DividerLine:SetVisible(true, 0.8, {delay = 0.1})
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
      x = self.animOffsetPosX,
      ease = "QuadOut",
      onComplete = function()
        self:OnTransitionOutCompleted()
      end
    })
    self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 0, ease = "QuadOut"})
    self.DividerLine:SetVisible(false, 0.1)
  end
end
function TurretShop:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.currentTurretInteractable = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Siege.TurretInteractable")
  local claimKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  if claimKey ~= nil then
    local summaryData = LandClaimRequestBus.Broadcast.GetTerritoryProgressionData(claimKey)
    local availableTerritoryUpgrades = summaryData.territoryUpgrades
    for key, entry in pairs(self.turretLevels) do
      for i = 1, #availableTerritoryUpgrades do
        local upgradeData = availableTerritoryUpgrades[i]
        if entry.category == upgradeData.category then
          self.turretLevels[key].level = upgradeData.categoryLevel + 1
        end
      end
    end
  end
  local children = UiElementBus.Event.GetChildren(self.Properties.TurrentList)
  for i = 1, #children do
    local turretType = i - 1
    local entityTable = self.registrar:GetEntityTable(children[i])
    if entityTable then
      entityTable:SetItem(self.turretNames[turretType], self.turretImages[turretType], self.turretLevels[turretType].level, turretType)
      entityTable:SetCallback(self.BuildTurret, self)
    end
  end
  self:SetScreenVisible(true)
end
function TurretShop:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self:SetScreenVisible(false)
end
function TurretShop:BuildTurret(turretType)
  DefensiveStructureRequestBus.Event.BuildStructure(self.currentTurretInteractable, turretType)
  self:OnExit()
end
function TurretShop:OnTransitionOutCompleted()
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntity then
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  end
  UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function TurretShop:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasHeight(self.BackgroundHolder, self.canvasId)
  end
end
function TurretShop:OnShutdown()
end
function TurretShop:OnExit()
  LyShineManagerBus.Broadcast.ExitState(3940276153)
end
return TurretShop
