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

  sub_test_case "key define" do

    test "KEY_0" do
      assert_equal 0x30, PPI::KEY_0
    end

    test "KEY_9" do
      assert_equal 0x39, PPI::KEY_9
    end

    test "KEY_A" do
      assert_equal 0x41, PPI::KEY_A
    end

    test "KEY_F" do
      assert_equal 0x46, PPI::KEY_F
    end

    test "KEY_RUN" do
      assert_equal 0x52, PPI::KEY_RUN
    end

    test "KEY_RET" do
      assert_equal 0x0d, PPI::KEY_RET
    end

    test "KEY_ADRS_SET" do
      assert_equal 0x20, PPI::KEY_ADRS_SET
    end

    test "KEY_READ_DEC" do
      assert_equal 44, PPI::KEY_READ_DEC
    end

    test "KEY_READ_INC" do
      assert_equal 46, PPI::KEY_READ_INC
    end

    test "KEY_WRITE_INC" do
      assert_equal 47, PPI::KEY_WRITE_INC
    end

    test "KEY_DATA_STORE" do
      assert_equal 0x53, PPI::KEY_STORE_DATA
    end

    test "KEY_DATA_LOAD" do
      assert_equal 0x4c, PPI::KEY_LOAD_DATA
    end


  end

end
