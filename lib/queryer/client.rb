# This serves as the "server" for the Queryer endpoint. You can implement
# another server to the Queryer client, so long as the endpoint receives
# nk.connection, nk.query_string, and nk.query
class Queryer
  class Client
    def initialize(pool, queryer)
      @pool = pool
      @queryer = queryer
    end
    
    def select(query_string)
      with_connection(query_string) do |env|
        @queryer.build_query(env)
        @queryer.select(env)
      end
    end

    def execute(query_string)
      with_connection(query_string) do |env|
        @queryer.build_query(env)
        @queryer.execute(env)
      end
    end

    def transaction
      @pool.with_connection { |connection| yield InTransaction.new(connection, @queryer) }
    end

    def with_connection(query_string)
      @pool.with_connection { |connection| yield env(connection, query_string) }
    end

    def env(connection, query_string)
      {
        "nk.connection" => connection, 
        "nk.query_string" => query_string, 
        "nk.query_class" => Query
      }
    end

    class InTransaction < Queryer::Client
      def initialize(connection, queryer)
        @connection = connection
        @queryer    = queryer
      end

      def transaction
        yield self
      end
    
      def with_connection(query_string)
        yield env(@connection, query_string)
      end
    end
  end
end