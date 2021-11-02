local MasteryNode = {
  Properties = {
    Rune = {
      default = EntityId()
    },
    Background = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    IconBg = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    },
    Border = {
      default = EntityId()
    },
    HorizontalLine = {
      default = EntityId()
    },
    VerticalLine = {
      default = EntityId()
    }
  },
  prereqNode = "",
  data = nil,
  iconPathRoot = "lyShineui/images/icons/abilities/",
  width = 0,
  childNode = nil,
  TYPE_PASSIVE = 0,
  TYPE_SLOTTABLE = 1,
  STATE_OWNED = 0,
  STATE_AVAILABLE = 1,
  STATE_SELECTED = 2,
  STATE_UNAVAILABLE = 3,
  UNAVAILABLE_REASON_LOCKED = 0,
  UNAVAILABLE_REASON_NO_POINTS = 1,
  ownedBgColor = ColorRgba(233, 227, 207, 1),
  unownedBgColor = ColorRgba(40, 40, 40, 1),
  glowColor = ColorRgba(162, 201, 221, 1),
  clickCallbackTable = nil,
  clickCallbackFn = nil,
  unfocusCallbackTable = nil,
  unfocusCallbackFn = nil,
  isAbilityUnlocked = false,
  stateAnimTime = 0.15
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MasteryNode)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local AbilitiesCommon = RequireScript("LyShineUI._Common.AbilitiesCommon")
function MasteryNode:OnInit()
  self:CacheAnimations()
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  UiImageBus.Event.SetColor(self.Properties.VerticalLine, self.UIStyle.COLOR_GRAY_60)
  UiImageBus.Event.SetColor(self.Properties.HorizontalLine, self.UIStyle.COLOR_GRAY_60)
  self.defaultVerticalPos = UiTransformBus.Event.GetLocalPosition(self.Properties.VerticalLine)
  self.defaultHorizontalPos = UiTransformBus.Event.GetLocalPosition(self.Properties.HorizontalLine)
  self:InitFlyoutWarningRow()
end
function MasteryNode:InitFlyoutWarningRow()
  if self.flyoutWarningRow then
    return
  end
  local flyoutMenu = RequireScript("LyShineUI.FlyoutMenu.FlyoutMenu")
  self.flyoutWarningRow = {
    type = flyoutMenu.ROW_TYPE_Label,
    backgroundPath = "",
    backgroundColor = self.UIStyle.COLOR_RED_DEEP,
    text = "@ui_abilitynotunlocked",
    textColor = self.UIStyle.COLOR_RED_MEDIUM
  }
  self.flyoutAbilityRow = {
    type = flyoutMenu.ROW_TYPE_Ability
  }
end
function MasteryNode:CacheAnimations()
  if not tweenerCommon.masteryNodeAnimations then
    tweenerCommon.masteryNodeAnimations = {
      onFocus = self.ScriptedEntityTweener:CacheAnimation(0.3, {
        scaleX = 1.075,
        scaleY = 1.075,
        ease = "QuadOut"
      }),
      glowFlash = self.ScriptedEntityTweener:CacheAnimation(0.3, {
        imgColor = self.glowColor,
        scaleX = 1,
        scaleY = 1,
        opacity = 1,
        ease = "QuadOut"
      }),
      borderFlash = self.ScriptedEntityTweener:CacheAnimation(0.3, {
        imgColor = self.UIStyle.COLOR_MASTERY,
        ease = "QuadOut"
      }),
      purchaseBackground1 = self.ScriptedEntityTweener:CacheAnimation(0.3, {
        scaleX = 1.2,
        scaleY = 1.2,
        imgColor = self.ownedBgColor,
        ease = "QuadOut"
      }),
      purchaseRune1 = self.ScriptedEntityTweener:CacheAnimation(0.3, {
        scaleX = 1.2,
        scaleY = 1.2,
        imgColor = self.ownedBgColor,
        ease = "QuadOut"
      }),
      purchaseGlow1 = self.ScriptedEntityTweener:CacheAnimation(0.3, {
        scaleX = 1.15,
        scaleY = 1.15,
        imgColor = self.UIStyle.COLOR_TAN_LIGHT,
        ease = "QuadOut"
      }),
      purchaseGlow2 = self.ScriptedEntityTweener:CacheAnimation(0.3, {
        scaleX = 0.5,
        scaleY = 0.5,
        imgColor = self.glowColor,
        ease = "QuadOut"
      })
    }
  end
