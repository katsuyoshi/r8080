require 'test/unit'
require 'i8080'

class TestI8080 < Test::Unit::TestCase

  setup do
    @cpu = I8080.new
  end

  sub_test_case "flags" do

    test "ADD A (0x80 + 0x80) -> z p cy" do
      @cpu.a = 0x80
      @cpu.mem[0] = 0b10_000_111
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_1, @cpu.f
    end

    test "ADD B (0x80 + 0x00) -> s ac" do
      @cpu.a = 0x80
      @cpu.b = 0x00
      @cpu.mem[0] = 0b10_000_000
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_0_1_0, @cpu.f
    end

    test "INR A (0xff + 0x01) -> z ac cy" do
      @cpu.a = 0xff
      @cpu.mem[0] = 0b00_111_100
      @cpu.run 1
      assert_equal 0b01_0_1_0_1_1_1, @cpu.f
    end

    test "DCR A from 1 (0x01 - 0x01) -> z p" do
      @cpu.a = 0x01
      @cpu.mem[0] = 0b00_111_101
      @cpu.run 1
      assert_equal 0b01_0_0_0_1_1_0, @cpu.f
    end

    test "DCR A from 0 (0x01 - 0x1) -> z ac p cy" do
      @cpu.a = 0x00
      @cpu.mem[0] = 0b00_111_101
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_1_1_1, @cpu.f
    end


  end


end
