# HTTP Requests
# Break down HTTP requests from client and display it
# run file & open browser localhost:1337/cakes-and/pies

require 'socket'

server = TCPServer.new(1337)

# Accept Incomming Connections
loop do
  client = server.accept # IO Stream opened --> IO object

  # Get the Request-line of the Request
  request_line = client.readline

  puts 'The HTTP request line looks like this:'
  puts request_line

  # Breaks down the HTTP request from the client
  method_token, target, version_number = request_line.split
  response_body = "✅ Received a #{method_token} request to #{target} with #{version_number}"

  client.puts response_body
  client.close
end
