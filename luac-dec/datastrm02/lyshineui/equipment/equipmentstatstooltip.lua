local EquipmentStatsTooltip = {
  Properties = {
    GearScoreHeader = {
      default = EntityId()
    },
    GearScoreDivider = {
      default = EntityId()
    },
    GearScoreDescription = {
      default = EntityId()
    },
    AttributesHeader = {
      default = EntityId()
    },
    AttributesDivider = {
      default = EntityId()
    },
    Attributes = {
      default = EntityId()
    },
    DamageResistanceHeader = {
      default = EntityId()
    },
    DamageResistanceDivider = {
      default = EntityId()
    },
    PhysicalDescriptionHolder = {
      default = EntityId()
    },
    PhysicalDescription = {
      default = EntityId()
    },
    PhysicalList = {
      default = EntityId()
    },
    ElementalDescriptionHolder = {
      default = EntityId()
    },
    ElementalDescription = {
      default = EntityId()
    },
    ElementalList = {
      default = EntityId()
    }
  },
  defaultPadding = 12
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(EquipmentStatsTooltip)
function EquipmentStatsTooltip:OnInit()
  BaseScreen.OnInit(self)
  SetTextStyle(self.Properties.GearScoreHeader, self.UIStyle.FONT_STYLE_EQUIPMENT_STAT_HEADER)
  SetTextStyle(self.Properties.AttributesHeader, self.UIStyle.FONT_STYLE_EQUIPMENT_STAT_HEADER)
  SetTextStyle(self.Properties.GearScoreHeader, self.UIStyle.FONT_STYLE_EQUIPMENT_STAT_HEADER)
  SetTextStyle(self.Properties.GearScoreDescription, self.UIStyle.FONT_STYLE_EQUIPMENT_STAT_DESCRIPTION)
end
function EquipmentStatsTooltip:SetData(data)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.PhysicalList, #data.physicalModifiers)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.ElementalList, #data.elementalModifiers)
  local physicalModifiersHeight = 0
  for i = 1, #data.physicalModifiers do
    local damageModifierInfo = data.physicalModifiers[i]
    local damageNameToUse = damageModifierInfo.name
    local iconPath = "lyshineui/images/icons/tooltip/icon_tooltip_" .. damageNameToUse .. "_opaque.dds"
    local damageName = "@" .. string.lower(damageNameToUse) .. "_DamageName"
    local damageAmount = GetFormattedNumber(damageModifierInfo.total * 100, 1)
    local modifier = ""
    if 0 < damageModifierInfo.total then
      modifier = "+"
    else
      modifier = "-"
    end
    local text = GetLocalizedReplacementText("@ui_damage_type_modifier_desc", {
      modifier = modifier,
      damageName = damageName,
      damageAmount = damageAmount
    })
    local textColor = 0 < damageModifierInfo.total and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED
    local childEntity = UiElementBus.Event.GetChild(self.Properties.PhysicalList, i - 1)
    local childTable = self.registrar:GetEntityTable(childEntity)
    local childTableHeight = childTable:SetData({
      text = text,
      textColor = textColor,
      iconPath = iconPath,
      topPadding = 0,
      bottomPadding = i < #data.physicalModifiers and 5 or 0
    })
    physicalModifiersHeight = physicalModifiersHeight + childTableHeight
  end
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.PhysicalList, physicalModifiersHeight)
  local elementalModifiersHeight = 0
  for i = 1, #data.elementalModifiers do
    local damageModifierInfo = data.elementalModifiers[i]
    local damageNameToUse = damageModifierInfo.name
    local iconPath = "lyshineui/images/icons/tooltip/icon_tooltip_" .. damageNameToUse .. "_opaque.dds"
    local damageName = "@" .. string.lower(damageNameToUse) .. "_DamageName"
    local damageAmount = GetFormattedNumber(damageModifierInfo.total * 100, 1)
    local modifier = ""
    if 0 < damageModifierInfo.total then
      modifier = "+"
    else
      modifier = "-"
    end
    local text = GetLocalizedReplacementText("@ui_damage_type_modifier_desc", {
      modifier = modifier,
      damageName = damageName,
      damageAmount = damageAmount
    })
    local textColor = 0 < damageModifierInfo.total and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED
    local childEntity = UiElementBus.Event.GetChild(self.Properties.ElementalList, i - 1)
    local childTable = self.registrar:GetEntityTable(childEntity)
    local childTableHeight = childTable:SetData({
      text = text,
      textColor = textColor,
      iconPath = iconPath,
      topPadding = 0,
      bottomPadding = i < #data.elementalModifiers and 5 or 0
    })
    elementalModifiersHeight = elementalModifiersHeight + childTableHeight
  end
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ElementalList, elementalModifiersHeight)
  self:SizeTooltip()
end
function EquipmentStatsTooltip:SizeTooltip()
  local totalHeight = 0
  local tooltipElements = {
    {
      element = self.Properties.GearScoreHeader,
      height = UiTextBus.Event.GetTextHeight(self.Properties.GearScoreHeader),
      padding = 8
    },
    {
      element = self.Properties.GearScoreDivider,
      height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.GearScoreDivider),
      padding = 6
    },
    {
      element = self.Properties.GearScoreDescription,
      height = UiTextBus.Event.GetTextHeight(self.Properties.GearScoreDescription),
      padding = 2
    },
    {
      element = self.Properties.AttributesHeader,
      height = UiTextBus.Event.GetTextHeight(self.Properties.AttributesHeader),
      padding = 14
    },
    {
      element = self.Properties.AttributesDivider,
      height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.AttributesDivider),
      padding = 6
    },
    {
      element = self.Properties.Attributes,
      height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Attributes),
      padding = 4
    },
    {
      element = self.Properties.DamageResistanceHeader,
      height = UiTextBus.Event.GetTextHeight(self.Properties.DamageResistanceHeader),
      padding = 13
    },
    {
      element = self.Properties.DamageResistanceDivider,
      height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.DamageResistanceDivider),
      padding = 6
    },
    {
      element = self.Properties.PhysicalDescriptionHolder,
      height = UiTextBus.Event.GetTextHeight(self.Properties.PhysicalDescription),
      padding = 4
    },
    {
      element = self.Properties.PhysicalList,
      height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.PhysicalList),
      padding = 4
    },
    {
      element = self.Properties.ElementalDescriptionHolder,
      height = UiTextBus.Event.GetTextHeight(self.Properties.ElementalDescription),
      padding = 12
    },
    {
      element = self.Properties.ElementalList,
      height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ElementalList),
      padding = 4
    }
  }
  for i = 1, #tooltipElements do
    local current = tooltipElements[i]
    local padding = current.padding
    if (current.element == self.Properties.PhysicalList or current.element == self.Properties.ElementalList) and current.height == 0 then
      padding = -8
    end
    totalHeight = totalHeight + padding
    UiTransformBus.Event.SetLocalPositionY(current.element, totalHeight)
    totalHeight = totalHeight + current.height
  end
  local bottomPadding = 20
  totalHeight = totalHeight + bottomPadding
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, totalHeight)
end
return EquipmentStatsTooltip
