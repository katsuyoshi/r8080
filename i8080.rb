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

  FLG_S  = 0x80
  FLG_Z  = 0x40
  FLG_H = 0x10
  FLG_P  = 0x04
  FLG_C = 0x01


  def initialize options={}
    @mem = [0] * 64 * 1024
    @a = 0; @f = 0x02; @b = 0; @c = 0; @d = 0; @e = 0; @h = 0; @l = 0; @pc = 0; @sp = 0
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

  def flg_s?
    (@f & FLG_S) != 0
  end

  def flg_s= f
    if f
      @f |= FLG_S
    else
      @f &= ~FLG_S
    end
  end

  def flg_z?
    (@f & FLG_Z) != 0
  end

  def flg_z= f
    if f
      @f |= FLG_Z
    else
      @f &= ~FLG_Z
    end
  end

  def flg_h?
    (@f & FLG_H) != 0
  end

  def flg_h= f
    if f
      @f |= FLG_H
    else
      @f &= ~FLG_H
    end
  end

  def flg_p?
    (@f & FLG_P) != 0
  end

  def flg_p= f
    if f
      @f |= FLG_P
    else
      @f &= ~FLG_P
    end
  end

  def flg_c?
    (@f & FLG_C) != 0
  end

  def flg_c= f
    if f
      @f |= FLG_C
    else
      @f &= ~FLG_C
    end
  end


  private

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
    when 0b11_000_110
      adi_i
    when 0b11_001_110
      aci_i
    when 0b11_010_110
      sui_i
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
    when lambda{|v| (v & 0b11_111_000) == 0b10_001_000}
      adc_r
    when lambda{|v| (v & 0b11_111_000) == 0b10_010_000}
      sub_r
    when lambda{|v| (v & 0b11_111_000) == 0b10_011_000}
      sbb_r
    when lambda{|v| (v & 0b11_111_000) == 0b10_100_000}
      ana_r
    when lambda{|v| (v & 0b11_111_000) == 0b10_101_000}
      xra_r
    when lambda{|v| (v & 0b11_111_000) == 0b10_110_000}
      ora_r
    when lambda{|v| (v & 0b11_111_000) == 0b11_011_000}
      sbi_i


    end

  end


  # --- execute command

  def add_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    write_r REG_A, read_r(REG_A) + read_r(s), true
    if reg_m? s
      @clock += 7
    else
      @clock += 4
    end
  end

  def adc_r
    v = @mem[@pc]; @pc += 1
    c = flg_c? ? 1 : 0
    s = src_r v
    write_r REG_A, read_r(REG_A) + read_r(s) + c, true
    if reg_m? s
      @clock += 7
    else
      @clock += 4
    end
  end

  def adi_i
    v = @mem[@pc]; @pc += 1
    i = @mem[@pc]; @pc += 1
    write_r REG_A, read_r(REG_A) + i, true
    @clock += 7
  end

  def aci_i
    v = @mem[@pc]; @pc += 1
    i = @mem[@pc]; @pc += 1
    c = flg_c? ? 1 : 0
    write_r REG_A, read_r(REG_A) + i + c, true
    @clock += 7
  end

  def sub_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    write_r REG_A, read_r(REG_A) - read_r(s), true
    if reg_m? s
      @clock += 7
    else
      @clock += 4
    end
  end

  def sbb_r
    v = @mem[@pc]; @pc += 1
    b = flg_c? ? 1 : 0
    s = src_r v
    write_r REG_A, read_r(REG_A) - read_r(s) - b, true
    if reg_m? s
      @clock += 7
    else
      @clock += 4
    end
  end

  def sui_i
    v = @mem[@pc]; @pc += 1
    i = @mem[@pc]; @pc += 1
    write_r REG_A, read_r(REG_A) - i, true
    @clock += 7
  end

  def sbi_i
    v = @mem[@pc]; @pc += 1
    i = @mem[@pc]; @pc += 1
    b = flg_c? ? 1 : 0
    write_r REG_A, read_r(REG_A) - i - b, true
    @clock += 7
  end

  def dcr_r
    v = @mem[@pc]; @pc += 1
    d = dst_r v
    write_r d, read_r(d) - 1, true
    if reg_m? d
      @clock += 10
    else
      @clock += 5
    end
  end

  def inr_r
    v = @mem[@pc]; @pc += 1
    d = dst_r v
    write_r d, read_r(d) + 1, true
    if reg_m? d
      @clock += 10
    else
      @clock += 5
    end
  end

  def ana_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    write_r REG_A, read_r(REG_A) & read_r(s), true
    if reg_m? s
      @clock += 7
    else
      @clock += 4
    end
  end

  def xra_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    write_r REG_A, read_r(REG_A) ^ read_r(s), true
    if reg_m? s
      @clock += 7
    else
      @clock += 4
    end
  end

  def ora_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    write_r REG_A, read_r(REG_A) | read_r(s), true
    if reg_m? s
      @clock += 7
    else
      @clock += 4
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
      @clock += 4
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

  def write_r r, v, set_f = false
    v8 = v & 0xff
    case r
    when REG_A
      if set_f
        vrh = read_r(r) >> 4
        v8h = v8 >> 4
        self.flg_s = (v8 & FLG_S) == FLG_S
        self.flg_z = (v8 == 0)
        self.flg_h = vrh != v8h
        # odd parity
        self.flg_p = ((8.times.inject(0){|n,i| n + ((v >> i) & 0x01)}) & 0x01) == 0
        self.flg_c = (v & 0xff00) != 0
      end
      @a = v8
    when REG_B
      @b = v8
    when REG_C
      @c = v8
    when REG_D
      @d = v8
    when REG_E
      @e = v8
    when REG_H
      @h = v8
    when REG_L
      @l = v8
    when REG_M
      @mem[hl] = v8
    end
  end

end

I8080.new.run if $0 == __FILE__
