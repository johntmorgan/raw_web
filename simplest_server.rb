require 'webrick'

# copy basic data from ruby-docs
class Simple < WEBrick::HTTPServlet::AbstractServlet
  # handles get request - doesn't care what request is, yet!
  def do_GET request, response
    require 'pry'; binding.pry
    response.status = 200
    response['Content-Type'] = 'text/plain'
    # response.body = 'Hello, World!'
    content = File.open("hello_world.html", 'r').read
    response.body = content
  end
end

# document root is current directory (not needed yet...)
server = WEBrick::HTTPServer.new(:Port => 8000, :DocumentRoot => '.')
server.mount '/', Simple

# shut down server with ctrl-C
# part of signal model - allow signal to running process from OS
# actually stored as a hash
# this is baked into rails
trap 'INT' do server.shutdown end

server.start