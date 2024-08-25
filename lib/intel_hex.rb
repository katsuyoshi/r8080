class IntelHex

  attr_reader :filename
  attr_reader :data

  def initialize filename, data = []
    @filename = filename
    @data = data || []
  end

  def load
    @data = []
    File.open(@filename, "r") do |f|
      f.each_line do |line|
        line = line.chomp
        next if line.empty?
        raise "Invalid Intel Hex format" unless line[0] == ":"
        size = line[1..2].to_i(16)
        addr = line[3..6].to_i(16)

        case line[7..8]
        when "00"
          @data[addr, size] = line[9..-3].scan(/../).map { |x| x.to_i(16) }
        when "01"
          break
        else
          raise "Invalid Intel Hex format"
        end
      end
    end
  end

  def save(ranges = {})
    File.open(@filename, "w") do |f|
      ranges.each do |range|
        addr = range[0]
        size = range[1]
        (0...size).each_slice(16) do |slice|
          sum = 0
          s = slice.size
          f.write(":")
          f.write(s.to_s(16).upcase.rjust(2, "0"));     sum += s
          f.write(addr.to_s(16).upcase.rjust(4, "0"));  sum += addr >> 8; sum += addr & 0xFF
          f.write("00");                                  sum += 0
          d = @data[addr, s]
          f.write(d.map { |x| (x || 0).to_s(16).upcase.rjust(2, "0") }.join)
          sum = d.inject(sum) { |sum, x| sum + x }
          f.write((0x100 - (sum & 0xFF)).to_s(16).upcase.rjust(2, "0"))
          f.write("\n")
          addr += s
        end
      end
      f.write(":00000001FF\n")
    end
  end

end
