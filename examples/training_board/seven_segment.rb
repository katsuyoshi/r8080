class SevenSegment

  attr_accessor :buf

  def initialize
    @buf = Array.new(3) { Array.new(4, ' ') }
  end

  def seg=(val)
    # a
    @buf[0][1] = val[0] == 0 ? ' ' : '_'
    # b
    @buf[1][2] = val[1] == 0 ? ' ' : '|'
    # c
    @buf[2][2] = val[2] == 0 ? ' ' : '|'
    # d
    @buf[2][1] = val[3] == 0 ? ' ' : '_'
    # e
    @buf[2][0] = val[4] == 0 ? ' ' : '|'
    # f
    @buf[1][0] = val[5] == 0 ? ' ' : '|'
    # g
    @buf[1][1] = val[6] == 0 ? ' ' : '_'
    # dp
    @buf[2][3] = val[7] == 0 ? ' ' : '.'
  end

  def puts delimiter = ""
    @buf.each do |row|
      Kernel.puts row.join + delimiter
    end
  end

end

class SevenSegmentDisplay

  def initialize
    @segs = Array.new(8) { SevenSegment.new }
  end

  def []=(i, val)
    @segs[i].seg = val
  end

  def puts delimiter = ""
    print delimiter
    3.times do |i|
      s = ''
      @segs.each do |seg|
        s << seg.buf[i].join
      end
      Kernel.puts s + delimiter
    end
  end

end
