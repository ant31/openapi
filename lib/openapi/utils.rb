require 'securerandom'

module OpenAPI
  module Utils
    class Random
      class << self
        def hex(n=16)
          SecureRandom.hex(n)
        end
      end
    end

    class Date
      class << self

        def format(date)
          date.strftime("%Y%m%d")
        end

        def now()
          format(Time.now.utc())
        end
      end

      def to_s()
        @date_str
      end

      def date()
        @date
      end

      def inititialize(t = nil)
        if t == nil
          t = Time.now.utc()
        end
        @date_str = OpenAPI::Utils::Date.format(t)
        @date = t.dup()
      end
    end
  end
end

module ActiveRecord
  module SecureRandom
    class << self
      def hex(n=16)
        OpenAPI::Utils::Random.hex(n)
      end
    end
  end
end
