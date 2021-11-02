local StatusEffects = {
  Properties = {
    ActiveContainer = {
      default = EntityId()
    },
    InactiveContainer = {
      default = EntityId()
    },
    ImageDirectory = {
      default = "lyshineui/images/status"
    },
    EncumbranceStatus = {
      default = EntityId()
    },
    StatusEffect1 = {
      default = EntityId()
    },
    StatusEffect2 = {
      default = EntityId()
    },
    StatusEffect3 = {
      default = EntityId()
    },
    StatusEffect4 = {
      default = EntityId()
    },
    StatusEffect5 = {
      default = EntityId()
    },
    StatusEffect6 = {
      default = EntityId()
    },
    StatusEffect7 = {
      default = EntityId()
    },
    StatusEffect8 = {
      default = EntityId()
    }
  },
  DEBUG_KeyBinds = false,
  tickTimer = 0,
  lastNumStatusEffects = -1,
  isFtue = false,
  MAX_SHOWING = 0,
  screenStatesToDisable = {
    [3901667439] = true,
    [3024636726] = true,
    [2552344588] = true,
    [2478623298] = true,
    [1967160747] = true,
    [4143822268] = true,
    [1628671568] = true,
    [3175660710] = true,
    [1823500652] = true,
    [156281203] = true,
    [3784122317] = true,
    [849925872] = true,
    [640726528] = true,
    [3370453353] = true,
    [2896319374] = true,
    [828869394] = true,
    [3211015753] = true,
    [2640373987] = true,
    [2437603339] = true,
    [1319313135] = true,
    [1468490675] = true,
    [1101180544] = true,
    [3576764016] = true,
    [1634988588] = true,
    [319051850] = true,
    [921202721] = true,
    [4283914359] = true,
    [3548394217] = true
  },
  threeColumnPositionX = -506,
  threeColumnPositionY = -168,
  threeColumnScale = 0.9,
  InventoryPositionX = -245,
  defaultPositionX = 0,
  defaultPositionY = -152,
  defaultScale = 1,
  offsetStates = {}
}
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(StatusEffects)
local InvalidEntityId = EntityId()
function StatusEffects:OnInit()
  BaseScreen.OnInit(self)
  self.cachedEffects = {
    self.StatusEffect1,
    self.StatusEffect2,
    self.StatusEffect3,
    self.StatusEffect4,
    self.StatusEffect5,
    self.StatusEffect6,
    self.StatusEffect7,
    self.StatusEffect8
  }
  for i, effect in ipairs(self.cachedEffects) do
    effect:SetStatusEffectDataPath(self.Properties.ImageDirectory, "Hud.LocalPlayer.StatusEffects." .. tostring(i), self, function(self, isActive)
      if isActive then
        local isResting = self:IsRestingEffect(effect.name)
        if isResting then
          self.restingEffect = effect
          self.tickTimer = 1
          if self.tickBusHandler == nil then
            self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
          end
          if self:IsFullHealth() then
            self:ShowRestedNotification()
          end
        else
          self:AnimateUpdate(effect.entityId)
        end
      else
        if effect == self.restingEffect then
          self.restingEffect = nil
        end
        self:AnimateOut(effect.entityId)
      end
    end)
  end
  self.offsetStates = {}
  self.offsetStates[2972535350] = true
  self.offsetStates[476411249] = true
  self.offsetStates[3349343259] = true
  self.offsetStates[2230605386] = true
  self.offsetStates[2478623298] = true
  self.offsetStates[1809891471] = true
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Equipment.EquipLoadCategory", self.OnEquipLoadChange)
  if self.DEBUG_KeyBinds then
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F01", "lc_statusEffectAdd MajorDrinkBleedResist")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F02", "lc_statusEffectRemove MajorDrinkBleedResist")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F03", "lc_statusEffectAdd MajorDrinkFrostbiteResist")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F04", "lc_statusEffectRemove MajorDrinkFrostbiteResist")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F05", "lc_statusEffectAdd MajorDrinkPoisonResist")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F06", "lc_statusEffectRemove MajorDrinkPoisonResist")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F07", "lc_statusEffectAdd MajorDrinkCurseResist")
    LyShineScriptBindRequestBus.Broadcast.CreateKeyBind("ctrl_keyboard_key_function_F08", "lc_statusEffectRemove MajorDrinkCurseResist")
  end
  DynamicBus.StatusEffects.Connect(self.entityId, self)
  local hudSettingCommon = RequireScript("LyShineUI._Common.HudSettingCommon")
  hudSettingCommon:RegisterEntityToFadeOnSprint(self.entityId)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  if self.uiLoaderHandler then
    DynamicBus.UiLoader.Disconnect(self.entityId, self)
  end
  self.uiLoaderHandler = DynamicBus.UiLoader.Connect(self.entityId, self)
end
function StatusEffects:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.StatusEffects.Disconnect(self.entityId, self)
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  self.restingEffect = nil
  if self.uiLoaderHandler then
    self.uiLoaderHandler = nil
    DynamicBus.UiLoader.Disconnect(self.entityId, self)
  end
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
end
function StatusEffects:IsCurrentlyResting()
  return self.restingEffect ~= nil
