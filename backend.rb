require 'base64'
require 'httparty'
require 'sinatra/base'

if ENV['RACK_ENV'] == 'development'
  require 'sinatra/reloader'
  require 'pry'
end

class Backend < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  # Note: Storing your actual Klarna credentials this way is a bad idea
  API_KEY = 'test_d8324b98-97ce-4974-88de-eaab2fdf4f14'
  API_SECRET = 'test_846853f798502446dbaf11ee8365fef2e533ddde1f5d6a6caa961398a776c08c'

  # This represents the inventory
  CATALOG = {
    'TCKT0001' => {
      name:     'Movie ticket - The Girl with the Dragon Tattoo',
      cost:     9900,
      tax_cost: 990
    }
  }

  post '/pay' do
    params.merge!(JSON.parse(request.body.read))

    basic_auth_options = {
      basic_auth: { username: API_KEY, password: API_SECRET}
    }

    item = CATALOG[params[:reference]]

    authorize_request_options = {
      headers: { 'Content-Type' => 'application/json' },
      body: {
        reference:        params[:reference],
        name:             item[:name],
        order_amount:     item[:cost],
        order_tax_amount: item[:tax_cost],
        currency:         'SEK',
        capture:          false,
        origin_proof:     params[:origin_proof]
      }.to_json
    }.merge!(basic_auth_options)

    authorize_url = "https://inapp.playground.klarna.com/api/v1/users/#{params[:user_token]}/orders"
    authorize_payment_response = HTTParty.post(authorize_url, authorize_request_options)

    if (authorize_payment_response && authorize_payment_response.code == 201)
      capture_response = HTTParty.post("#{authorize_payment_response}/capture", basic_auth_options)
    else
      halt authorize_payment_response.code, 'Failed to authorize purchase'
    end

    if (capture_response && capture_response.code == 200)
      status 204
    else
      halt authorize_payment_response.code, 'Failed to capture order'
    end
  end
end
