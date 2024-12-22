dir = File.dirname(__FILE__)
lib_dir = File.join(dir, '../../../lib')
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'nokogiri'
require 'open-uri'
require 'intel_hex'

mm = [0] * 8 * 1024

url = 'https://computerarcheology.com/Arcade/SpaceInvaders/Code.html'
doc = Nokogiri::HTML(URI.open(url))
doc.search('.codePreStyle').each do |code|
  code.text.each_line do |line|
    case line
    when /^([0-9A-F]{4}):(.*)/i
      addr = $1.to_i(16)
      opcodes = $2.split(/\s{2,}|;/).first.scan(/[0-9A-F]{2}/i).map{|e| e.to_i(16)}
      opcodes.each_with_index do |opcode, i|
        mm[addr + i] = opcode
      end
    end
  end
end

path = File.join(dir, '..', 'rom.hex')
hex = IntelHex.new path, mm
hex.save(0 => mm.size)

path = File.join(dir, '..', 'rom.rb')
File.write(path, "@rom = [\n" + mm.each_slice(16).map{|e| "  " + e.map{|f| "0x%02X" % f}.join(',')}.join(",\n") + "\n]\n")
#s = File.read(path)
#File.write(path.gsub(/\.hex/, '.rb'), "@rom_hex = \"\n" + s + "\"\n")
