class Io < I8080::IoDelegate

  Player = Struct.new(:start, :shot, :left, :right)

  # dip switches
  attr_accessor :ship
  attr_accessor :extra_ship
  attr_accessor :show_coin
  attr_accessor :self_test

  # buttons
  attr_accessor :players

  # sonsors
  attr_accessor :credit
  attr_accessor :tilt

  SHIP_3 = 0
  SHIP_4 = 1
  SHIP_5 = 2
  SHIP_6 = 3

  EXTRA_SHIP_1500 = 0
  EXTRA_SHIP_1000 = 1

  ONE = 0
  TWO = 1

  def initialize
    @ship = SHIP_3
    @extra_ship = EXTRA_SHIP_1500
    @show_coin = false
    @self_test = false
    @players = [Player.new(false, false, false, false), Player.new(false, false, false, false)]
    @shifts = [0, 0]
    @shift_amount = 0
  end

  def in port
    case port
    when 0
      0x0e | (self_test ? 0x01 : 0x00)

    when 1
      (credit ?               0x01 : 0x00) |
      (players[TWO][:start] ? 0x02 : 0x00) |
      (players[ONE][:start] ? 0x04 : 0x00) |
                              0x08         | 
      (players[ONE][:shot]  ? 0x10 : 0x00) |
      (players[ONE][:left]  ? 0x20 : 0x00) |
      (players[ONE][:right] ? 0x40 : 0x00) |
                                     0x00
                                     
    when 2
      ship                                 |
      (tilt                 ? 0x04 : 0x00) |
      (extra_ship           ? 0x08 : 0x00) |
      (players[TWO][:shot]  ? 0x10 : 0x00) |
      (players[TWO][:left]  ? 0x20 : 0x00) |
      (players[TWO][:right] ? 0x40 : 0x00) |
      (show_coin            ? 0x80 : 0x00) |
      0x00

    when 3
      (((@shifts[1] << 8 | @shifts[0]) << @shift_amount) >> 8) & 0xff

    else
      0
    end
  end
  
  def out port, data
    case port
    when 2
      @shift_amount = data & 0x07

    when 4
      # later is high byte
      @shifts << (data & 0xff)
      @shifts.shift
      
    end
  end

  def reset
  end

end
