$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../', __FILE__)

require 'i8080'
require 'ppi'
require 'intel_hex'
require 'seven_segment'
require 'io/console'
require 'debug'
require 'memory_manager'

hex_file = ARGV[0] || 'seven_segment.hex'

BOARD_HEX_FILE = 'board.hex'

@print_queue = Queue.new
@print_queue.push nil

def print_sync
  @print_queue.pop
  yield
ensure
  @print_queue.push nil
end

class Interrupter < I8080::Interrupter
  attr_accessor :step

  def initialize
    super
    @step = false
  end

  def step?
    @step
  end

  def toggle
    @step = !@step
  end

  def interrupted? cpu
    step?
  end

  def interrupt cpu
    super
  end

  
end

def display_help
  delimiter = "\r"

  10.times do
    puts delimiter
  end

  [
    "0-9, A-F: hex key",
    "↩️: RET         R: RUN         SP: ADRS SET",
    "<: READ DECR   >: READ INCR   /: WRITE INCR",
    "S: STORE DATA  L: LOAD DATA",
    "TAB: RESET     H: Help",
  ].each do |s|
    puts s + delimiter
  end

end


# create cpu and seven segment display
mm = MemoryManager.new rom: (0x0000..0x03ff), ram: (0x8000..0x83ff)
cpu = I8080.new memory_manager: mm, io_delegate: PPI.new, clock: 2048000, interrupter: Interrupter.new
# load hex file
cpu.mem.force_write {
  data = IntelHex.load(hex_file)
  cpu.mem[0, data.size] = data
}
seg = SevenSegmentDisplay.new

# run cpu in t1 thread
t1 = Thread.new do
  cpu.run
end

# display segments and registers in t2 thread
t2 = Thread.new do
  delimiter = "\r"
  #i = 0
  loop do
    cpu.hold {
      print_sync {
        # display segments
        puts
        8.times do |i|
          seg[i] = cpu.mem[0x83f8 + i]
        end

        # clear line
        seg.puts delimiter
        
        # display registers
        cpu.dump_regs delimiter

        # display stored pc and sp
        cpu.print_address 0x83e0, delimiter
        cpu.dump_mem 0x83e0, 2
        cpu.dump_mem 0x83e2, 2

        # display breake point and break count
        cpu.print_address 0x83f0
        cpu.dump_mem 0x83f0, 2
        cpu.dump_mem 0x83f2, 1

        # display step mode
        print "STEP: #{cpu.interrupter.step? ? "ON " : "OFF"}"
        print "\e[7A"
      }
    }
    sleep 0.03
  end
end

# Make key input to ppi input value in main thead.
# NOTE: ↑: 0x44, ↓: 0x42, →: 0x43, ←: 0x41, ESC: 0x1b
while true
  c = $stdin.getch
  case c
  when "\e"
    c1 = $stdin.getch
    case c1
    when '['
      c2 = $stdin.getch
      case c2
      when 'A'
        cpu.interrupter.step = true
      when 'B'
        cpu.interrupter.step = false
      end
    end
  when ?\C-c
    exit
  when nil
  when /s/i
    cpu.sync {
      data = cpu.memory_manager.mem
      IntelHex.save(BOARD_HEX_FILE, data, 0 => data.size)
      data2 = IntelHex.load(BOARD_HEX_FILE)
    }
  when /l/i
    cpu.reset {
      cpu.mem.force_write {
        data = IntelHex.load(BOARD_HEX_FILE)
        cpu.mem[0, data.size] = data
      } 
    } if File.exist?(BOARD_HEX_FILE)
  when "\t"
    cpu.reset
  when /h/i
    print_sync {
      display_help
    }
  else
    cpu.io_delegate.press c.upcase
    sleep 0.03
  end
end

t1.join
t2.join
