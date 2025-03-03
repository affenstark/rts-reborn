-- All the text-related things (wow I am so good at organizing code)

-- Damage Font and Numbers
NewDamageFont = graphics.fontFromSprite(Sprite.load("Graphics/font.png", 81, 0, 1), [[ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789/!”#¤%&()=?+-§@£$€{[]}\’*.,_<>^~¨ÜÏËŸ¿¡:;|]], -1, false)
export("NewDamageFont")

local damage = Object.new("FakeDamageNumbers")
local empty = Sprite.load("Graphics/empty.png", 1, 0, 0)

damage:addCallback("create", function(this)
  local data = this:getData()
  this.alpha = 1
  this.sprite = empty
  this.blendColor = Color.LIGHT_GRAY
  data.font = NewDamageFont
  data.text = "0"
  data.life = 30
  data.step = 1
  data.speed = 0.2
  data.alphaStep = 0.1
  data.parent = nil
end)
damage:addCallback("step", function(this)
  local data = this:getData()
  this.y = this.y - data.speed
  if data.life > 0 then
    data.life = data.life - data.step
  else
    this.alpha = this.alpha - data.alphaStep
    if this.alpha <= 0 then this:destroy() return end
  end
end)
damage:addCallback("draw", function(this)
  local data = this:getData()
  graphics.alpha(this.alpha)
  graphics.color(this.blendColor)
  graphics.print(data.text, this.x, this.y, data.font, graphics.ALIGN_MIDDLE, graphics.ALIGN_MIDDLE)
  graphics.alpha(1)
  graphics.color(Color.WHITE)
end)

-- Creates damage numbers that supports text at the coordinates specified. Does not support color formatting, but a color can be passed in.
-- Returns the created damage numbers.
CreateDamageText = function(text, x, y, color)
  local foo = Object.find("FakeDamageNumbers", "rts-reborn"):create(x,y)
  foo.blendColor = color
  foo:getData().text = text
  return foo
end
export("CreateDamageText", CreateDamageText)

-- Pop-up Text
PopUpText = {}
local textCount = 0

local _textObject = Object.new("Text")
_textObject:addCallback("create", function(self)
  self:set("life", 60)
  self:set("text", "???")
  self:set("movement", 0)
  self:set("alpha", 1)
end)
_textObject:addCallback("draw", function(self)
  if self:get("life") <= 0 and self:get("alpha") > 0 then
    self:set("alpha", self:get("alpha") - 0.05)
  end
  graphics.alpha(self:get("alpha"))
  graphics.color(Color.fromRGB(255, 255, 255))
  graphics.printColor(self:get("text"), self.x - (graphics.textWidth(self:get("text"), graphics.FONT_DEFAULT) / 2), self.y - (graphics.textWidth(self:get("text"), graphics.FONT_DEFAULT) / 2))
end)
_textObject:addCallback("step", function(self, player)
  self:set("life", self:get("life") - 1)
  self:set("movement", self:get("movement") - 1)
  if self:get("alpha") <= 0 then
    self:destroy()
  return
  else
    if self:get("movement") <= 0 then
      self.y = self.y - 1
    end
  end
end)

PopUpText.new = function(text, life, movement, x, y)
  local t = _textObject:create(x, y)
  t:set("text", text)
  t:set("life", life)
  t:set("movement", movement)
  return t
end

export("PopUpText")
return PopUpText
