require 'test/unit'
require 'i8080'

class TestI8080Speed < Test::Unit::TestCase

  setup do
    @cpu = I8080.new clock: 1000
  end

  test "speed" do
    @cpu.mem[0] = 0b011_000_011
    @cpu.mem[1] = 0
    @cpu.mem[2] = 0
    s = Time.now
    @cpu.run 100
    e = Time.now
    assert_equal 1000, @cpu.clock
    assert_equal 1000, @cpu.state
    #assert_equal 1.0, e - s
    assert_equal true, 0.005 > (1.0 - (e - s)).abs
  end

end