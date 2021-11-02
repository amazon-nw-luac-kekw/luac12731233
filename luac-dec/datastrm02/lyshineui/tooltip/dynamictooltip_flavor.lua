local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local DynamicTooltip_Flavor = {
  Properties = {
    Container = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    },
    Hint = {
      default = EntityId()
    },
    HintText = {
      default = EntityId()
    },
    IngredientTypesText = {
      default = EntityId()
    },
    RefinedOrDerivedText = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    }
  },
  PADDING_WIDTH = 30,
  BOTTOM_MARGIN = 19
}
BaseElement:CreateNewElement(DynamicTooltip_Flavor)
function DynamicTooltip_Flavor:OnInit()
  self.LogSettings = {"Tooltips"}
  BaseElement.OnInit(self)
end
function DynamicTooltip_Flavor:SetItem(itemTable, equipSlot, compareTo)
  UiElementBus.Event.SetIsEnabled(self.Properties.RefinedOrDerivedText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Icon, false)
  SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
  self.TOTAL_HEIGHT = 0
  local containerPositionY = 7
  self.ScriptedEntityTweener:Set(self.Properties.Container, {y = containerPositionY})
  if itemTable and type(itemTable.description) == "string" and 0 < string.len(itemTable.description) then
    local flavorText = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(itemTable.description)
    if type(itemTable.displayName) == "string" and 0 < string.len(itemTable.displayName) then
      if self.Properties.Hint:IsValid() and string.find(itemTable.displayName, "FishingPole") then
        UiElementBus.Event.SetIsEnabled(self.Properties.HintText, true)
        self.Hint:SetActionMap("player")
        self.Hint:SetKeybindMapping("fishing_activate")
        UiTextBus.Event.SetTextWithFlags(self.Properties.HintText, "@ui_start_fishing_instruction", eUiTextSet_SetLocalized)
        self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + 43
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.HintText, false)
      end
    end
    if itemTable.descriptionHorizontalAlignment then
      UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.Text, itemTable.descriptionHorizontalAlignment)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.Text, flavorText, eUiTextSet_SetLocalized)
    local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.Text)
    self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + textHeight
  else
    UiTextBus.Event.SetText(self.Properties.Text, "")
  end
  local categories = itemTable.id and ItemDataManagerBus.Broadcast.GetIngredientCategories(itemTable.id)
  local numCategories = categories and #categories or 0
  UiElementBus.Event.SetIsEnabled(self.Properties.IngredientTypesText, 0 < numCategories)
  if 0 < numCategories then
    self.ScriptedEntityTweener:Set(self.Properties.IngredientTypesText, {
      y = self.TOTAL_HEIGHT
    })
    local ingredientsUsed = {}
    local ingredientTypesHeader = LyShineScriptBindRequestBus.Broadcast.LocalizeText(1 < numCategories and "@ui_tooltip_ingredient_types" or "@ui_tooltip_ingredient_type")
    local ingredientTypesText = ""
    for i = 1, numCategories do
      local category = categories[i]
      local categoryData = CraftingCategoryDataManagerBus.Broadcast.GetCategoryDataById(category)
      if not ingredientsUsed[categoryData.displayText] then
        ingredientsUsed[categoryData.displayText] = true
        if 1 < i then
          ingredientTypesText = ingredientTypesText .. ", "
        end
        ingredientTypesText = ingredientTypesText .. LyShineScriptBindRequestBus.Broadcast.LocalizeText(categoryData.displayText)
      end
    end
    local ingredientTypesString = "<font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_TOOLTIP_GRAY_STATS) .. " face=\"lyshineui/fonts/nimbus_medium.font\">" .. ingredientTypesHeader .. "</font> <font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_WHITE) .. " face=\"lyshineui/fonts/nimbus_medium.font\">" .. ingredientTypesText .. "</font>"
    UiTextBus.Event.SetText(self.Properties.IngredientTypesText, ingredientTypesString)
    local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.IngredientTypesText)
    self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + textHeight
  end
  if itemTable and itemTable.tooltipLayout and type(itemTable.tooltipLayout.RefinedAtText) == "string" and 0 < string.len(itemTable.tooltipLayout.RefinedAtText) then
    UiElementBus.Event.SetIsEnabled(self.Properties.RefinedOrDerivedText, true)
    self.ScriptedEntityTweener:Set(self.Properties.RefinedOrDerivedText, {
      y = self.TOTAL_HEIGHT
    })
    local refinedAtHeader = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_tooltip_refinedat")
    local refinedAtText = LyShineScriptBindRequestBus.Broadcast.LocalizeText(itemTable.tooltipLayout.RefinedAtText)
    local refinedAtString = "<font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_TOOLTIP_GRAY_STATS) .. " face=\"lyshineui/fonts/nimbus_medium.font\">" .. refinedAtHeader .. "</font> <font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_WHITE) .. " face=\"lyshineui/fonts/nimbus_medium.font\">" .. refinedAtText .. "</font>"
    UiTextBus.Event.SetText(self.Properties.RefinedOrDerivedText, refinedAtString)
    local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.RefinedOrDerivedText)
    self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + textHeight
    local isVisible = itemTable.tooltipLayout.RefinedAtIcon ~= nil and 0 < string.len(itemTable.tooltipLayout.RefinedAtIcon)
    if isVisible then
      UiElementBus.Event.SetIsEnabled(self.Properties.Icon, true)
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, itemTable.tooltipLayout.RefinedAtIcon)
      self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + 60
    end
  end
  if itemTable and itemTable.tooltipLayout and type(itemTable.tooltipLayout.DerivedFromText) == "string" and 0 < string.len(itemTable.tooltipLayout.DerivedFromText) then
    UiElementBus.Event.SetIsEnabled(self.Properties.RefinedOrDerivedText, true)
    self.ScriptedEntityTweener:Set(self.Properties.RefinedOrDerivedText, {
      y = self.TOTAL_HEIGHT
    })
    local derivedFromHeader = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_tooltip_derivedfrom")
    local derivedFromText = LyShineScriptBindRequestBus.Broadcast.LocalizeText(itemTable.tooltipLayout.DerivedFromText)
    local derivedFromString = "<font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_TOOLTIP_GRAY_STATS) .. " face=\"lyshineui/fonts/nimbus_medium.font\">" .. derivedFromHeader .. "</font> <font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_WHITE) .. " face=\"lyshineui/fonts/nimbus_medium.font\">" .. derivedFromText .. "</font>"
    UiTextBus.Event.SetText(self.Properties.RefinedOrDerivedText, derivedFromString)
    local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.RefinedOrDerivedText)
    self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + textHeight
    local isVisible = itemTable.tooltipLayout.DerivedFromIcon ~= nil and 0 < string.len(itemTable.tooltipLayout.DerivedFromIcon)
    if isVisible then
      UiElementBus.Event.SetIsEnabled(self.Properties.Icon, true)
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, itemTable.tooltipLayout.DerivedFromIcon)
      self.TOTAL_HEIGHT = self.TOTAL_HEIGHT + 60
    end
  end
  if self.TOTAL_HEIGHT == 0 then
    return 0
  end
  return self.TOTAL_HEIGHT + self.BOTTOM_MARGIN
end
function DynamicTooltip_Flavor:GetWidth()
  return UiTextBus.Event.GetTextWidth(self.Properties.Text) + self.PADDING_WIDTH
end
function DynamicTooltip_Flavor:SetDividerEnabled(enabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.Divider, enabled)
end
return DynamicTooltip_Flavor
