require 'test/unit'
require 'i8080'

class I8080
  def _push_i16 data; push_i16 data; end
end 

class TestI8080 < Test::Unit::TestCase

  setup do
    @cpu = I8080.new
  end

  sub_test_case "PUSH" do

    setup do
      @cpu.a = 0x11
      @cpu.b = 0x22
      @cpu.c = 0x33
      @cpu.d = 0x44
      @cpu.e = 0x55
      @cpu.h = 0x66
      @cpu.l = 0x77
    end

    test "PUSH B" do
      @cpu.mem[0] = 0b11_000_101
      @cpu.run 1
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x33, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x22, @cpu.mem[@cpu.sp + 1]
      assert_equal 1, @cpu.pc
      assert_equal 11, @cpu.state
    end

    test "PUSH D" do
      @cpu.mem[0] = 0b11_010_101
      @cpu.run 1
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x55, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x44, @cpu.mem[@cpu.sp + 1]
      assert_equal 1, @cpu.pc
      assert_equal 11, @cpu.state
    end

    test "PUSH H" do
      @cpu.mem[0] = 0b11_100_101
      @cpu.run 1
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x77, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x66, @cpu.mem[@cpu.sp + 1]
      assert_equal 1, @cpu.pc
      assert_equal 11, @cpu.state
    end

    test "PUSH PSW" do
      @cpu.mem[0] = 0b11_110_101
      @cpu.run 1
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x02, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x11, @cpu.mem[@cpu.sp + 1]
      assert_equal 1, @cpu.pc
      assert_equal 11, @cpu.state
    end

  end

  sub_test_case "POP" do

    test "POP B" do
      @cpu.mem[0] = 0b11_000_001
      @cpu._push_i16 0x2233
      @cpu.run 1
      assert_equal 0x0000, @cpu.sp
      assert_equal 0x33, @cpu.c
      assert_equal 0x22, @cpu.b
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.state
    end

    test "POP D" do
      @cpu.mem[0] = 0b11_010_001
      @cpu._push_i16 0x4455
      @cpu.run 1
      assert_equal 0x0000, @cpu.sp
      assert_equal 0x55, @cpu.e
      assert_equal 0x44, @cpu.d
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.state
    end

    test "POP H" do
      @cpu.mem[0] = 0b11_100_001
      @cpu._push_i16 0x6677
      @cpu.run 1
      assert_equal 0x0000, @cpu.sp
      assert_equal 0x77, @cpu.l
      assert_equal 0x66, @cpu.h
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.state
    end

    test "POP PSW" do
      @cpu.mem[0] = 0b11_110_001
      @cpu._push_i16 0x1102
      @cpu.run 1
      assert_equal 0x0000, @cpu.sp
      assert_equal 0x02, @cpu.f
      assert_equal 0x11, @cpu.a
      assert_equal 1, @cpu.pc
      assert_equal 10, @cpu.state
    end

  end

  sub_test_case "XTHL" do

    test "XTHL" do
      @cpu.mem[0] = 0b11_100_011
      @cpu.h = 0x22
      @cpu.l = 0x33
      @cpu._push_i16 0x4455
      @cpu.run 1
      assert_equal 0x4455, @cpu.hl
      assert_equal 0x33, @cpu.mem[0xfffe]
      assert_equal 0x22, @cpu.mem[0xffff]
      assert_equal 1, @cpu.pc
      assert_equal 18, @cpu.state
    end

  end

  sub_test_case "SPHL" do
      
      test "SPHL" do
        @cpu.mem[0] = 0b11_111_001
        @cpu.h = 0x22
        @cpu.l = 0x33
        @cpu.run 1
        assert_equal 0x2233, @cpu.sp
        assert_equal 1, @cpu.pc
        assert_equal 5, @cpu.state
      end
  
    end 

end
