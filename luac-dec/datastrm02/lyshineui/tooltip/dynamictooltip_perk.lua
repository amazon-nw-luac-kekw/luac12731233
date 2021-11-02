local DynamicTooltip_Perk = {
  Properties = {
    GemSlotIcon = {
      default = EntityId()
    },
    PerkIcon = {
      default = EntityId()
    },
    NameText = {
      default = EntityId()
    },
    DescriptionText = {
      default = EntityId()
    },
    OrText = {
      default = EntityId()
    },
    PerkImageCover = {
      default = EntityId()
    },
    PerkImageBg = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    },
    Sheen = {
      default = EntityId()
    }
  },
  PADDING = 5,
  MIN_PERK_HEIGHT = 26,
  attributeIconPath = "LyShineUI/images/icons/misc/icon_attribute_arrow.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DynamicTooltip_Perk)
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
function DynamicTooltip_Perk:OnInit()
  BaseElement.OnInit(self)
end
function DynamicTooltip_Perk:SetAttributes(attributeTable, isBroken, isTooltip, isLastAttribute)
  if not attributeTable then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.GemSlotIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PerkIcon, false)
  if isTooltip then
    SetTextStyle(self.Properties.NameText, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL_BLUE)
    SetTextStyle(self.Properties.DescriptionText, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL_BLUE)
    if isBroken then
      UiTextBus.Event.SetColor(self.Properties.NameText, self.UIStyle.COLOR_RED_MEDIUM)
      UiTextBus.Event.SetColor(self.Properties.DescriptionText, self.UIStyle.COLOR_RED_MEDIUM)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkIcon, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.PerkIcon, self.attributeIconPath)
    self.ScriptedEntityTweener:Set(self.Properties.PerkIcon, {scaleX = 0.8, scaleY = 0.8})
    self.ScriptedEntityTweener:Set(self.Properties.NameText, {x = 35})
    self.ScriptedEntityTweener:Set(self.Properties.DescriptionText, {x = 35})
    local attributeText = GetLocalizedReplacementText("@ui_stat_bonus_tooltip", {
      amount = attributeTable.amount,
      attribute = attributeTable.attribute
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.NameText, "", eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, attributeText, eUiTextSet_SetAsIs)
    local spacing = isLastAttribute and 5 or -4
    local height = UiTextBus.Event.GetTextHeight(self.Properties.DescriptionText) + spacing
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
    return height
  else
    local attributeText = ""
    for _, statData in ipairs(attributeTable) do
      if statData.amount > 0 then
        if attributeText ~= "" then
          attributeText = attributeText .. "\n"
        end
        local locString = isTooltip and "@ui_stat_bonus_tooltip" or "@ui_stat_bonus"
        attributeText = attributeText .. GetLocalizedReplacementText(locString, {
          amount = statData.amount,
          attribute = statData.attribute
        })
      end
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.NameText, attributeText, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, "", eUiTextSet_SetAsIs)
  end
end
function DynamicTooltip_Perk:ClearPerkData()
  UiElementBus.Event.SetIsEnabled(self.Properties.OrText, false)
