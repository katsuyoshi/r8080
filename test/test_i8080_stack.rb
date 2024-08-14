require 'test/unit'
require 'i8080'

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
      assert_equal 11, @cpu.clock
    end

    test "PUSH D" do
      @cpu.mem[0] = 0b11_010_101
      @cpu.run 1
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x55, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x44, @cpu.mem[@cpu.sp + 1]
      assert_equal 1, @cpu.pc
      assert_equal 11, @cpu.clock
    end

    test "PUSH H" do
      @cpu.mem[0] = 0b11_100_101
      @cpu.run 1
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x77, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x66, @cpu.mem[@cpu.sp + 1]
      assert_equal 1, @cpu.pc
      assert_equal 11, @cpu.clock
    end

    test "PUSH PSW" do
      @cpu.mem[0] = 0b11_110_101
      @cpu.run 1
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x02, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x11, @cpu.mem[@cpu.sp + 1]
      assert_equal 1, @cpu.pc
      assert_equal 11, @cpu.clock
    end

  end

end
