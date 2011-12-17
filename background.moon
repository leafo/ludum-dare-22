

import graphics from love

export *

class Paralax
  new: (@img, @dist) =>
    @img = imgfy @img
    @img\setWrap "repeat", "repeat"
    @dist = 0.5

  draw: (viewport) =>
    import box from viewport

    w, h = @img\getWidth!, @img\getHeight!
    q = graphics.newQuad box.x*@dist, box.y*@dist, box.w, box.h, w,h
    graphics.drawq @img, q, box.x, box.y

