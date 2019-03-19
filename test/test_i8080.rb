require 'test/unit'
require 'i8080'

class TestI8080 < Test::Unit::TestCase

  setup do
    @cpu = I8080.new
  end

  test "HLT" do
      @cpu.mem[0] = 0b01_110_110
      @cpu.run 1
      assert_equal 0, @cpu.pc
      assert_equal 7, @cpu.clock
  end

end
