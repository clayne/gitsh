module Gitsh
  module Arguments
    class PatternValue
      attr_reader :pattern

      def initialize(pattern)
        @pattern = pattern
      end

      def expand
        options = yield
        matches = options.grep(pattern)
        # FIXME: only exact matches, i.e. implicit `^...$`
        if matches.any?
          matches
        else
          ['FIXME']
          # FIXME: fallback to the original gitsh source (not the regexp)
        end
      end

      def +(other)
        case other
        when PatternValue
          PatternValue.new(Regexp.new(pattern.source + other.pattern.source))
        when StringValue
          PatternValue.new(Regexp.new(pattern.source + other.value))
        else
          raise ArgumentError,
            "Cannot append a #{other.class.name} to a #{self.class.name}"
        end
      end

      def ==(other)
        other.is_a?(self.class) && pattern == other.pattern
      end
    end
  end
end
