require 'test/unit'
require 'i8080'

class TestMemoryManager < Test::Unit::TestCase

  setup do
    @manager = I8080::MemoryManager.new size:0x100
  end

  test "by index access" do
    @manager[0] = 1
    assert_equal 1, @manager[0]
  end
  
  test "by range access" do
    @manager[0x10..0x1f] = (0x10..0x1f).to_a
    (0x10..0x1f).each do |i|
      assert_equal i, @manager[i]
    end
  end
  
  test "by index and size" do
    @manager[0x20, 0x10] = (0x20..0x2f).to_a
    (0x20..0x2f).each do |i|
      assert_equal i, @manager[i]
    end
  end
  

end