end
function DynamicTooltip_Perk:SetPerkData(perkData, isWeapon, isBroken, isTooltip, showOrText, perkMultiplier)
  if not perkData then
    return
  end
  if isTooltip then
    SetTextStyle(self.Properties.NameText, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL_BLUE)
    SetTextStyle(self.Properties.DescriptionText, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL_BLUE_DESCRIPTION)
  end
  if isBroken then
    UiTextBus.Event.SetColor(self.Properties.NameText, self.UIStyle.COLOR_RED_MEDIUM)
    UiTextBus.Event.SetColor(self.Properties.DescriptionText, self.UIStyle.COLOR_RED_MEDIUM)
  end
  self.ScriptedEntityTweener:Set(self.Properties.PerkIcon, {scaleX = 1, scaleY = 1})
  local perkIconPath = "lyshineui/images/" .. perkData.iconPath .. ".png"
  UiElementBus.Event.SetIsEnabled(self.Properties.GemSlotIcon, perkData.perkType == ePerkType_Gem)
  if perkData.perkType == ePerkType_Gem then
    if isWeapon then
      UiImageBus.Event.SetSpritePathname(self.Properties.GemSlotIcon, "lyshineui/images/tooltip/frame_gemsocket.png")
    else
      UiImageBus.Event.SetSpritePathname(self.Properties.GemSlotIcon, "lyshineui/images/tooltip/frame_gemsocket.png")
    end
    local hasGem = perkData.id ~= itemCommon.EMPTY_GEM_SLOT_PERK_ID
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkIcon, hasGem)
    if hasGem then
      UiImageBus.Event.SetSpritePathname(self.Properties.PerkIcon, perkIconPath)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkIcon, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.PerkIcon, perkIconPath)
  end
  if isTooltip then
    self.ScriptedEntityTweener:Set(self.Properties.NameText, {x = 35})
    self.ScriptedEntityTweener:Set(self.Properties.DescriptionText, {x = 35})
  else
    UiTextBus.Event.SetShrinkToFit(self.Properties.NameText, eUiTextShrinkToFit_Uniform)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.NameText, perkData.displayName, eUiTextSet_SetLocalized)
  if perkMultiplier == nil then
    perkMultiplier = 1
  end
  local description = GetLocalizedReplacementText(perkData.description, {
    perkMultiplier = tostring(perkMultiplier)
  })
  if isTooltip then
    description = "<font color=" .. ColorRgbaToHexString(not isBroken and self.UIStyle.COLOR_TOOLTIP_BLUE or self.UIStyle.COLOR_RED_MEDIUM) .. ">" .. LyShineScriptBindRequestBus.Broadcast.LocalizeText(perkData.displayName) .. ": </font>" .. description
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.OrText, showOrText)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, description, eUiTextSet_SetAsIs)
  if isTooltip then
    local height = UiTextBus.Event.GetTextHeight(self.Properties.DescriptionText)
    if showOrText then
      self.ScriptedEntityTweener:Set(self.Properties.OrText, {y = height})
      height = height + 25
    end
    height = math.max(self.MIN_PERK_HEIGHT, height)
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
    return height
  end
end
function DynamicTooltip_Perk:ShowPerk(delay, isGemPerk)
  self.ScriptedEntityTweener:Play(self.Properties.PerkImageBg, 0.2, {
    scaleX = 2,
    scaleY = 2,
    opacity = 0
  }, {
    scaleX = 1,
    scaleY = 1,
    opacity = 1,
    delay = delay,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.PerkImageCover, 0.3, {opacity = 1}, {
    opacity = 0,
    delay = delay + 0.1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Bg, 0.3, {opacity = 0, x = 0}, {
    opacity = 1,
    x = 30,
    delay = delay + 0.1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Sheen, 0.1, {
    opacity = 0,
    x = -165,
    w = 0
  }, {
    opacity = 1,
    x = 40,
    w = 200,
    delay = delay + 0.1
  })
  self.ScriptedEntityTweener:Play(self.Properties.Sheen, 0.2, {opacity = 1, x = -40}, {
    opacity = 0,
    x = 300,
    delay = delay + 0.2
  })
  self.ScriptedEntityTweener:Play(self.Properties.Bg, 0, {scaleX = 1}, {
    scaleX = 1,
    delay = delay,
    onComplete = function()
      if isGemPerk then
        self.audioHelper:PlaySound(self.audioHelper.Crafting_GemSlot_Show)
      else
        self.audioHelper:PlaySound(self.audioHelper.Crafting_Perk_Show)
      end
    end
  })
end
function DynamicTooltip_Perk:StopAnimation()
  self.ScriptedEntityTweener:Stop(self.Properties.PerkImageBg)
  self.ScriptedEntityTweener:Stop(self.Properties.PerkImageCover)
  self.ScriptedEntityTweener:Stop(self.Properties.Bg)
  self.ScriptedEntityTweener:Stop(self.Properties.Sheen)
end
return DynamicTooltip_Perk
