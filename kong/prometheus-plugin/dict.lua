local SharedDict = {}
local function set(data, key, value)
  data[key] = {
    value = value,
    info = {expired = false}
  }
end
function SharedDict:new()
  return setmetatable({data = {}}, {__index = self})
end
function SharedDict:get(key)
  return self.data[key] and self.data[key].value, nil
end
function SharedDict:set(key, value)
  set(self.data, key, value)
  return true, nil, false
end
SharedDict.safe_set = SharedDict.set
function SharedDict:add(key, value, exptime)
  if self.data[key] ~= nil then
    return false, "exists", false
  end

  if exptime then
    ngx.timer.at(exptime, function()
      self.data[key] = nil
    end)
  end

  set(self.data, key, value)
  return true, nil, false
end
SharedDict.safe_add = SharedDict.add
function SharedDict:replace(key, value)
  if self.data[key] == nil then
    return false, "not found", false
  end
  set(self.data, key, value)
  return true, nil, false
end
function SharedDict:delete(key)
  if self.data[key] ~= nil then
    self.data[key] = nil
  end
  return true
end
function SharedDict:incr(key, value, init)
  if not self.data[key] then
    if not init then
      return nil, "not found"
    else
      self.data[key] = { value = init }
    end
  elseif type(self.data[key].value) ~= "number" then
    return nil, "not a number"
  end
  self.data[key].value = self.data[key].value + value
  return self.data[key].value, nil
end
function SharedDict:flush_all()
  for _, item in pairs(self.data) do
    item.info.expired = true
  end
end
function SharedDict:flush_expired(n)
  local data = self.data
  local flushed = 0

  for key, item in pairs(self.data) do
    if item.info.expired then
      data[key] = nil
      flushed = flushed + 1
      if n and flushed == n then
        break
      end
    end
  end
  self.data = data
  return flushed
end
function SharedDict:get_keys(n)
  n = n or 1024
  local i = 0
  local keys = {}
  for k in pairs(self.data) do
    keys[#keys+1] = k
    i = i + 1
    if n ~= 0 and i == n then
      break
    end
  end
  return keys
end

return function (name)
  local d = SharedDict:new()
  ngx.shared[name] = d
  return d
end