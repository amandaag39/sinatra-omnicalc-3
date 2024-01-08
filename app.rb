require "sinatra"
require "sinatra/reloader"
require "http"

get("/") do
  "
  <h1>Welcome to your Sinatra App!</h1>
  <p>Define some routes in app.rb</p>
  "
end
get("/umbrella") do
  erb(:umbrella_form)
end

get("/process_umbrella") do
  @user_location = params.fetch("user_loc")
  erb(:umbrella_results)
end
