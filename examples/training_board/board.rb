$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../', __FILE__)

require 'i8080'
require 'intel_hex'
require 'seven_segment'
require 'io/console'


hex_file = ARGV[0] || 'seven_segment.hex'

class MemoryManager < I8080::MemoryManager

  def initialize(options={})
    super(options)
    # rom 1kbyte
    @rom = 0..0x3ff
    # ram 1kbyte
    @ram = 0x8000..0x83ff
    @force = false
  end

  def [](*args)
    #return super
    case args.size
    when 1
      case args[0]
      when Range
        args[0].map do |i|
          a = i & 0x83ff
          if @rom.include?(a) || @ram.include?(a)
            @mem[a]
          else
            0
          end
        end
      else
        a = args[0] & 0x83ff
        if @rom.include?(a) || @ram.include?(a)
          @mem[a]
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
      v = args[1]
      case args[0]
      when Range
        args[0].each_with_index do |a, i|
          adr = a & 0x83ff
          if @force || @ram.include?(adr)
            @mem[adr] = v[i]
          end
        end
      else
        adr = args[0] & 0x83ff
        if @force || @ram.include?(adr)
          @mem[adr] = v
        else
          0
        end
      end

    when 3
      adr = args[0]
      size = args[1]
      v = args[2]
      size.times do |i|
        if @force || @ram.include?(adr)
          @mem[(adr + i) & 0x83ff] = v[i]
        end
      end
    end
  end

  # Usually, the ROM memory is read-only.
  # This method enables to force write to the ROM memory.
  def force_write
    begin
      @force = true
      yield
    ensure
      @force = false
    end
  end

end



hex = IntelHex.new(hex_file)
hex.load
data = hex.data

cpu = I8080.new memory_manager: MemoryManager.new
cpu.mem.force_write {
  cpu.mem[0, data.size] = data
}
seg = SevenSegmentDisplay.new

t1 = Thread.new do
  cpu.run
end

t2 = Thread.new do
  delimiter = "\r"
  i = 0
  loop do
    cpu.hold {
      s = Time.now
      puts
      #8.times do |i|
        seg[i] = cpu.mem[0x83f8 + i]
      #end
      seg.puts delimiter
      cpu.dump_regs delimiter
      print "\e[7A"
      print "%.6f" % (Time.now - s)
      i = (i + 1) % 8
    }
    sleep 0.01
  end
end

while true
  case $stdin.getch
  when ?\C-c
    exit
  end
end

t1.join
t2.join
