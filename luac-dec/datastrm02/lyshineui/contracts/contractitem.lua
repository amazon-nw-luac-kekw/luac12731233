local ContractItem = {
  Properties = {
    Button = {
      default = EntityId()
    },
    IsUsingSortButton = {default = false, order = 0},
    Column1Icon = {
      default = EntityId(),
      order = 1
    },
    Column1 = {
      default = EntityId(),
      order = 2
    },
    Column1Text = {
      default = EntityId(),
      order = 2
    },
    Column2 = {
      default = EntityId(),
      order = 3
    },
    Column2Text = {
      default = EntityId(),
      order = 3
    },
    Column3 = {
      default = EntityId(),
      order = 4
    },
    Column3Text = {
      default = EntityId(),
      order = 4
    },
    Column4 = {
      default = EntityId(),
      order = 5
    },
    Column4Text = {
      default = EntityId(),
      order = 5
    },
    Column5 = {
      default = EntityId(),
      order = 6
    },
    Column5Text = {
      default = EntityId(),
      order = 6
    },
    Column6 = {
      default = EntityId(),
      order = 7
    },
    Column6Text = {
      default = EntityId(),
      order = 7
    },
    Column7 = {
      default = EntityId(),
      order = 8
    },
    Column7Text = {
      default = EntityId(),
      order = 8
    },
    Column8 = {
      default = EntityId(),
      order = 9
    },
    Column8Text = {
      default = EntityId(),
      order = 9
    },
    Column9 = {
      default = EntityId(),
      order = 10
    },
    Column9Text = {
      default = EntityId(),
      order = 10
    },
    Column10 = {
      default = EntityId(),
      order = 11
    },
    Column10Text = {
      default = EntityId(),
      order = 11
    },
    Column11 = {
      default = EntityId(),
      order = 12
    },
    Column11Text = {
      default = EntityId(),
      order = 12
    },
    Tint = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    },
    On = {
      default = EntityId()
    },
    LocalPlayer = {
      default = EntityId()
    },
    PerksContainer = {
      default = EntityId()
    },
    PerkIcon1 = {
      default = EntityId()
    },
    PerkIcon2 = {
      default = EntityId()
    },
    PerkIcon3 = {
      default = EntityId()
    },
    PerkIcon4 = {
      default = EntityId()
    }
  },
  isSelected = false,
  isDisabled = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractItem)
function ContractItem:OnInit()
  BaseElement.OnInit(self)
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  for i = 1, 10 do
    local columnName = string.format("Column%iText", i)
    if not self.Properties[columnName]:IsValid() then
      self.Properties[columnName] = UiElementBus.Event.FindDescendantByName(self.entityId, columnName)
    end
    local lastColumnName = string.format("Column%i", i - 1)
    columnName = "Column" .. tostring(i)
    if not self.Properties[columnName]:IsValid() then
      self.Properties[columnName] = UiElementBus.Event.FindDescendantByName(self.entityId, columnName)
      if not self.Properties[columnName] or not self.Properties[columnName]:IsValid() then
        local lastColumn = self.Properties[lastColumnName]
        local columnParent = UiElementBus.Event.GetParent(lastColumn)
        local clonedEntity = CloneUiElement(canvasId, self.registrar, lastColumn, columnParent, true)
        if type(clonedEntity) == "table" then
          self.Properties[columnName] = clonedEntity.entityId
        else
          self.Properties[columnName] = clonedEntity
        end
      end
      self[columnName] = self.registrar:GetEntityTable(self.Properties[columnName])
    end
  end
  if self.Properties.Button:IsValid() then
    self.Button:SetButtonStyle(self.Button.BUTTON_STYLE_CTA)
  end
end
function ContractItem:OnShutdown()
end
function ContractItem:SetColumnWidths(widths)
  local orderedColumns = {
    self.Properties.Column1,
    self.Properties.Column2,
    self.Properties.Column3,
    self.Properties.Column4,
    self.Properties.Column5,
    self.Properties.Column6,
    self.Properties.Column7,
    self.Properties.Column8,
    self.Properties.Column9,
    self.Properties.Column10,
    self.Properties.Column11
  }
  for i = 1, #orderedColumns do
    local width = widths[i] and widths[i] or 0
    UiLayoutCellBus.Event.SetTargetWidth(orderedColumns[i], width)
    UiElementBus.Event.SetIsEnabled(orderedColumns[i], width ~= 0)
  end
end
function ContractItem:GetColumnString(col)
  return col and col or ""
