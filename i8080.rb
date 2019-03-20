# ref http://www.st.rim.or.jp/~nkomatsu/intel8bit/i8080.html
class I8080

  attr_accessor :a, :f, :b, :c, :d, :e, :h, :l, :pc, :sp
  attr_accessor :clock
  attr_reader :mem, :model

  REG_A = 7
  REG_B = 0
  REG_C = 1
  REG_D = 2
  REG_E = 3
  REG_H = 4
  REG_L = 5
  REG_M = 6

  def initialize options={}
    @model = options[:model] || "uPD8080A" # or uPD8080AF
    @mem = [0] * 64 * 1024
    @a = 0; @f = 0; @b = 0; @c = 0; @d = 0; @e = 0; @h = 0; @l = 0; @pc = 0; @sp = 0
    @clock = 0
  end

  def run cycle=-1
    loop do

      execute
      #dump_regs

      cycle -= 1 if cycle > 0
      break if cycle == 0
    end
  end

  def psw; @a << 8 | @f; end
  def bc; @b << 8 | @c; end
  def de; @d << 8 | @e; end
  def hl; @h << 8 | @l; end

  # --- dump register

  def dump_regs
    puts
    print "\n\e[2A"
    %w(A F B C D E H L).zip([a, f, b, c, d, e, h, l]).each do |n, v|
      print "#{n}:#{v.to_s(16).rjust(2, '0')} "
    end
    print "\n"
    %w(BC DE HL PC SP).zip([bc, de, hl, pc, sp]).each do |n, v|
      print "#{n}:#{v.to_s(16).rjust(4, '0')} "
    end
  end


  private

  def model_af?
    @model == "uPD8080AF"
  end

  def reg_m? v
    v == REG_M
  end

  def src_r v
    (v & 0b00_000_111)
  end

  def dst_r v
    (v & 0b00_111_000) >> 3
  end


  # --- execute

  def execute

    case @mem[@pc]
    when 0b01_110_110
      hlt
    when lambda{|v| (v & 0b11_000_000) == 0b01_000_000}
      mov_r_r
    when lambda{|v| (v & 0b11_000_111) == 0b00_000_110}
      mvi_r_i
    when lambda{|v| (v & 0b11_000_111) == 0b00_000_100}
      inr_r
    when lambda{|v| (v & 0b11_000_111) == 0b00_000_101}
      dcr_r
    when lambda{|v| (v & 0b11_111_000) == 0b10_000_000}
      add_r
    end

  end


  # --- execute command

  def add_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    write_r REG_A, read_r(REG_A) + read_r(s)
    if reg_m? s
      @clock += 7
    else
      @clock += 4
    end
  end

  def dcr_r
    v = @mem[@pc]; @pc += 1
    d = dst_r v
    write_r d, read_r(d) - 1
    if reg_m? d
      @clock += 10
    else
      @clock += 5
    end
  end

  def inr_r
    v = @mem[@pc]; @pc += 1
    d = dst_r v
    write_r d, read_r(d) + 1
    if reg_m? d
      @clock += 10
    else
      @clock += 5
    end
  end

  def mvi_r_i
    v = @mem[@pc]; @pc += 1
    i = @mem[@pc]; @pc += 1
    d = dst_r v
    write_r d, i
    if reg_m? d
      @clock += 10
    else
      @clock += 7
    end
  end

  def mov_r_r
    v = @mem[@pc]; @pc += 1
    d = dst_r v
    s = src_r v
    write_r d, read_r(s)
    if reg_m?(d) || reg_m?(s)
      @clock += 7
    else
      @clock += model_af? ? 5 : 4
    end
  end

  def hlt
    @clock += 7
  end


  # --- read / write register

  def read_r r
    case r
    when REG_A
      @a
    when REG_B
      @b
    when REG_C
      @c
    when REG_D
      @d
    when REG_E
      @e
    when REG_H
      @h
    when REG_L
      @l
    when REG_M
      @mem[hl]
    end
  end

  def write_r r, v
    v &= 0xff
    case r
    when REG_A
      @a = v
    when REG_B
      @b = v
    when REG_C
      @c = v
    when REG_D
      @d = v
    when REG_E
      @e = v
    when REG_H
      @h = v
    when REG_L
      @l = v
    when REG_M
      @mem[hl] = v
    end
  end

end

I8080.new.run if $0 == __FILE__
