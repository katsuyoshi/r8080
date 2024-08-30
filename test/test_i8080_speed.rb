require 'test/unit'
require 'i8080'

class TestI8080 < Test::Unit::TestCase

  setup do
    @cpu = I8080.new
  end

  test "speed" do
    @cpu.mem[0] = 0b011_000_011
    @cpu.mem[1] = 0
    @cpu.mem[2] = 0
    s = Time.now
    @cpu.run 100000
    e = Time.now
    assert_equal 1000000, @cpu.state
    #assert_equal 1.0, e - s
    assert_equal true, 0.005 > (1.0 - (e - s)).abs
  end

end