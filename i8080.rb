# ref http://www.st.rim.or.jp/~nkomatsu/intel8bit/i8080.html
class I8080

  attr_accessor :a, :f, :b, :c, :d, :e, :h, :l, :pc, :sp
  attr_reader :mem

  def initialize
    @mem = [0] * 64 * 1024
    @a = 0; @f = 0; @b = 0; @c = 0; @d = 0; @e = 0; @h = 0; @l = 0; @pc = 0; @sp = 0
  end

  def run cycle=-1
    loop do

      fetch
      dump_regs

      cycle -= 1 if cycle > 0
      break if cycle == 0
    end
  end

  private

  def fetch
  end

  def bc; b << 8 | c; end
  def de; d << 8 | e; end
  def hl; h << 8 | l; end

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
