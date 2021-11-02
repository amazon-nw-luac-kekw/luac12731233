local MasteryTree = {
  Properties = {
    Bg = {
      default = EntityId()
    },
    DividerLines = {
      default = {
        EntityId()
      }
    },
    Rows = {
      default = {
        EntityId()
      }
    },
    TreeId = {default = 0}
  },
  abilityData = {},
  ABILITIES_NEEDED_PER_ROW = 1,
  ABILITIES_NEEDED_FOR_FINAL_ROW = 10,
  MAX_NODES_PER_ROW = 4
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MasteryTree)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function MasteryTree:OnInit()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerEntityId = playerEntityId
      self:SetPlayerEntityId(playerEntityId)
    end
  end)
  self:UpdateBgHeight()
end
function MasteryTree:UpdateBgHeight(skipAnimation)
  local highestRow = 0
  for i = highestRow, #self.abilityData do
    highestRow = i
    if self.Rows[i]:GetNumOwnedNodes(true) < self.ABILITIES_NEEDED_PER_ROW then
      break
    end
  end
  local bgHeight = UiTransformBus.Event.GetLocalPositionY(self.Properties.Rows[highestRow])
  if 0 < self.Rows[highestRow]:GetNumOwnedNodes(true) then
    if highestRow == #self.abilityData then
      bgHeight = bgHeight + UiTransform2dBus.Event.GetLocalHeight(self.Properties.Rows[highestRow])
      bgColor = self.UIStyle.COLOR_YELLOW_GOLD
    else
      bgHeight = bgHeight + UiTransform2dBus.Event.GetLocalHeight(self.Properties.Rows[highestRow]) / self.ABILITIES_NEEDED_PER_ROW
    end
  end
  local animTime = skipAnimation and 0 or 0.3
  self.ScriptedEntityTweener:Play(self.Properties.Bg, animTime, {h = bgHeight, ease = "QuadOut"})
end
function MasteryTree:GetAbilityDataFromId(pointId)
  for _, data in pairs(self.abilityData) do
    if data.id == pointId then
      return data
    end
  end
  return nil
end
function MasteryTree:SetPlayerEntityId(entityId)
  for i = 0, #self.Rows do
    self.Rows[i]:SetPlayerEntityId(entityId)
  end
end
function MasteryTree:SetTableId(tableid)
  for i = 0, #self.Rows do
    self.Rows[i]:Reset()
  end
  self.tableid = tableid
  self.abilityData = {}
  local slottableAbilities = {}
  local slottableAbilityData = CharacterAbilityRequestBus.Event.GetAvailableAbilityDataByAbilityTableId(self.playerEntityId, tableid)
  for i = 1, #slottableAbilityData do
    if slottableAbilityData[i] then
      slottableAbilities[tostring(slottableAbilityData[i].id)] = true
    end
  end
  local progressionData = ProgressionPointRequestBus.Event.GetAllProgressionPointDataFromPoolId(self.playerEntityId, tableid)
  local availablePoints = ProgressionPointRequestBus.Event.GetUnallocatedPoolPoints(self.playerEntityId, tableid)
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  if rootEntityId then
    for i = 1, #progressionData do
      local ability = CharacterAbilityRequestBus.Event.GetAbilityData(rootEntityId, tableid, progressionData[i].id)
      if ability.treeId == self.TreeId then
        if not self.abilityData[ability.treeRowPos] then
          self.abilityData[ability.treeRowPos] = {}
        end
        local nodeData = {
          id = ability.id,
          poolid = tableid,
          displayName = ability.displayName,
          displayDescription = ability.displayDescription,
          sound = ability.sound,
          cooldownTimer = ability.cooldownTimer,
          displayIcon = ability.displayIcon,
          uiCategory = ability.uiCategory,
          treeId = ability.treeId,
          treeRowPos = ability.treeRowPos,
          treeColPos = ability.treeColPos,
          isLastRow = ability.treeRowPos >= #self.Rows,
          requiredPointId = progressionData[i].requiredPointId,
          isSlottable = slottableAbilities[tostring(ability.id)] or false
        }
        if nodeData.requiredPointId == 0 then
          table.insert(self.abilityData[ability.treeRowPos], 1, nodeData)
        else
          table.insert(self.abilityData[ability.treeRowPos], nodeData)
        end
        if #self.abilityData[ability.treeRowPos] > self.MAX_NODES_PER_ROW then
          Debug.Log("Error: Too many nodes added to row: " .. ability.treeRowPos .. ". Tree (" .. self.TreeId .. ") will not be displayed correctly")
        end
      end
    end
    local canPurchaseInRow = true
    local totalPurchased = 0
    for i = 0, #self.abilityData do
      self.Rows[i]:SetRowNodes(i, self.abilityData[i])
      for _, abilityData in pairs(self.abilityData[i]) do
        if abilityData.requiredPointId ~= 0 then
          local node = self:FindNodeById(abilityData.id)
          if node then
            node:SetParentNode(self:FindNodeById(abilityData.requiredPointId))
          end
        end
      end
      if i < #self.abilityData then
        totalPurchased = totalPurchased + self.Rows[i]:RefreshStatus(availablePoints, nil, canPurchaseInRow)
        canPurchaseInRow = self.Rows[i]:GetCanPurchaseInNextRow()
      else
        self.Rows[i]:RefreshStatus(availablePoints, nil, canPurchaseInRow and totalPurchased >= self.ABILITIES_NEEDED_FOR_FINAL_ROW)
      end
    end
  end
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Bg, 0)
  self:UpdateBgHeight(true)
  for i = 0, #self.Properties.DividerLines do
    self.ScriptedEntityTweener:PlayFromC(self.Properties.DividerLines[i], 0.5, {scaleX = 0}, tweenerCommon.scaleXTo1, i * 0.15)
  end
end
function MasteryTree:GetAbilityData()
  return self.abilityData
end
function MasteryTree:RefreshStatus(unspentPoints, selectedAbilityIds)
  local canPurchaseInRow = true
  local totalPurchased = 0
  for i = 0, #self.Rows - 1 do
    totalPurchased = totalPurchased + self.Rows[i]:RefreshStatus(unspentPoints, selectedAbilityIds, canPurchaseInRow)
    canPurchaseInRow = self.Rows[i]:GetCanPurchaseInNextRow()
  end
  self.Rows[#self.Rows]:RefreshStatus(unspentPoints, selectedAbilityIds, canPurchaseInRow and totalPurchased >= self.ABILITIES_NEEDED_FOR_FINAL_ROW)
  self:UpdateBgHeight()
end
function MasteryTree:EnableTree(enable, tableId)
  if self.progHandler then
    self:BusDisconnect(self.progHandler)
    self.progHandler = nil
  end
  if enable then
    self:SetTableId(tableId)
    self.progHandler = self:BusConnect(ProgressionPointsNotificationBus, self.playerEntityId)
  end
end
function MasteryTree:FindNodeById(id)
  for i = 0, #self.Rows do
    for _, node in pairs(self.Rows[i].Nodes) do
      if node.data and node.data.id == id then
        return node
      end
    end
  end
  return nil
end
function MasteryTree:SetNodeClickCallback(command, table)
  for i = 0, #self.Rows do
    for _, node in pairs(self.Rows[i].Nodes) do
      node:SetClickCallback(command, table)
    end
  end
end
return MasteryTree