end
function MasteryNode:SetAbilityData(data)
  self.data = data
  self.state = nil
  if data.displayIcon ~= "" then
    self.displayIconPath = self.iconPathRoot .. data.displayIcon .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.displayIconPath)
  else
    self.displayIconPath = nil
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, "")
  end
  local bgPath = AbilitiesCommon:GetBackgroundPath(data.uiCategory, not data.isSlottable)
  UiImageBus.Event.SetSpritePathname(self.Properties.IconBg, bgPath)
  self:SetType(data.isSlottable and self.TYPE_SLOTTABLE or self.TYPE_PASSIVE)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.VerticalLine, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.HorizontalLine, false)
  if data.treeRowPos == 5 then
    UiTransformBus.Event.SetScale(self.entityId, Vector2(1.5, 1.5))
    UiTransformBus.Event.SetScale(self.Properties.VerticalLine, Vector2(0.66, 0.66))
  end
  self.stateAnimTime = 0
end
function MasteryNode:Reset()
  self.data = nil
  self.childNode = nil
  self.parentNode = nil
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.VerticalLine, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.HorizontalLine, false)
  UiTransformBus.Event.SetLocalPosition(self.Properties.VerticalLine, self.defaultVerticalPos)
  UiTransformBus.Event.SetLocalPosition(self.Properties.HorizontalLine, self.defaultHorizontalPos)
end
function MasteryNode:SetPlayerEntityId(playerEntityId)
  self.playerEntityId = playerEntityId
end
function MasteryNode:SetParentNode(node)
  self.parentNode = node
  self.parentNodeName = self.parentNode.data.displayName
  local verticalLineOffset = 21
  local horizontalLineOffset = 6
  local parentNodeHeight = UiTransform2dBus.Event.GetLocalHeight(self.parentNode.entityId)
  local nodeRelativeOffset = GetOffsetFrom(self.entityId, self.parentNode.entityId)
  local verticalLineHeight
  if self.parentNode.data.treeRowPos < self.data.treeRowPos then
    verticalLineHeight = nodeRelativeOffset.y - verticalLineOffset
    self.ScriptedEntityTweener:Set(self.Properties.VerticalLine, {
      rotation = 0,
      x = 0,
      y = -verticalLineOffset
    })
    if self.parentNode.data.treeColPos == self.data.treeColPos then
      verticalLineHeight = verticalLineHeight - parentNodeHeight / 2
    else
      verticalLineHeight = verticalLineHeight - parentNodeHeight - horizontalLineOffset
      UiElementBus.Event.SetIsEnabled(self.Properties.HorizontalLine, true)
      local horizontalLineMargin = 4
      local parentNodeWidth = UiTransform2dBus.Event.GetLocalWidth(self.parentNode.entityId)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.HorizontalLine, math.abs(nodeRelativeOffset.x) - parentNodeWidth / 2 - horizontalLineMargin)
      if 0 < nodeRelativeOffset.x then
        UiTransformBus.Event.SetScaleX(self.Properties.HorizontalLine, -1)
        UiTransformBus.Event.SetLocalPositionX(self.Properties.HorizontalLine, -horizontalLineMargin / 2)
      else
        UiTransformBus.Event.SetScaleX(self.Properties.HorizontalLine, 1)
        UiTransformBus.Event.SetLocalPositionX(self.Properties.HorizontalLine, horizontalLineMargin / 2)
      end
    end
  else
    local parentNodeWidth = UiTransform2dBus.Event.GetLocalWidth(self.parentNode.entityId)
    if 0 < nodeRelativeOffset.x then
      verticalLineHeight = nodeRelativeOffset.x + parentNodeWidth / 2 - verticalLineOffset
      self.ScriptedEntityTweener:Set(self.Properties.VerticalLine, {
        rotation = -90,
        x = -verticalLineOffset,
        y = 0
      })
    else
      verticalLineHeight = math.abs(nodeRelativeOffset.x) + parentNodeWidth / 2 - verticalLineOffset
      self.ScriptedEntityTweener:Set(self.Properties.VerticalLine, {
        rotation = 90,
        x = verticalLineOffset,
        y = 0
      })
    end
    UiElementBus.Event.SetRenderPriority(self.entityId, 1)
    UiElementBus.Event.SetRenderPriority(self.parentNode.entityId, 0)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.VerticalLine, true)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.VerticalLine, verticalLineHeight)
