-- Bezerker's Pauldron

local item = Item("Bezerker\'s Pauldron")
item.pickupText = "Enter a frenzy after killing 3 enemies in quick succession."
item.sprite = Sprite.load("Items/resources/pauldron.png", 1, 12, 13)
item:setTier("uncommon")

-- Buff
local frenzy = Buff.new("War Cry")
frenzy.sprite = Sprite.load("Items/resources/frenzyBuff.png", 1, 8, 8)
local sound = Sound.load("frenzySound", "Items/resources/frenzyProc.ogg")

local frenzyFX = ParticleType.new("frenzyParticles")
frenzyFX:shape("Square")
frenzyFX:color(Color.RED)
frenzyFX:alpha(1,0)
frenzyFX:additive(true)
frenzyFX:size(0.01, 0.01, 0, 0)
frenzyFX:life(5, 15)
frenzyFX:speed(0.3, 0.5, 0, 0)
frenzyFX:direction(0, 360, 0, 1)

frenzy:addCallback("start", function(player)
  player:set("pHmax", player:get("pHmax") + 0.5)
  player:set("attack_speed", player:get("attack_speed") + 1)
end)
frenzy:addCallback("step", function(player)
  frenzyFX:burst("middle", player.x, player.y, 15)
end)
frenzy:addCallback("end", function(player)
  player:set("pHmax", player:get("pHmax") - 0.5)
  player:set("attack_speed", player:get("attack_speed") - 1)
end)

-- Timer
callback.register("onActorInit", function(actor)
  if isa(actor, "PlayerInstance") then
    actor:set("killstreak", 0)
    actor:set("pauldron_timer", 60)
  end
end)

callback.register("onNPCDeathProc", function(npc, player)
  if player:isValid() then
    player:set("killstreak", player:get("killstreak") + 1)
  end
end)

callback.register("onPlayerStep", function(player)
  local stack = player:countItem(item)
  if player:get("killstreak") > 0 then
    if player:get("killstreak") >= 3 and stack > 0 then
      if not sound:isPlaying() then
        sound:play(0.9 + math.random() * 0.4, 0.8)
      end
      player:applyBuff(frenzy, 6 * 60 + ((4 * 60) * (stack - 1)))
    end
    if player:get("pauldron_timer") <= 0 then
      player:set("killstreak", 0)
      player:set("pauldron_timer", 60)
    else
      player:set("pauldron_timer", player:get("pauldron_timer") - 1)
    end
  end
end)

-- Item Log
item:setLog{
  group = "uncommon",
	description = "&y&Killing 3 enemies&!& within &y&1&!& second sends you into a &y&frenzy&!& for &y&6s&!&&lt&(+4s per stack)&!&. Increases &b&movement speed&!& by &b&50%&!& and &y&attack speed&!& by &y&100%&!&.",
	story = "Another antique for the collection. This bad boy was found on the battlefield where much of the War was fought. The excavation site was littered with bones, all surrounding the remains of one rebel soldier, who was carrying this artifact. According to hearsay and rumors, rebel soldiers wearing pauldrons much like this one would enter trances on the battlefield. Time would slow down, and all they could see was the enemy.\n\nOf course, it\'s just speculation, but… There were a lot of bodies surrounding this thing’s old owner. Be careful, OK?",
	destination = "Jungle VII,\nMuseum of 2019,\nEarth",
	date = "04/05/2056",
	priority = "&g&Priority&!&"
}
