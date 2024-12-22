require 'dxopal'
require_remote 'i8080.rb'
require_remote 'memory_manager.rb'
require_remote 'rom.rb'

include DXOpal

@cpu = I8080.new
t_ex = Time.now

mm = MemoryManager.new rom: (0..0x1fff), ram: (0x2000..0x23ff), vram: (0x2400..0x3fff)
@cpu.memory_manager = mm

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

#vram_test_set

Window.load_resources do
  Window.bgcolor = C_BLACK
  ex_key_down = false #Input.key_down?(K_S)
  
  Window.loop do
    #now = Time.now
    #d = now - t_ex
    #t_ex = now

    key_down = Input.key_down?(K_S)
    if true #key_down && !ex_key_down
      @cpu.run(1)
    end
    ex_key_down = key_down
    #@cpu.state = 0
    #c = d * @cpu.clock
    #while @cpu.state < c
    #  @cpu.run(1)
    #end
    Window.draw(0, 0, @cpu.mem.vram_image)
    # regs_info(@cpu).each_line.with_index do |line, i|
    #   Window.draw_font(0, i * 20, line.chomp, Font.default, color: C_WHITE)
    # end
  end
end
