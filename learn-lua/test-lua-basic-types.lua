local test = require "u-test"

test.test_lua_type_fun = function()
  test.equal(type("hello"), "string")
  test.equal(type(print), "function")
  test.equal(type(true), "boolean")
  test.equal(type(360.0), "number")
  test.equal(type(360), "number")
  test.equal(type(nil), "nil")
end

test.test_lua_nil = function()
  local num
  test.is_nil(num)
  num = 10
  test.is_not_nil(num)
end

test.test_truthy_value = function()
  -- 注意 在 Lua 中 0 和 空字符串都表示为真值。只有 nil 和 false 表示假值
  if 0 then
    test.assert(true)
  else
    test.assert(false)
  end
  if "" then
    test.assert(true)
  else
    test.assert(false)
  end
  test.is_nil(nil)
  test.is_false(false)
end

test.test_numbers = function()
  local order = 3.99
  local score = 98.01
  test.equal(math.floor(order), 3)
  test.equal(math.ceil(score), 99)
  -- LuaJIT 支持长长整型 64位 test.equal(9223372036854775807LL -1,9223372036854775806LL)
end

test.test_strings = function()
  test.equal("lua", "lua")
  test.equal([[I'm yours]], "I'm yours")
end

test.test_table_basic = function()
  local corp = {
    web = "google.com",
    Web = "banxi1988.com",
    telephone = "185",
    staff = {"banxi", "iyan"},
    1988,
    1989,
    [10] = 2018,
    ["city"] = "Nanning"
  }
  test.equal(corp.web, "google.com")
  test.equal(corp.Web, "banxi1988.com")
  test.equal(corp["telephone"], "185")
  test.equal(corp[2], 1989)
  test.equal(corp[10], 2018)
  test.equal(corp.city, "Nanning")
  test.equal(corp.staff[1], "banxi") -- 列表索引从 1 开始
end
