require 'byebug'

class Static
  CONTENT_TYPES = {
    ".jpg" => "image/jpg",
    ".png" => "image/png",
    ".txt" => "text/plain",
    ".zip" => "application/zip"
  }

  def initialize(app)
    @app = app
  end

  attr_reader :app

  def call(env)
    serve_public_file(env) || app.call(env)
  end

  def serve_public_file(env)
    return nil unless env['PATH_INFO'] =~ /^\/public\//
    path = File.expand_path("../../#{env['PATH_INFO']}", __FILE__ )
    begin
      data = File.read(path)
    rescue Errno::ENOENT => e
      return ['404', {"Content-Type" => content_type(path)}, "File not found"]
    end
    ['200', {"Content-Type" => content_type(path)}, data]
  end

  def content_type(path)
    ext = path[/\.\w+$/]
    CONTENT_TYPES[ext]
  end
end
