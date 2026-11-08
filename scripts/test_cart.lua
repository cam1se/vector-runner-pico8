-- Minimal host-side behavior checks for vector_runner_pico8.p8.
-- This test shim is independent code; it intentionally mirrors only the
-- standard PICO-8 APIs the cartridge uses.

local cart = assert(arg[1], "usage: lua scripts/test_cart.lua <cart.p8>")
local file = assert(io.open(cart, "r"))
local source = file:read("*a")
file:close()

local code = assert(source:match("__lua__\n(.*)"), "missing __lua__ section")
code = code:match("(.-)\n__[%a_]+__") or code
-- PICO-8 accepts += and -=; host Lua does not.
code = code:gsub("([%a_][%w_%.]*)%s*([%+%-])=", function(name, op)
 return name .. "=" .. name .. op
end)

local buttons, pressed, draw_calls, sound_calls = {}, {}, 0, 0
local function reset_input()
 buttons, pressed = {}, {}
end

local env = {
 abs = math.abs, flr = math.floor, max = math.max, min = math.min,
 mid = function(a, b, c) return math.max(a, math.min(b, c)) end,
 srand = math.randomseed,
 add = function(t, v) t[#t + 1] = v return v end,
 del = function(t, v)
  for i = #t, 1, -1 do if t[i] == v then table.remove(t, i) return end end
 end,
 all = function(t)
  local i = 0
  return function() i = i + 1 return t[i] end
 end,
 btn = function(n) return buttons[n] or false end,
 btnp = function(n) local v = pressed[n] or false pressed[n] = false return v end,
 cls = function() draw_calls = draw_calls + 1 end,
 pset = function() draw_calls = draw_calls + 1 end,
 line = function() draw_calls = draw_calls + 1 end,
 circfill = function() draw_calls = draw_calls + 1 end,
 rectfill = function() draw_calls = draw_calls + 1 end,
 rect = function() draw_calls = draw_calls + 1 end,
 print = function() draw_calls = draw_calls + 1 end,
 sfx = function() sound_calls = sound_calls + 1 end,
}
setmetatable(env, { __index = _G })
assert(load(code, "@" .. cart, "t", env))()

local passed = 0
local function check(condition, name)
 assert(condition, "FAIL: " .. name)
 passed = passed + 1
 io.write("ok - " .. name .. "\n")
end
local function start()
 reset_input()
 env._init()
 pressed[4] = true
 env._update60()
 check(env.state == 1, "start transitions from title to running")
end

start()
check(#env.objs > 0 and env.speed > 0, "run initializes active obstacles")
env.score = 1000
pressed[5] = true
env._update60()
check(env.state == 3 and env.score == 1000, "X pauses without changing score")
pressed[5] = true
env._update60()
check(env.state == 1, "X resumes a paused run")
buttons[0] = true
for _ = 1, 200 do env._update60() end
buttons[0] = false
check(env.px >= -.78 and env.px <= .78, "left steering remains world-bounded")
buttons[1] = true
for _ = 1, 400 do env._update60() end
buttons[1] = false
check(env.px >= -.78 and env.px <= .78, "right steering remains world-bounded")

-- Pickup and collision paths are kept deterministic by injecting an object at
-- the player's collision plane.
env.state = 1
env.objs = {{x = env.px, z = 6, k = 5, w = .10}}
local before = env.score
env._update60()
check(env.score > before and #env.objs == 0, "score pickup is collected")

env.state = 1
env.shield = 1
env.objs = {{x = env.px, z = 6, k = 7, w = .10}}
env._update60()
check(env.shield == 2, "shield pickup repairs one shield")

env.state = 1
env.inv = 0
env.objs = {{x = env.px, z = 6, k = 8, w = .10}}
env._update60()
check(env.inv > 0, "invincibility pickup starts a timer")

env.state = 1
env.emp = 0
env.objs = {{x = env.px, z = 6, k = 4, w = .11}}
env._update60()
check(env.emp > 0 and #env.objs == 0, "EMP mine briefly removes depth vision")

env.state = 1
local shield_before = env.shield
env.objs = {{x = env.px, z = 6, k = 1, w = .18}}
env._update60()
check(env.state == 1 and env.shield == shield_before, "invincibility absorbs a barrier")

env.state = 1
env.objs = {{x = env.px, z = 6, k = 1, w = .18}}
env.inv = 0
env.hurt = 0
env.shield = 2
env._update60()
check(env.state == 1 and env.shield == 1, "shield absorbs one barrier")

env.state = 1
env.objs = {{x = env.px, z = 6, k = 1, w = .18}}
env.hurt = 0
env.shield = 0
env._update60()
check(env.state == 2, "unshielded barrier ends run")

env.state = 1
env.hurt = 0
env.shield = 1
env.objs = {{x = env.px, z = 6, k = 2, w = .20}}
env._update60()
check(env.state == 2 and env.shield == 0, "final shield loss ends the run")

draw_calls = 0
env._draw()
check(draw_calls > 20, "draw path renders title/game objects")
check(sound_calls > 0, "gameplay events issue sound effects")
io.write(string.format("%d behavioral checks passed\n", passed))
