
-- some sort of a tile, and collision, map

require "moon"
require "collide"

import rectangle, setColor, getColor from love.graphics
import mixin_object from moon

export *

style = {
  dirt: 0
  surface: 1
  behind: 2
}

hash_color = (r,g,b) ->
  r.."-"..g.."-"..b

tile_types = {
  ["0-0-0"]: {
    sid: style.dirt
    layer: 1
  }
  ["198-132-49"]: {
    sid: style.behind
    layer: 0
  }
  ["255-0-0"]: { spawn: true }
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
          tile = tile_types[hash_color r,g,b,a]
          tiles[len] = if tile
            if tile.spawn
              spawn = {x,y}
              nil
            else
              tile

        len += 1

    with Map width, height, tiles
      .sprite = Spriter tile_image, .cell_size, .cell_size
      .spawn = {spawn[1] * .cell_size, spawn[2] * .cell_size}


  new: (@width, @height, @tiles) =>
    @count = @width * @height
    layer = -> UniformGrid @cell_size * 3

    @min_layer, @max_layer = nil

    @layers = {}

    ground = {}
    for x,y,t,i in @each_xyt!
      if t
        box = Tile t.sid,
          x * @cell_size, y * @cell_size,
          @cell_size, @cell_size

        @min_layer = not @min_layer and t.layer or math.min @min_layer, t.layer
        @max_layer = not @max_layer and t.layer or math.max @max_layer, t.layer

        @layers[t.layer] = layer!  if not @layers[t.layer]
        @layers[t.layer]\add box

        if t.layer == 1 -- ground
          ground[i] = box

    -- color the tiles
    for x,y,t in @each_xyt ground
      if t
        above = ground[@to_i x, y - 1]
        if above == nil
          t.sid = style.surface

    print "min:", @min_layer, "max:", @max_layer
    @solid = @layers[1]
    mixin_object self, @solid, {"get_candidates"}
 
  to_xy: (i) =>
    i -= i
    x = i % @width
    y = math.floor(i / @width)
    x, y

  to_i: (x,y) =>
    return false if x < 0 or x >= @width
    return false if y < 0 or y >= @height
    y * @width + x + 1

  -- final x,y coord
  each_xyt: (tiles=@tiles)=>
    coroutine.wrap ->
      for i=1,@count
        t = tiles[i]
        i -= 1
        x = i % @width
        y = math.floor(i / @width)
        coroutine.yield x, y, t, i

  draw: (viewport) =>
    for i=@min_layer,@max_layer
      for tile in *@layers[i]\get_candidates viewport.box
        tile\draw @sprite

