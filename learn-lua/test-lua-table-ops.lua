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
