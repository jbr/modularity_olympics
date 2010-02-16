require "queryer/vendor/foundation"
require "queryer/client"
require "queryer/middleware/builder"
require "queryer/middleware/core"
require "queryer/middleware/middleware"

class Queryer
  class QueryMaker
    def build_query(env)
      env["nk.query_class"].new(env["nk.connection"], env["nk.query_string"])
    end
    
    def select(env)
      build_query(env).select
    end

    def execute(env)
      build_query(env).execute
    end
  end
end