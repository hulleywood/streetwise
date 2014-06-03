namespace :latest_crimes do
  desc 'connect to SFGOV api and grab last 3 months of crime data'
  task seed: :environment do

    client = SODA::Client.new({:domain => "data.sfgov.org", app_token: ENV['DATA_TOKEN']})

    all_responses = response = client.get("tmnf-yvry")
    prev_response_count = all_responses.length

    until prev_response_count < 1000
      response = client.get("tmnf-yvry", { "$offset" => all_responses.length })
      all_responses += response
      prev_response_count = response.length
      puts prev_response_count
    end

    puts all_responses.length

    all_responses.each do |crime|
      crime.delete('location')
      Crime.create(crime)
    end
  end
end
