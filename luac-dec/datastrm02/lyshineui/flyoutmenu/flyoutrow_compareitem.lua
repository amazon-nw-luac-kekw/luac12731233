local FlyoutRow_CompareItem = {
  Properties = {
    ItemLocation = {
      default = EntityId()
    },
    ItemLayout = {
      default = EntityId()
    },
    SecondaryScoreText = {
      default = EntityId()
    },
    SecondaryScoreArrow = {
      default = EntityId()
    },
    GearScoreText = {
      default = EntityId()
    },
    GearScoreArrow = {
      default = EntityId()
    }
  },
  callback = nil,
  callbackTable = nil,
  callbackData = nil,
  height = 54,
  HEIGHT_WITH_HEADER = 98,
  HEIGHT_WITHOUT_HEADER = 54,
  HEIGHT_HEADER_ONLY = 44
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_CompareItem)
function FlyoutRow_CompareItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.ItemLocation, self.UIStyle.FONT_STYLE_TOOLTIP_ACTIONS_HEADER)
  SetTextStyle(self.Properties.SecondaryScoreText, self.UIStyle.FONT_STYLE_GEAR_SCORE_SMALL)
  SetTextStyle(self.Properties.GearScoreText, self.UIStyle.FONT_STYLE_GEAR_SCORE_SMALL)
  self.ItemLayout:SetFocusCallback(self, self.OnItemLayoutFocus)
  self.ItemLayout:SetUnfocusCallback(self, self.OnItemLayoutUnfocus)
