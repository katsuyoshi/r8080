require 'test/unit'
require 'intel_hex'

class TestIntelHex < Test::Unit::TestCase

  setup do
    @data = (0...0x100).to_a
    @hex = IntelHex.new "test.hex", @data
  end

  teardown do
    File.delete "test.hex"
  end

  test "save" do
    @hex.save(0 => 0x100)
    assert_equal File.read("test.hex"), 
    ":10000000000102030405060708090A0B0C0D0E0F78\n" +
    ":10001000101112131415161718191A1B1C1D1E1F68\n" +
    ":10002000202122232425262728292A2B2C2D2E2F58\n" +
    ":10003000303132333435363738393A3B3C3D3E3F48\n" +
    ":10004000404142434445464748494A4B4C4D4E4F38\n" +
    ":10005000505152535455565758595A5B5C5D5E5F28\n" +
    ":10006000606162636465666768696A6B6C6D6E6F18\n" +
    ":10007000707172737475767778797A7B7C7D7E7F08\n" +
    ":10008000808182838485868788898A8B8C8D8E8FF8\n" +
    ":10009000909192939495969798999A9B9C9D9E9FE8\n" +
    ":1000A000A0A1A2A3A4A5A6A7A8A9AAABACADAEAFD8\n" +
    ":1000B000B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC8\n" +
    ":1000C000C0C1C2C3C4C5C6C7C8C9CACBCCCDCECFB8\n" +
    ":1000D000D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFA8\n" +
    ":1000E000E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF98\n" +
    ":1000F000F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF88\n" +
    ":00000001FF\n"
  end

  test "load" do
    @hex.save(0 => 0x100)
    @hex.load
    assert_equal @data, @hex.data
  end

end


class TestIntelHexChecksum < Test::Unit::TestCase

  setup do
    @data = [0] * 0x2000
    @hex = IntelHex.new "test.hex", @data
  end

  teardown do
    File.delete "test.hex"
  end

  test "save" do
    @hex.save(0x10e0 => 0x10)
    assert_equal File.read("test.hex"), 
    ":1010E0000000000000000000000000000000000000\n" +
    ":00000001FF\n"
  end

end
