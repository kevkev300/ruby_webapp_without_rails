# Rack app and Rack Requests:
# * Transform Mirth into an application that
#   follows the Rack specifications and uses
#   Rack::Request to handle requests
# * Use Puma as an application server

require 'yaml/store'

# Require the relevant libraries
require 'rack'
require 'rack/handler/puma'

app = ->environment {
  # Create an Aplpication Server and New Rack::Request Object
  request = Rack::Request.new(environment)

  # use Yaml as database
  store = YAML::Store.new('mirth.yml')

  if request.get? && request.path == '/show/birthdays'
    status = 200
    content_type = 'text/html'
    response_message = "<ul>\n"

    all_birthdays = {}
    store.transaction do
      all_birthdays = store[:birthdays]
    end

    all_birthdays.each do |birthday|
      response_message << "<li> #{birthday[:name]} was born on #{birthday[:date]}!</li>"
    end

    response_message << "</ul>\n"
    response_message << <<~STR
      <form action ="/add/birthday" method="post" enctype="application/x-www-form-urlencoded">
      <p><label>Name <input type="text" name="name"></label></p>
      <p><label>Birthday <input type="date" name="date"></label></p>
      <p><button>Submit birthday</button></p>
      </form>
    STR

  elsif request.post? && request.path == '/add/birthday'
    status = 303
    content_type = 'text/html'
    response_message = ''

    # Instead of decoding the body, qw can use #params to get get the decoded body
    new_birthday = request.params

    # Store the user-input birthday data
    # back into the YAML store
    store.transaction do
      store[:birthdays] << new_birthday.transform_keys(&:to_sym)
    end

  else
    status = 200
    content_type = 'text/plain'
    response_message = "✅ Received a #{request.request_method} request to #{request.path}"
  end

  # Return 3-element Array
  headers = {
    'Content-Type' => "#{content_type}; charset=#{response_message.encoding.name}",
    'Location' => '/show/birthdays'
  }

  body = [response_message]

  [status, headers, body]
}

# Run the application with Puma
Rack::Handler::Puma.run(app, Port: 1337, Verbose: true)
