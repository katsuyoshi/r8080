require 'test/unit'
require 'i8080'

class TestI8080 < Test::Unit::TestCase

  setup do
    @cpu = I8080.new
  end

  sub_test_case "INR   r" do

    test "INR A" do
      @cpu.mem[0] = 0b00_111_100
      @cpu.run 1
      assert_equal 1, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "INR M" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0] = 0b00_110_100
      @cpu.run 1
      assert_equal 1, @cpu.mem[0x8000]
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.clock
    end

  end


  test "HLT" do
    @cpu.mem[0] = 0b01_110_110
    @cpu.run 1
    assert_equal 0, @cpu.pc
    assert_equal 7, @cpu.clock
  end

end
