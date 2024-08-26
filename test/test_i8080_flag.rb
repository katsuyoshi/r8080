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

  end

  sub_test_case "CMP   r" do

    test "CMP A (case zero) -> z p" do
      @cpu.mem[0] = 0b10_111_111
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "CMP B (case minus) -> s p" do
      @cpu.mem[0] = 0b10_111_000
      @cpu.a = 0xff
      @cpu.b = 0x00
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_1_1_0, @cpu.f
    end

    test "CMP B (case carry) -> s p ac cy" do
      @cpu.mem[0] = 0b10_111_000
      @cpu.a = 0x00
      @cpu.b = 0x01
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_1_1_1, @cpu.f
    end

    test "CMP M (case parity off) -> s p ac cy" do
      @cpu.mem[0] = 0b10_111_110
      @cpu.a = 0x01
      @cpu.h = 0x80; @cpu.l = 0
      @cpu.mem[0x8000] = 0x00
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end
  
  sub_test_case "CPI   i" do

    test "CPI 0x8000 (case zero) -> z p" do
      @cpu.mem[0] = 0b11_111_110
      @cpu.mem[1] = 0x00
      @cpu.mem[2] = 0x80
      @cpu.mem[0x8000] = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "CPI 0x8000 (case minus) -> s p" do
      @cpu.mem[0] = 0b11_111_110
      @cpu.mem[1] = 0x00
      @cpu.mem[2] = 0x80
      @cpu.a = 0xff
      @cpu.mem[0x8000] = 0x00
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_1_1_0, @cpu.f
    end

    test "CPI 0x8000 (case carry) -> s p ac cy" do
      @cpu.mem[0] = 0b11_111_110
      @cpu.mem[1] = 0x00
      @cpu.mem[2] = 0x80
      @cpu.a = 0x00
      @cpu.mem[0x8000] = 0x01
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_1_1_1, @cpu.f
    end

    test "CPI 0x8000 (case parity off) -> s p ac cy" do
      @cpu.mem[0] = 0b11_111_110
      @cpu.mem[1] = 0x00
      @cpu.mem[2] = 0x80
      @cpu.a = 0x01
      @cpu.mem[0x8000] = 0x00
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  sub_test_case "ADD   r" do

    test "ADD A (case zero) -> z p cy" do
      @cpu.mem[0] = 0b10_000_111
      @cpu.a = 0x80
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_1, @cpu.f
    end

    test "ADD B (case minus) -> s ac" do
      @cpu.mem[0] = 0b10_000_000
      @cpu.a = 0x80
      @cpu.b = 0x00
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_0_1_0, @cpu.f
    end
    
  end

  sub_test_case "ADC   r" do

    test "ADC A (case zero) -> z p cy" do
      @cpu.mem[0] = 0b10_001_111
      @cpu.a = 0x80
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_1, @cpu.f
    end

    test "ADC B (case minus) -> s ac" do
      @cpu.mem[0] = 0b10_001_000
      @cpu.a = 0x80
      @cpu.b = 0x00
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_0_1_0, @cpu.f
    end

    test "ADC B with carry (case zero) -> z ac p cy" do
      @cpu.mem[0] = 0b10_001_000
      @cpu.a = 0xff
      @cpu.b = 0x00
      @cpu.flg_cy = 1
      @cpu.run 1
      assert_equal 0b0_1_0_1_0_1_1_1, @cpu.f
    end

    test "ADC B with carry (case minus) -> s" do
      @cpu.mem[0] = 0b10_001_000
      @cpu.a = 0x82
      @cpu.b = 0x00
      @cpu.flg_cy = 1
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_0_1_0, @cpu.f
    end

  end

  sub_test_case "ADI   i" do

    test "ADI 0x00 (case zero) -> z p cy" do
      @cpu.mem[0] = 0b11_000_110
      @cpu.mem[1] = 0x80
      @cpu.a = 0x80
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_1, @cpu.f
    end

    test "ADI 0x00 (case minus) -> s ac" do
      @cpu.mem[0] = 0b11_000_110
      @cpu.mem[1] = 0x80
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_0_1_0, @cpu.f
    end

  end

  sub_test_case "ACI   i" do


    test "ACI 0x00 (case zero) -> z p cy" do
      @cpu.mem[0] = 0b11_001_110
      @cpu.mem[1] = 0x80
      @cpu.a = 0x80
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_1, @cpu.f
    end

    test "ACI 0x00 (case minus) -> s ac" do
      @cpu.mem[0] = 0b11_001_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x80
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_0_1_0, @cpu.f
    end

    test "ACI 0x00 with carry (case zero) -> z ac p cy" do
      @cpu.mem[0] = 0b11_001_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0xff
      @cpu.flg_cy = 1
      @cpu.run 1
      assert_equal 0b0_1_0_1_0_1_1_1, @cpu.f
    end

  end

  sub_test_case "SUB   r" do

    test "SUB A (case zero) -> z p" do
      @cpu.mem[0] = 0b10_010_111
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "SUB B (case minus) -> s p" do
      @cpu.mem[0] = 0b10_010_000
      @cpu.a = 0xff
      @cpu.b = 0x00
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_1_1_0, @cpu.f
    end

  end

  sub_test_case "SBB   r" do

    test "SBB A (case zero) -> z p" do
      @cpu.mem[0] = 0b10_011_111
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "SBB B (case minus) -> s ac p cy" do
      @cpu.mem[0] = 0b10_011_000
      @cpu.a = 0x00
      @cpu.b = 0x01
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_1_1_1, @cpu.f
    end

    test "SBB B (case parity off) -> none" do
      @cpu.mem[0] = 0b10_011_000
      @cpu.a = 0x02
      @cpu.b = 0x01
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

    test "SBB B with carry (case zero) -> z p" do
      @cpu.mem[0] = 0b10_011_000
      @cpu.a = 0x01
      @cpu.b = 0x00
      @cpu.flg_cy = 1
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "SBB B with carry (case minus) -> s ac p cy" do
      @cpu.mem[0] = 0b10_011_000
      @cpu.a = 0x00
      @cpu.b = 0x00
      @cpu.flg_cy = 1
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_1_1_1, @cpu.f
    end

    test "SBB B with carry (case parity off) -> none" do
      @cpu.mem[0] = 0b10_011_000
      @cpu.a = 0x02
      @cpu.b = 0x00
      @cpu.flg_cy = 1
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  sub_test_case "SUI   i" do

    test "SUI 0x00 (case zero) -> z p" do
      @cpu.mem[0] = 0b11_010_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "SUI 0x00 (case minus) -> s ac" do
      @cpu.mem[0] = 0b11_010_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x80
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_0_1_0, @cpu.f
    end

  end

  sub_test_case "SBI   i" do

    test "SBI 0x00 (case zero) -> z p" do
      @cpu.mem[0] = 0b11_011_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "SBI 0x00 (case minus) -> s ac p cy" do
      @cpu.mem[0] = 0b11_011_110
      @cpu.mem[1] = 0x01
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_1_1_1, @cpu.f
    end

    test "SBI 0x00 (case parity off) -> none" do
      @cpu.mem[0] = 0b11_011_110
      @cpu.mem[1] = 0x01
      @cpu.a = 0x02
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

    test "SBI 0x00 with carry (case zero) -> z p" do
      @cpu.mem[0] = 0b11_011_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x01
      @cpu.flg_cy = 1
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "SBI 0x00 with carry (case minus) -> s ac p cy" do
      @cpu.mem[0] = 0b11_011_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x00
      @cpu.flg_cy = 1
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_1_1_1, @cpu.f
    end

    test "SBI 0x00 with carry (case parity off) -> none" do 
      @cpu.mem[0] = 0b11_011_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x02
      @cpu.flg_cy = 1
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end


  end


  sub_test_case "INR   A" do
    
    # carray is not affected by INR
    test "INR A (case zero) -> z ac p" do
      @cpu.mem[0] = 0b00_111_100
      @cpu.a = 0xff
      @cpu.run 1
      assert_equal 0b0_1_0_1_0_1_1_0, @cpu.f
    end
  
    # carray is not affected by INR
    test "INR A (case minus) -> s ac" do
      @cpu.mem[0] = 0b00_111_100
      @cpu.a = 0x7f
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_0_1_0, @cpu.f
    end
  
    test "INR A (case not ac) -> none" do
      @cpu.mem[0] = 0b00_111_100
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end
  
  end
  
  sub_test_case "INR   B" do
    
    # carray is not affected by INR
    test "INR B (case zero) -> z ac p" do
      @cpu.mem[0] = 0b00_000_100
      @cpu.b = 0xff
      @cpu.run 1
      assert_equal 0b0_1_0_1_0_1_1_0, @cpu.f
    end
  
    # carray is not affected by INR
    test "INR B (case minus) -> s ac" do
      @cpu.mem[0] = 0b00_000_100
      @cpu.b = 0x7f
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_0_1_0, @cpu.f
    end
  
    test "INR B (case not ac) -> none" do
      @cpu.mem[0] = 0b00_000_100
      @cpu.b = 0x00
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end
  
  end
  
  sub_test_case "DCR   r" do

    test "DCR A (case zero) -> z p" do
      @cpu.mem[0] = 0b00_111_101
      @cpu.a = 0x01
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    # carray is not affected by DCR
    test "DCR A (case minus) -> s ac p" do
      @cpu.mem[0] = 0b00_111_101
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b1_0_0_1_0_1_1_0, @cpu.f
    end

    test "DCR A (case not p) -> s ac" do
      @cpu.mem[0] = 0b00_111_101
      @cpu.a = 0x02
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_1_0, @cpu.f
    end

  end

  sub_test_case "INX   rp" do

    # inx is nothing effected flags
    test "INX B (case zero) -> z p" do
      @cpu.mem[0] = 0b00_000_011
      @cpu.b = 0xff
      @cpu.c = 0xff
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  sub_test_case "DCX   rp" do

    # dcx is nothing effected flags
    test "DCX B (case zero) -> z p" do
      @cpu.mem[0] = 0b00_000_101
      @cpu.b = 0x00
      @cpu.c = 0x00
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  # DAD is only effected carry flag
  sub_test_case "DAD   rp" do

    test "DAD B (case zero) -> none" do
      @cpu.mem[0] = 0b00_001_001
      @cpu.b = 0x00
      @cpu.c = 0x00
      @cpu.h = 0x00
      @cpu.l = 0x00
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

    test "DAD B (case carry) -> cy" do
      @cpu.mem[0] = 0b00_001_001
      @cpu.b = 0x01
      @cpu.c = 0x00
      @cpu.h = 0xff
      @cpu.l = 0xff
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_1, @cpu.f
    end

  end

  # AC is always false. Carry is always false. NOTE: ac is always true if the cpu type is 8085
  sub_test_case "ANA   r" do

    test "ANA A (case zero) -> z p" do
      @cpu.mem[0] = 0b10_100_111
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "ANA A (case minus) -> s p" do
      @cpu.mem[0] = 0b10_100_111
      @cpu.a = 0xff
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_1_1_0, @cpu.f
    end

    test "ANA A (case no parity) -> s p" do
      @cpu.mem[0] = 0b10_100_111
      @cpu.a = 0x01
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  # AC is always false. Carry is always false. NOTE: ac is always true if the cpu type is 8085
  sub_test_case "ANI   r" do

    test "ANI 0x00 (case zero) -> z p" do
      @cpu.mem[0] = 0b11_100_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "ANI 0xff (case minus) -> s p" do
      @cpu.mem[0] = 0b11_100_110
      @cpu.mem[1] = 0xff
      @cpu.a = 0xff
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_1_1_0, @cpu.f
    end

    test "ANI 0x01 (case no parity) -> s p" do
      @cpu.mem[0] = 0b11_100_110
      @cpu.mem[1] = 0x01
      @cpu.a = 0x01
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  # AC is always false. Carry is always false.
  sub_test_case "ORA   r" do

    test "ORA A (case zero) -> z p" do
      @cpu.mem[0] = 0b10_110_111
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "ORA A (case minus) -> s p" do
      @cpu.mem[0] = 0b10_110_111
      @cpu.a = 0xff
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_1_1_0, @cpu.f
    end

    test "ORA A (case no parity) -> s p" do
      @cpu.mem[0] = 0b10_110_111
      @cpu.a = 0x01
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end
  
  end

  # AC is always false. Carry is always false.
  sub_test_case "ORI   i" do

    test "ORI 0x00 (case zero) -> z p" do
      @cpu.mem[0] = 0b11_110_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "ORI 0xff (case minus) -> s p" do
      @cpu.mem[0] = 0b11_110_110
      @cpu.mem[1] = 0xff
      @cpu.a = 0xff
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_1_1_0, @cpu.f
    end

    test "ORI 0x01 (case no parity) -> s p" do
      @cpu.mem[0] = 0b11_110_110
      @cpu.mem[1] = 0x01
      @cpu.a = 0x01
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  # AC is always false. Carry is always false.
  sub_test_case "XRA   r" do

    test "XRA A (case zero) -> z p" do
      @cpu.mem[0] = 0b10_101_000
      @cpu.a = 0x00
      @cpu.b = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "XRA A (case minus) -> s p" do
      @cpu.mem[0] = 0b10_101_000
      @cpu.a = 0xff
      @cpu.b = 0x00
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_1_1_0, @cpu.f
    end

    test "XRA A (case no parity) -> s p" do
      @cpu.mem[0] = 0b10_101_000
      @cpu.a = 0x01
      @cpu.b = 0x00
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  # AC is always false. Carry is always false.
  sub_test_case "XRI   i" do

    test "XRI 0x00 (case zero) -> z p" do
      @cpu.mem[0] = 0b11_101_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_1_0_0_0_1_1_0, @cpu.f
    end

    test "XRI 0xff (case minus) -> s p" do
      @cpu.mem[0] = 0b11_101_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0xff
      @cpu.run 1
      assert_equal 0b1_0_0_0_0_1_1_0, @cpu.f
    end

    test "XRI 0x01 (case no parity) -> s p" do
      @cpu.mem[0] = 0b11_101_110
      @cpu.mem[1] = 0x00
      @cpu.a = 0x01
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  # It's effected no flags
  sub_test_case "CMA" do

    test "CMA (case zero) -> none" do
      @cpu.mem[0] = 0b00_101_111
      @cpu.a = 0x00
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

    test "CMA (case carry) -> none" do
      @cpu.mem[0] = 0b00_101_111
      @cpu.a = 0xff
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

    test "CMA (case no parity) -> none" do
      @cpu.mem[0] = 0b00_101_111
      @cpu.a = 0x01
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_0, @cpu.f
    end

  end

  # It's effected only carry flag
  sub_test_case "CMC" do

    test "CMC (case zero) -> cy" do
      @cpu.mem[0] = 0b00_111_111
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_1, @cpu.f
    end

    test "CMC (case carry) -> cy" do
      @cpu.mem[0] = 0b00_111_111
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_1, @cpu.f
    end

    test "CMC (case no parity) -> cy" do
      @cpu.mem[0] = 0b00_111_111
      @cpu.run 1
      assert_equal 0b0_0_0_0_0_0_1_1, @cpu.f
    end

  end



end
