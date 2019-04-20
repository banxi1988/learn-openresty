local test = require "u-test"

test.test_loop_table = function()
  local sentinel_hps = {
    {host = "127.0.0.1", port = 26380},
    {host = "127.0.0.1", port = 26381},
    {host = "127.0.0.1", port = 26382},
    other = {}
  }
  local i = 1
  -- ipairs ignore non array index
  for k, hp in ipairs(sentinel_hps) do
    test.assert(k == i)
    i = i + 1
  end
  local kvset = {
    false,
    false,
    false,
    other = false
  }
  -- pairs will not ignore array index
  for k, hp in pairs(sentinel_hps) do
    kvset[k] = true
  end
  test.assert(kvset[1])
  test.assert(kvset[2])
  test.assert(kvset[3])
  test.assert(kvset["other"])
end

test.test_concat = function()
  t1 = {"a", "b", "c"}
  t1_str = table.concat(t1, ",")
  test.assert(t1_str == "a,b,c")
end

test.test_meta_table = function()
  local tbl = {name = "banxi"}
  test.assert(getmetatable(tbl) == nil)
  local metatbl = {
    __index = function(tb, key)
      return "HelloMetatable"
    end,
    __newindex = function(tb, key, value)
      print("__newindex called: tb=", tb, ",key=", key, ",value=", value)
    end
  }
  setmetatable(tbl, metatbl)
  test.assert(getmetatable(tbl) == metatbl)
  tbl.name = "codetalks"
  tbl.sex = "男"
  test.assert(tbl.name == "codetalks")
  test.assert(tbl["name"] == "codetalks")
  test.assert(tbl.age == "HelloMetatable")
  test.assert(tbl.sex == "HelloMetatable")

  local metatbl2 = {}
  local tbl2 = {name = "codetalks"}
  setmetatable(tbl2, {__newindex = metatbl2})
  test.assert(tbl2.name == "codetalks")
  tbl2.sex = "男"
  test.assert(tbl2.sex == nil)
  test.assert(metatbl2.sex == "男")
end

Set = {}
Set.mt = {} -- metatable for sets
Set.mt.__metatable = "readonly_metatable"
function Set.new(t)
  local set = {}
  setmetatable(set, Set.mt)
  for _, v in ipairs(t) do
    set[v] = true
  end
  return set
end

function Set.union(a, b)
  local res = Set.new {}
  for k in pairs(a) do
    res[k] = true
  end
  for k in pairs(b) do
    res[k] = true
  end
  return res
end

function Set.intersection(a, b)
  local res = Set.new {}
  for k in pairs(a) do
    res[k] = b[k]
  end
  return res
end

Set.mt.__add = Set.union
Set.mt.__mul = Set.intersection

Set.mt.__le = function(a, b) -- set containment
  for k in pairs(a) do
    if not b[k] then
      return false
    end
  end
  return true
end

Set.mt.__lt = function(a, b)
  return a <= b and not (b <= a)
end

Set.mt.__eq = function(a, b)
  return a <= b and b <= a
end

function Set.tostring(set)
  values = {}
  for e in pairs(set) do
    table.insert(values, e)
  end
  values_str = table.concat(values, ",")
  return "{" .. values_str .. "}"
end

Set.mt.__tostring = Set.tostring

test.test_meta_table_impl_set = function()
  local s1 = Set.new {1, 2, 3, 1, 2}
  local s2 = Set.new {3, 4, 5, 4}
  print(s1)
  print(s2)
  test.assert(Set.tostring(s1) == "{1,2,3}")
  test.assert(Set.tostring(s2) == "{3,4,5}")
  test.assert(getmetatable(s1) == getmetatable(s2))
  test.assert(getmetatable(s1) == "readonly_metatable")
  -- setmetatable(s1, {}) cannot change a protected metatable

  s1add2 = s1 + s2
  test.assert(Set.tostring(s1add2) == "{1,2,3,4,5}")
  s1mul2 = s1 * s2
  test.assert(Set.tostring(s1mul2) == "{3}")
  print(s1mul2)
  print({})
end

Window = {}
-- 创建原型填充默认值
Window.prototype = {x = 0, y = 0, width = 100, height = 100}
Window.mt = {} -- 创建元表
function Window.new(opt)
  setmetatable(opt, Window.mt)
  return opt
end

Window.mt.__index = function(tbl, key)
  return Window.prototype[key]
