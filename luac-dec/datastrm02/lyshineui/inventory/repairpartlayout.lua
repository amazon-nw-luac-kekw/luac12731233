local RepairPartLayout = {
  Properties = {
    Tier = {
      default = 1,
      min = 1,
      max = 5,
      step = 1,
      order = 1
    },
    Icon = {
      default = EntityId(),
      order = 2
    },
    ValueText = {
      default = EntityId(),
      order = 3
    },
    SeparatorText = {
      default = EntityId(),
      order = 4
    },
    MaxValueText = {
      default = EntityId(),
      order = 5
    }
  },
  value = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RepairPartLayout)
local InventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
function RepairPartLayout:OnInit()
  BaseElement.OnInit(self)
  local iconPath = "LyShineUI/Images/Icons/RepairPartsCurrency/RepairPartsT" .. self.Properties.Tier .. "_Currency.png"
  self.Icon:SetIcon(iconPath, self.UIStyle.COLOR_WHITE)
  local valueStyle = {
    fontFamily = self.FONT_FAMILY_CASLON,
    fontSize = 28,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.Properties.ValueText, valueStyle)
  local maxValueStyle = {
    fontFamily = self.FONT_FAMILY_CASLON,
    fontSize = 28,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.Properties.SeparatorText, maxValueStyle)
  SetTextStyle(self.Properties.MaxValueText, maxValueStyle)
end
function RepairPartLayout:SetValue(value)
  self.value = value
  UiTextBus.Event.SetText(self.Properties.ValueText, GetFormattedNumber(value, 0))
end
function RepairPartLayout:GetValue()
  return self.value
end
function RepairPartLayout:SetMaxValue(value)
  UiTextBus.Event.SetText(self.Properties.MaxValueText, GetFormattedNumber(value, 0))
end
function RepairPartLayout:OnFocus()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu:IsLocked() then
    return
  end
  local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
  if flyoutVisible and flyoutMenu.invokingEntityId == self.entityId then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local rows = {}
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_CurrencyInfo,
    iconPath = "LyShineUI/Images/Icons/Items_HiRes/RepairPartsT1.dds",
    descriptionText = "@inv_repairparts_tooltip_description",
    currencyName = "@inv_repairparts_tooltip_name",
    derivedFrom = "@inv_repairparts_tooltip_drivedfrom"
  })
  if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
    flyoutMenu:SetOpenLocation(self.entityId)
    flyoutMenu:SetClosedCallback(self, self.OnFlyoutMenuClosed)
    flyoutMenu:SetRowData(rows)
    flyoutMenu:SetSourceHoverOnly(true)
    flyoutMenu:DockToCursor()
    flyoutMenu:Unlock()
  end
end
function RepairPartLayout:OnUnfocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
function RepairPartLayout:OnPress()
  if self.Tier > InventoryCommon.MAX_REPAIR_PART_CONVERSION_TIER then
    return
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  flyoutMenu:SetSourceHoverOnly(false)
  flyoutMenu:Lock()
end
function RepairPartLayout:OnFlyoutMenuClosed()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  flyoutMenu:Unlock()
end
return RepairPartLayout
