# Rack Response:
# Use Rack::Response instead of returning
# the response array manually

require 'rack'
require 'rack/handler/puma'
require 'sqlite3'

app = ->environment {
  request = Rack::Request.new(environment)
  response = Rack::Response.new

  # Create a SQLite3 Database Object
  database = SQLite3::Database.new('mirth.sqlite3', results_as_hash: true)

  if request.get? && request.path == '/show/birthdays'
    response.content_type = 'text/html; charset=UTF-8'
    response.write("<ul>\n")

    # Get all birthdays from db
    all_birthdays = database.execute('SELECT * FROM birthdays')

    all_birthdays.each do |birthday|
      response.write("<li> #{birthday['name']} was born on #{birthday['date']}!</li>")
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

    # Create a Query for New User-Inputted row
    query = 'INSERT INTO birthdays (name, date) VALUES (?, ?)'
    database.execute(query, [new_birthday['name'], new_birthday['date']])

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
