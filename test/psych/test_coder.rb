require 'minitest/autorun'
require 'psych'

module Psych
  class TestCoder < MiniTest::Unit::TestCase
    class InitApi
      attr_accessor :implicit
      attr_accessor :style
      attr_accessor :tag
      attr_accessor :a, :b, :c

      def initialize
        @a = 1
        @b = 2
        @c = 3
      end

      def init_with coder
        @a = coder['aa']
        @b = coder['bb']
        @implicit = coder.implicit
        @tag      = coder.tag
        @style    = coder.style
      end

      def encode_with coder
        coder['aa'] = @a
        coder['bb'] = @b
      end
    end

    class TaggingCoder < InitApi
      def encode_with coder
        super
        coder.tag       = coder.tag.sub(/!/, '!hello')
        coder.implicit  = false
        coder.style     = Psych::Nodes::Mapping::FLOW
      end
    end

    class ScalarCoder
      def encode_with coder
        coder.scalar = "foo"
      end
    end

    class Represent
      yaml_tag 'foo'
      def encode_with coder
        coder.represent_scalar 'foo', 'bar'
      end
    end

    class RepresentWithInit
      yaml_tag name
      attr_accessor :str

      def init_with coder
        @str = coder.scalar
      end

      def encode_with coder
        coder.represent_scalar self.class.name, 'bar'
      end
    end

    class RepresentWithSeq
      yaml_tag name
      attr_accessor :seq

      def init_with coder
        @seq = coder.seq
      end

      def encode_with coder
        coder.represent_seq self.class.name, %w{ foo bar }
      end
    end

    class RepresentWithMap
      yaml_tag name
      attr_accessor :map

      def init_with coder
        @map = coder.map
      end

      def encode_with coder
        coder.represent_map self.class.name, { 'a' => 'b' }
      end
    end

    def test_represent_map
      thing = Psych.load(Psych.dump(RepresentWithMap.new))
      assert_equal({ 'a' => 'b' }, thing.map)
    end

    def test_represent_sequence
      thing = Psych.load(Psych.dump(RepresentWithSeq.new))
      assert_equal %w{ foo bar }, thing.seq
    end

    def test_represent_with_init
      thing = Psych.load(Psych.dump(RepresentWithInit.new))
      assert_equal 'bar', thing.str
    end

    def test_represent!
      assert_match(/foo/, Psych.dump(Represent.new))
      assert_instance_of(Represent, Psych.load(Psych.dump(Represent.new)))
    end

    def test_scalar_coder
      foo = Psych.load(Psych.dump(ScalarCoder.new))
      assert_equal 'foo', foo
    end

    def test_load_dumped_tagging
      foo = InitApi.new
      bar = Psych.load(Psych.dump(foo))
      assert_equal false, bar.implicit
      assert_equal "!ruby/object:Psych::TestCoder::InitApi", bar.tag
      assert_equal Psych::Nodes::Mapping::BLOCK, bar.style
    end

    def test_dump_with_tag
      foo = TaggingCoder.new
      assert_match(/hello/, Psych.dump(foo))
      assert_match(/\{aa/, Psych.dump(foo))
    end

    def test_dump_encode_with
      foo = InitApi.new
      assert_match(/aa/, Psych.dump(foo))
    end

    def test_dump_init_with
      foo = InitApi.new
      bar = Psych.load(Psych.dump(foo))
      assert_equal foo.a, bar.a
      assert_equal foo.b, bar.b
      assert_nil bar.c
    end
  end
end