end
function FlyoutRow_CompareItem:SetCompareData(itemSlot, location, count, isInPaperdoll, ownerItemTable, flyoutOnRight)
  local showIcon = itemSlot and itemSlot:IsValid()
  local showLocationText = location ~= "" and location ~= nil
  if not showIcon and not showLocationText then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemLocation, showLocationText)
  if showLocationText then
    local headerText = location
    if showIcon then
      headerText = GetLocalizedReplacementText("@inv_compareTo", {location = location})
      self.height = self.HEIGHT_WITH_HEADER
    else
      self.height = self.HEIGHT_HEADER_ONLY
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemLayout, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreText, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryScoreText, false)
    end
    UiTextBus.Event.SetText(self.Properties.ItemLocation, headerText)
  else
    self.height = self.HEIGHT_WITHOUT_HEADER
  end
  if showIcon then
    self.ItemLayout:SetItemAndSlotProvider(itemSlot, nil, function()
      return itemSlot
    end)
    self.ItemLayout:SetTooltipEnabled(true)
    if 1 < count then
      UiTextBus.Event.SetText(self.ItemLayout.Properties.ItemQuantity, tostring(count))
      UiElementBus.Event.SetIsEnabled(self.ItemLayout.Properties.ItemQuantity, true)
    end
    self.ScriptedEntityTweener:Set(self.Properties.ItemLayout, {scaleX = 0.8, scaleY = 0.8})
    self:OnItemLayoutUnfocus()
    local itemDescriptor = itemSlot:GetItemDescriptor()
    local gearScore = itemDescriptor and itemDescriptor:GetGearScore() or 0
    local gearScoreDifference = gearScore - ownerItemTable.gearScore
    UiTextBus.Event.SetText(self.Properties.GearScoreText, gearScore)
    if 0 < gearScoreDifference then
      UiTextBus.Event.SetColor(self.Properties.GearScoreText, self.UIStyle.COLOR_COMPARE_BETTER)
      UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreArrow, true)
      self.ScriptedEntityTweener:Set(self.Properties.GearScoreArrow, {
        scaleY = 1,
        imgColor = self.UIStyle.COLOR_COMPARE_BETTER
      })
    elseif gearScoreDifference < 0 then
      UiTextBus.Event.SetColor(self.Properties.GearScoreText, self.UIStyle.COLOR_COMPARE_WORSE)
      UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreArrow, true)
      self.ScriptedEntityTweener:Set(self.Properties.GearScoreArrow, {
        scaleY = -1,
        imgColor = self.UIStyle.COLOR_COMPARE_WORSE
      })
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreArrow, false)
      UiTextBus.Event.SetColor(self.Properties.GearScoreText, self.UIStyle.COLOR_COMPARE_EVEN)
      UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreArrow, false)
    end
    local itemType = itemSlot:GetItemType()
    local weaponAttributes = itemSlot:GetWeaponAttributes()
    local secondaryScore = 0
    local ownerSecondaryScore = 0
    if ownerItemTable.itemType == "Ammo" and itemType == "Ammo" then
      local ammoAttributes = itemDescriptor:GetAmmoAttributes()
      UiTextBus.Event.SetText(self.Properties.SecondaryScoreText, LocalizeDecimalSeparators(string.format("x %.02f", ammoAttributes.damageModifier)))
      secondaryScore = ammoAttributes.damageModifier
      ownerSecondaryScore = ownerItemTable.ammoAttributes.damageModifier
    elseif ownerItemTable.weaponAttributes and weaponAttributes then
      if type(ownerItemTable.weaponAttributes.gatheringEfficiency) == "number" and 0 < ownerItemTable.weaponAttributes.gatheringEfficiency and type(weaponAttributes.gatheringEfficiency) == "number" and 0 < weaponAttributes.gatheringEfficiency then
        UiTextBus.Event.SetText(self.Properties.SecondaryScoreText, string.format("%.0f%%", weaponAttributes.gatheringEfficiency * 100))
        secondaryScore = weaponAttributes.gatheringEfficiency
        ownerSecondaryScore = ownerItemTable.weaponAttributes.gatheringEfficiency
      elseif type(ownerItemTable.weaponAttributes.baseDamage) == "number" and 0 < ownerItemTable.weaponAttributes.baseDamage and type(weaponAttributes.baseDamage) == "number" and 0 < weaponAttributes.baseDamage then
        local showDamageText = weaponAttributes.primaryAttack and 0 < #weaponAttributes.primaryAttack or weaponAttributes.alternateAttack and 0 < #weaponAttributes.alternateAttack
        local ownerShowDamageText = ownerItemTable.weaponAttributes.primaryAttack and 0 < #ownerItemTable.weaponAttributes.primaryAttack or ownerItemTable.weaponAttributes.alternateAttack and 0 < #ownerItemTable.weaponAttributes.alternateAttack
        if (showDamageText or weaponAttributes.isMagic) and (ownerShowDamageText or ownerItemTable.weaponAttributes.isMagic) then
          local shortNumber = math.floor(weaponAttributes.baseDamage)
          UiTextBus.Event.SetText(self.Properties.SecondaryScoreText, shortNumber)
          secondaryScore = weaponAttributes.baseDamage
          ownerSecondaryScore = ownerItemTable.weaponAttributes.baseDamage
        end
      end
    end
    local hasSecondaryScore = secondaryScore ~= 0 and ownerSecondaryScore ~= 0
    UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryScoreText, hasSecondaryScore)
    local isRectangle = self.ItemLayout.layout == self.UIStyle.ITEM_LAYOUT_RECTANGLE
    local secondaryScoreTextPosition = -37
    local gearScoreTextPosition = -74
    local itemLayoutPosition = 42
    if not isRectangle then
      secondaryScoreTextPosition = -12
      gearScoreTextPosition = -51
    end
    if hasSecondaryScore then
      local secondaryScoreDifference = secondaryScore - ownerSecondaryScore
      if 0 < secondaryScoreDifference then
        UiTextBus.Event.SetColor(self.Properties.SecondaryScoreText, self.UIStyle.COLOR_COMPARE_BETTER)
        UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryScoreArrow, true)
        self.ScriptedEntityTweener:Set(self.Properties.SecondaryScoreArrow, {
          scaleY = 1,
          imgColor = self.UIStyle.COLOR_COMPARE_BETTER
        })
      elseif secondaryScoreDifference < 0 then
        UiTextBus.Event.SetColor(self.Properties.SecondaryScoreText, self.UIStyle.COLOR_COMPARE_WORSE)
        UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryScoreArrow, true)
        self.ScriptedEntityTweener:Set(self.Properties.SecondaryScoreArrow, {
          scaleY = -1,
          imgColor = self.UIStyle.COLOR_COMPARE_WORSE
        })
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryScoreArrow, false)
        UiTextBus.Event.SetColor(self.Properties.SecondaryScoreText, self.UIStyle.COLOR_COMPARE_EVEN)
        UiElementBus.Event.SetIsEnabled(self.Properties.SecondaryScoreArrow, false)
      end
    else
      gearScoreTextPosition = secondaryScoreTextPosition
    end
    if flyoutOnRight then
      gearScoreTextPosition = gearScoreTextPosition - 6
    end
    self.ScriptedEntityTweener:Set(self.Properties.GearScoreText, {x = gearScoreTextPosition})
    self.ScriptedEntityTweener:Set(self.Properties.SecondaryScoreText, {x = secondaryScoreTextPosition})
    self.ScriptedEntityTweener:Set(self.Properties.ItemLayout, {x = itemLayoutPosition})
  end
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, self.height)
end
function FlyoutRow_CompareItem:GetHeight()
  return self.height
end
function FlyoutRow_CompareItem:SetCallback(command, table, data)
  self.callback = command
  self.table = table
  self.data = data
end
function FlyoutRow_CompareItem:ExecuteCallback()
  if self.callback and self.table then
    if type(self.callback) == "function" then
      self.callback(self.table, self.data)
    elseif type(self.table[self.callback]) == "function" then
      self.table[self.callback](self.table, self.data)
    end
  end
end
function FlyoutRow_CompareItem:OnButtonClick()
  self:ExecuteCallback()
  if not self.stayOpenOnPress then
    DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
  end
end
function FlyoutRow_CompareItem:OnItemLayoutFocus()
  self.ScriptedEntityTweener:Play(self.Properties.ItemLayout, 0.15, {opacity = 1})
  self.ScriptedEntityTweener:Play(self.Properties.SecondaryScoreText, 0.15, {opacity = 1})
  self.ScriptedEntityTweener:Play(self.Properties.GearScoreText, 0.15, {opacity = 1})
end
function FlyoutRow_CompareItem:OnItemLayoutUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.ItemLayout, 0.15, {opacity = 0.4})
  self.ScriptedEntityTweener:Play(self.Properties.SecondaryScoreText, 0.15, {opacity = 0.6})
  self.ScriptedEntityTweener:Play(self.Properties.GearScoreText, 0.15, {opacity = 0.6})
end
return FlyoutRow_CompareItem
