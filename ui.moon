
import rectangle, setColor, getColor from love.graphics
import keyboard, graphics from love

export *

class HealthBar
  new: =>
    @value = 0.5

    @width = 100
    @height = 8
    @padding = 2

  draw: =>
    import padding, w, h from screen
    setColor 255,255,255

    ox = w - @width - padding
    oy = padding

    rectangle "line",
      ox - @padding, oy - @padding,
      @width + @padding*2, @height + @padding*2

    setColor 227, 52, 52, 200
    rectangle "fill",
      ox, oy, @width * @value, @height

