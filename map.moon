
-- some sort of a tile, and collision, map

require "moon"

import rectangle, setColor, getColor from love.graphics
import mixin_object from moon

export *

class Map
  cell_size: 32
  color: { 133, 168, 119 }

  new: (@width, @tiles) =>
    @solid = UniformGrid @cell_size * 8
    for x,y,t in @each_xyt!
      if t
        @solid\add Box x,y, @cell_size, @cell_size

    mixin_object self, @solid, {"get_candidates"}

  each_xyt: =>
    coroutine.wrap ->
      for i, t in ipairs @tiles
        if t != 0
          i -= 1
          x = i % @width * @cell_size
          y = math.floor(i / @width) * @cell_size
          coroutine.yield x, y, t

  draw: =>
    setColor @color
    for x,y,t in @each_xyt!
      rectangle "fill", x, y, @cell_size, @cell_size

