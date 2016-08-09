require 'json'

class Flash
  COOKIE_NAME = "_rails_lite_app_flash"

  attr_accessor :now
  def initialize(req)
    if req.cookies[COOKIE_NAME]
      @flash_in = JSON.parse(req.cookies[COOKIE_NAME])
    else
      @flash_in = {}
    end

    @flash_out = {}
    @now = {}
  end

  def [](key)
    @now[key] || @flash_out[key] || @flash_in[key]
  end

  def []=(key, val)
    @flash_out[key] = val
  end

  def store_flash(res)
    res.set_cookie(COOKIE_NAME, {path: "/", value: @flash_out.to_json})
  end
end
