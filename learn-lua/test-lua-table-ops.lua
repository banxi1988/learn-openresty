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
