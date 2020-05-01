-- stackoverflow post about PPU memory write
-- https://stackoverflow.com/questions/41954718/how-to-get-ppu-memory-from-fceux-in-lua
-- @SpiderDave answer

function memory.readbyteppu(a)
  memory.writebyte(0x2001,0x00) -- Turn off rendering
  memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
  memory.writebyte(0x2006,math.floor(a/0x100)) -- PPUADDR high byte
  memory.writebyte(0x2006,a % 0x100) -- PPUADDR low byte
  if a < 0x3f00 then 
      dummy=memory.readbyte(0x2007) -- PPUDATA (discard contents of internal buffer if not reading palette area)
  end
  ret=memory.readbyte(0x2007) -- PPUDATA
  memory.writebyte(0x2001,0x1e) -- Turn on rendering
  return ret
end

function memory.readbytesppu(a,l)
  memory.writebyte(0x2001,0x00) -- Turn off rendering
  local ret
  local i
  ret=""
  for i=0,l-1 do
      memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
      memory.writebyte(0x2006,math.floor((a+i)/0x100)) -- PPUADDR high byte
      memory.writebyte(0x2006,(a+i) % 0x100) -- PPUADDR low byte
      if (a+i) < 0x3f00 then 
          dummy=memory.readbyte(0x2007) -- PPUDATA (discard contents of internal buffer if not reading palette area)
      end
      ret=ret..string.char(memory.readbyte(0x2007)) -- PPUDATA
  end
  memory.writebyte(0x2001,0x1e) -- Turn on rendering
  return ret
end

function memory.writebyteppu(a,v)
  memory.writebyte(0x2001,0x00) -- Turn off rendering
  memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
  memory.writebyte(0x2006,math.floor(a/0x100)) -- PPUADDR high byte
  memory.writebyte(0x2006,a % 0x100) -- PPUADDR low byte
  memory.writebyte(0x2007,v) -- PPUDATA
  memory.writebyte(0x2001,0x1e) -- Turn on rendering
end

function memory.writebytesppu(a,str)
  memory.writebyte(0x2001,0x00) -- Turn off rendering

  local i
  for i = 0, #str-1 do
      memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
      memory.writebyte(0x2006,math.floor((a+i)/0x100)) -- PPUADDR high byte
      memory.writebyte(0x2006,(a+i) % 0x100) -- PPUADDR low byte
      memory.writebyte(0x2007,string.byte(str,i+1)) -- PPUDATA
  end

  memory.writebyte(0x2001,0x1e) -- Turn on rendering
end