end
function StatusEffects:AnimateUpdate(entityId)
  local parentId = UiElementBus.Event.GetParent(entityId)
  if parentId ~= self.Properties.ActiveContainer then
    local fadeValue = UiFaderBus.Event.GetFadeValue(entityId)
    UiElementBus.Event.Reparent(entityId, self.Properties.ActiveContainer, InvalidEntityId)
    local adjustedDuration = (1 - fadeValue) * 0.25
    self.ScriptedEntityTweener:Play(entityId, adjustedDuration, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1
    })
  end
end
function StatusEffects:AnimateOut(entityId)
  local parentId = UiElementBus.Event.GetParent(entityId)
  if parentId ~= self.Properties.InactiveContainer then
    self.ScriptedEntityTweener:Play(entityId, 0.25, {
      opacity = 0,
      scaleX = 0.05,
      scaleY = 0.05,
      onComplete = function()
        UiElementBus.Event.Reparent(entityId, self.Properties.InactiveContainer, InvalidEntityId)
      end
    })
    return true
  end
end
function StatusEffects:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
  if self.offsetStates[fromState] then
    return
  end
  if self.offsetStates[toState] then
    local offsetPositionX = self.threeColumnPositionX
    local scale = self.threeColumnScale
    local positionY = self.threeColumnPositionY
    if toState == 2972535350 then
      offsetPositionX = self.InventoryPositionX
      scale = self.defaultScale
      positionY = self.defaultPositionY
    end
    if toState == 3349343259 and self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop") then
      offsetPositionX = self.InventoryPositionX
      scale = self.defaultScale
      positionY = self.defaultPositionY
    end
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
      x = offsetPositionX,
      scaleX = scale,
      scaleY = scale,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ActiveContainer, 0.3, {y = positionY, ease = "QuadOut"})
  end
end
function StatusEffects:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.offsetStates[fromState] and not self.offsetStates[toState] then
    local currentPosX = UiTransformBus.Event.GetLocalPositionX(self.entityId)
    if currentPosX ~= self.defaultPositionX then
      self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
        x = self.defaultPositionX,
        scaleX = self.defaultScale,
        scaleY = self.defaultScale,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ActiveContainer, 0.3, {
        y = self.defaultPositionY,
        ease = "QuadOut"
      })
    end
  end
  if self.screenStatesToDisable[fromState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
end
function StatusEffects:ShowRestedNotification()
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_fully_rested"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function StatusEffects:OnTick(deltaTime, timePoint)
  self.tickTimer = self.tickTimer + deltaTime
  if self.tickTimer > 1 then
    self.tickTimer = 0
    if self.restingEffect then
      if self:IsFullHealth() then
        if self:AnimateOut(self.restingEffect.entityId) then
          self:ShowRestedNotification()
        end
      else
        self:AnimateUpdate(self.restingEffect.entityId)
      end
    end
    if not self.restingEffect and self.tickBusHandler then
      self:BusDisconnect(self.tickBusHandler)
      self.tickBusHandler = nil
    end
  end
end
function StatusEffects:IsFullHealth()
  return self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.HealthPercent") > 0.99
end
function StatusEffects:IsRestingEffect(effectName)
  if effectName then
    return string.find(effectName, "status_hpregen", 1, true) ~= nil
  else
    return false
  end
end
function StatusEffects:OnEquipLoadChange(equipLoadState)
  local isOverburdened = equipLoadState == eEquipLoad_Overburdened
  if isOverburdened then
    self.ScriptedEntityTweener:Play(self.Properties.EncumbranceStatus, 0.25, {
      scaleX = 1,
      scaleY = 1,
      opacity = 1
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.EncumbranceStatus, 0.25, {
      scaleX = 0.05,
      scaleY = 0.05,
      opacity = 0
    })
  end
end
function StatusEffects:OnUiLoadingComplete()
  if self.uiLoaderHandler then
    self.uiLoaderHandler = nil
    DynamicBus.UiLoader.Disconnect(self.entityId, self)
  end
  local imagePath = string.format("%s/%s.png", self.Properties.ImageDirectory, "over_equipped")
  self.EncumbranceStatus:SetStatusEffectInfo("@inv_equipLoadOverburdened", "@inv_equipLoadOverburdened_Tooltip", imagePath, timeHelpers:ServerNow())
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    self.EncumbranceStatus:UpdateText()
    for k, effect in pairs(self.cachedEffects) do
      effect:UpdateText()
    end
  end)
end
function StatusEffects:SetVisible(visible)
  if visible then
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.1, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.1, tweenerCommon.fadeOutQuadOut)
  end
end
function StatusEffects:SetElementVisibleForFtue(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:PlayC(self.entityId, self.UIStyle.DURATION_FTUE_OUTRO, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.entityId, self.UIStyle.DURATION_FTUE_OUTRO, tweenerCommon.fadeOutQuadOut)
  end
  UiCanvasBus.Event.SetEnabled(self.canvasId, isVisible == true)
end
return StatusEffects
