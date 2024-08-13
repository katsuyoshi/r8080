require 'test/unit'
require 'i8080'

class TestI8080 < Test::Unit::TestCase

  setup do
    @cpu = I8080.new
  end

  sub_test_case "call   i" do

    test "call 0x1234" do
      @cpu.mem[0] = 0b11_001_101
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x03, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x00, @cpu.mem[@cpu.sp + 1]
      assert_equal 17, @cpu.clock
    end

  end

  sub_test_case "cc   i" do

    test "cc 0x1234 without carry" do
      @cpu.mem[0] = 0b11_011_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x0003, @cpu.pc
      assert_equal 0x000, @cpu.sp
      assert_equal 11, @cpu.clock
    end

    test "cc 0x1234 with carry" do
      @cpu.mem[0] = 0b11_011_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x03, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x00, @cpu.mem[@cpu.sp + 1]
      assert_equal 17, @cpu.clock
    end

  end

  sub_test_case "cnc   i" do

    test "cnc 0x1234 without carry" do
      @cpu.mem[0] = 0b11_010_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x03, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x00, @cpu.mem[@cpu.sp + 1]
      assert_equal 17, @cpu.clock
    end

    test "cnc 0x1234 with carry" do
      @cpu.mem[0] = 0b11_010_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.flg_c = true
      @cpu.run 1
      assert_equal 0x0003, @cpu.pc
      assert_equal 0x0000, @cpu.sp
      assert_equal 11, @cpu.clock
    end

  end

  sub_test_case "cz   i" do

    test "cz 0x1234 without zero" do
      @cpu.mem[0] = 0b11_001_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x0003, @cpu.pc
      assert_equal 0x0000, @cpu.sp
      assert_equal 11, @cpu.clock
    end

    test "cz 0x1234 with zero" do
      @cpu.mem[0] = 0b11_001_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.flg_z = true
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x03, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x00, @cpu.mem[@cpu.sp + 1]
      assert_equal 17, @cpu.clock
    end

  end

  sub_test_case "cnz   i" do

    test "cnz 0x1234 without zero" do
      @cpu.mem[0] = 0b11_000_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x03, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x00, @cpu.mem[@cpu.sp + 1]
      assert_equal 17, @cpu.clock
    end

    test "cnz 0x1234 with zero" do
      @cpu.mem[0] = 0b11_000_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.flg_z = true
      @cpu.run 1
      assert_equal 0x0003, @cpu.pc
      assert_equal 0x000, @cpu.sp
      assert_equal 11, @cpu.clock
    end

  end

  sub_test_case "cp   i" do

    test "cp 0x1234 without sign" do
      @cpu.mem[0] = 0b11_110_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x03, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x00, @cpu.mem[@cpu.sp + 1]
      assert_equal 17, @cpu.clock
    end

    test "cp 0x1234 with sign" do
      @cpu.mem[0] = 0b11_110_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.flg_s = true
      @cpu.run 1
      assert_equal 0x0003, @cpu.pc
      assert_equal 0x000, @cpu.sp
      assert_equal 11, @cpu.clock
    end

  end

  sub_test_case "cm   i" do

    test "cm 0x1234 with sign" do
      @cpu.mem[0] = 0b11_111_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x0003, @cpu.pc
      assert_equal 0x000, @cpu.sp
      assert_equal 11, @cpu.clock
    end

    test "cm 0x1234 without sign" do
      @cpu.mem[0] = 0b11_111_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.flg_s = true
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x03, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x00, @cpu.mem[@cpu.sp + 1]
      assert_equal 17, @cpu.clock
    end

  end

  sub_test_case "cpe   i" do

    test "cpe 0x1234 with sign" do
      @cpu.mem[0] = 0b11_101_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x0003, @cpu.pc
      assert_equal 0x000, @cpu.sp
      assert_equal 11, @cpu.clock
    end

    test "cpe 0x1234 without sign" do
      @cpu.mem[0] = 0b11_101_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.flg_p = true
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x03, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x00, @cpu.mem[@cpu.sp + 1]
      assert_equal 17, @cpu.clock
    end

  end

  sub_test_case "cpo   i" do

    test "cpo 0x1234 without sign" do
      @cpu.mem[0] = 0b11_100_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.run 1
      assert_equal 0x1234, @cpu.pc
      assert_equal 0xfffe, @cpu.sp
      assert_equal 0x03, @cpu.mem[@cpu.sp + 0]
      assert_equal 0x00, @cpu.mem[@cpu.sp + 1]
      assert_equal 17, @cpu.clock
    end

    test "cpo 0x1234 with sign" do
      @cpu.mem[0] = 0b11_100_100
      @cpu.mem[1] = 0x34
      @cpu.mem[2] = 0x12
      @cpu.flg_p = true
      @cpu.run 1
      assert_equal 0x0003, @cpu.pc
      assert_equal 0x000, @cpu.sp
      assert_equal 11, @cpu.clock
    end

  end

end
