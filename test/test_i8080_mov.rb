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
      assert_equal 4, @cpu.state
    end

    test "MOV A, B" do
      @cpu.mem[0] = 0b01111000
      @cpu.run 1
      assert_equal 0x22, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV A, C" do
      @cpu.mem[0] = 0b01111001
      @cpu.run 1
      assert_equal 0x33, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV A, D" do
      @cpu.mem[0] = 0b01111010
      @cpu.run 1
      assert_equal 0x44, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV A, E" do
      @cpu.a = 0x55
      @cpu.mem[0] = 0b01111011
      @cpu.run 1
      assert_equal 0x55, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV A, H" do
      @cpu.mem[0] = 0b01111100
      @cpu.run 1
      assert_equal 0x66, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV A, L" do
      @cpu.mem[0] = 0b01111101
      @cpu.run 1
      assert_equal 0x77, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV A, M" do
      @cpu.h = 0; @cpu.l = 0
      @cpu.mem[0] = 0b01111110
      @cpu.run 1
      assert_equal 0b01111110, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.state
    end


    test "MOV B, A" do
      @cpu.mem[0] = 0b01000111
      @cpu.run 1
      assert_equal 0x11, @cpu.b
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV C, A" do
      @cpu.mem[0] = 0b01001111
      @cpu.run 1
      assert_equal 0x11, @cpu.c
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV D, A" do
      @cpu.mem[0] = 0b01010111
      @cpu.run 1
      assert_equal 0x11, @cpu.d
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV E, A" do
      @cpu.mem[0] = 0b01011111
      @cpu.run 1
      assert_equal 0x11, @cpu.e
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV H, A" do
      @cpu.mem[0] = 0b01100111
      @cpu.run 1
      assert_equal 0x11, @cpu.h
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV L, A" do
      @cpu.mem[0] = 0b01101111
      @cpu.run 1
      assert_equal 0x11, @cpu.l
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

    test "MOV M, A" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0] = 0b01110111
      @cpu.run 1
      assert_equal 0x11, @cpu.mem[0x8000]
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.state
    end


  end

  sub_test_case "MVI   r imm" do

    test "MVI A, 0x12" do
      @cpu.mem[0] = 0b00_111_110
      @cpu.mem[1] = 0x12
      @cpu.run 1
      assert_equal 0x12, @cpu.a
      assert_equal 2, @cpu.pc
      assert_equal 7, @cpu.state
    end

    test "MVI M, 0x12" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0] = 0b00_110_110
      @cpu.mem[1] = 0x12
      @cpu.run 1
      assert_equal 0x12, @cpu.mem[0x8000]
      assert_equal 2, @cpu.pc
      assert_equal 10, @cpu.state
    end

  end

  sub_test_case "LXI   r imm" do

    test "LXI B, 0x1234" do
      @cpu.mem[0] = 0b00_000_001
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x12, @cpu.b
      assert_equal 0x34, @cpu.c
      assert_equal 3, @cpu.pc
      assert_equal 10, @cpu.state
    end

    test "LXI D, 0x2345" do
      @cpu.mem[0] = 0b00_010_001
      @cpu.mem[1] = 0x45
      @cpu.mem[2] = 0x23
      @cpu.run 1
      assert_equal 0x23, @cpu.d
      assert_equal 0x45, @cpu.e
      assert_equal 3, @cpu.pc
      assert_equal 10, @cpu.state
    end

    test "LXI H, 0x3456" do
      @cpu.mem[0] = 0b00_100_001
      @cpu.mem[1] = 0x56
      @cpu.mem[2] = 0x34
      @cpu.run 1
      assert_equal 0x34, @cpu.h
      assert_equal 0x56, @cpu.l
      assert_equal 3, @cpu.pc
      assert_equal 10, @cpu.state
    end

    test "LXI SP, 0x4567" do
      @cpu.mem[0] = 0b00_110_001
      @cpu.mem[1] = 0x67
      @cpu.mem[2] = 0x45
      @cpu.run 1
      assert_equal 0x4567, @cpu.sp
      assert_equal 10, @cpu.state
    end

  end

  sub_test_case "STA   imm" do

    test "STA 8000" do
      @cpu.mem[0] = 0b00_110_010
      @cpu.mem[1] = 0x00
      @cpu.mem[2] = 0x80
      @cpu.a = 0x12
      @cpu.run 1
      assert_equal 0x12, @cpu.mem[0x8000]
      assert_equal 3, @cpu.pc
      assert_equal 13, @cpu.state
    end

  end

  sub_test_case "LDA   imm" do

    test "LDA 8000" do
      @cpu.mem[0] = 0b00_111_010
      @cpu.mem[1] = 0x00
      @cpu.mem[2] = 0x80
      @cpu.mem[0x8000] = 0x12
      @cpu.run 1
      assert_equal 0x12, @cpu.a
      assert_equal 3, @cpu.pc
      assert_equal 13, @cpu.state
    end

  end

  sub_test_case "XCHG" do

    test "XCHG" do
      @cpu.mem[0] = 0b11_101_011
      @cpu.h = 0x12
      @cpu.l = 0x34
      @cpu.d = 0x56
      @cpu.e = 0x78
      @cpu.run 1
      assert_equal 0x56, @cpu.h
      assert_equal 0x78, @cpu.l
      assert_equal 0x12, @cpu.d
      assert_equal 0x34, @cpu.e
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

  end

  sub_test_case "PCHL" do

    test "PCHL" do
      @cpu.mem[0] = 0b11_101_001
      @cpu.h = 0x12
      @cpu.l = 0x34
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 5, @cpu.state
    end

  end

  sub_test_case "STAX   rp" do

    test "STAX B" do
      @cpu.mem[0] = 0b00_000_010
      @cpu.b = 0x12
      @cpu.c = 0x34
      @cpu.a = 0x56
      @cpu.run 1
      assert_equal 0x56, @cpu.mem[0x1234]
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.state
    end

    test "STAX D" do
      @cpu.mem[0] = 0b00_010_010
      @cpu.d = 0x12
      @cpu.e = 0x34
      @cpu.a = 0x56
      @cpu.run 1
      assert_equal 0x56, @cpu.mem[0x1234]
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.state
    end

  end

  sub_test_case "LDAX   rp" do

    test "LDAX B" do
      @cpu.mem[0] = 0b00_001_010
      @cpu.b = 0x12
      @cpu.c = 0x34
      @cpu.mem[0x1234] = 0x56
      @cpu.run 1
      assert_equal 0x56, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.state
    end

    test "LDAX D" do
      @cpu.mem[0] = 0b00_011_010
      @cpu.d = 0x12
      @cpu.e = 0x34
      @cpu.mem[0x1234] = 0x56
      @cpu.run 1
      assert_equal 0x56, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.state
    end

  end

  sub_test_case "STC" do

    test "STC" do
      @cpu.mem[0] = 0b00_110_111
      @cpu.run 1
      assert_equal true, @cpu.flg_cy?
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state
    end

  end

  sub_test_case "CMC" do

    test "CMC" do
      @cpu.mem[0] = 0b00_111_111
      @cpu.run 1
      assert_equal true, @cpu.flg_cy?
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.state

      @cpu.mem[1] = 0b00_111_111
      @cpu.run 1
      assert_equal false, @cpu.flg_cy?
      assert_equal 2, @cpu.pc
      assert_equal 8, @cpu.state
    end

  end

  sub_test_case "SHLD   imm" do
      
    test "SHLD 8000" do
      @cpu.mem[0] = 0b00_100_010
      @cpu.mem[1] = 0x00
      @cpu.mem[2] = 0x80
      @cpu.h = 0x12
      @cpu.l = 0x34
      @cpu.run 1
      assert_equal 0x34, @cpu.mem[0x8000]
      assert_equal 0x12, @cpu.mem[0x8001]
      assert_equal 3, @cpu.pc
      assert_equal 16, @cpu.state
    end
  
  end

  sub_test_case "LHLD   imm" do
      
    test "LHLD 8000" do
      @cpu.mem[0] = 0b00_101_010
      @cpu.mem[1] = 0x00
      @cpu.mem[2] = 0x80
      @cpu.mem[0x8000] = 0x34
      @cpu.mem[0x8001] = 0x12
      @cpu.run 1
      assert_equal 0x12, @cpu.h
      assert_equal 0x34, @cpu.l
      assert_equal 3, @cpu.pc
      assert_equal 16, @cpu.state
    end

  end

end