end
function ContractItem:SetContractItem(paramTable)
  local col1 = self:GetColumnString(paramTable.col1)
  local col2 = self:GetColumnString(paramTable.col2)
  local col3 = self:GetColumnString(paramTable.col3)
  local col4 = self:GetColumnString(paramTable.col4)
  local col5 = self:GetColumnString(paramTable.col5)
  local col6 = self:GetColumnString(paramTable.col6)
  local col7 = self:GetColumnString(paramTable.col7)
  local col8 = self:GetColumnString(paramTable.col8)
  local col9 = self:GetColumnString(paramTable.col9)
  local col10 = self:GetColumnString(paramTable.col10)
  local col11 = self:GetColumnString(paramTable.col11)
  if self.Properties.LocalPlayer then
    UiElementBus.Event.SetIsEnabled(self.Properties.LocalPlayer, paramTable.isLocalPlayerCreator == true)
  end
  if self.Properties.IsUsingSortButton then
    if self.Properties.Column1:IsValid() then
      self.Column1:SetText(col1)
    end
    if self.Properties.Column2:IsValid() then
      self.Column2:SetText(col2)
    end
    if self.Properties.Column3:IsValid() then
      self.Column3:SetText(col3)
    end
    if self.Properties.Column4:IsValid() then
      self.Column4:SetText(col4)
    end
    if self.Properties.Column5:IsValid() then
      self.Column5:SetText(col5)
    end
    if self.Properties.Column6:IsValid() then
      self.Column6:SetText(col6)
    end
    if self.Properties.Column7:IsValid() then
      self.Column7:SetText(col7)
    end
    if self.Properties.Column8:IsValid() then
      self.Column8:SetText(col8)
    end
    if self.Properties.Column9:IsValid() then
      self.Column9:SetText(col9)
    end
    if self.Properties.Column10:IsValid() then
      self.Column10:SetText(col10)
    end
    if self.Properties.Column11:IsValid() then
      self.Column11:SetText(col11)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Column1Icon, paramTable.itemDescriptor ~= nil)
    if paramTable.itemDescriptor then
      self.Column1Icon:SetItemByDescriptor(paramTable.itemDescriptor)
      self.Column1Icon:SetTooltipEnabled(true)
      self.Column1Icon:SetQuantityText(nil)
      self.Column1Icon:SetAllowExternalCompare(paramTable.allowCompare)
      UiElementBus.Event.SetIsEnabled(self.Column1Icon.ItemFrame, not paramTable.disableItemBackgrounds)
      UiElementBus.Event.SetIsEnabled(self.Column1Icon.ItemRarityBg, not paramTable.disableItemBackgrounds)
      UiElementBus.Event.SetIsEnabled(self.Column1Icon.ItemTier, not paramTable.disableItemBackgrounds)
    end
    if self.Properties.PerksContainer:IsValid() then
      local enablePerks = paramTable.perkIcons and #paramTable.perkIcons > 0
      UiElementBus.Event.SetIsEnabled(self.Properties.PerksContainer, enablePerks)
      if enablePerks then
        local numPerks = #paramTable.perkIcons
        for i = 1, 4 do
          local shouldEnable = i <= numPerks
          local perkEntityId = self.Properties["PerkIcon" .. i]
          UiElementBus.Event.SetIsEnabled(perkEntityId, shouldEnable)
          if shouldEnable then
            UiImageBus.Event.SetSpritePathnameIfExists(perkEntityId, paramTable.perkIcons[i])
          end
        end
        self.ScriptedEntityTweener:Set(self.Properties.Column1Icon, {y = 0})
        self.ScriptedEntityTweener:Set(self.Properties.PerksContainer, {
          x = 2 + 12 * (4 - numPerks)
        })
      else
        self.ScriptedEntityTweener:Set(self.Properties.Column1Icon, {y = 12})
      end
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column1Text, col1, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column2Text, col2, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column3Text, col3, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column4Text, col4, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column5Text, col5, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column6Text, col6, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column7Text, col7, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column8Text, col8, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column9Text, col9, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column10Text, col10, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Column11Text, col11, eUiTextSet_SetLocalized)
    self.isDisabled = paramTable.isDisabled == true
    self.ScriptedEntityTweener:Set(self.entityId, {
      opacity = self.isDisabled and 0.75 or 1
    })
  end
  if paramTable.tintColor then
    UiElementBus.Event.SetIsEnabled(self.Properties.Tint, true)
    UiImageBus.Event.SetColor(self.Properties.Tint, paramTable.tintColor)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Tint, false)
  end
end
function ContractItem:SetCallback(callerTable, callerFn)
  self.callerTable = callerTable
  self.callerFn = callerFn
end
function ContractItem:SetSelectedVisualState(isSelected)
  if self.isSelected ~= isSelected then
    self.isSelected = isSelected
    if self.On then
      self.ScriptedEntityTweener:Set(self.Properties.On, {
        opacity = isSelected and 0.9 or 0
      })
    end
  end
end
function ContractItem:OnSelected(entityId)
  if self.Properties.IsUsingSortButton then
    return
  end
  if self.isDisabled then
    return
  end
  if self.callerTable then
    self.callerFn(self.callerTable)
  end
end
function ContractItem:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Tab_Hover)
  if self.Highlight then
    self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  end
  self.ScriptedEntityTweener:Play(self.Properties.Column1Text, 0.2, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  if self.Bg then
    self.ScriptedEntityTweener:Play(self.Properties.Bg, 0.2, {opacity = 0.5}, {opacity = 0.7, ease = "QuadOut"})
  end
end
function ContractItem:OnUnfocus()
  if self.Highlight then
    self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.2, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  end
  self.ScriptedEntityTweener:Play(self.Properties.Column1Text, 0.2, {
    textColor = self.UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
  if self.Bg then
    self.ScriptedEntityTweener:Play(self.Properties.Bg, 0.2, {opacity = 0.7}, {opacity = 0.5, ease = "QuadOut"})
  end
end
function ContractItem:OnPress()
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Tab_Select)
end
return ContractItem
