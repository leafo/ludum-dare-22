
-- some sort of a tile, and collision, map

require "moon"
require "collide"

import rectangle, setColor, getColor from love.graphics
import mixin_object from moon
import random from math

export *

style = {
  solid: 0
  solid_decor1: 16
  solid_decor2: 24

  top: 1
  bottom: 18

  back: 2
  back_floor: 13
  back_ceil: 14

  back_topleft: 17

  decor1: 4

  hot: {
    back: 3
    top: 6
    bottom: 5
  }

  inside: {
    back: 9
    top: 10
    decor1: 11
    decor2: 12
  }

}

hash_color = (r,g,b) ->
  r.."-"..g.."-"..b

nothing =  (tile) ->
  tile == nil or tile and tile.layer == 0

tile_types = {
  ["0-0-0"]: {
    sid: style.solid
    layer: 1
    auto: (x,y) =>
      above = @tiles[@to_i x, y - 1]
      if nothing above
        style.top
      else
        below = @tiles[@to_i x, y + 1]
        if nothing below
          style.bottom
        else
          r = random!
          if r > 0.98
            style.solid_decor1
          elseif r > 0.95
            style.solid_decor2
  }

  ["107-0-3"]: {
    sid: style.hot.back
    layer: 1
    auto: (x,y) =>
      below = @tiles[@to_i x, y + 1]
      if nothing below
        style.hot.bottom
      else
        above = @tiles[@to_i x, y - 1]
        if nothing above
          style.hot.top

  }

  ["198-132-49"]: {
    sid: style.back
    layer: 0
    auto: (x,y) =>
      below = @tiles[@to_i x, y + 1]
      if below and below.layer == 1
        style.back_floor
      else
        -- check if corner
        left = @tiles[@to_i x - 1, y]
        above = @tiles[@to_i x, y - 1]
        if left == nil and above == nil
          style.back_topleft
        elseif above and above.layer == 1
          style.back_ceil
        elseif random! > 0.95
          style.decor1
  }

  ["245-134-78"]: {
    sid: style.inside.back
    layer: 0
    auto: (x,y) =>
      above = @tiles[@to_i x, y - 1]
      if above == nil
        style.inside.top
      else
        r = random!
        if r > 0.98
          style.inside.decor1
        elseif r > 0.96
          style.inside.decor2
  }

  ["255-0-0"]: { spawn: true }
}


class Tile extends Box
  new: (@sid, ...) => super ...
  draw: (sprite) => sprite\draw_cell @sid, @x, @y

class Map
  cell_size: 16

  self.from_image = (fname, tile_image, num_x=8) ->
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
              print "found spawn"
              spawn = {x,y}
              nil
            else
              tile

        len += 1

    with Map width, height, tiles
      .sprite = Spriter tile_image, .cell_size, .cell_size, num_x
      .spawn = {spawn[1] * .cell_size, spawn[2] * .cell_size}


  new: (@width, @height, @tiles) =>
    @count = @width * @height
    layer = -> UniformGrid @cell_size * 3

    @min_layer, @max_layer = nil

    -- pixel size of the map
    @real_width = @width * @cell_size
    @real_height = @height * @cell_size

    -- do the autotiles
    for x,y,t,i in @each_xyt!
      if t and t.auto
        sid = t.auto self, x,y,t,i
        if sid
          @tiles[i] = { layer: t.layer, :sid }

    @layers = {}
    for x,y,t,i in @each_xyt!
      if t
        box = Tile t.sid,
          x * @cell_size, y * @cell_size,
          @cell_size, @cell_size

        @min_layer = not @min_layer and t.layer or math.min @min_layer, t.layer
        @max_layer = not @max_layer and t.layer or math.max @max_layer, t.layer

        @layers[t.layer] = layer!  if not @layers[t.layer]
        @layers[t.layer]\add box

    -- -- color the tiles
    -- for x,y,t in @each_xyt ground
    --   if t
    --     above = ground[@to_i x, y - 1]
    --     if above == nil
    --       t.sid = style.surface

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
        coroutine.yield x, y, t, i + 1

  draw: (viewport) =>
    for i=@min_layer,@max_layer
      for tile in *@layers[i]\get_candidates viewport.box
        tile\draw @sprite

