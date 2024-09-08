# ref http://www.st.rim.or.jp/~nkomatsu/intel8bit/i8080.html
class I8080

  attr_accessor :a, :f, :b, :c, :d, :e, :h, :l, :pc, :sp
  attr_accessor :interrupt_enable, :interrupt_pending
  attr_accessor :state, :clock
  attr_reader :mem, :model
  attr_reader :sync_queue

  attr_accessor :io_delegate

  REG_NONE = -1
  REG_A = 7
  REG_B = 0
  REG_C = 1
  REG_D = 2
  REG_E = 3
  REG_H = 4
  REG_L = 5
  REG_M = 6

  REG_PAIR_BC = 0
  REG_PAIR_DE = 1
  REG_PAIR_HL = 2
  REG_PAIR_SP = 3
  REG_PAIR_PSW = 3

  FLG_S  = 0x80
  FLG_Z  = 0x40
  FLG_AC = 0x10
  FLG_P  = 0x04
  FLG_CY = 0x01

  FLGS_NONE = 0x00
  FLGS_ALL = 0xff
  FLGS_S_Z_AC_P = FLG_S | FLG_Z | FLG_AC | FLG_P

  # You should override this class to implement IO. And set it to io_delegate.
  class IoDelegate
    attr_accessor :values
    def initialize
      @values = {}
    end
    def in port; values[port] || 0; end
    def out port, data; values[port] = data end
    def reset; end
  end

  class MemoryManager
    attr_accessor :mem
    def initialize options={}
      @mem = [0] * (options[:size] || 64 * 1024)
    end
    def inspect; puts self; end
    def method_missing m, *args
      case m
      when :[], :[]=
        @mem.send m, *args
      end
    end
  end

  def initialize options={}
    @mem = options[:memory_manager] || MemoryManager.new
    @io_delegate = options[:io_delegate] || IoDelegate.new

    @a = 0; @f = 0x02; @b = 0; @c = 0; @d = 0; @e = 0; @h = 0; @l = 0; @pc = 0; @sp = 0
    @interrupt_enable = false
    @interrupt_pending = nil
    @clock = 1000000
    @state = 0
    @sync_queue = Queue.new
    @sync_queue.push nil
  end

  def memory_manager
    @mem
  end

  def memory_manager= m
    @mem = m
  end

  def run cycle=-1
    s_t = Time.now
    s_st = @state
    loop do
  
      begin
        @sync_queue.pop
        execute
      ensure
        @sync_queue.push nil
      end

      cycle -= 1 if cycle > 0

      # adjust clock time
      t = Time.now
      st = @state
      d = (st - s_st).to_f / @clock - (t - s_t)
      if d > 0.03
        sleep d
        s_t = t
        s_st = st
      end

      break if cycle == 0
    end
  end

  def psw; @a << 8 | @f; end
  def bc;  @b << 8 | @c; end
  def de;  @d << 8 | @e; end
  def hl;  @h << 8 | @l; end

  def psw=v; p caller if v == nil; @a = v >> 8; @f = v & 0xff; end
  def bc=v;  @b = v >> 8; @c = v & 0xff; end
  def de=v;  @d = v >> 8; @e = v & 0xff; end
  def hl=v;  @h = v >> 8; @l = v & 0xff; end

  # --- dump register

  def dump_regs delimiter="", rollback=false
    puts delimiter
    print delimiter + "\n\e[2A" if rollback
    %w(A F B C D E H L).zip([a, f, b, c, d, e, h, l]).each do |n, v|
      print "#{n}:#{v.to_s(16).rjust(2, '0')} "
    end
    print delimiter + "\n"
    %w(BC DE HL PC SP).zip([bc, de, hl, pc, sp]).each do |n, v|
      print "#{n}:#{v.to_s(16).rjust(4, '0')} "
    end
    puts delimiter unless rollback
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

  def flg_ac?
    (@f & FLG_AC) != 0
  end

  def flg_ac= f
    if f
      @f |= FLG_AC
    else
      @f &= ~FLG_AC
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

  def flg_cy?
    (@f & FLG_CY) != 0
  end

  def flg_cy= f
    if f
      @f |= FLG_CY
    else
      @f &= ~FLG_CY
    end
  end

  def interrupt_enabled?
    @interrupt_enable
  end

  def hold
    begin
      @sync_queue.pop
      yield
    ensure
      @sync_queue.push nil
    end
  end

  def interrupt
    return unless interrupt_enabled?
    @sync_queue.pop
    rst 7
    @sync_queue.push nil
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

    @interrupt_pending += 1 if @interrupt_pending

    case @mem[@pc]
    when 0b00_000_000
      nop
    when 0b01_110_110
      hlt
    when 0b11_000_110
      adi_i
    when 0b11_001_110
      aci_i
    when 0b11_010_110
      sui_i
    when 0b00_000_111
      rlc
    when 0b00_001_111
      rrc
    when 0b00_010_111
      ral
    when 0b00_011_111
      rar
    when 0b11_000_011
      jmp_i
    when 0b11_011_010
      jc_i
    when 0b11_010_010
      jnc_i
    when 0b11_001_010
      jz_i
    when 0b11_000_010
      jnz_i
    when 0b11_110_010
      jp_i
    when 0b11_111_010
      jm_i
    when 0b11_101_010
      jpe_i
    when 0b11_100_010
      jpo_i
    when 0b11_001_101
      call_i
    when 0b11_011_100
      cc_i
    when 0b11_010_100
      cnc_i
    when 0b11_001_100
      cz_i
    when 0b11_000_100
      cnz_i
    when 0b11_111_100
      cm_i
    when 0b11_110_100
      cp_i
    when 0b11_101_100
      cpe_i
    when 0b11_100_100
      cpo_i
    when 0b11_001_001
      ret
    when 0b11_011_000
      rc
    when 0b11_010_000
      rnc
    when 0b11_001_000
      rz
    when 0b11_000_000
      rnz
    when 0b11_111_000
      rm
    when 0b11_110_000
      rp
    when 0b11_101_000
      rpe
    when 0b11_100_000
      rpo
    when 0b00_110_010
      sta_i
    when 0b00_111_010
      lda_i
    when 0b11_101_011
      xchg
    when 0b11_100_011
      xthl
    when 0b11_111_001
      sphl
    when 0b11_101_001
      pchl
    when 0b00_000_010, 0b00_010_010
      stax_rp
    when 0b00_001_010, 0b00_011_010
      ldax_rp
    when 0b00_101_111
      cma
    when 0b00_110_111
      stc
    when 0b00_111_111
      cmc
    when 0b00_100_111
      daa
    when 0b00_100_010
      shld_i
    when 0b00_101_010
      lhld_i
    when 0b11_111_011
      ei
    when 0b11_110_011
      di
    when 0b11_011_011
      in_i
    when 0b11_010_011
      out_i
    when 0b11_111_110
      cpi_i

    when lambda{|v| (v & 0b11_001_111) == 0b00_000_001}
      lxi_r_i
    when lambda{|v| (v & 0b11_001_111) == 0b11_000_101}
      push_rp
    when lambda{|v| (v & 0b11_001_111) == 0b11_000_001}
      pop_rp
    when lambda{|v| (v & 0b11_001_111) == 0b00_001_001}
      dad_rp
    when lambda{|v| (v & 0b11_001_111) == 0b00_000_011}
      inx_rp
    when lambda{|v| (v & 0b11_001_111) == 0b00_001_011}
      dcx_rp

    when lambda{|v| (v & 0b11_000_111) == 0b00_000_110}
      mvi_r_i
    when lambda{|v| (v & 0b11_000_111) == 0b00_000_100}
      inr_r
    when lambda{|v| (v & 0b11_000_111) == 0b00_000_101}
      dcr_r
    when lambda{|v| (v & 0b11_000_111) == 0b11_000_111}
      rst

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
    when lambda{|v| (v & 0b11_111_000) == 0b11_100_000}
      ani_i
    when lambda{|v| (v & 0b11_111_000) == 0b11_101_000}
      xri_i
    when lambda{|v| (v & 0b11_111_000) == 0b11_110_000}
      ori_i
    when lambda{|v| (v & 0b11_111_000) == 0b10_111_000}
      cmp_r

    when lambda{|v| (v & 0b11_000_000) == 0b01_000_000}
      mov_r_r
    
    end

    if @interrupt_pending && @interrupt_pending >= 1
      @interrupt_enable = true
      @interrupt_pending = nil
    end


  end


  # --- execute command

  def add_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    a = read_r(REG_A)
    b = read_r(s)
    write_r REG_A, a + b, (a & 0xf) + (b & 0xf), FLGS_ALL
    if reg_m? s
      @state += 7
    else
      @state += 4
    end
  end

  def adc_r
    v = @mem[@pc]; @pc += 1
    c = flg_cy? ? 1 : 0
    s = src_r v
    a = read_r(REG_A)
    b = read_r(s)
    write_r REG_A, a + b + c, (a & 0xf) + (b & 0xf) + c, FLGS_ALL
    if reg_m? s
      @state += 7
    else
      @state += 4
    end
  end

  def adi_i
    @pc += 1
    i = @mem[@pc]; @pc += 1
    a = read_r(REG_A)
    write_r REG_A, a + i, (a & 0xf) + (i & 0xf), FLGS_ALL
    @state += 7
  end

  def aci_i
    @pc += 1
    i = @mem[@pc]; @pc += 1
    c = flg_cy? ? 1 : 0
    a = read_r(REG_A)
    write_r REG_A, a + i + c, (a & 0xf) + (i & 0xf) + c, FLGS_ALL
    @state += 7
  end

  def sub_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    a = read_r(REG_A)
    b = read_r(s)
    write_r REG_A, a - b, (a & 0xf) - (b & 0xf), FLGS_ALL
    if reg_m? s
      @state += 7
    else
      @state += 4
    end
  end

  def sbb_r
    v = @mem[@pc]; @pc += 1
    c = flg_cy? ? 1 : 0
    s = src_r v
    a = read_r(REG_A)
    b = read_r(s)
    write_r REG_A, a - b - c, (a & 0xf) - (b & 0xf) - c, FLGS_ALL
    if reg_m? s
      @state += 7
    else
      @state += 4
    end
  end

  def cmp_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    a = read_r(REG_A)
    b = read_r(s)
    write_r REG_NONE, a - b, (a & 0xf) - (b & 0xf), FLGS_ALL
    if reg_m? s
      @state += 7
    else
      @state += 4
    end
  end

  def cpi_i
    @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    i = @mem[h << 8 | l]
    a = read_r(REG_A)
    write_r REG_NONE, a - i, (a & 0xf) - (i & 0xf), FLGS_ALL
    @state += 7
  end
  

  def sui_i
    @pc += 1
    i = @mem[@pc]; @pc += 1
    a = read_r(REG_A)
    write_r REG_A, a - i, (a & 0xf) - (i & 0xf), FLGS_ALL
    @state += 7
  end

  def sbi_i
    @pc += 1
    i = @mem[@pc]; @pc += 1
    c = flg_cy? ? 1 : 0
    a = read_r(REG_A)
    write_r REG_A, a - i - c, (a & 0xf) - (i & 0xf) - c, FLGS_ALL
    @state += 7
  end

  def dad_rp
    v = @mem[@pc]; @pc += 1
    r = (v >> 4) & 0x03
    case r
    when REG_PAIR_BC
      self.hl += self.bc
    when REG_PAIR_DE
      self.hl += self.de
    when REG_PAIR_HL
      self.hl += self.hl
    when REG_PAIR_SP
      self.hl += @sp
    end
    self.flg_cy = (self.hl & 0xffff0000) != 0
    self.hl &= 0xffff
    @state += 10
  end

  def daa
    @pc += 1
    v = @a
    if (v & 0x0f) > 9 || flg_ac?
      v += 6
    end
    if (v & 0xf0) > 0x90 || flg_cy?
      v += 0x60
      self.flg_cy = true
    end
    write_r REG_A, v, 0, FLGS_ALL
    @state += 4
  end

  def dcr_r
    v = @mem[@pc]; @pc += 1
    d = dst_r v
    a = read_r(d)
    write_r d, a - 1, (a & 0xf) - 1, FLGS_S_Z_AC_P
    if reg_m? d
      @state += 10
    else
      @state += 5
    end
  end

  def inr_r
    v = @mem[@pc]; @pc += 1
    d = dst_r v
    a = read_r(d)
    write_r d, a + 1, (a & 0xf) + 1, FLGS_S_Z_AC_P
    if reg_m? d
      @state += 10
    else
      @state += 5
    end
  end

  def inx_rp
    v = @mem[@pc]; @pc += 1
    r = (v >> 4) & 0x03
    case r
    when REG_PAIR_BC
      self.bc += 1
    when REG_PAIR_DE
      self.de += 1
    when REG_PAIR_HL
      self.hl += 1
    when REG_PAIR_SP
      @sp += 1
    end
    @state += 5
  end

  def dcx_rp
    v = @mem[@pc]; @pc += 1
    r = (v >> 4) & 0x03
    case r
    when REG_PAIR_BC
      self.bc -= 1
    when REG_PAIR_DE
      self.de -= 1
    when REG_PAIR_HL
      self.hl -= 1
    when REG_PAIR_SP
      @sp -= 1
    end
    @state += 5
  end

  def cma
    @pc += 1
    @a = ~@a & 0xff
    @state += 4
  end

  def ana_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    write_r REG_A, read_r(REG_A) & read_r(s), 0, FLGS_ALL
    if reg_m? s
      @state += 7
    else
      @state += 4
    end
  end

  def ani_i
    @pc += 1
    i = @mem[@pc]; @pc += 1
    write_r REG_A, read_r(REG_A) & i, 0, FLGS_ALL
    @state += 7
  end

  def xra_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    write_r REG_A, read_r(REG_A) ^ read_r(s), 0, FLGS_ALL
    if reg_m? s
      @state += 7
    else
      @state += 4
    end
  end

  def xri_i
    @pc += 1
    i = @mem[@pc]; @pc += 1
    write_r REG_A, read_r(REG_A) ^ i, 0, FLGS_ALL
    @state += 7
  end

  def ora_r
    v = @mem[@pc]; @pc += 1
    s = src_r v
    write_r REG_A, read_r(REG_A) | read_r(s), 0, FLGS_ALL
    if reg_m? s
      @state += 7
    else
      @state += 4
    end
  end

  def ori_i
    @pc += 1
    i = @mem[@pc]; @pc += 1
    write_r REG_A, read_r(REG_A) | i, 0, FLGS_ALL
    @state += 7
  end

  def rlc
    @pc += 1
    v = read_r(REG_A) << 1
    c = v & 0x100 != 0 ? 1 : 0
    v = v | c
    write_r REG_A, v, 0, FLGS_ALL
    @state += 4
  end

  def ral
    @pc += 1
    c = flg_cy? ? 1 : 0
    v = read_r(REG_A) << 1
    v = v | c
    write_r REG_A, v, 0, FLGS_ALL
    @state += 4
  end

  def rrc
    @pc += 1
    v = read_r(REG_A) 
    c = v & 0x01 != 0 ? 0x180 : 0
    v = (v >> 1) | c
    write_r REG_A, v, 0, FLGS_ALL
    @state += 4
  end

  def rar
    @pc += 1
    v = read_r(REG_A)
    c = (flg_cy? ? 0x80 : 0) | (v & 0x01 != 0 ? 0x100 : 0)
    v = (v >> 1) | c
    write_r REG_A, v, 0, FLGS_ALL
    @state += 4
  end

  def mvi_r_i
    v = @mem[@pc]; @pc += 1
    i = @mem[@pc]; @pc += 1
    d = dst_r v
    write_r d, i, 0
    if reg_m? d
      @state += 10
    else
      @state += 7
    end
  end

  def mov_r_r
    v = @mem[@pc]; @pc += 1
    d = dst_r v
    s = src_r v
    write_r d, read_r(s), 0
    if reg_m?(d) || reg_m?(s)
      @state += 7
    else
      @state += 4
    end
  end

  def lxi_r_i
    v = @mem[@pc]; @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    r = (v >> 4) & 0x03
    case r
    when REG_PAIR_BC
      @b = h; @c = l
    when REG_PAIR_DE
      @d = h; @e = l
    when REG_PAIR_HL
      @h = h; @l = l
    when REG_PAIR_SP
      @sp = h << 8 | l
    end
    @state += 10
  end

  def sta_i
    @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    @mem[h << 8 | l] = @a
    @state += 13
  end

  def lda_i
    @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    @a = @mem[h << 8 | l]
    @state += 13
  end

  def stax_rp
    v = @mem[@pc]; @pc += 1
    r = (v >> 4) & 0x03
    case r
    when REG_PAIR_BC
      @mem[bc] = @a
    when REG_PAIR_DE
      @mem[de] = @a
    end
    @state += 7
  end

  def ldax_rp
    v = @mem[@pc]; @pc += 1
    r = (v >> 4) & 0x03
    case r
    when REG_PAIR_BC
      @a = @mem[bc]
    when REG_PAIR_DE
      @a = @mem[de]
    end
    @state += 7
  end

  def shld_i
    @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    adr = h << 8 | l
    @mem[adr] = @l
    @mem[adr + 1] = @h
    @state += 16
  end

  def lhld_i
    @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    adr = h << 8 | l
    @l = @mem[adr]
    @h = @mem[adr + 1]
    @state += 16
  end

  def xchg
    @pc += 1
    t = self.de
    self.de = self.hl
    self.hl = t
    @state += 4
  end

  def xthl
    @pc += 1
    t = pop_i16
    push_i16 self.hl
    self.hl = t
    @state += 18
  end

  def sphl
    @pc += 1
    @sp = self.hl
    @state += 5
  end

  def pchl
    @pc += 1
    @pc = self.hl
    @state += 5
  end

  def jmp_i
    @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    @pc = h << 8 | l
    @state += 10
  end

  def jmp_cond cond
    @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    @pc = h << 8 | l if cond
    @state += 10
  end

  def jc_i ; jmp_cond flg_cy? ; end
  def jnc_i; jmp_cond !flg_cy?; end
  def jz_i ; jmp_cond flg_z? ; end
  def jnz_i; jmp_cond !flg_z?; end
  def jp_i ; jmp_cond !flg_s?; end
  def jm_i ; jmp_cond flg_s? ; end
  def jpe_i; jmp_cond flg_p?; end
  def jpo_i; jmp_cond !flg_p? ; end

  def call_i
    @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    push_i16 @pc
    @pc = h << 8 | l
    @state += 17
  end

  def call_cond cond
    @pc += 1
    l = @mem[@pc]; @pc += 1
    h = @mem[@pc]; @pc += 1
    if cond
      push_i16 @pc
      @pc = h << 8 | l
      @state += 17
    else
      @state += 11
    end
  end

  def cc_i ; call_cond flg_cy? ; end
  def cnc_i; call_cond !flg_cy?; end
  def cz_i ; call_cond flg_z? ; end
  def cnz_i; call_cond !flg_z?; end
  def cm_i ; call_cond flg_s? ; end
  def cp_i ; call_cond !flg_s?; end
  def cpe_i; call_cond flg_p? ; end
  def cpo_i; call_cond !flg_p?; end

  def ret
    @pc = pop_i16
    @state += 10
  end

  def ret_cond cond
    if cond
      @pc = pop_i16
      @state += 11
    else
      @pc += 1
      @state += 5
    end
  end

  def rc ; ret_cond flg_cy? ; end
  def rnc; ret_cond !flg_cy?; end
  def rz ; ret_cond flg_z? ; end
  def rnz; ret_cond !flg_z?; end
  def rm ; ret_cond flg_s? ; end
  def rp ; ret_cond !flg_s?; end
  def rpe; ret_cond flg_p? ; end
  def rpo; ret_cond !flg_p?; end

  # If execcute it in interrupt, call it with vector no.
  def rst vect = nil
    if vect
      v = b011_000_111 | (vect << 3)
    else
      v = @mem[@pc]; @pc += 1
    end
    push_i16 @pc
    v = ((v >> 3) & 0x07) << 3
    @pc = v
    @state += 11
  end

  def push_rp
    v = @mem[@pc]; @pc += 1
    r = (v >> 4) & 0x03
    case r
    when REG_PAIR_BC
      push_i16 bc
    when REG_PAIR_DE
      push_i16 de
    when REG_PAIR_HL
      push_i16 hl
    when REG_PAIR_PSW
      push_i16 psw
    end
    @state += 11
  end

  def pop_rp
    v = @mem[@pc]; @pc += 1
    r = (v >> 4) & 0x03
    case r
    when REG_PAIR_BC
      self.bc = pop_i16
    when REG_PAIR_DE
      self.de = pop_i16
    when REG_PAIR_HL
      self.hl = pop_i16
    when REG_PAIR_PSW
      self.psw = pop_i16
    end
    @state += 10
  end

  def push_i8 i8
    @sp = (@sp - 1) & 0xffff
    @mem[@sp] = i8
  end

  def push_i16 i16
   push_i8 i16 >> 8
   push_i8 i16 & 0xff
  end

  def pop_i8
    v = @mem[@sp]
    @sp = (@sp + 1) & 0xffff
    v
  end

  def pop_i16
    l = pop_i8
    h = pop_i8
    h << 8 | l
  end

  def stc
    @pc += 1
    self.flg_cy = true
    @state += 4
  end

  def cmc
    @pc += 1
    self.flg_cy = !self.flg_cy?
    @state += 4
  end

  def in_i
    @pc += 1
    port = @mem[@pc]; @pc += 1
    @a = @io_delegate.in port if @io_delegate
    @state += 10
  end

  def out_i
    @pc += 1
    port = @mem[@pc]; @pc += 1
    @io_delegate.out port, @a if @io_delegate
    @state += 10
  end

  def nop
    @pc += 1
    @state += 4
  end

  def ei
    @pc += 1
    @interrupt_pending = 0
    @state += 4
  end

  def di
    @pc += 1
    @interrupt_enable = false
    @interrupt_pending = nil
    @state += 4
  end

  def hlt
    @state += 7
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

  def write_r r, v, hv, set_f = FLGS_NONE
    v8 = v & 0xff

    self.flg_s = (v8 & FLG_S) == FLG_S  if set_f & FLG_S != 0
    self.flg_z = (v8 == 0)              if set_f & FLG_Z != 0
    self.flg_cy = (v & 0xff00) != 0     if set_f & FLG_CY != 0
            
    # odd parity
    bits = v8
    bits = (bits & 0x55) + (bits >> 1 & 0x55);
    bits = (bits & 0x33) + (bits >> 2 & 0x33);
    bits = (bits & 0x0f) + (bits >> 4 & 0x0f);
    self.flg_p = (bits & 0x01) == 0     if set_f & FLG_P != 0

    # ac
    self.flg_ac = (hv & 0xf0) != 0      if set_f & FLG_AC != 0

  case r
    when REG_A, REG_NONE
      @a = v8 if r == REG_A
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

if $0 == __FILE__
  cpu = I8080.new
  cpu.mem[0] = 0b01_110_110
  p cpu.mem[0].to_s(2).rjust(8, '0')
end
