require "sinatra"
require "sinatra/reloader"
require "http"

get("/") do
    erb(:homepage)
end
get("/umbrella") do
  erb(:umbrella_form)
end

post("/process_umbrella") do
  @user_location = params.fetch("user_loc")

  url_encoded_string = @user_location.gsub(" ", "%20")

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + url_encoded_string + "&key=" + ENV.fetch("GMAPS_KEY")

  @raw_response = HTTP.get(gmaps_url).to_s

  @parsed_response = JSON.parse(@raw_response)

  @loc_hash = @parsed_response.dig("results", 0, "geometry","location")

  @latitude = @loc_hash.fetch("lat")
  @longitude = @loc_hash.fetch("lng")

  @pirate_weather_api_key = ENV.fetch("PIRATE_WEATHER_KEY")

  @pirate_weather_url = "https://api.pirateweather.net/forecast/#{@pirate_weather_api_key}/#{@latitude},#{@longitude}"

  # Place a GET request to the URL
  @raw_response = HTTP.get(@pirate_weather_url)

  @parsed_response = JSON.parse(HTTP.get(@pirate_weather_url))

  @currently_hash = @parsed_response.fetch("currently")
  @current_temp = @currently_hash.fetch("temperature")
  @hourly_hash = @parsed_response.fetch("hourly")
  @hourly_summary = @hourly_hash.fetch("summary")

  @hourly_data = @hourly_hash.fetch("data")
  @will_need_umbrella = false

  @hourly_data[0..11].each_with_index do |hour_data, index|
  @precipitation_probability = hour_data.fetch("precipProbability")

  if @precipitation_probability > 0.1
    @will_need_umbrella = true
    puts "There's a high chance (#{@precipitation_probability * 100}%) of precipitation in #{index + 1} hour(s)."
  else
    puts "There's a low chance (#{@precipitation_probability * 100}%) of precipitation in #{index + 1} hour(s)."
  end

  if @will_need_umbrella
    @umbrella = "You might want to take an umbrella!"
  else
    @umbrella = "You probably won't need an umbrella."
  end
end

  erb(:umbrella_results)
end


get("/message") do
  erb(:message_form)
end

get("/chat") do
  erb(:chat_form)
end
