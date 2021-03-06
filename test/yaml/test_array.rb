require 'helper'

module YAML
  class TestArray < MiniTest::Unit::TestCase
    def setup
      @list = [{ :a => 'b' }, 'foo']
    end

    def test_self_referential
      @list << @list
      assert_equal @list, YAML.load(@list.to_yaml)
    end

    def test_to_yaml
      assert_equal @list, YAML.load(@list.to_yaml)
    end

    def test_dump
      assert_equal @list, YAML.load(YAML.dump(@list))
    end
  end
end
