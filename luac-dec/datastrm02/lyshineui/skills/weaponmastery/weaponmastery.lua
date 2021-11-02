local WeaponMastery = {
  Properties = {
    OneHandedWeapons = {
      default = EntityId()
    },
    OneHandedWeaponsTitleBg = {
      default = EntityId()
    },
    OneHandedWeaponsTitle = {
      default = EntityId()
    },
    TwoHandedWeapons = {
      default = EntityId()
    },
    TwoHandedWeaponsTitleBg = {
      default = EntityId()
    },
    TwoHandedWeaponsTitle = {
      default = EntityId()
    },
    RangedWeapons = {
      default = EntityId()
    },
    RangedWeaponsTitleBg = {
      default = EntityId()
    },
    RangedWeaponsTitle = {
      default = EntityId()
    },
    MagicSkills = {
      default = EntityId()
    },
    MagicTitleBg = {
      default = EntityId()
    },
    MagicTitle = {
      default = EntityId()
    },
    MasteryTreeWindow = {
      default = EntityId()
    }
  },
  WeaponRowSlicePath = "LyShineUI\\Skills\\WeaponMastery\\WeaponMasteryRow",
  WeaponRowEntities = {},
  OneHandedWeaponsData = {},
  TwoHandedWeaponsData = {},
  RangedWeaponsData = {},
  MagicSkillsData = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WeaponMastery)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(WeaponMastery)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local WeaponMasteryData = RequireScript("LyShineUI.Skills.WeaponMastery.WeaponMasteryData")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function WeaponMastery:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiSpawnerNotificationBus, self.OneHandedWeapons)
  for i = 1, #WeaponMasteryData.data.OneHandedWeaponsData do
    local data = WeaponMasteryData.data.OneHandedWeaponsData[i]
    data.tableName = "OneHandedWeaponsData"
    data.tableIndex = i
    self:SpawnSlice(self.OneHandedWeapons, self.WeaponRowSlicePath, self.OnWeaponRowStatSpawned, data)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.TwoHandedWeapons)
  for i = 1, #WeaponMasteryData.data.TwoHandedWeaponsData do
    local data = WeaponMasteryData.data.TwoHandedWeaponsData[i]
    data.tableName = "TwoHandedWeaponsData"
    data.tableIndex = i
    self:SpawnSlice(self.TwoHandedWeapons, self.WeaponRowSlicePath, self.OnWeaponRowStatSpawned, data)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.RangedWeapons)
  for i = 1, #WeaponMasteryData.data.RangedWeaponsData do
    local data = WeaponMasteryData.data.RangedWeaponsData[i]
    data.tableName = "RangedWeaponsData"
    data.tableIndex = i
    self:SpawnSlice(self.RangedWeapons, self.WeaponRowSlicePath, self.OnWeaponRowStatSpawned, data)
  end
  self:BusConnect(UiSpawnerNotificationBus, self.MagicSkills)
  for i = 1, #WeaponMasteryData.data.MagicSkillsData do
    local data = WeaponMasteryData.data.MagicSkillsData[i]
    data.tableName = "MagicSkillsData"
    data.tableIndex = i
    self:SpawnSlice(self.MagicSkills, self.WeaponRowSlicePath, self.OnWeaponRowStatSpawned, data)
  end
  self.MasteryTreeWindow:SetBackClick(self, self.WeaponMasteryBackClick)
end
function WeaponMastery:SetScreenVisible(isVisible)
  for i, entity in pairs(self.WeaponRowEntities) do
    if isVisible then
      entity:Update()
    end
    entity:SetIsVisible(isVisible, entity.tableIndex * 0.05)
  end
  local titleBgs = {
    self.Properties.OneHandedWeaponsTitleBg,
    self.Properties.TwoHandedWeaponsTitleBg,
    self.Properties.RangedWeaponsTitleBg,
    self.Properties.MagicTitleBg
  }
  for i, titleBg in pairs(titleBgs) do
    self.ScriptedEntityTweener:PlayFromC(titleBg, 0.3, {opacity = 0, imgFill = 0}, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(titleBg, 0.6, tweenerCommon.imgFillTo1)
  end
end
function WeaponMastery:TransitionIn()
  self:SetScreenVisible(true)
  self.MasteryTreeWindow:SetVisible(false)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Skills.ScreenChecked", true)
end
function WeaponMastery:TransitionOut()
  self:SetScreenVisible(false)
  self.MasteryTreeWindow:SetVisible(false)
end
function WeaponMastery:OnShutdown()
  for i, entity in pairs(self.WeaponRowEntities) do
    UiElementBus.Event.DestroyElement(entity.entityId)
    self.WeaponRowEntities[i] = nil
  end
end
function WeaponMastery:OnWeaponRowStatSpawned(entity, data)
  if FtueSystemRequestBus.Broadcast.IsFtue() and data.tableNameId ~= 3907802902 then
    UiInteractableBus.Event.SetIsHandlingEvents(entity.entityId, false)
  end
  entity:SetAbilityTableId(data.tableNameId)
  entity:SetText(data.text)
  entity:SetTooltip(data.tooltip)
  entity:SetIcon(data.icon)
  entity:SetTableInfo(data.tableName, data.tableIndex)
  entity:SetCallback(self, self.WeaponMasteryRowClicked)
  table.insert(self.WeaponRowEntities, entity)
end
function WeaponMastery:WeaponMasteryRowClicked(tableName, tableIndex)
  local tableData = WeaponMasteryData.data[tableName]
  if tableData and tableData[tableIndex] then
    masteryData = tableData[tableIndex]
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    self.MasteryTreeWindow:SetVisible(true, masteryData)
    self:SetScreenVisible(false)
  end
end
function WeaponMastery:WeaponMasteryBackClick()
  self:SetScreenVisible(true)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.MasteryTreeWindow:SetVisible(false)
end
return WeaponMastery
