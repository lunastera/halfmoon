require 'singleton'
# __END__
# ConfigBaseClass
class ConfigBase
  include Singleton
  def initialize
  end

  class << self
    def all
      @opts ||= {}
    end

    def add(key, val)
      class_ins = all
      class_ins[key] = val
      nil
    end

    def get(key)
      class_ins = all
      class_ins[key]
    end

    def to_a
      class_ins = all
      class_ins.to_a
    end

    def size
      class_ins = all
      class_ins.size
    end

    def each(&_block)
      ary = to_a
      size.times do |i|
        yield ary[i].first, ary[i].last
      end
    end

    def [](key)
      class_ins = all
      class_ins[key]
    end

    def get_all(pattern)
      class_ins = all
      class_ins
        .select { |k, _| k.to_s.match(pattern) }
        .map { |k, v| [k.to_s.gsub(pattern, '').to_sym, v] }.to_h
    end
  end
end