-- Super Mario variables tables
-- must be updated
local memoryMap = {
  {addr = 0x0000, str = "Gravity acceleration",   values = {}},
  {addr = 0x0001, str = "Player's animation",     values = {}},
  {addr = 0x0002, str = "Player Y",               values = {}},
  {addr = 0x0003, str = "Player's direction",     values = {1, 2}},
  {addr = 0x0004, str = "How much to load",       values = {}},
  {addr = 0x0008, str = "Object Offset",          values = {}},
  {addr = 0x000A, str = "Button state",           values = {0x00, 0x40, 0x80, 0xC0}},
  {addr = 0x000B, str = "Vertical Direction",     values = {0x00, 0x40, 0x80, 0xC0}},
  {addr = 0x000E, str = "Player's state",         values = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x0A, 0x0B, 0x0C}},
  {addr = 0x000F, str = "Enemy draw 1",           values = {0, 1}},
  {addr = 0x0010, str = "Enemy draw 2",           values = {0, 1}},
  {addr = 0x0011, str = "Enemy draw 3",           values = {0, 1}},
  {addr = 0x0012, str = "Enemy draw 4",           values = {0, 1}},
  {addr = 0x0013, str = "Enemy draw 5",           values = {0, 1}},
  {addr = 0x0014, str = "Powerup draw",           values = {0, 1}},
  {addr = 0x0016, str = "Enemy type 1",           values = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C}},
  {addr = 0x0017, str = "Enemy type 2",           values = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C}},
  {addr = 0x0018, str = "Enemy type 3",           values = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C}},
  {addr = 0x0019, str = "Enemy type 4",           values = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C}},
  {addr = 0x001A, str = "Enemy type 5",           values = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C}},
  {addr = 0x001B, str = "Powerup screen",         values = {0x00, 0x2E}},
  {addr = 0x001D, str = "Player float state",     values = {0x00, 0x01, 0x02, 0x03}},
  {addr = 0x001E, str = "Enemy state 1",          values = {0x00, 0x01, 0x04, 0x20, 0x22, 0x23, 0xC4, 0x84, 0xFF}},
  {addr = 0x001E, str = "Enemy state 2",          values = {0x00, 0x01, 0x04, 0x20, 0x22, 0x23, 0xC4, 0x84, 0xFF}},
  {addr = 0x001E, str = "Enemy state 3",          values = {0x00, 0x01, 0x04, 0x20, 0x22, 0x23, 0xC4, 0x84, 0xFF}},
  {addr = 0x001E, str = "Enemy state 4",          values = {0x00, 0x01, 0x04, 0x20, 0x22, 0x23, 0xC4, 0x84, 0xFF}},
  {addr = 0x001E, str = "Enemy state 5",          values = {0x00, 0x01, 0x04, 0x20, 0x22, 0x23, 0xC4, 0x84, 0xFF}},
  {addr = 0x0023, str = "Powerup state",          values = {0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0xC0, 0xC2, 0x80, 0x82}},
  {addr = 0x0024, str = "Fireball draw 1",        values = {}},
  {addr = 0x0025, str = "Fireball draw 2",        values = {}},
  {addr = 0x002A, str = "Hammer 1",               values = {}},
  {addr = 0x002B, str = "Hammer 2",               values = {}},
  {addr = 0x002C, str = "Hammer 3",               values = {}},
  {addr = 0x002D, str = "Hammer 4",               values = {}},
  {addr = 0x002E, str = "Hammer 5",               values = {}},
  {addr = 0x002F, str = "Hammer 6",               values = {}},
  {addr = 0x0030, str = "Hammer 7",               values = {}},
  {addr = 0x0031, str = "Hammer 8",               values = {}},
  {addr = 0x0032, str = "Hammer 9",               values = {}},
  {addr = 0x0033, str = "Player facing dir",      values = {0, 1, 2}},
  {addr = 0x0039, str = "Powerup type",           values = {0, 1, 2, 3}},
  {addr = 0x0045, str = "Player moving dir",      values = {1, 2}},
  {addr = 0x0046, str = "Enemy heading 1",        values = {1, 2}},
  {addr = 0x0047, str = "Enemy heading 2",        values = {1, 2}},
  {addr = 0x0048, str = "Enemy heading 3",        values = {1, 2}},
  {addr = 0x0049, str = "Enemy heading 4",        values = {1, 2}},
  {addr = 0x004A, str = "Enemy heading 5",        values = {1, 2}},
  {addr = 0x004B, str = "Shroom heading",         values = {1, 2}},
  {addr = 0x0057, str = "Player H speed",         values = {}},
  {addr = 0x0058, str = "Enemy H speed 1",        values = {}},
  {addr = 0x0059, str = "Enemy H speed 2",        values = {}},
  {addr = 0x005A, str = "Enemy H speed 3",        values = {}},
  {addr = 0x005B, str = "Enemy H speed 4",        values = {}},
  {addr = 0x005C, str = "Enemy H speed 5",        values = {}},
  {addr = 0x006D, str = "Player H pos lvl",       values = {}},
  {addr = 0x006E, str = "Enemy H pos 1 lvl",      values = {}},
  {addr = 0x006F, str = "Enemy H pos 2 lvl",      values = {}},
  {addr = 0x0070, str = "Enemy H pos 3 lvl",      values = {}},
  {addr = 0x0071, str = "Enemy H pos 4 lvl",      values = {}},
  {addr = 0x0072, str = "Enemy H pos 5 lvl",      values = {}},
  {addr = 0x0086, str = "player X pos screen",    values = {}},
  {addr = 0x0087, str = "Enemy X pos 1 screen",   values = {}},
  {addr = 0x0088, str = "Enemy X pos 2 screen",   values = {}},
  {addr = 0x0089, str = "Enemy X pos 3 screen",   values = {}},
  {addr = 0x008A, str = "Enemy X pos 4 screen",   values = {}},
  {addr = 0x008B, str = "Enemy X pos 5 screen",   values = {}},
  {addr = 0x008C, str = "Powerup X pos screen",   values = {}},
  {addr = 0x008D, str = "Fireball X pos screen",  values = {}},
  {addr = 0x00D5, str = "Fireball Y pos screen",  values = {}},
  {addr = 0x008F, str = "Brick Smash 1y",         values = {}},
  {addr = 0x0090, str = "Brick Smash 1y",         values = {}},
  {addr = 0x0091, str = "Brick Smash 1y",         values = {}},
  {addr = 0x009F, str = "Player Vertcial veloc",  values = {}},
  {addr = 0x00A0, str = "Enemy 1 Vertcial veloc", values = {}},
  {addr = 0x00A1, str = "Enemy 2 Vertcial veloc", values = {}},
  {addr = 0x00A2, str = "Enemy 3 Vertcial veloc", values = {}},
  {addr = 0x00A3, str = "Enemy 4 Vertcial veloc", values = {}},
  {addr = 0x00A4, str = "Enemy 5 Vertcial veloc", values = {}},
  {addr = 0x00CE, str = "Player Y pos screen",    values = {}},
  {addr = 0x00CF, str = "Enemy Y pos 1 screen",   values = {}},
  {addr = 0x00D0, str = "Enemy Y pos 2 screen",   values = {}},
  {addr = 0x00D1, str = "Enemy Y pos 3 screen",   values = {}},
  {addr = 0x00D2, str = "Enemy Y pos 4 screen",   values = {}},
  {addr = 0x00D3, str = "Enemy Y pos 5 screen",   values = {}},
  {addr = 0x00D4, str = "Powerup Y pos screen",   values = {}},
  {addr = 0x00A6, str = "Fireball Y Speed",       values = {}},
  {addr = 0x00A7, str = "Fireball 2 Y Speed",     values = {}},
  {addr = 0x00D6, str = "Vertical 1 vert speed",  values = {}},
  {addr = 0x00D7, str = "Fireball 2 vert Speed",  values = {}},
  {addr = 0x00E7, str = "Level layout address",   values = {}},
  {addr = 0x00E9, str = "Enemy layout address",   values = {}},
  {addr = 0x00FB, str = "Area Music Register",    values = {}},
  {addr = 0x00FC, str = "Event Music Register",   values = {}},
  {addr = 0x00FD, str = "Sound Effect Register 1",values = {}},
  {addr = 0x00FE, str = "Sound Effect Register 2",values = {}},
  {addr = 0x00FF, str = "Sound Effect Register 3",values = {}},
  {addr = 0x03AD, str = "Player x pos offset",    values = {}},
  {addr = 0x03AE, str = "Enemy 1 x pos offset",   values = {}},
  {addr = 0x03AF, str = "Enemy 2 x pos offset",   values = {}},
  {addr = 0x03B0, str = "Enemy 3 x pos offset",   values = {}},
  {addr = 0x03B1, str = "Enemy 4 x pos offset",   values = {}},
  {addr = 0x03B2, str = "Enemy 5 x pos offset",   values = {}},
  {addr = 0x03B3, str = "Powerup x pos offset",   values = {}},
  {addr = 0x03B8, str = "Player y pos offset",    values = {}},
  {addr = 0x03B9, str = "Enemy 1 y pos offset",   values = {}},
  {addr = 0x03BA, str = "Enemy 2 y pos offset",   values = {}},
  {addr = 0x03BB, str = "Enemy 3 y pos offset",   values = {}},
  {addr = 0x03BC, str = "Enemy 4 y pos offset",   values = {}},
  {addr = 0x03BD, str = "Enemy 5 y pos offset",   values = {}},
  {addr = 0x03BE, str = "Powerup y pos offset",   values = {}},
  {addr = 0x03AF, str = "Fireball Relative Xpos", values = {}},
  {addr = 0x03BA, str = "Fireball Relative Ypos", values = {}},
  {addr = 0x03C4, str = "Player palette",         values = {}},
  {addr = 0x0400, str = "Player Object Xmove",    values = {}},
  {addr = 0x0416, str = "Player Object YMF",      values = {}},
  {addr = 0x0433, str = "Player vertical velo",   values = {}},
  {addr = 0x043A, str = "Fireball stuff 1",       values = {}},
  {addr = 0x043B, str = "Fireball stuff 2",       values = {}},
  {addr = 0x0450, str = "Player velo left",       values = {}},
  {addr = 0x0456, str = "Player velo right",      values = {}},
  -- tiles
  {addr = 0x06CE, str = "Fireball counter",       values = {}},
  {addr = 0x06D6, str = "Warpzone control",       values = {}},
  {addr = 0x0702, str = "walk animation",         values = {}},
  {addr = 0x0704, str = "Swimming flag",          values = {0, 1}},
  {addr = 0x0709, str = "Current gravity",        values = {}},
  {addr = 0x070A, str = "Current fall gravity",   values = {}},
  {addr = 0x070B, str = "Big small animation",    values = {}},
  {addr = 0x070C, str = "player walk anim delay", values = {}},
  {addr = 0x070D, str = "Player walk anim frame", values = {}},
  {addr = 0x0733, str = "Replace tree and mushr", values = {0, 1, 2, 3, 4}},
  {addr = 0x0739, str = "Current enemy layout",   values = {}},
  {addr = 0x0743, str = "Tiles to cloud",         values = {}},
  {addr = 0x0744, str = "Background palette",     values = {}},
  {addr = 0x0754, str = "Player's state",         values = {0, 1, 2, 5}},
  {addr = 0x0756, str = "Powerup state",          values = {}},
  {addr = 0x075A, str = "Lives",                  values = {}},
  {addr = 0x075E, str = "Coins",                  values = {}},
  {addr = 0x075F, str = "World",                  values = {0, 1, 2, 3, 4, 5, 6, 7}},
  {addr = 0x0760, str = "Level",                  values = {0, 1, 2, 3}},
  {addr = 0x0773, str = "Level palette",          values = {0, 1, 2, 3, 4}},
  {addr = 0x0781, str = "Player animation Timer", values = {}},
  {addr = 0x0782, str = "JumpSwim Timer",         values = {}},
  {addr = 0x0783, str = "Running Timer",          values = {}},
  {addr = 0x0784, str = "BlockBounce Timer",      values = {}},
  {addr = 0x0785, str = "SideCollision Timer",    values = {}},
  {addr = 0x0786, str = "Jumpspring Timer",       values = {}},
  {addr = 0x0789, str = "ClimbSide Timer",        values = {}},
  {addr = 0x078A, str = "EnemyFrame Timer",       values = {}},
  {addr = 0x078F, str = "Player animation Timer", values = {}},
  {addr = 0x0790, str = "BowserFireBreath Timer", values = {}},
  {addr = 0x0791, str = "Stomp Timer",            values = {}},
  {addr = 0x0792, str = "Airbubble Timer",        values = {}},
  {addr = 0x0795, str = "Falling down Timer",     values = {}},
  {addr = 0x079E, str = "Invincible Timer",       values = {}},
  {addr = 0x079F, str = "Start Timer",            values = {}},
}

