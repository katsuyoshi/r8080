require 'i8080'


class PPI < I8080::IoDelegate

  attr_reader :mode_a, :mode_b, :mode_c_l, :mode_c_h
  attr_reader :port_a, :port_b, :port_c

  def initialize
    super
    @port_a = 0
    @port_b = 0
    @port_c = 0
    @control = 0
    @mode = 0
    @mode_a = :input
    @mode_b = :input
    @mode_c_l = :input
    @mode_c_h = :input
  end

  def in port
    values[port]
  end
  
  def out port, data
    case port & 0x3
    when 0
      @port_a = data if @mode_a == :output
    when 1
      @port_b = data if @mode_b == :output
    when 2
      mask = (@mode_c_h == :output ? 0xf0 : 0x00) |
             (@mode_c_l == :output ? 0x0f : 0x00)
      @port_c = data & mask
    when 3
      if data & 0x80 == 0
        bit = (data >> 1) & 0x07
        set = data & 0x01 == 0 ? 0 : 1
        if @mode_c_h == :output && bit >= 4 ||
           @mode_c_l == :output && bit < 4
          @port_c = (@port_c & ~(1 << bit)) | (set << bit)
        end
      else
        @mode_a = data[4] == 0 ? :output : :input
        @mode_c_h = data[3] == 0 ? :output : :input
        @mode_b = data[1] == 0 ? :output : :input
        @mode_c_l = data[0] == 0 ? :output : :input
      end
    end
  end

end

