
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
  self.from_size = (x,y,w,h) ->
    Box x,y, x+w, x+h

  new: (@x1, @y1, @x2, @y2) =>

  unpack: => @x1, @y1, @x2, @y2
  unpack2: => @x1, @y1, @x2 - @x1, @y2 - @y1

  touches_pt: (x, y) =>
    x > @x1 and x < @x2 and y > @y1 and y < @y2


  touches_box: (o) =>
    return false if @x2 < o.x1
    return false if @x1 > o.x2
    return false if @y2 < o.y1
    return false if @y1 > o.y2
    true

  draw: (color=nil) =>
    setColor color if color
    rectangle "fill", @unpack2!

  __tostring: =>
    ("box<(%d, %d), (%d, %d)>")\format @x1, @y1, @x2, @y2


