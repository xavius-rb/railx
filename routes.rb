class Routes
  @routes = []

  class << self
    attr_reader :routes

    def draw(&block)
      instance_eval(&block)
    end

    def get(path, options)
      add_route('GET', path, options)
    end

    def post(path, options)
      add_route('POST', path, options)
    end

    def add_route(method, path, options)
      @routes << { method: method, path: path, options: options }
    end

    def all
      @routes
    end
  end
end
