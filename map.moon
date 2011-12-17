
-- some sort of a tile, and collision, map

require "moon"
require "collide"

import rectangle, setColor, getColor from love.graphics
import mixin_object from moon

export *

style = {
  surface: 1
  dirt: 0
}

class Tile extends Box
  new: (@sid, ...) => super ...
  draw: (sprite) => sprite\draw_cell @sid, @x, @y

class Map
  cell_size: 16

  self.from_image = (fname, tile_image) ->
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
      .sprite = Spriter tile_image, .cell_size, .cell_size
      .spawn = {spawn[1] * .cell_size, spawn[2] * .cell_size}

  new: (@width, @tiles) =>
    @solid = UniformGrid @cell_size * 4

    @count = #@tiles
    @height = @count / @width

    for x,y,t, i in @each_xyt!
      @tiles[i] = if t > 0
        tile = Tile style.dirt,
          x * @cell_size, y * @cell_size,
          @cell_size, @cell_size

        @solid\add tile
        tile
      else
        nil

    -- color the tiles
    for x,y,t,i in @each_xyt!
      if t
        above = @get_tile x, y - 1
        if above == nil
          t.sid = style.surface

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
      tile\draw @sprite

