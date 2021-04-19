# Use Ruby Socket Library
# open server by running file
# connect to server running `nc localhost 1337`ƒ
require 'socket'

server = TCPServer.new(1337)

# Accept Incomming Connections
loop do
  client = server.accept # IO Stream opened --> IO object

  client.puts 'What`s yout name?'
  input = client.gets
  puts "Received #{input.chomp}! from a client sockent on 1337" # only logs
  client.puts "Hi, #{input.chomp}! You've succesfully connected to the server socket"

  # close the Client Socket
  puts 'Closing client socket'
  client.puts "Goodby #{input}"
  client.close
end
