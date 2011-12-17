
-- some sort of a tile, and collision, map

require "moon"
require "collide"

import rectangle, setColor, getColor from love.graphics
import mixin_object from moon

export *

class Tile extends Box
  draw: =>
    setColor @color
    rectangle "fill", @unpack!

class Map
  cell_size: 32

  color: {
    surface: {133, 168, 119}
    dirt: {111, 140, 99}
  }

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

    @count = #@tiles
    @height = @count / @width

    for x,y,t, i in @each_xyt!
      @tiles[i] = if t > 0
        box = with Tile x * @cell_size, y * @cell_size, @cell_size, @cell_size
          .color = @color.dirt
          .i = i

        @solid\add box
        box
      else
        nil

    -- color the tiles
    for x,y,t,i in @each_xyt!
      if t
        above = @get_tile x, y - 1
        if above == nil
          t.color = @color.surface

    mixin_object self, @solid, {"get_candidates"}
 
  to_xy: (i) =>
    x = i % @width
    y = math.floor(i / @width)
    x, y

  get_tile: (x,y) =>
    return false if x < 0 or x >= @width
    return false if y < 0 or y >= @height
    @tiles[y * @width + x + 1]

  -- final x,y coord
  each_xyt: =>
    coroutine.wrap ->
      for i=1,@count
        t = @tiles[i]
        i -= 1
        x = i % @width
        y = math.floor(i / @width)
        coroutine.yield x, y, t, i

  draw: (viewport) =>
    for tile in *@get_candidates viewport.box
      tile\draw!

