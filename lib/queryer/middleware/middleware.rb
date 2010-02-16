class Queryer
  class StatsCollector < Middleware
    def initialize(queryer, stats)
      super(queryer)
      @stats = stats
    end

    def delegate(method, env)
      case method
      when :execute, :select
        @stats.measure(method) { super }
      else super
      end
    end
  end

  class Timeout < Middleware
    def initialize(queryer, timeout)
      super(queryer)
      @timeout = timeout
    end

    def delegate(method, env)
      case method
      when :execute, :select
        result = ::Timeout.timeout(@timeout) { super }
        puts "Did not timeout! Yay fast database!"
        result
      else super
      end
    end
  end

  class Memoizing < Middleware
    def build_query(env)
      @memo[[env['nk.connection'], env['nk.query_string']]] ||= begin
        puts "Instantiating Query Object"
        super
      end
    end
    
    def initialize(queryer)
      super(queryer)
      @memo = {}
    end
  end
end