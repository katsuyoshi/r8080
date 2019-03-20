# ref http://www.st.rim.or.jp/~nkomatsu/intel8bit/i8080.html
class I8080

  attr_accessor :a, :f, :b, :c, :d, :e, :h, :l, :pc, :sp
  attr_accessor :clock
  attr_reader :mem, :model

  def initialize options={}
    @model = options[:model] || "uPD8080A" # or uPD8080AF
    @mem = [0] * 64 * 1024
    @a = 0; @f = 0; @b = 0; @c = 0; @d = 0; @e = 0; @h = 0; @l = 0; @pc = 0; @sp = 0
    @clock = 0
  end

  def run cycle=-1
    loop do

      fetch
      #dump_regs

      cycle -= 1 if cycle > 0
      break if cycle == 0
    end
  end

  def psw; @a << 8 | @f; end
  def bc; @b << 8 | @c; end
  def de; @d << 8 | @e; end
  def hl; @h << 8 | @l; end

  private

  def model_af?
    @model == "uPD8080AF"
  end

  def reg_m? v
    v == 6
  end


  def fetch

    case @mem[@pc]
    when 0b01_110_110
      hlt
    when lambda{|v| (v & 0b01_000_000) == 0b01_000_000}
      mov_r_r
    when lambda{|v| (v & 0b00_000_110) == 0b00_000_110}
      mvi_r_i
    end

  end

  def mvi_r_i
    v = @mem[@pc]; @pc += 1
    i = @mem[@pc]; @pc += 1
    d = (v & 0b00_111_000) >> 3
    write_r d, i
    if reg_m? d
      @clock += 10
    else
      @clock += 7
    end
  end

  def mov_r_r
    v = @mem[@pc]; @pc += 1
    d = (v & 0b00_111_000) >> 3
    s = v & 0b00_000_111
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

  def read_r r
    case r
    when 7
      @a
    when 0
      @b
    when 1
      @c
    when 2
      @d
    when 3
      @e
    when 4
      @h
    when 5
      @l
    when 6
      @mem[hl]
    end
  end

  def write_r r, v
    case r
    when 7
      @a = v
    when 0
      @b = v
    when 1
      @c = v
    when 2
      @d = v
    when 3
      @e = v
    when 4
      @h = v
    when 5
      @l = v
    when 6
      @mem[hl] = v
    end
  end

  def dump_regs
    now = Time.now
    if @dump_regs_at.nil? || (now - @dump_regs_at >= 1)
      puts if @dump_regs_at.nil?
      print "\n\e[2A"
      %w(A F B C D E H L).zip([a, f, b, c, d, e, h, l]).each do |n, v|
        print "#{n}:#{v.to_s(16).rjust(2, '0')} "
      end
      print "\n"
      %w(BC DE HL PC SP).zip([bc, de, hl, pc, sp]).each do |n, v|
        print "#{n}:#{v.to_s(16).rjust(4, '0')} "
      end
    end
    @dump_regs_at = now
  end

end

I8080.new.run if $0 == __FILE__