emu.speedmode("normal") -- Set the speed of the emulator

local rand = 0
local count = 0
local newValue = 0
local sizeOfMap = #memoryMap

while true do -- main loop

  -- Every 4 seconds (if run in 60 fps), do randomize
  if (count == 240) then

    -- only randomize if player is currently playing (not dying, not in pause or in menu)
    local gameplay_status = memory.readbyte(0x0772) -- 3 = playing
    local in_pause = memory.readbyte(0x07C6) -- 1 = pause
    local mario_is_dying = memory.readbyte(0x000E) -- 0x0B = dying

    -- if playing we cant randomize
    if ((gameplay_status == 3) and (in_pause ~= 1) and (mario_is_dying ~= 0x0B)) then

      ppu_addr = math.random(0, 0x3F20)
      rand_mem = math.random(0, sizeOfMap)
      mem_addr = memoryMap[rand_mem].addr

      ppu_val = memory.readbyteppu(ppu_addr)
      mem_val = memory.readbyte(mem_addr)
      choice = math.random(1,3)

      if (choice == 1) then -- add 1
        ppu_val = ppu_val + 1
        mem_val = mem_val + 1
      elseif (choice == 2) then -- sub 1
        ppu_val = ppu_val - 1
        mem_val = mem_val -1
      else -- random value
        length = #memoryMap[rand_mem].values
        ppu_val = math.random(0,255)
        if (length == 0) then 
          mem_val = ppu_val
        else
          c = math.random(1, length)
          mem_val = memoryMap[rand_mem].values[c]
        end
      end
      memory.writebyteppu(ppu_addr, ppu_val)
      memory.writebyte(mem_addr, mem_val)
    end
    count = 0
  end
  emu.frameadvance() -- keep running
  count = count + 1
end

