local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local DamageStatRow = {
  Properties = {
    ItemLayout = {
      default = EntityId()
    },
    BaseDamageValue = {
      default = EntityId()
    },
    PreviewDamageValue = {
      default = EntityId()
    },
    KeyHint = {
      default = EntityId()
    },
    EmptySlot = {
      default = EntityId()
    },
    EmptySlotTooltip = {
      default = EntityId()
    }
  },
  pendingValue = 0,
  statValue = 0,
  weaponBaseDamage = 0,
  previewOffset = 9
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DamageStatRow)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function DamageStatRow:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", self.SetPaperdollId)
  self.previewDamageDefaultX = UiTransformBus.Event.GetLocalPositionX(self.Properties.PreviewDamageValue)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.PreviewDamageValue, self.previewDamageDefaultX - self.previewOffset)
  self.EmptySlotTooltip:SetSimpleTooltip("@ui_quickslot_mainhand_tooltip")
  SetTextStyle(self.Properties.BaseDamageValue, self.UIStyle.FONT_STYLE_ATTRIBUTES_STAT)
end
function DamageStatRow:SetPaperdollId(value)
  self.paperdollId = value
end
function DamageStatRow:RegisterObservers()
  if self.pendingDataPath ~= nil then
    self.dataLayer:RegisterAndExecuteDataObserver(self, self.pendingDataPath, function(self, data)
      if data ~= nil then
        self:UpdateModifiedValue(data)
      end
    end)
  end
end
function DamageStatRow:UnregisterObservers()
  self.dataLayer:UnregisterObservers(self)
end
function DamageStatRow:SetDataPath(value)
  self.statDataPath = value
  if self.pendingDataPath then
    self:RegisterObservers()
  end
end
function DamageStatRow:SetPendingDataPath(value)
  self.pendingDataPath = value
  if self.statDataPath then
    self:RegisterObservers()
  end
end
function DamageStatRow:SetSlotType(value)
  self.slotType = value
  self:RefreshItemData()
end
function DamageStatRow:EmptySlotFocus()
  self.EmptySlotTooltip:OnTooltipSetterHoverStart()
end
function DamageStatRow:EmptySlotUnfocus()
  self.EmptySlotTooltip:OnTooltipSetterHoverEnd()
end
function DamageStatRow:RefreshItemData()
  local isItemValid = false
  if self.paperdollId and self.slotType then
    local itemSlot = ContainerRequestBus.Event.GetSlot(self.paperdollId, self.slotType)
    isItemValid = itemSlot:IsValid()
    local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    local weaponCoreDamage = itemSlot:GetCoreDamage(rootEntityId)
    if self.numberFormat then
      weaponCoreDamage = string.format(self.numberFormat, weaponCoreDamage)
    end
    UiTextBus.Event.SetText(self.Properties.BaseDamageValue, weaponCoreDamage)
    if isItemValid then
      self.ItemLayout:SetItemAndSlotProvider(itemSlot, self.slotType, function()
        local slot = ContainerRequestBus.Event.GetSlot(self.paperdollId, self.slotType)
        return slot
      end)
      self.ItemLayout:SetTooltipEnabled(true)
      self.ItemLayout:SetAllowExternalCompare(true)
      self.ItemLayout:SetIsInPaperdoll(true)
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemLayout, isItemValid)
  UiElementBus.Event.SetIsEnabled(self.Properties.BaseDamageValue, isItemValid)
  UiElementBus.Event.SetIsEnabled(self.Properties.EmptySlot, not isItemValid)
  self.ScriptedEntityTweener:Set(self.Properties.KeyHint, {
    opacity = isItemValid and 1 or 0.4
  })
end
function DamageStatRow:SetIsPercent(value)
  self.isPercent = value
end
function DamageStatRow:SetNumberFormat(value)
  self.numberFormat = value
end
function DamageStatRow:SetName(value)
  self.name = value
end
function DamageStatRow:SetHint(value)
  self.KeyHint:SetKeybindMapping(value)
end
function DamageStatRow:UpdateModifiedValue(weaponDamage)
  local animDuration = 0.15
  if weaponDamage and 0 < weaponDamage then
    if self.numberFormat then
      weaponDamage = string.format(self.numberFormat, weaponDamage)
    end
    UiTextBus.Event.SetText(self.Properties.PreviewDamageValue, weaponDamage)
    self.ScriptedEntityTweener:Play(self.Properties.PreviewDamageValue, animDuration, {
      x = self.previewDamageDefaultX,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:PlayC(self.Properties.PreviewDamageValue, animDuration, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:Play(self.Properties.PreviewDamageValue, animDuration, {
      x = self.previewDamageDefaultX - self.previewOffset,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:PlayC(self.Properties.PreviewDamageValue, animDuration, tweenerCommon.fadeOutQuadIn)
  end
end
function DamageStatRow:OnShutdown()
  self:UnregisterObservers()
end
return DamageStatRow
