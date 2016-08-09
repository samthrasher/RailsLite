require 'erb'
require 'rack'

class ShowExceptions
  def initialize(app)
    @app = app
  end

  attr_reader :app

  def call(env)
    begin
      app.call(env)
    rescue Exception => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    res = Rack::Response.new
    code_sample = nearby_lines(e)
    path = File.expand_path('../templates/rescue.html.erb', __FILE__)
    template = File.read(path)
    content = ERB.new(template).result(binding)

    res.set_header("Content-Type", 'text/html')
    res.status = 500
    res.write(content)
    res.finish
  end


  def nearby_lines(e)
    path = e.backtrace.first[/^[^\:]*/]
    line = e.backtrace_locations.first.lineno
    first_line = [line - 5, 0].max
    last_line = line + 8

    File.read(path).split('\n')[first_line...last_line]
  end

end