end
function MasteryNode:OnFocus()
  if self.state == self.STATE_SELECTED or self.state == self.STATE_AVAILABLE then
    self.ScriptedEntityTweener:PlayC(self.Properties.Background, 0.15, tweenerCommon.masteryNodeAnimations.onFocus)
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local rows = {}
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  self:InitFlyoutWarningRow()
  if self.state == self.STATE_AVAILABLE then
    self.flyoutWarningRow.backgroundColor = self.UIStyle.COLOR_YELLOW_DARKER
    self.flyoutWarningRow.textColor = self.UIStyle.COLOR_YELLOW
    self.flyoutWarningRow.text = "@ui_ability_available"
    table.insert(rows, self.flyoutWarningRow)
  elseif self.state == self.STATE_UNAVAILABLE then
    self.flyoutWarningRow.backgroundColor = self.UIStyle.COLOR_RED_DEEP
    self.flyoutWarningRow.textColor = self.UIStyle.COLOR_RED_MEDIUM
    if self.unavailableReason == self.UNAVAILABLE_REASON_NO_POINTS then
      self.flyoutWarningRow.text = "@ui_ability_unavailable_nopoints"
    elseif not self.data.isLastRow then
      if self.parentNode then
        if self.data.treeRowPos == 0 then
          self.flyoutWarningRow.text = GetLocalizedReplacementText("@ui_ability_unavailable_parent_firstrow", {
            parent = self.parentNodeName
          })
        else
          self.flyoutWarningRow.text = GetLocalizedReplacementText("@ui_ability_unavailable_parent", {
            parent = self.parentNodeName
          })
        end
      else
        self.flyoutWarningRow.text = "@ui_ability_unavailable_noparent"
      end
    elseif self.parentNode then
      self.flyoutWarningRow.text = GetLocalizedReplacementText("@ui_ability_unavailable_parent_lastrow", {
        parent = self.parentNodeName
      })
    else
      self.flyoutWarningRow.text = "@ui_ability_unavailable_noparent_lastrow"
    end
    table.insert(rows, self.flyoutWarningRow)
  elseif self.state == self.STATE_SELECTED then
    self.flyoutWarningRow.backgroundColor = self.UIStyle.COLOR_YELLOW_DARKER
    self.flyoutWarningRow.textColor = self.UIStyle.COLOR_YELLOW
    self.flyoutWarningRow.text = "@ui_ability_selected"
    table.insert(rows, self.flyoutWarningRow)
  end
  self.flyoutAbilityRow.abilityName = self.data.displayName
  self.flyoutAbilityRow.abilityIcon = self.iconPathRoot .. self.data.displayIcon .. ".dds"
  if self.type == self.TYPE_SLOTTABLE then
    local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    local cooldownTime = CharacterAbilityRequestBus.Event.GetTotalCooldownTime(rootEntityId, self.data.id)
    self.flyoutAbilityRow.cooldownTime = string.format("%.1f", cooldownTime)
  else
    self.flyoutAbilityRow.cooldownTime = nil
  end
  self.flyoutAbilityRow.abilityDescription = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(self.data.displayDescription)
  self.flyoutAbilityRow.isAbilityUnlocked = self.isAbilityUnlocked
  table.insert(rows, self.flyoutAbilityRow)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:SetOpenLocation(self.entityId)
  flyoutMenu:EnableFlyoutDelay(true)
  flyoutMenu:SetSourceHoverOnly(true)
  flyoutMenu:SetRowData(rows)
  self.audioHelper:PlaySound(self.audioHelper.WeaponMastery_TreeAbilityHover)
end
function MasteryNode:OnUnfocus()
  if self.state == self.STATE_SELECTED or self.state == self.STATE_AVAILABLE then
    self.ScriptedEntityTweener:PlayC(self.Properties.Background, 0.15, tweenerCommon.scaleTo1)
  end
  if self.unfocusCallbackTable and self.unfocusCallbackFn then
    self.unfocusCallbackFn(self.unfocusCallbackTable, self)
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
end
function MasteryNode:SetUnfocusCallback(command, table)
  self.unfocusCallbackFn = command
  self.unfocusCallbackTable = table
