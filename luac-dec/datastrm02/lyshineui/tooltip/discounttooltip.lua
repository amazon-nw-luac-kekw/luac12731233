local DiscountTooltip = {
  Properties = {
    Header = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    },
    UnusedEntries = {
      default = EntityId()
    },
    UnusedDiscountEntries = {
      default = EntityId()
    },
    UnusedSeparators = {
      default = EntityId()
    },
    Entries = {
      default = {
        EntityId()
      }
    },
    DiscountEntries = {
      default = {
        EntityId()
      }
    },
    Separators = {
      default = {
        EntityId()
      }
    },
    Total = {
      default = EntityId()
    },
    TotalCost = {
      default = EntityId()
    },
    TotalIcon = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DiscountTooltip)
local TooltipCommon = RequireScript("LyShineUI._Common.TooltipCommon")
function DiscountTooltip:OnInit()
  BaseElement.OnInit()
  SetTextStyle(self.Properties.Header, self.UIStyle.FONT_STYLE_FLYOUT_BUTTON)
end
function DiscountTooltip:SetData(tooltipInfo)
  local cost = 0
  local fee = 0
  UiTextBus.Event.SetTextWithFlags(self.Properties.Header, tooltipInfo.name, eUiTextSet_SetLocalized)
  if tooltipInfo.costEntries then
    for i, entry in pairs(tooltipInfo.costEntries) do
      if i >= #self.Properties.Entries then
        Debug.Log("Warning: Too many cost entries for Discount Tooltip, add more in Tooltip.uicanvas")
        break
      end
      local newEntry = self.Properties.Entries[i - 1]
      UiElementBus.Event.Reparent(newEntry, self.Properties.Content, EntityId())
      self.Entries[i - 1]:SetData(entry, tooltipInfo.useLocalizedCurrency)
      if entry.cost then
        cost = cost + entry.cost
      end
      if entry.type == TooltipCommon.DiscountEntryTypes.Fee then
        fee = fee + entry.cost
      end
    end
    self:ReparentRestToUnused(#tooltipInfo.costEntries, self.Properties.Entries, self.Properties.UnusedEntries)
  end
  local discountEntriesUsed = 0
  local nextSeparator = 0
  UiElementBus.Event.Reparent(self.Properties.Separators[nextSeparator], self.Properties.Content, EntityId())
  nextSeparator = nextSeparator + 1
  if tooltipInfo.costEntriesDiscounts and 0 < #tooltipInfo.costEntriesDiscounts then
    for i, entry in pairs(tooltipInfo.costEntriesDiscounts) do
      if i > #self.Properties.DiscountEntries then
        Debug.Log("Warning: Too many discount entries for Discount Tooltip, add more in Tooltip.uicanvas")
        break
      end
      local newEntry = self.Properties.DiscountEntries[i - 1]
      UiElementBus.Event.Reparent(newEntry, self.Properties.Content, EntityId())
      entry.cost = entry.discount
      entry.hasDiscount = entry.cost ~= 0
      cost = cost - entry.discount
      self.DiscountEntries[i - 1]:SetData(entry, tooltipInfo.useLocalizedCurrency)
    end
    discountEntriesUsed = discountEntriesUsed + #tooltipInfo.costEntriesDiscounts
    UiElementBus.Event.Reparent(self.Properties.Separators[nextSeparator], self.Properties.Content, EntityId())
    nextSeparator = nextSeparator + 1
  elseif UiElementBus.Event.GetParent(self.Properties.Separators[nextSeparator]) ~= self.Properties.UnusedSeparators then
    UiElementBus.Event.Reparent(self.Properties.Separators[nextSeparator], self.Properties.UnusedSeparators, EntityId())
    nextSeparator = nextSeparator + 1
  end
  local totalBeforeDiscount = cost
  local totalDiscounts = 0
  if tooltipInfo.discountEntries and 0 < #tooltipInfo.discountEntries then
    for i, entry in pairs(tooltipInfo.discountEntries) do
      local index = i + discountEntriesUsed
      if index > #self.Properties.DiscountEntries then
        Debug.Log("Warning: Too many discount entries for Discount Tooltip, add more in Tooltip.uicanvas")
        break
      end
      local newEntry = self.Properties.DiscountEntries[index - 1]
      UiElementBus.Event.Reparent(newEntry, self.Properties.Content, EntityId())
      if entry.hasDiscount == true then
        if entry.applyOnFeeOnly then
          entry.cost = math.floor(fee * (entry.discountPct / 100))
        elseif entry.useRemainingValue then
          entry.cost = tooltipInfo.totalDiscounts - totalDiscounts
        elseif entry.roundValue then
          entry.cost = math.floor(totalBeforeDiscount * (entry.discountPct / 100))
        else
          entry.cost = totalBeforeDiscount * (entry.discountPct / 100)
        end
        cost = cost - entry.cost
        totalDiscounts = totalDiscounts + entry.cost
      elseif entry.hasMultiplicativeDiscount == true then
        totalBeforeDiscount = totalBeforeDiscount * (1 - entry.discountPct / 100)
        local nextCumulativePrice = GetRoundedNumber(totalBeforeDiscount)
        if not entry.isComputed then
          entry.cost = cost - nextCumulativePrice
          entry.isComputed = true
        end
        cost = nextCumulativePrice
      end
      self.DiscountEntries[index - 1]:SetData(entry, tooltipInfo.useLocalizedCurrency)
    end
    discountEntriesUsed = discountEntriesUsed + #tooltipInfo.discountEntries
    UiElementBus.Event.Reparent(self.Properties.Separators[nextSeparator], self.Properties.Content, EntityId())
    nextSeparator = nextSeparator + 1
  elseif UiElementBus.Event.GetParent(self.Properties.Separators[nextSeparator]) ~= self.Properties.UnusedSeparators then
    UiElementBus.Event.Reparent(self.Properties.Separators[nextSeparator], self.Properties.UnusedSeparators, EntityId())
    nextSeparator = nextSeparator + 1
  end
  self:ReparentRestToUnused(discountEntriesUsed, self.Properties.DiscountEntries, self.Properties.UnusedDiscountEntries)
  UiElementBus.Event.Reparent(self.Properties.Total, self.Properties.Content, EntityId())
  local costString = tostring(cost)
  if tooltipInfo.useLocalizedCurrency then
    costString = tostring(GetLocalizedCurrency(cost))
  end
  UiTextBus.Event.SetText(self.Properties.TotalCost, costString)
  local height = UiLayoutCellDefaultBus.Event.GetTargetHeight(self.Properties.Content)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  if tooltipInfo.useLocalizedCurrency then
    UiImageBus.Event.SetSpritePathname(self.Properties.TotalIcon, "lyshineui/images/icon_crown.dds")
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.TotalIcon, "lyshineui/images/icons/misc/icon_azothcurrency.dds")
  end
end
function DiscountTooltip:ReparentRestToUnused(index, list, parent)
  for i = index, #list do
    if UiElementBus.Event.GetParent(list[i]) ~= parent then
      UiElementBus.Event.Reparent(list[i], parent, EntityId())
    end
  end
end
return DiscountTooltip
