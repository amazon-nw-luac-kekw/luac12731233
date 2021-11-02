local MarkerStatusEffect = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    StackCountText = {
      default = EntityId()
    }
  },
  imageDirectory = "lyshineui/images/status",
  isEnabled = false,
  isStackCountEnabled = false,
  isNegative = false
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local registrar = RequireScript("LyShineUI.EntityRegistrar")
function MarkerStatusEffect:OnActivate()
  self.UIStyle = UIStyle
  self.dataLayer = dataLayer
  self.registrar = registrar
  self.registrar:RegisterEntity(self)
end
function MarkerStatusEffect:OnDeactivate()
  if self.registrar then
    self.registrar:UnregisterEntity(self)
  end
  self.dataLayer:UnregisterObservers(self)
end
function MarkerStatusEffect:InitializeToMarkerDatapath(dataPath, index)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPath .. ".StatusEffectStackSize." .. tostring(index), function(self, stackSize)
    local isEnabled = stackSize and 0 < stackSize
    UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
    if isEnabled then
      self.isStackCountEnabled = 1 < stackSize
      UiElementBus.Event.SetIsEnabled(self.Properties.StackCountText, self.isStackCountEnabled)
      if self.isStackCountEnabled then
        UiTextBus.Event.SetText(self.Properties.StackCountText, "\195\151" .. stackSize)
        UiTextBus.Event.SetColor(self.Properties.StackCountText, self.UIStyle.COLOR_WHITE)
      end
    else
      self.isStackCountEnabled = false
      self.isNegative = false
    end
    if isEnabled ~= self.isEnabled then
      self.isEnabled = isEnabled
      if self.visibilityCallback then
        self.visibilityCallback(self.visibilityCallbackTable, self.isEnabled)
      end
    end
  end)
  self.dataLayer:RegisterDataObserver(self, dataPath .. ".StatusEffectImage." .. tostring(index), function(self, icon)
    if icon then
      local imagePath = string.format("%s/%s.dds", self.imageDirectory, icon)
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, imagePath)
    end
  end)
  self.dataLayer:RegisterDataObserver(self, dataPath .. ".StatusEffectIsNegative." .. tostring(index), function(self, isNegative)
    self.isNegative = isNegative
    if self.isEnabled then
      UiImageBus.Event.SetColor(self.entityId, self.isNegative and self.UIStyle.COLOR_RED_DARK or self.UIStyle.COLOR_BLACK)
      if self.isStackCountEnabled then
        UiTextBus.Event.SetColor(self.Properties.StackCountText, self.isNegative and self.UIStyle.COLOR_YELLOW or self.UIStyle.COLOR_WHITE)
      end
    end
  end)
end
function MarkerStatusEffect:SetVisibilityCallback(callback, callbackTable)
  self.visibilityCallback = callback
  self.visibilityCallbackTable = callbackTable
end
return MarkerStatusEffect
