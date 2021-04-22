# Rack Response:
# Use Rack::Response instead of returning
# the response array manually

require 'yaml/store'
require 'rack'
require 'rack/handler/puma'

app = ->environment {
  request = Rack::Request.new(environment)

  # Create a Rack::Request object to use
  response = Rack::Response.new

  store = YAML::Store.new('mirth.yml')

  if request.get? && request.path == '/show/birthdays'
    response.content_type = 'text/html; charset=UTF-8'
    response.write("<ul>\n")

    all_birthdays = {}
    store.transaction do
      all_birthdays = store[:birthdays]
    end

    all_birthdays.each do |birthday|
      response.write("<li> #{birthday[:name]} was born on #{birthday[:date]}!</li>")
    end

    response.write("</ul>\n")
    response.write <<~STR
      <form action ="/add/birthday" method="post" enctype="application/x-www-form-urlencoded">
      <p><label>Name <input type="text" name="name"></label></p>
      <p><label>Birthday <input type="date" name="date"></label></p>
      <p><button>Submit birthday</button></p>
      </form>
    STR

  elsif request.post? && request.path == '/add/birthday'
    new_birthday = request.params
    store.transaction do
      store[:birthdays] << new_birthday.transform_keys(&:to_sym)
    end

    # redirect response
    response.redirect('/show/birthdays', 303)
  else
    response.content_type = 'text/plain; charset=UTF-8'
    response.write("✅ Received a #{request.request_method} request to #{request.path}")
  end

  # Mark response as finished
  response.finish
}

# Run the application with Puma
Rack::Handler::Puma.run(app, Port: 1337, Verbose: true)
