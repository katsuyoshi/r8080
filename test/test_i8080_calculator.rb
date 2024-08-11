require 'test/unit'
require 'i8080'

class TestI8080 < Test::Unit::TestCase

  setup do
    @cpu = I8080.new
  end

  sub_test_case "INR   r" do

    setup do
      @cpu.a = 0x11
      @cpu.b = 0x22
      @cpu.c = 0x33
      @cpu.d = 0x44
      @cpu.e = 0x55
      @cpu.h = 0x66
      @cpu.l = 0x77
    end

    test "INR A" do
      @cpu.mem[0] = 0b00_111_100
      @cpu.run 1
      assert_equal 0x12, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "INR B" do
      @cpu.mem[0] = 0b00_000_100
      @cpu.run 1
      assert_equal 0x23, @cpu.b
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "INR C" do
      @cpu.mem[0] = 0b00_001_100
      @cpu.run 1
      assert_equal 0x34, @cpu.c
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "INR D" do
      @cpu.mem[0] = 0b00_010_100
      @cpu.run 1
      assert_equal 0x45, @cpu.d
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "INR E" do
      @cpu.mem[0] = 0b00_011_100
      @cpu.run 1
      assert_equal 0x56, @cpu.e
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "INR H" do
      @cpu.mem[0] = 0b00_100_100
      @cpu.run 1
      assert_equal 0x67, @cpu.h
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "INR L" do
      @cpu.mem[0] = 0b00_101_100
      @cpu.run 1
      assert_equal 0x78, @cpu.l
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "INR M" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0x8000] = 0x88
      @cpu.mem[0] = 0b00_110_100
      @cpu.run 1
      assert_equal 0x89, @cpu.mem[0x8000]
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.clock
    end

  end

  sub_test_case "DCR   r" do

    setup do
      @cpu.a = 0x11
      @cpu.b = 0x22
      @cpu.c = 0x33
      @cpu.d = 0x44
      @cpu.e = 0x55
      @cpu.h = 0x66
      @cpu.l = 0x77
    end

    test "DCR A" do
      @cpu.mem[0] = 0b00_111_101
      @cpu.run 1
      assert_equal 0x10, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "DCR B" do
      @cpu.mem[0] = 0b00_000_101
      @cpu.run 1
      assert_equal 0x21, @cpu.b
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "DCR C" do
      @cpu.mem[0] = 0b00_001_101
      @cpu.run 1
      assert_equal 0x32, @cpu.c
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "DCR D" do
      @cpu.mem[0] = 0b00_010_101
      @cpu.run 1
      assert_equal 0x43, @cpu.d
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "DCR E" do
      @cpu.mem[0] = 0b00_011_101
      @cpu.run 1
      assert_equal 0x54, @cpu.e
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "DCR H" do
      @cpu.mem[0] = 0b00_100_101
      @cpu.run 1
      assert_equal 0x65, @cpu.h
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "DCR L" do
      @cpu.mem[0] = 0b00_101_101
      @cpu.run 1
      assert_equal 0x76, @cpu.l
      assert_equal 1, @cpu.pc
      assert_equal 5, @cpu.clock
    end

    test "DCR M" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0x8000] = 0x88
      @cpu.mem[0] = 0b00_110_101
      @cpu.run 1
      assert_equal 0x87, @cpu.mem[0x8000]
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.clock
    end

  end

  sub_test_case "ADD   r" do

    setup do
      @cpu.a = 0x11
      @cpu.b = 0x22
      @cpu.c = 0x33
      @cpu.d = 0x44
      @cpu.e = 0x55
      @cpu.h = 0x66
      @cpu.l = 0x77
    end

    test "ADD A" do
      @cpu.mem[0] = 0b10_000_111
      @cpu.run 1
      assert_equal 0x22, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADD B" do
      @cpu.mem[0] = 0b10_000_000
      @cpu.run 1
      assert_equal 0x33, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADD C" do
      @cpu.mem[0] = 0b10_000_001
      @cpu.run 1
      assert_equal 0x44, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADD D" do
      @cpu.mem[0] = 0b10_000_010
      @cpu.run 1
      assert_equal 0x55, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADD E" do
      @cpu.mem[0] = 0b10_000_011
      @cpu.run 1
      assert_equal 0x66, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADD H" do
      @cpu.mem[0] = 0b10_000_100
      @cpu.run 1
      assert_equal 0x77, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADD L" do
      @cpu.mem[0] = 0b10_000_101
      @cpu.run 1
      assert_equal 0x88, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADD M" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0x8000] = 0x88
      @cpu.mem[0] = 0b10_000_110
      @cpu.run 1
      assert_equal 0x99, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end


  sub_test_case "ADC   r" do

    setup do
      @cpu.a = 0x11
      @cpu.b = 0x22
      @cpu.c = 0x33
      @cpu.d = 0x44
      @cpu.e = 0x55
      @cpu.h = 0x66
      @cpu.l = 0x77
    end

    test "ADC A without Carry" do
      @cpu.mem[0] = 0b10_001_111
      @cpu.run 1
      assert_equal 0x22, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADC A with Carry" do
      @cpu.mem[0] = 0b10_001_111
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0x23, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADC B without Carry" do
      @cpu.mem[0] = 0b10_001_000
      @cpu.run 1
      assert_equal 0x33, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADC B with Carry" do
      @cpu.mem[0] = 0b10_001_000
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0x34, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ADC M without Carry" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0x8000] = 0x88
      @cpu.mem[0] = 0b10_001_110
      @cpu.run 1
      assert_equal 0x99, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end

    test "ADC M with Carry" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0x8000] = 0x88
      @cpu.mem[0] = 0b10_001_110
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0x9a, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end

  sub_test_case "SUB   r" do

    setup do
      @cpu.a = 0x11
      @cpu.b = 0x22
      @cpu.c = 0x33
      @cpu.d = 0x44
      @cpu.e = 0x55
      @cpu.h = 0x66
      @cpu.l = 0x77
    end

    test "SUB A" do
      @cpu.mem[0] = 0b10_010_111
      @cpu.run 1
      assert_equal 0x00, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "SUB B" do
      @cpu.mem[0] = 0b10_010_000
      @cpu.run 1
      assert_equal 0xef, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "SUB M" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0x8000] = 0x88
      @cpu.mem[0] = 0b10_010_110
      @cpu.run 1
      assert_equal 0x89, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end

  sub_test_case "SBB   r" do

    setup do
      @cpu.a = 0x11
      @cpu.b = 0x22
      @cpu.c = 0x33
      @cpu.d = 0x44
      @cpu.e = 0x55
      @cpu.h = 0x66
      @cpu.l = 0x77
    end

    test "SBB A without Borrow" do
      @cpu.mem[0] = 0b10_011_111
      @cpu.run 1
      assert_equal 0x00, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "SBB A with Borrow" do
      @cpu.mem[0] = 0b10_011_111
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0xff, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "SBB B without Borrow" do
      @cpu.mem[0] = 0b10_011_000
      @cpu.run 1
      assert_equal 0xef, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "SBB B with Borrow" do
      @cpu.mem[0] = 0b10_011_000
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0xee, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "SBB M without Borrow" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0x8000] = 0x88
      @cpu.mem[0] = 0b10_011_110
      @cpu.run 1
      assert_equal 0x89, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end

    test "SBB M with Borrow" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0x8000] = 0x88
      @cpu.mem[0] = 0b10_011_110
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0x88, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end

  sub_test_case "ANA   r" do

    setup do
      @cpu.a = 0xff
      @cpu.b = 0x01
      @cpu.c = 0x02
      @cpu.d = 0x04
      @cpu.e = 0x10
      @cpu.h = 0x20
      @cpu.l = 0x40
      @cpu.mem[0x8000] = 0x80
    end

    test "ANA A" do
      @cpu.mem[0] = 0b10_100_111
      @cpu.run 1
      assert_equal 0xff, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ANA B" do
      @cpu.mem[0] = 0b10_100_000
      @cpu.run 1
      assert_equal 0x01, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "ANA M" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0] = 0b10_100_110
      @cpu.run 1
      assert_equal 0x80, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end

  sub_test_case "XRA   r" do

    setup do
      @cpu.a = 0x55
      @cpu.b = 0xaa
      @cpu.c = 0x02
      @cpu.d = 0x04
      @cpu.e = 0x10
      @cpu.h = 0x20
      @cpu.l = 0x40
      @cpu.mem[0x8000] = 0xff
    end

    test "XRA A" do
      @cpu.mem[0] = 0b10_101_111
      @cpu.run 1
      assert_equal 0x00, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "XRA B" do
      @cpu.mem[0] = 0b10_101_000
      @cpu.run 1
      assert_equal 0xff, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 4, @cpu.clock
    end

    test "XRA M" do
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0] = 0b10_101_110
      @cpu.run 1
      assert_equal 0xaa, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 7, @cpu.clock
    end

    sub_test_case "ORA   r" do

      setup do
        @cpu.a = 0x00
        @cpu.b = 0x01
        @cpu.c = 0x02
        @cpu.d = 0x04
        @cpu.e = 0x10
        @cpu.h = 0x20
        @cpu.l = 0x40
        @cpu.mem[0x8000] = 0x80
      end
  
      test "ORA A" do
        @cpu.mem[0] = 0b10_110_111
        @cpu.run 1
        assert_equal 0x00, @cpu.a
        assert_equal 1, @cpu.pc
        assert_equal 4, @cpu.clock
      end
  
      test "ORA B" do
        @cpu.mem[0] = 0b10_110_000
        @cpu.run 1
        assert_equal 0x01, @cpu.a
        assert_equal 1, @cpu.pc
        assert_equal 4, @cpu.clock
      end
  
      test "ORA M" do
        @cpu.h = 0x80; @cpu.l = 0
        @cpu.mem[0] = 0b10_110_110
        @cpu.run 1
        assert_equal 0x80, @cpu.a
        assert_equal 1, @cpu.pc
        assert_equal 7, @cpu.clock
      end

    end
  
  end

  sub_test_case "ADI   i" do

    setup do
      @cpu.a = 0x11
    end

    test "ADI i" do
      @cpu.mem[0] = 0b11_000_110
      @cpu.mem[1] = 0x23
      @cpu.run 1
      assert_equal 0x34, @cpu.a
      assert_equal 2, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end

  sub_test_case "ACI   i" do

    setup do
      @cpu.a = 0x11
    end

    test "ACI i without carry" do
      @cpu.mem[0] = 0b11_001_110
      @cpu.mem[1] = 0x23
      @cpu.run 1
      assert_equal 0x34, @cpu.a
      assert_equal 2, @cpu.pc
      assert_equal 7, @cpu.clock
    end

    test "ACI i with carry" do
      @cpu.mem[0] = 0b11_001_110
      @cpu.mem[1] = 0x23
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0x35, @cpu.a
      assert_equal 2, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end

  sub_test_case "SUI   i" do

    setup do
      @cpu.a = 0x23
    end

    test "SUI i" do
      @cpu.mem[0] = 0b11_010_110
      @cpu.mem[1] = 0x11
      @cpu.run 1
      assert_equal 0x12, @cpu.a
      assert_equal 2, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end

  sub_test_case "SBI   i" do

    setup do
      @cpu.a = 0x23
    end

    test "SBI i without borrow" do
      @cpu.mem[0] = 0b11_011_110
      @cpu.mem[1] = 0x11
      @cpu.run 1
      assert_equal 0x12, @cpu.a
      assert_equal 2, @cpu.pc
      assert_equal 7, @cpu.clock
    end

    test "SBI i with borrow" do
      @cpu.mem[0] = 0b11_011_110
      @cpu.mem[1] = 0x11
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0x11, @cpu.a
      assert_equal 2, @cpu.pc
      assert_equal 7, @cpu.clock
    end

  end

end
