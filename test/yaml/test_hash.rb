require 'helper'

module YAML
  class TestHash < MiniTest::Unit::TestCase
    def setup
      @hash = { :a => 'b' }
    end

    def test_self_referential
      @hash['self'] = @hash
      assert_equal @hash, YAML.load(YAML.dump(@hash))
    end

    def test_to_yaml
      assert_equal @hash, YAML.load(@hash.to_yaml)
    end

    def test_dump
      assert_equal @hash, YAML.load(YAML.dump(@hash))
    end
  end
end
