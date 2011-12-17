
-- some sort of a tile, and collision, map

require "moon"

import rectangle, setColor, getColor from love.graphics
import mixin_object from moon

export *

class Map
  cell_size: 16
  color: { 133, 168, 119 }

  self.from_image = (fname) ->
    data = love.image.newImageData fname
    width, height = data\getWidth!, data\getHeight!

    spawn = {0,0}

    tiles = {}
    len = 1
    for y=0,height - 1
      for x=0,width - 1
        r,g,b,a = data\getPixel x, y
        if a == 255
          if r == 255
            spawn = {x,y}
            tiles[len] = 0
          else
            tiles[len] = 1
        else
          tiles[len] = 0
        len += 1

    with Map width, tiles
      .spawn = {spawn[1] * .cell_size, spawn[2] * .cell_size}

  new: (@width, @tiles) =>
    @solid = UniformGrid @cell_size * 4
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

