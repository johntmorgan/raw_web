Today: building a server from scratch, no Rack or Webrick!

First, rebuild part 1 using basic TCP servers.
Second, run through concepts from last time.

TCP server, hello world.

tcp_server.rb

require 'socket' #ruby library

server = TCPServer.open('localhost', 2000)

#What does this mean? TCP is a transport protocol. Bind process to listen on the post.

loop do
  client = server.accept # server waits for client to connect
  puts "Receiving a request at #{Time.now}"
  client.puts "Hello World!"
  client.close
  sleep 1
  puts "Finished serving request at #{Time.now}"
end

# window 1
$ruby tcp_server.rb
# window 2
$curl localhost:2000
Hello World!
connection reset by peer (closed connection)

Now see messages on the server side
Nothing HTTP here. By doing this, creating a new socket. A pipe between two programs on the same computer, or on two different servers.

Could bind to ('0.0.0.0', 2000) - then available on all networks this computer is part of, such as LAN. If internet accessible with a fixed IP, can get to it using that.

telnet localhost 2000
# note to self, look up telnet, curl, and related utilities

Could use this to transfer HTML documents, or just transfer text

# check out HTTP specifications
simple HTTP server

require 'socket'
server  = TCPServer.open('localhost', 2000)
html = "<html><body><p>Hello World!</p></body></html>"

loop do
  client = server.accept
  client.puts "HTTP/1.1 200 OK\r\nServer: Simple Ruby Server\r\nDate: #{Time.now}\r\nContent-Type: text/html\r\n\r\n#{html}"
  client.close
end

HTTP response - 
status line: HTTP-version, status-code
general header
response header
entity-header
CRLF
message-body

now if we curl, get a response in HTML

#just headers
curl - I localhost:2000 

check it out on dev http client 

http://localhost:2000
do a get, response ok, header info, etc.

\r\n #character return, newline - need that format for the browser to parse

Can load up in browser! Browser is smart enough to guess content type if you delete it. But if weird content-type - e.g. 'text/html' instead of text/html, will download

serve_file.rb

require 'socket'
server  = TCPServer.open('localhost', 2000)
html = File.read("hello_world.html")

while true
  client = server.accept
  client.puts "HTTP/1.1 200 OK\r\nServer: Simple Ruby Server\r\nDate: #{Time.now}\r\nContent-Type: text/html\r\n\r\n#{html}"
  client.close
end

serve_any_file - pass any file name, look under directory, pass back

require 'socket'
server  = TCPServer.open('localhost', 2000)

while true
  client = server.accept
  path = client.gets.slice(/\/(.*) /).strip
  html = file.read("site#{path}")
  client.puts "HTTP/1.1 200 OK\r\nServer: Simple Ruby Server\r\nDate: #{Time.now}\r\nContent-Type: text/html\r\n\r\n#{html}"
  client.close
end

client.gets
"GET /hello_world.html HTTP/1.1\r\n"

regex
escaped forward slash, then any string, then space

Right now the server is very fragile! If any request is bad, it crashes!

Can go ahead and serve index.html from our server site!
Loads HTML and images fine.
But CSS is not served due to content type. 

It's multiple hits, loads main page, then tries to load each stylesheet, other html files linked, in order.

request = client.gets
# simplest server log
puts "Getting request: #{request}"

require 'socket'
server = TCPServer.open('localhost', 2000)

while true
  client = server.accept
  path = client.gets.slice(/\/(.*) /).strip
  html = file.read("site#{path}")
  suffix = path.slice (/\.(.*)/)
  content_type = case suffix
                 when html then "text/html"
                 when css then "text/css"
                 etc.
                 end
  client.puts "HTTP/1.1 200 OK\r\nServer: Simple Ruby Server\r\nDate: #{Time.now}\r\nContent-Type: content-type\r\n\r\n#{html}"
  client.close
end

Analogy
TCP - telephone line
HTTP - a language, like English

handle_errors.rb
check 

if File.exists?("site#{url}")

else 
  client.puts "HTTP/1.1 404 NOT FOUND etc."

chrome looks for a favicon

if path == '/'
  redirect "HTTP/1.1 302 FOUND\r\nLocation: /index.html"
elsif File.exists?
  etc.

Redirect back to client, makes another request. Two round trips

(The JPG file makes a huge mess of Kevin's terminal)

Next step is to put the server on Rack. We're doing a lot of manual parsing here. Bleah. Huge string concatenate ourselves, look at HTTP document, set content type, reading everything up front rather than streaming in, etc. 

Webrick, unicorn, thin, puma all from scratch

Rack!
Whole HTTP request come in as a hash, env (luxury, already parsed!)

class SurfServer
  def call(env)
    local_file_name = "site#{env['PATH_INFO"]}"
    if File.exists?(local_file_name)
      [200, {}, [File.read(local_file_name)]]
    else
      [400. {}, #html error message here]

notes scattered due to cat - review week2 for basics
fragments are purely client-side, server does not see them

passing in params 
name = request.params[name]
insert to {{name}} using mustache

curl localhost:2000

query: follows ?
key-value pairs
fragment: follows #
not seen by server
purely on client side

forms.
action is a mandatory attribute for a form, defines where form will be handled.
Link labels via ID
Default method for form is still get

<form action = "/create_journal_entry">
  <label for="entry-title"> Title </label>
  <input type="text" name="title" id="entry-title">
  <label for="entry-content"> Content </label>
  <textarea name="description" row="6" id="entry-content"></textarea>
  <button type="submit"> Add </button>
</form>

elsif request.get? && request.path == "/create_journal_entry"
  binding.pry
