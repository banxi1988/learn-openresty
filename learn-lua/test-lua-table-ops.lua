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

test.test_meta_table = function()
  local tbl = {name = "banxi"}
  tbl.name = "codetalks"
  local metatbl = {
    __index = function(tb, key)
      return "HelloMetatable"
    end
  }
  print(tbl["name"], tbl.name)
  setmetatable(tbl, metatbl)
  test.assert(tbl.name == "codetalks")
  test.assert(tbl["name"] == "codetalks")
  test.assert(tbl.age == "HelloMetatable")
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
