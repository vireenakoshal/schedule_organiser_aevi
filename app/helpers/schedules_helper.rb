module SchedulesHelper
  def interpolate_day_color(progress)
    # 0.0 = morning yellow, 1.0 = night dark orange
    stops = [
      [1.0, 0.85, 0.40],  # #FFD966 morning yellow
      [0.96, 0.66, 0.25],  # #F4A940 mid morning
      [0.85, 0.49, 0.23],  # #D97C3A afternoon terracotta
      [0.76, 0.38, 0.23],  # #C1613A late afternoon
      [0.55, 0.23, 0.16],  # #8B3A2A night dark orange
    ]

    # Find which two stops we're between
    scaled   = progress * (stops.length - 1)
    lower    = scaled.floor.clamp(0, stops.length - 2)
    upper    = lower + 1
    fraction = scaled - lower

    r1, g1, b1 = stops[lower]
    r2, g2, b2 = stops[upper]

    r = ((r1 + (r2 - r1) * fraction) * 255).round
    g = ((g1 + (g2 - g1) * fraction) * 255).round
    b = ((b1 + (b2 - b1) * fraction) * 255).round

    "rgb(#{r}, #{g}, #{b})"
  end
end
