

import graphics from love

export *

class Paralax
  new: (@img, @dist_x, @dist_y, opts) =>
    @dist_y = @dist_x if not @dist_y

    @repeat_x = true
    @repeat_y = true
    @ox = 0
    @oy = 0

    if opts
      self[k] =v for k,v in pairs opts

    @img = imgfy @img

    repx = if @repeat_x then "repeat" else "clamp"
    repy = if @repeat_y then "repeat" else "clamp"

    @img\setWrap repx, repy

  draw: (viewport) =>
    import box from viewport

    w, h = @img\getWidth!, @img\getHeight!
    q = graphics.newQuad (box.x - @ox)*@dist_x, (box.y - @oy)*@dist_y, box.w, box.h, w,h
    graphics.drawq @img, q, box.x, box.y

