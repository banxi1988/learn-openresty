local test = require "u-test"

function setfield(f, v)
  local t = _G -- 从全局变量表开始
  -- split by .
  for var, dot in string.gmatch(f, "([%w_]+)(.?)") do
    if dot == "." then
      t[var] = t[var] or {} -- create table if absent
      t = t[var]
    else
      -- last field
      t[var] = v
    end
  end
end

function getfield(f)
  local v = _G
  for var in string.gmatch(f, "([%w_]+)") do
    v = v[var]
    if v == nil then
      return nil
    end
  end
  return v
end

test.test_global_G = function()
  test.assert(_G == _G._G)
  for name in pairs(_G) do
    print(name)
  end
  test.assert(getfield("f") == nil)
  test.assert(getfield("f.a") == nil)
  setfield("f.a.b.c", 10)
  test.assert(getfield("f.a.b.c") == 10)
end

test.test_global_declaring_global_var = function()
  setmetatable(
    _G,
    {
      __newindex = function(_, n)
        error("attempt to write to undeclared variable " .. n, 2)
      end,
      __index = function(_, n)
        error("attempt to read undeclared variable " .. n, 2)
      end
    }
  )
  test.error_raised(
    function()
      print(a)
    end,
    "read"
  )
  test.error_raised(
    function()
      b = 3
    end,
    "write"
  )
  setmetatable(_G, nil)
end

test.test_global_declare_new_var = function()
  local declaredNames = {}
  function let(name, intval)
    rawset(_G, name, intval or false)
  end
  let "a"
  test.is_not_nil(rawget(_G, "a"))
  setmetatable(
    _G,
    {
      __newindex = function(t, n, v)
        if not declaredNames[n] then
          error("attempt to write to undeclared variable " .. n, 2)
        else
          rawset(t, n, v) -- do the actual set
        end
      end,
      __index = function(_, n)
        if not declaredNames[n] then
          error("attempt to read undeclared variable " .. n, 2)
        else
          return rawget(_G, n)
        end
      end
    }
  )
  let("b", 10)
  test.assert(b == 10)

  setmetatable(_G, nil) -- rollback
end
--[[
Sets the environment to be used by the given function. 
  f can be a Lua function or 
  a number that specifies the function at that stack level: 
    Level 1 is the function calling setfenv. 
    setfenv returns the given function.

As a special case, when f is 0 setfenv changes the environment of the running thread. 
In this case, setfenv returns no values.
--]]
test.test_setfenv = function()
  function test_env1()
    a = 1 -- create global variable
    test.assert(a == 1)
    setfenv(1, {})
    test.is_nil(a)
    test.is_nil(_G)
  end
  test_env1()

  function test_env2()
    a = 1
    setfenv(1, {_G = _G})
    test.is_nil(a)
    test.assert(_G.a == 1)
  end
  test_env2()

  function test_env3()
    a = 1
    local newgt = {} -- create new env
    setmetatable(newgt, {__index = _G})
    setfenv(1, newgt)
    test.assert(a == 1)
  end
  test_env3()
end
