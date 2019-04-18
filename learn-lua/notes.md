# Lua 学习笔记

## 基本语法

### 注释

1. 单行注释 以`--` 开头,相关于 C 系的 `//`
2. 多行注释:以`--[[` 开头,相对于 C 系的 `/*`,以 `--]]` 结尾,相当于 C 系的 `*/`

### 标识符

1. 保留的关键字

```lua
and break do  else  elseif
end false for function  if
in  local nil not or
repeat  return  then  true  until while
```

2. 其他符号.

```lua
+     -     *     /     %     ^     #
==    ~=    <=    >=    <     >     =
(     )     {     }     [     ]
;     :     ,     .     ..    ...
```

3. 不允许使用 `@`,`$`,`%` 来定义标识符.

4. 例如 `_VERSION` 以下划线开头后面的全大写变量,一般用作 Lua 内部的全局变量.

## 数据类型

1. `number` 数字类型 双精度浮点值.
2. `boolean` 布尔类型,`true` 和 `false` ,lua 中除了 `false` 和 `nil` 为假值,其他全为真.
3. `nil` 表示没有任何有效值,将全局变量和表中的变量赋值为 `nil`的话,就相当于删除的效果.

### 字符串

1. 用单引号包装.
2. 用双引号包装.
3. 跨行字符串使用 `[[` 开头 `]]` 作为结尾包装.
4. 简单的字符串连接使用,可以连接操作符,`..` ,复杂的建议使用 `table.concat` 效率更高.
5. 转义字符同 C 系字符串如 `\t` 表示一个 `TAB`,`\"` 表示双引号转义.

## table (表)

table 是 Lua 最核心的数据结构了,模块,类,对象,包等都是通过 table 来实现的.
简单的表实例.

```lua
local tb = {
  name = "banxi",
  age = "18",
  "Coding is Cool",
  "Lua is Fun"
}
```

以上,演示了表的两种填充方式:

1. 同时指定 `key`,`value`.
2. 另一种,只指定 `value` 让 table 自动指定自动增长的数字索引. 值得注意的是数字索引是从 `1` 开始的. 也可以以 `[10] = "banxi"` 这样的方式,直接指定数据索引 .

### 模块

模块的定义基本是如下的格式.

1. 创建一个模块文件.如 `myluamodule.lua`
2. 创建一个 table 对象作为命名空间 ,如 按 OpenResty 的命名惯例来说是 `local _M = {}`
3. 给`_M` 命名空间添加我们需要导出的函数方法,常量等.
4. 在模块的结尾导出我们模块的命名空间 `return _M`

5. 加载模块使用 `require "<模块名>"` 或者 `require(<"模块名">)` `require` 函数的返回值便是我们模块的返回值.也就是 `_M` 表.

6. 如果使用 `local m = require("myluamodule")` 相当于给导入的模块指定了 `m` 的名称,否则名称是 `myluamodule`

7. 可以通过加载一个不存在的模块测试模块的加载顺序,如下:

```
learn-lua/test_lua_custom_module.lua:4: module 'myluamodule2' not found:
        no field package.preload['myluamodule2']
        no file './myluamodule2.lua'
        no file '/usr/local/share/luajit-2.1.0-beta3/myluamodule2.lua'
        no file '/usr/local/share/lua/5.1/myluamodule2.lua'
        no file '/usr/local/share/lua/5.1/myluamodule2/init.lua'
        no file './myluamodule2.so'
        no file '/usr/local/lib/lua/5.1/myluamodule2.so'
        no file '/usr/local/lib/lua/5.1/loadall.so'
```

8. 通过 `export LUA_PATH="~/lua/?.lua;;"` 设置环境变量增加 `lua` 的加载路径.后面的两个分号 表示将原来的新加的路径+原来的路径.

### 元表 (Metatable)

> 元表之于表,就好比元类之于类. -by 代码会说话

1. `setmetable(tbl,metatbl)` 函数设置元表.
2. `getmetatable(tbl)` 返回元表.

## 常用内置函数

1. `print(...)` 使用 `tostring` 将各参数转换为字符串.
2. `pairs(t)` 返回 3 个值 `next` 函数,表 `t`,和 `nil` 用于遍历表.

```lua
for k,v in pairs(t) do
end
```

如果要在遍历时修改表,请参考 `next` 函数.

3. `pcall(f,arg1,...)` 以安全模式调用函数`f`,参数为 `arg1,...` 等. 执行无错返回 `false`, 有错返回 `false,err`

4. `rawget(table,index)` 取值时忽略元方法.
5. `rawset(table,index,value)` 赋值时忽略元方法.
6. `tonumber(e[,base])` 字符串转数字,base 范围在 `[2,36]` 如果 `base=10` `A或a` 表示 `10` 跟 16 进制一样.