end

function setDefault(t, d)
  local mt = {
    __index = function()
      return d
    end
  }
  setmetatable(t, mt)
end

local defaults_mt = {
  __index = function(t)
    return t.___
  end
}

function setDefaultv2(t, d)
  t.___ = d
  setmetatable(t, defaults_mt)
end

local defaults_key = {} -- empty table as unique key
local defaults_mt2 = {
  __index = function(t)
    return t[defaults_key]
  end
}

function setDefaultv3(t, d)
  t[defaults_key] = d
  setmetatable(t, defaults_mt2)
end

test.test_meta_table__index = function()
  w = Window.new {x = 10, y = 20}
  print(w.width)
  print(w.height)
  test.assert(w.width == 100)
  test.assert(w.height == 100)
  test.is_nil(rawget(w, "width"))
  test.is_nil(rawget(w, "height"))

  tab = {x = 10, y = 20}
  test.assert(tab.x == 10)
  test.assert(tab.z == nil)
  setDefault(tab, 0)
  test.assert(tab.z == 0)

  tab2 = {x = 10, y = 20}
  test.assert(tab2.x == 10)
  test.assert(tab2.z == nil)
  setDefaultv2(tab2, 0)
  test.assert(tab2.z == 0)

  tab3 = {x = 10, y = 20}
  test.assert(tab3.x == 10)
  test.assert(tab3.z == nil)
  setDefaultv3(tab3, 0)
  test.assert(tab3.z == 0)
end

test.test_meta_table__newindex = function()
  t = {} -- original table
  local _t = t -- keep a private access to original table
  t = {} -- create proxy
  -- create metaable
  local mt = {
    __index = function(t, k)
      print("*access to element " .. tostring(k))
      return _t[k] -- access the original table
    end,
    __newindex = function(t, k, v)
      print("*update of element " .. tostring(k) .. " to " .. tostring(v))
    end
  }
  setmetatable(t, mt)

  t[2] = "hello"
  print(t[2])
end

test.test_meta_table_track = function()
  local index = {}
  local mt = {
    __index = function(t, k)
      print("*access t is " .. tostring(t))
      print("*access to element " .. tostring(k))
      return t[index][k]
    end,
    __newindex = function(t, k, v)
      print("*update of element " .. tostring(k) .. " to " .. tostring(v))
      t[index][k] = v
    end
  }

  function track(t)
    local proxy = {}
    proxy[index] = t
    print("proxy is " .. tostring(proxy))
    setmetatable(proxy, mt)
    return proxy
  end

  local tbl = {name = "banxi", memo = "codetalks"}
  local orig_tbl = tbl
  tbl = track(tbl)
  test.assert(orig_tbl ~= tbl)
  tbl.age = 18
  print(tbl.age)
  test.is_nil(tbl.sex)
end

test.test_meta_table_impl_read_only_decor = function()
  function readOnly(t)
    local proxy = {}
    local mt = {
      __index = t,
      __newindex = function(t, k, v)
        error("attempt to update a readOnly table", 2)
      end
    }
    setmetatable(proxy, mt)
    return proxy
  end

  weekdays = readOnly {"Sun", "Mon", "Tue", "Wed", "Thur", "Fri", "Sat"}
  test.assert(weekdays[1] == "Sun")
  test.error_raised(
    function()
      weekdays[1] = "Mon"
    end,
    "attempt to update a readOnly table"
  )
end

Account1 = {balance = 100}
function Account1.withdraw(v)
  Account1.balance = Account1.balance - v
end
function Account1.withdraw2(self, v)
  self.balance = self.balance - v
end
-- Class:method(args) 是 Class.method(self,args) 的语法糖
function Account1:withdraw3(v)
  self.balance = self.balance - v
end

test.test_oop_obj = function()
  test.assert(Account1.balance == 100)
  Account1.withdraw(10)
  test.assert(Account1.balance == 90)
  a2 = Account1
  Account1 = nil
  print(a2)
  test.is_not_nil(a2)
  a2.withdraw2(a2, 10)
  test.assert(a2.balance == 80)
  -- obj:method(other_args) 调用法是 obj.method(obj,other_args) 的语法糖
  a2:withdraw2(10)
  test.assert(a2.balance == 70)
  a2.withdraw3(a2, 10)
  test.assert(a2.balance == 60)
  a2:withdraw3(10)
  test.assert(a2.balance == 50)
end
