require 'dxopal'
require_remote 'i8080.rb'
require_remote 'memory_manager.rb'
require_remote 'rom.rb'
require_remote 'io.rb'

include DXOpal

class Timer

  def initialize interval
    @interval = interval
    start
  end

  def start
    @start = Time.now
  end

  def elapsed
    Time.now - @start
  end

  def fired?
    f = elapsed >= @interval
    if f
      start
    end
    f
  end

end


@cpu = I8080.new clock: 1_996_800
@refresh_rate = 120
@refresh_state = (@cpu.clock / @refresh_rate).to_i

mm = MemoryManager.new rom: (0..0x1fff), ram: (0x2000..0x23ff), vram: (0x2400..0x3fff)
@cpu.memory_manager = mm

@io = Io.new
@cpu.io_delegate = @io

# Load ROM
@cpu.mem.force_write {
  @cpu.mem[0, @rom.size] = @rom
}

def regs_info cpu
  s = ""
  %w(A F B C D E H L).zip([@cpu.a, @cpu.f, @cpu.b, @cpu.c, @cpu.d, @cpu.e, @cpu.h, @cpu.l]).each do |n, v|
    s += "#{n}:#{v.to_s(16).upcase.rjust(2, '0')} "
  end
  s += "\n"
  %w(BC DE HL PC SP).zip([@cpu.bc, @cpu.de, @cpu.hl, @cpu.pc, @cpu.sp]).each do |n, v|
     s += "#{n}:#{v.to_s(16).upcase.rjust(4, '0')} "
  end
  s += "\n"

  pc = @cpu.pc
  4.times do |i|
    s += @cpu.memory_manager[pc + i].to_s(16).rjust(2, '0') + " "
  end
  s += "\n"
  s
end

def vram_test_set
  w = @cpu.mem.size[:width]
  h = @cpu.mem.size[:height] / 8
p_ w: w, h: h
  v = 0
  (0...w).each do |x|
    (0...h).each do |y|
      @cpu.mem[0x2400 + x * h + y] = v
      v += 1
    end
  end
end

def key_push?
  keys = [K_B, K_D, K_S, K_C, K_O]
  keys.each do |k|
    return k if Input.key_push?(k)
  end
  false
end

class Debug
  attr_accessor :enabled_breakpoint
  attr_accessor :debug_mode
  attr_accessor :break_points

  def initialize
    @break_points = []
  end

  def toggle_breakpoint
    @enabled_breakpoint = !@enabled_breakpoint
  end

  def toggle_debug_mode
    @debug_mode = !@debug_mode
  end

  def fired_breakpoint? pc
    return false unless @enabled_breakpoint
    @break_points.include?(pc)
  end

  def inspect
    "MODE: #{@debug_mode} BREAK: #{@enabled_breakpoint}"
  end

end

@debug = Debug.new
@debug.break_points = [
  #0x008c,
  #0x1439,
  #0x0042,
  #0x1837,
  #0x1815,
  #0x0248,
  #0x14A4,
  #0x14B8,
]
@debug.enabled_breakpoint = true

#vram_test_set


Window.fps = @refresh_rate

Window.load_resources do
  Window.bgcolor = C_BLACK
  
  isr_toggle = false

  Window.loop do
    step = false
    step_out = false

    case key_push?
    when K_B
      @debug.toggle_breakpoint
    when K_D
      @debug.toggle_debug_mode
    when K_S
      step = true
    when K_C
      @debug.debug_mode = false
    when K_O
      step_out = true
    end

    if @debug.debug_mode
      if step
        @cpu.run(1)
      end
      if step_out
        while @cpu.mem[@cpu.pc] != 0xc9 # RET
          @cpu.run(1)
        end
      end
    else
      while @cpu.state < @refresh_state
        @cpu.run(1)
        if @debug.fired_breakpoint?(@cpu.pc)
          @debug.debug_mode = true
          break
        end
      end
    end

    Window.draw(0, 0, @cpu.mem.vram_image)
    "#{regs_info(@cpu)}\n#{Window.real_fps}Hz state: #{@cpu.state} #{@refresh_state}\n#{@debug.inspect}".each_line.with_index do |line, i|
      Window.draw_font(0, 300 + i * 20, line.chomp, Font.default, color: C_WHITE)
    end

    if @cpu.state >= @refresh_state
      @cpu.interrupter.interrupt @cpu, isr_toggle ? 2 : 1
      isr_toggle = !isr_toggle
      @cpu.state -= @refresh_state
    end

  end
end
