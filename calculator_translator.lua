-- Rime Script >https://github.com/baopaau/rime-lua-collection/blob/master/calculator_translator.lua
-- 簡易計算器（執行任何Lua表達式）
-- 格式：=<exp>
-- Lambda語法糖：\<arg>-><exp>|
-- 例子：
-- =1+1 輸出 2
-- =floor(9^(8/7)*cos(deg(6))) 輸出 -3
-- =e^pi>pi^e 輸出 true
-- =max({1,7,2}) 輸出 7
-- =map({1,2,3},\x->x^2|) 輸出 {1.0, 4.0, 9.0}
-- 需在方案增加 `recognizer/patterns/expression: "^=.*$"`

-- 定義直呼函數（注意命名空間污染）
abs = math.abs
acos = math.acos
asin = math.asin
atan = math.atan
ceil = math.ceil
cos = math.cos
deg = math.deg
exp = math.exp
floor = math.floor
fmod = math.fmod
huge = math.huge
max = math.max
maxinteger = math.maxinteger
min = math.min
mininteger = math.mininteger
modf = math.modf
pi = math.pi
rad = math.rad
random = math.random
randomseed = math.randomseed
sin = math.sin
sqrt = math.sqrt
tan = math.tan
tointeger = math.tointeger
type = math.type
ult = math.ult

inf = 1/0
e = exp(1)
ln = math.log
log = function (x, base)
  base = base or 10
  return ln(x)/ln(base)
end
min = function (arr)
  local m = inf
  for k, x in ipairs(arr) do
   m = x < m and x or m
  end
  return m
end
max = function (arr)
  local m = -inf
  for k, x in ipairs(arr) do
   m = x > m and x or m
  end
  return m
end


-- iterator -> array
array = function (...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end

-- iterator <- [form, to)
irange = function (from,to)
  if to == nil then
    to = from
    from = 0
  end
  local i = from - 1
  to = to - 1
  return function()
    if i < to then
      i = i + 1
      return i
    end
  end
end

-- array <- [form, to)
range = function (from, to)
  return array(irange(from, to))
end

-- array -> reversed iterator
irev = function (arr)
  local i = #arr + 1
  return function()
    if i > 1 then
      i = i - 1
      return arr[i]
    end
  end
end

-- array -> reversed array
arev = function (arr)
  return array(irev(arr))
end


-- # Functional
map = function (t, f)
  local ta = {}
  for k,v in pairs(t) do ta[k] = f(v) end
  return ta
end

filter = function (t, f)
  local ta = {}
  local i = 1
  for k,v in pairs(t) do
    if f(v) then
	  ta[i] = v
	  i = i + 1
    end
  end
  return ta
end

-- 鏈式調用函數
-- 用例：chain(range(-5,5))(map,\x->x/5|)(map,sin)(map,\x->e^x*10|)(map,floor)() = {4, 4, 5, 6, 8, 10, 12, 14, 17, 20}
chain = function (t)
  local ta = t
  local function cf(f, ...)
    if f ~= nil then
      ta = f(ta, ...)
      return cf
    else
      return ta
    end
  end
  return cf
end


-- # Linear Algebra


-- # Calculus
-- Linear approximation
lapproxd = function (f, delta)
  local delta = delta or 1e-8
  return function (x)
           return (f(x+delta) - f(x)) / delta
         end
end

-- Linear approximation
mlapproxd = function (f, delta)
  local delta = delta or 1e-8
  return function (x)
           return (f(x+delta) - f(x-delta)) / delta / 2
         end
end

-- Trapezoidal rule
trapzo = function (f, a, b, n)
  local dif = b - a
  local sum = 0
  for i = 1, n-1 do
    sum = sum + f(a + dif * (i/n))
  end
  sum = sum * 2 + f(a) + f(b)
  sum = sum * dif / n / 2
  return sum
end

-- Runge-Kutta
rk4 = function (f, timestep)
  local timestep = timestep or 0.01
  return function (start_x, start_y, time)
           local x = start_x
           local y = start_y
           local t = time
           -- loop until i >= t
           for i = 0, t, timestep do
             local k1 = f(x, y)
             local k2 = f(x + (timestep/2), y + (timestep/2)*k1)
             local k3 = f(x + (timestep/2), y + (timestep/2)*k2)
             local k4 = f(x + timestep, y + timestep*k3)
             y = y + (timestep/6)*(k1 + 2*k2 + 2*k3 + k4)
             x = x + timestep
           end
           return y
         end
end



-- # System
date = os.date
time = os.time
path = function ()
  return debug.getinfo(1).source:match("@?(.*/)")
end


local function serialize(obj)
  local str
  -- 應對 type(obj) 返回值非標準
  if type(obj) ~= nil then -- integer/float類型
    str = obj
  elseif obj == true then -- boolean類型
    str = "true"
  elseif obj == false then --
    str = "false"
  elseif pcall(string.len, obj) then -- string類型
    str = obj
  elseif pcall(obj) then -- function類型
    str = "function"
  else -- table類型
    str = "{"
    local i = 1
    for k, v in pairs(obj) do
      if i ~= k then  
        str = str.."["..serialize(k).."]="
      end
      str = str..serialize(v)..", "  
      i = i + 1
    end
    str = str:len() > 3 and str:sub(0,-3) or str
    str = str.."}" 
  end
  return str
end

-- greedy：隨時求值（每次變化都會求值，否則結尾爲特定字符時求值）
local greedy = true

local function calculator_translator(input, seg)
  if string.sub(input, 1, 1) ~= "=" then return end
  
  local expfin = greedy or string.sub(input, -1, -1) == ";"
  local exp = (greedy or not expfin) and string.sub(input, 2, -1) or string.sub(input, 2, -2)
  
  -- 空格輸入可能
  exp = exp:gsub("#", " ")
  
  yield(Candidate("number", seg.start, seg._end, exp, "表達式"))
       
  if not expfin then return end
  
  -- lambda語法糖
  local expe = exp
  do
    local count
    repeat
      expe, count = expe:gsub("\\%s*([%a%d%s,_]-)%s*->(.-)|", " (function (%1) return %2 end) ")
    until count == 0
  end
  yield(Candidate("number", seg.start, seg._end, expe, "展開"))
  
  -- 防止危險操作，禁用os和io命名空間
  if expe:find("i?os?%.") then return end
  -- return語句保證了只有合法的Lua表達式才可執行
  local result = load("return "..expe)()
  if result == nil then return end
  
  result = serialize(result)
  yield(Candidate("number", seg.start, seg._end, result, "答案"))
  yield(Candidate("number", seg.start, seg._end, exp.." = "..result, "等式"))
end

return calculator_translator
