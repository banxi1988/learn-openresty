local test = require "u-test"

test.test_arithmetic_operators = function()
  -- 测试算术运算符
  test.equal(1 + 2, 3)
  test.equal(5 / 10, 0.5)
  test.equal(2 ^ 10, 1024) -- 相当于 Python 中的 2**10,不过在  ^ 是异或运算符
  local num = 1357
  test.equal((num % 2), 1)
  test.is_true((num % 2) == 1)
  test.is_false((num % 5) == 0)
end

test.test_relational_operators = function()
  -- 测试关系运算表达式
  test.assert(1 < 2)
  test.is_false(1 == 2)
  test.is_true(1 ~= 2) -- ~= 相当于 != 不等于
  local t1 = {x = 1, y = 0}
  local t2 = {x = 1, y = 0}
  test.not_equal(t1, t2) -- 表类型是作为引用类型比较的。
  test.is_false(t1 == t2)
end

test.test_logical_operators = function()
end