end
function MasteryNode:OnClick()
  if self.clickCallbackTable and self.clickCallbackFn then
    self.clickCallbackFn(self.clickCallbackTable, self, self.data.id, self.state)
  end
  if self.state == self.STATE_AVAILABLE then
    self.audioHelper:PlaySound(self.audioHelper.WeaponMastery_TreeAbilityDeselected)
  elseif self.state == self.STATE_SELECTED then
    if self.data.sound ~= "" then
      self.audioHelper:PlaySound(self.data.sound)
    else
      self.audioHelper:PlaySound(self.audioHelper.WeaponMastery_TreeAbilitySelected)
    end
  end
end
function MasteryNode:SetClickCallback(command, table)
  self.clickCallbackFn = command
  self.clickCallbackTable = table
end
function MasteryNode:RefreshStatus(availablePoints, selectedAbilityIds, canPurchaseInRow)
  if not self.data then
    return
  end
  if FtueSystemRequestBus.Broadcast.IsFtue() and self.data.id ~= 248953190 and self.data.id ~= 655891104 then
    self:SetState(self.STATE_UNAVAILABLE)
    return
  end
  local level = ProgressionPointRequestBus.Event.GetLevel(self.playerEntityId, self.data.id)
  if 0 < level then
    self:SetState(self.STATE_OWNED)
    return self.state
  end
  local prereqNodeSelected = true
  if self.parentNode then
    local parentNodeId = self.parentNode.data.id
    local parentNodeOwned = ProgressionPointRequestBus.Event.GetLevel(self.playerEntityId, parentNodeId) > 0
    local parentNodeSelected = selectedAbilityIds and selectedAbilityIds[tostring(self.parentNode.data.id)] ~= nil
    prereqNodeSelected = parentNodeOwned or parentNodeSelected
  end
  if selectedAbilityIds and selectedAbilityIds[tostring(self.data.id)] then
    if prereqNodeSelected and canPurchaseInRow then
      self:SetState(self.STATE_SELECTED)
      return self.state
    else
      selectedAbilityIds[tostring(self.data.id)] = nil
    end
  end
  if prereqNodeSelected and canPurchaseInRow then
    if 0 < availablePoints then
      self:SetState(self.STATE_AVAILABLE)
    else
      self:SetState(self.STATE_UNAVAILABLE, self.UNAVAILABLE_REASON_NO_POINTS)
    end
    return self.state
  end
  self:SetState(self.STATE_UNAVAILABLE, self.UNAVAILABLE_REASON_LOCKED)
  return self.state
end
function MasteryNode:SetType(type)
  if type == self.type then
    return
  end
  self.type = type
  local baseSize = 56
  local iconSize = 45
  local runeSize = 72
  local glowSize = 96
  local backgroundPath = "lyshineui/images/skills/mastery/masteryNodePassiveBg.dds"
  local runePath = "lyshineui/images/skills/mastery/masteryNodePassiveRune.dds"
  local borderPath = "lyshineui/images/skills/mastery/masteryNodePassiveBorder.dds"
  if type == self.TYPE_SLOTTABLE then
    baseSize = 72
    iconSize = 68
    runeSize = 84
    glowSize = 118
    backgroundPath = "lyshineui/images/skills/mastery/masteryNodeActiveBg.dds"
    runePath = "lyshineui/images/skills/mastery/masteryNodeActiveRune.dds"
    borderPath = "lyshineui/images/skills/mastery/masteryNodeActiveBorder.dds"
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Rune, runePath)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Rune, runeSize)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Rune, runeSize)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Glow, glowSize)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Glow, glowSize)
  UiImageBus.Event.SetSpritePathname(self.Properties.Background, backgroundPath)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Background, baseSize)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Background, baseSize)
  UiImageBus.Event.SetSpritePathname(self.Properties.Border, borderPath)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Border, baseSize)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Border, baseSize)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.IconBg, iconSize)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.IconBg, iconSize)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, iconSize)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, iconSize)
end
function MasteryNode:GetType()
  return self.type
