
-- collision stuff

import rectangle, setColor, getColor from love.graphics

export *

class Vec2d
  new: (x=0, y=0) =>
    self[1] = x
    self[2] = y

  len: =>
    n = self[1]^2 + self[2]^2
    return 0 if n == 0
    math.sqrt n

  normalized: =>
    len = @len!
    if len == 0
      Vec2d!
    else
      Vec2d self[1] / len, self[2] / len

  __mul: (other) =>
    if type(other) == "number"
      Vec2d self[1] * other, self[2] * other

  __tostring: =>
    ("vec2d<%d, %d>")\format self[1], self[2]

class Box
  self.from_pt = (x1, y1, x2, y2) ->
    Box x1, y1, x2 - x1, y2 - y1

  new: (@x, @y, @w, @h) =>

  unpack: => @x, @y, @w, @h
  unpack2: => @x, @y, @x + @w, @y + @h

  touches_pt: (x, y) =>
    x1, y1, x2, y2 = @unpack2!
    x > x1 and x < x2 and y > y1 and y < y2

  touches_box: (o) =>
    x1, y1, x2, y2 = @unpack2!
    ox1, oy1, ox2, oy2 = o\unpack2!

    return false if x2 < ox1
    return false if x1 > ox2
    return false if y2 < oy1
    return false if y1 > oy2
    true

  draw: (color=nil) =>
    setColor color if color
    rectangle "fill", @unpack!

  __tostring: =>
    ("box<(%d, %d), (%d, %d)>")\format @unpack!


