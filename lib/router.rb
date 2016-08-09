class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    req.path =~ pattern && req.request_method.downcase.to_sym == http_method
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    match_data = pattern.match(req.path)
    route_params = {}
    match_data.names.each { |name| route_params[name] = match_data[name] }
    controller = controller_class.new(req, res, route_params)
    controller.invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    self.routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&prc)
    instance_eval(&prc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |method|
    define_method(method) do |pattern, controller_class, action_name|
      add_route(pattern, method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    matching_routes = routes.find { |route| route.matches?(req) }
    # raise "Ambiguous routes! That's bad!" if matching_routes.length > 1
    # matching_routes.first
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = 404
      res.write("Can't find the thing!")
    end
  end
end
