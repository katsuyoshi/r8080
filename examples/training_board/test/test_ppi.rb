require 'test/unit'
require 'i8080'
require 'ppi'

class TestI8080 < Test::Unit::TestCase

  setup do
    @ppi = PPI.new
  end

  sub_test_case "control input/output mode" do

    test "initialy" do
      assert_equal :input, @ppi.mode_a
      assert_equal :input, @ppi.mode_b
      assert_equal :input, @ppi.mode_c_l
      assert_equal :input, @ppi.mode_c_h
    end

    test "set c port to output" do
      @ppi.out(0xfb, 0x92)
      assert_equal :input, @ppi.mode_a
      assert_equal :input, @ppi.mode_b
      assert_equal :output, @ppi.mode_c_l
      assert_equal :output, @ppi.mode_c_h
    end

    test "set a port to output" do
      @ppi.out(0xfb, 0x8b)
      assert_equal :output, @ppi.mode_a
      assert_equal :input, @ppi.mode_b
      assert_equal :input, @ppi.mode_c_l
      assert_equal :input, @ppi.mode_c_h
    end

    test "set b port to output" do
      @ppi.out(0xfb, 0x99)
      assert_equal :input, @ppi.mode_a
      assert_equal :output, @ppi.mode_b
      assert_equal :input, @ppi.mode_c_l
      assert_equal :input, @ppi.mode_c_h
    end

    test "set upper of c port to output" do
      @ppi.out(0xfb, 0x93)
      assert_equal :input, @ppi.mode_a
      assert_equal :input, @ppi.mode_b
      assert_equal :input, @ppi.mode_c_l
      assert_equal :output, @ppi.mode_c_h
    end

    test "set lower of c port to output" do
      @ppi.out(0xfb, 0x9a)
      assert_equal :input, @ppi.mode_a
      assert_equal :input, @ppi.mode_b
      assert_equal :output, @ppi.mode_c_l
      assert_equal :input, @ppi.mode_c_h
    end

  end

  sub_test_case "set each bit of c port" do

    sub_test_case "if port c is input mode, it doesen't change" do

      test "set bit 0" do
        @ppi.out(0xfb, 0x01)
        assert_equal 0, @ppi.port_c[0]
      end

      test "set bit 7" do
        @ppi.out(0xfb, 0x0f)
        assert_equal 0, @ppi.port_c[0]
      end

    end

    sub_test_case "if port c is out mode, it changes" do

      setup do
        @ppi.out(0xfb, 0x92)
      end

      test "set bit 0" do
        @ppi.out(0xfb, 0x01)
        assert_equal 1, @ppi.port_c[0]
      end

      test "set bit 7" do
        @ppi.out(0xfb, 0x0f)
        assert_equal 1, @ppi.port_c[7]
      end

    end

  end

  sub_test_case "port a" do
  
    sub_test_case "if port a is input mode, it doesn't change" do

      test "set" do
        @ppi.out(0xf8, 0x5a)
        assert_equal 0, @ppi.port_a
      end

    end

    sub_test_case "if port a is out mode, it changes" do
      setup do
        @ppi.out(0xfb, 0x8b)
      end

      test "set" do
        @ppi.out(0xf8, 0x5a)
        assert_equal 0x5a, @ppi.port_a
      end

    end

  end

  sub_test_case "port b" do
  
    sub_test_case "if port b is input mode, it doesn't change" do

      test "set" do
        @ppi.out(0xf9, 0x5a)
        assert_equal 0, @ppi.port_b
      end

    end

    sub_test_case "if port b is out mode, it changes" do
      setup do
        @ppi.out(0xfb, 0x99)
      end

      test "set" do
        @ppi.out(0xf9, 0x5a)
        assert_equal 0x5a, @ppi.port_b
      end

    end

  end

  sub_test_case "port c" do
  
    sub_test_case "if port c is input mode, it doesn't change" do

      setup do
        @ppi.out(0xfb, 0x9b)
      end

      test "set" do
        @ppi.out(0xfa, 0x5a)
        assert_equal 0, @ppi.port_c
      end

    end

    sub_test_case "if upper of port c is out mode, it changes" do

      setup do
        @ppi.out(0xfb, 0x93)
      end

      test "set" do
        @ppi.out(0xfa, 0x5a)
        assert_equal 0x50, @ppi.port_c
      end

    end

    sub_test_case "if lower of port c is out mode, it changes" do

      setup do
        @ppi.out(0xfb, 0x9a)
      end

      test "set" do
        @ppi.out(0xfa, 0x5a)
        assert_equal 0x0a, @ppi.port_c
      end

    end

  end

end
