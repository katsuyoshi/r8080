require 'test/unit'
require 'i8080'

class TestI8080 < Test::Unit::TestCase

  setup do
    @cpu = I8080.new
  end

  sub_test_case "MOV   r r" do

    setup do
      @cpu.a = 0x11
      @cpu.b = 0x22
      @cpu.c = 0x33
      @cpu.d = 0x44
      @cpu.e = 0x55
      @cpu.h = 0x66
      @cpu.l = 0x77
    end

    test "MOV A, A" do
      @cpu.mem[0] = 0b01111111
      @cpu.run 1
      assert_equal 0x11, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV A, B" do
      @cpu.mem[0] = 0b01111000
      @cpu.run 1
      assert_equal 0x22, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV A, C" do
      @cpu.mem[0] = 0b01111001
      @cpu.run 1
      assert_equal 0x33, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV A, D" do
      @cpu.mem[0] = 0b01111010
      @cpu.run 1
      assert_equal 0x44, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV A, E" do
      @cpu.a = 0x55
      @cpu.mem[0] = 0b01111011
      @cpu.run 1
      assert_equal 0x55, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV A, H" do
      @cpu.mem[0] = 0b01111100
      @cpu.run 1
      assert_equal 0x66, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV A, L" do
      @cpu.mem[0] = 0b01111101
      @cpu.run 1
      assert_equal 0x77, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV A, M" do
      @cpu.h = 0; @cpu.l = 0
      @cpu.mem[0] = 0b01111110
      @cpu.run 1
      assert_equal 0b01111110, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end


    test "MOV B, A" do
      @cpu.mem[0] = 0b01000111
      @cpu.run 1
      assert_equal 0x11, @cpu.b
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV C, A" do
      @cpu.mem[0] = 0b01001111
      @cpu.run 1
      assert_equal 0x11, @cpu.c
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV D, A" do
      @cpu.mem[0] = 0b01010111
      @cpu.run 1
      assert_equal 0x11, @cpu.d
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV E, A" do
      @cpu.mem[0] = 0b01011111
      @cpu.run 1
      assert_equal 0x11, @cpu.e
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV H, A" do
      @cpu.mem[0] = 0b01100111
      @cpu.run 1
      assert_equal 0x11, @cpu.h
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV L, A" do
      @cpu.mem[0] = 0b01101111
      @cpu.run 1
      assert_equal 0x11, @cpu.l
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "MOV M, A" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0] = 0b01110111
      @cpu.run 1
      assert_equal 0x11, @cpu.mem[0x8000]
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end


  end

  sub_test_case "MVI   r imm" do

    test "MVI A, 0x12" do
      @cpu.mem[0] = 0b00_111_110
      @cpu.mem[1] = 0x12
      @cpu.run 1
      assert_equal 0x12, @cpu.a
      assert_equal 2, @cpu.pc
      assert_equal 7, @cpu.clock
    end

    test "MVI M, 0x12" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0] = 0b00_110_110
      @cpu.mem[1] = 0x12
      @cpu.run 1
      assert_equal 0x12, @cpu.mem[0x8000]
      assert_equal 2, @cpu.pc
      assert_equal 10, @cpu.clock
    end

  end

end
