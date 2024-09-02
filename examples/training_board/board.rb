$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../', __FILE__)

require 'i8080'
require 'intel_hex'
require 'seven_segment'

hex_file = ARGV[0] || 'seven_segment.hex'

class MemoryManager < I8080::MemoryManager

  def initialize(options={})
    super(options)
    # rom 1kbyte
    @rom = 0..0x3ff
    # ram 1kbyte
    @ram = 0x8000..0x83ff
  end

  def [](*args)
    case args.size
    when 1
      a_or_r = args[0] & 0x83ff
      case a_or_r
      when Range
        a_or_r.map do |i|
          if @rom.include?(i) || @ram.include?(i)
            @mem[i]
          else
            0
          end
        end
      else
        if @rom.include?(a_or_r) || @ram.include?(a_or_r)
          @mem[a_or_r]
        else
          0
        end
      end

    when 2
      addr = args[0]
      size = args[1]
      a = []
      size.times do |i|
        a << self[(addr + i) & 0x83ff]
      end
      a
    end
  end

  def []=(*args)
    case args.size
    when 2
      a_or_r = args[0] & 0x83ff
      v = args[1]
      case a_or_r
      when Range
        a_or_r.each do |i|
          if @rom.include?(i) || @ram.include?(i)
            @mem[i] = v[i]
          end
        end
      else
        if @rom.include?(a_or_r) || @ram.include?(a_or_r)
          @mem[a_or_r] = v
        else
          0
        end
      end

    when 3
      addr = args[0]
      size = args[1]
      v = args[2]
      size.times do |i|
        @mem[(addr + i) & 0x83ff] = v[i]
      end
    end
  end

end



hex = IntelHex.new(hex_file)
hex.load
data = hex.data

cpu = I8080.new #memory_manager: MemoryManager.new
cpu.mem[0, data.size] = data
seg = SevenSegmentDisplay.new

t1 = Thread.new do
  cpu.run
end

t2 = Thread.new do
  #i = 0
  loop do
    cpu.hold {
      s = Time.now
      puts
      8.times do |i|
        seg[i] = cpu.mem[0x83f8 + i]
      end
      seg.puts
      cpu.dump_regs
      print "\e[7A"
      print "%.6f" % (Time.now - s)
      #i = (i + 1) % 8
    }
    sleep 0.01
  end
end

t1.join
t2.join