end
function MasteryNode:SetState(state, unavailableReason)
  if state == self.state then
    return
  elseif state == self.STATE_OWNED and self.state == self.STATE_SELECTED then
    return self:PlayPurchaseAnimation()
  end
  self.state = state
  self.unavailableReason = unavailableReason
  local isRuneEnabled = false
  local isBorderEnabled = false
  local isGlowEnabled = false
  local backgroundColor = self.unownedBgColor
  local iconColor = self.UIStyle.COLOR_GRAY_30
  local iconBgOpacity = 0.2
  local lineColor = self.UIStyle.COLOR_GRAY_30
  if state == self.STATE_OWNED then
    isRuneEnabled = true
    backgroundColor = self.ownedBgColor
    iconColor = self.UIStyle.COLOR_WHITE
    lineColor = self.UIStyle.COLOR_TAN_LIGHT
    iconBgOpacity = 0.8
    self.isAbilityUnlocked = true
  elseif state == self.STATE_AVAILABLE then
    isBorderEnabled = true
    lineColor = self.UIStyle.COLOR_TAN_LIGHT
    self.isAbilityUnlocked = false
  elseif state == self.STATE_SELECTED then
    isRuneEnabled = true
    isBorderEnabled = true
    isGlowEnabled = true
    iconColor = self.UIStyle.COLOR_WHITE
    lineColor = self.UIStyle.COLOR_TAN_LIGHT
    iconBgOpacity = 1
    self.isAbilityUnlocked = false
  else
    self.isAbilityUnlocked = false
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.Rune, self.stateAnimTime, isRuneEnabled and tweenerCommon.fadeInQuadOut or tweenerCommon.fadeOutQuadIn)
  self.ScriptedEntityTweener:Play(self.Properties.Background, self.stateAnimTime, {imgColor = backgroundColor, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Icon, self.stateAnimTime, {imgColor = iconColor, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.IconBg, self.stateAnimTime, {opacity = iconBgOpacity, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.VerticalLine, self.stateAnimTime, {imgColor = lineColor, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HorizontalLine, self.stateAnimTime, {imgColor = lineColor, ease = "QuadOut"})
  if isGlowEnabled then
    self.ScriptedEntityTweener:PlayFromC(self.Properties.Glow, 0.3, {
      imgColor = self.UIStyle.COLOR_TAN_LIGHT,
      scaleX = 1.3,
      scaleY = 1.3,
      opacity = 0.5
    }, tweenerCommon.masteryNodeAnimations.glowFlash)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.Glow, 10, {rotation = 0}, tweenerCommon.rotateCWInfinite)
  else
    UiFaderBus.Event.SetFadeValue(self.Properties.Glow, 0)
    self.ScriptedEntityTweener:Stop(self.Properties.Glow)
  end
  if isBorderEnabled and not self.wasBorderEnabled then
    self.ScriptedEntityTweener:Set(self.Properties.Border, {
      imgColor = self.UIStyle.COLOR_WHITE
    })
    self.ScriptedEntityTweener:PlayC(self.Properties.Border, 0.3, tweenerCommon.masteryNodeAnimations.borderFlash)
  end
  UiFaderBus.Event.SetFadeValue(self.Properties.Border, isBorderEnabled and 1 or 0)
  self.wasBorderEnabled = isBorderEnabled
  self.stateAnimTime = 0.15
end
function MasteryNode:PlayPurchaseAnimation()
  self.ScriptedEntityTweener:PlayC(self.Properties.Background, 0.15, tweenerCommon.masteryNodeAnimations.purchaseBackground1, 0.05)
  self.ScriptedEntityTweener:PlayC(self.Properties.Background, 0.3, tweenerCommon.scaleTo1, 0.3)
  self.ScriptedEntityTweener:PlayC(self.Properties.Rune, 0.15, tweenerCommon.masteryNodeAnimations.purchaseRune1)
  self.ScriptedEntityTweener:PlayC(self.Properties.Rune, 0.3, tweenerCommon.scaleTo1, 0.25)
  self.ScriptedEntityTweener:PlayC(self.Properties.Glow, 0.15, tweenerCommon.masteryNodeAnimations.purchaseGlow1, 0.1)
  self.ScriptedEntityTweener:PlayC(self.Properties.Glow, 0.3, tweenerCommon.masteryNodeAnimations.purchaseGlow2, 0.35)
  self.ScriptedEntityTweener:PlayC(self.Properties.Border, 0.15, tweenerCommon.imgToWhite)
  self.ScriptedEntityTweener:PlayC(self.Properties.Border, 0.2, tweenerCommon.fadeOutQuadOut, 0.2)
  self.state = self.STATE_OWNED
  self.wasBorderEnabled = false
end
function MasteryNode:GetState()
  return self.state
end
return MasteryNode
