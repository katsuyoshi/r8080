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

  def bc; @b << 8 | @c; end
  def de; @d << 8 | @e; end
  def hl; @h << 8 | @l; end

  private

  def fetch

    case @mem[@pc]
    when lambda{|v| (v & 0b01000000) == 0b01000000}
      mov_rm_r
    end

  end

  def model_af?
    @model == "uPD8080AF"
  end

  def mov_rm_r
    v = @mem[pc]
    rm = (v & 0b00111000) >> 3
    r = v & 0b111
    write_rm rm, read_r(r)
    @pc += 1
    if (rm == 6) || (r == 6)
      @clock += 7
    else
      @clock += model_af? ? 5 : 4
    end
  end

  def read_r r
    throw "M is not permitted." if r == 6
    read_rm r
  end

  def write_r r, v
    throw "M is not permitted." if r == 6
    write_rm r, v
  end

  def read_rm r
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

  def write_rm r, v
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
p @mem, hl, v
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
