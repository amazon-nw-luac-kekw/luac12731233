Spawner = {
  Spawner = {
    m_callbacks = {}
  }
}
function Spawner:SpawnSlice(entityId, path, callback, cbdata, returnAllEntities)
  if path == "" or path == nil then
    Debug.Log("No path supplied")
    return nil
  end
  local ticket = UiSpawnerBus.Event.SpawnSlicePath(entityId, path)
  if ticket == nil then
    Debug.Log("Failed to generate ticket, missing spawner component? : " .. path)
  else
    self.Spawner.m_callbacks[ticket] = {
      cb = callback,
      data = cbdata,
      returnAllEntities = returnAllEntities
    }
  end
  return ticket
end
function Spawner:GetEntityTable(entityId)
  local entityTable = self.registrar:GetEntityTable(entityId)
  if entityTable == nil then
    return entityId
  end
  return entityTable
end
function Spawner:OnTopLevelEntitiesSpawned(ticket, entities)
  for ticketKey, cbdata in pairs(self.Spawner.m_callbacks) do
    if ticketKey == ticket then
      local entitiesToReturn
      if cbdata.returnAllEntities then
        entitiesToReturn = {}
        for i = 1, #entities do
          table.insert(entitiesToReturn, self:GetEntityTable(entities[i]))
        end
      else
        entitiesToReturn = self:GetEntityTable(entities[1])
      end
      if cbdata.cb then
        cbdata.cb(self, entitiesToReturn, cbdata.data)
      end
      self.Spawner.m_callbacks[ticketKey] = nil
      return
    end
  end
end
function Spawner:GetNumSpawning()
  return CountAssociativeTable(self.Spawner.m_callbacks)
end
function Spawner:AttachSpawner(attachToTable)
  Merge(attachToTable, Spawner, true)
end
return Spawner
