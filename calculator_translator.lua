-- Rime Script >https://github.com/baopaau/rime-lua-collection/blob/master/calculator_translator.lua
-- 簡易計算器（執行任何Lua表達式）
-- 格式：=<exp>
-- 例子：
-- =1+1 輸出 2
-- =floor(9^(8/7)*cos(deg(6))) 輸出 -3
-- =e^pi>pi^e 輸出 true
-- 需增加 `recognizer/patterns/expression: "^=.*$"`

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
log = math.log
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

e = exp(1)
ln = math.log

date = os.date
time = os.time

-- greedy：隨時求值（每次變化都會求值，否則結尾爲特定字符時求值）
local greedy = true

local function calculator_translator(input, seg)
  if string.sub(input, 1, 1) ~= "=" then return end
  
  local expfin = greedy or string.sub(input, -1, -1) == ";"
  local exp = (greedy or not expfin) and string.sub(input, 2, -1) or string.sub(input, 2, -2)
  
  yield(Candidate("number", seg.start, seg._end, exp, "表達式"))
       
  if not expfin then return end
  
  -- 防止危險操作，禁用os和io命名空間
  if exp:find("i?os?%.") then return end
  -- return語句保證了只有合法的Lua表達式才可執行
  local result = load("return "..exp)()
  if result == nil then return end
  
  if result == true then result = "true" end
  if result == false then result = "false" end
  yield(Candidate("number", seg.start, seg._end, result, "答案"))
  yield(Candidate("number", seg.start, seg._end, exp.." = "..result, "等式"))
end

return calculator_translator
