require 'test/unit'
require 'i8080'

class TestI8080 < Test::Unit::TestCase

  def setup
    @cpu = I8080.new
  end

  sub_test_case "ADD   r" do

    setup do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.a = 0x12
      @cpu.mem[0x8000] = 0x23
    end

    test "ADD A" do
      @cpu.mem[0] = 0b10_000_111
      @cpu.run 1
      assert_equal 0x24, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADD M" do
      @cpu.mem[0] = 0b10_000_110
      @cpu.run 1
      assert_equal 0x35, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end

  sub_test_case "DCR   r" do

    setup do
      @cpu.h = 0x80; @cpu.l = 0
    end

    test "DCR A" do
      @cpu.mem[0] = 0b00_111_101
      @cpu.run 1
      assert_equal 0xff, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "DCR M" do
      @cpu.mem[0] = 0b00_110_101
      @cpu.run 1
      assert_equal 0xff, @cpu.mem[0x8000]
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.clock
    end

  end

  sub_test_case "INR   r" do

    setup do
      @cpu.h = 0x80; @cpu.l = 0
    end

    test "INR A" do
      @cpu.mem[0] = 0b00_111_100
      @cpu.run 1
      assert_equal 1, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "INR M" do
      @cpu.mem[0] = 0b00_110_100
      @cpu.run 1
      assert_equal 1, @cpu.mem[0x8000]
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.clock
    end

  end

  test "NOP" do
    @cpu.mem[0] = 0b00_000_000
    @cpu.run 1
    assert_equal 1, @cpu.pc
    assert_equal 4, @cpu.clock
  end

  test "HLT" do
    @cpu.mem[0] = 0b01_110_110
    @cpu.run 1
    assert_equal 0, @cpu.pc
    assert_equal 7, @cpu.clock
  end

end
