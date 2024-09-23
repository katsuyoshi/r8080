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
      assert_equal 4, @cpu.state
    end

    test "ADD M" do
      @cpu.mem[0] = 0b10_000_110
      @cpu.run 1
      assert_equal 0x35, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.state
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
      assert_equal 5, @cpu.state
    end

    test "DCR M" do
      @cpu.mem[0] = 0b00_110_101
      @cpu.run 1
      assert_equal 0xff, @cpu.mem[0x8000]
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.state
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
      assert_equal 5, @cpu.state
    end

    test "INR M" do
      @cpu.mem[0] = 0b00_110_100
      @cpu.run 1
      assert_equal 1, @cpu.mem[0x8000]
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.state
    end

  end

  test "NOP" do
p "test nop #{@cpu.pc}"
    @cpu.mem[0] = 0b00_000_000
    @cpu.run 1
    assert_equal 1, @cpu.pc
p "test nop #{@cpu.pc}"
    assert_equal 4, @cpu.state
  end

  test "HLT" do
    @cpu.mem[0] = 0b01_110_110
    @cpu.run 1
    assert_equal 0, @cpu.pc
    assert_equal 7, @cpu.state
  end

  # EI enables interrupts after the next instruction is executed.
  # But the actual interrupt may be accepted during the next M1 cycle.
  # So, the interrupt is accepted after two cycles.
  test "EI" do
    @cpu.enabled_interrupt = false
    @cpu.mem[0] = 0b11_111_011
    @cpu.mem[1] = 0b00_000_000
    @cpu.mem[2] = 0b00_000_000
    @cpu.run 1
    assert_equal false, @cpu.enabled_interrupt?
    assert_equal 1, @cpu.pc
    assert_equal 4, @cpu.state
    @cpu.run 1
    assert_equal false, @cpu.enabled_interrupt?
    assert_equal 2, @cpu.pc
    assert_equal 8, @cpu.state
    @cpu.run 1
    assert_equal true, @cpu.enabled_interrupt?
    assert_equal 3, @cpu.pc
    assert_equal 12, @cpu.state
  end

  test "DI" do
    @cpu.enabled_interrupt = true
    @cpu.mem[0] = 0b11_111_011
    @cpu.mem[1] = 0b00_000_000
    @cpu.mem[2] = 0b11_110_011
    @cpu.run 2
    assert_equal true, @cpu.enabled_interrupt?
    assert_equal 2, @cpu.pc
    assert_equal 8, @cpu.state
    @cpu.run 1
    assert_equal false, @cpu.enabled_interrupt?
    assert_equal 3, @cpu.pc
    assert_equal 12, @cpu.state
  end

  test "OUT" do
    @cpu.mem[0] = 0b11_010_011
    @cpu.mem[1] = 0b00_000_000
    @cpu.a = 0x12
    @cpu.run 1
    assert_equal 0x12, @cpu.io_delegate.in(0)
    assert_equal 2, @cpu.pc
    assert_equal 10, @cpu.state
  end

  test "IN" do
    @cpu.mem[0] = 0b11_010_011
    @cpu.mem[1] = 0b00_000_000
    @cpu.mem[2] = 0b11_011_011
    @cpu.mem[3] = 0b00_000_000
    @cpu.a = 0x12
    @cpu.run 2
    assert_equal 0x12, @cpu.a
    assert_equal 4, @cpu.pc
    assert_equal 20, @cpu.state
  end


end
