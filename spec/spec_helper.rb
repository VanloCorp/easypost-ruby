require 'open-uri'
require 'easypost'
require 'vcr'

Dir["./spec/support/**/*.rb"].each { |f| require f }

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.default_cassette_options = {
    match_requests_on: [:uri, :body],
  }

  config.before_record do |interaction|
    if interaction.request.headers["Authorization"]
      interaction.request.headers["Authorization"] = "<AUTHORIZATION>"
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    EasyPost.api_key = 'BmvaWhg8mP26QXWdTplYWA'
  end

  config.around(:each) do |example|
    path = example.file_path.gsub("_spec.rb", "").gsub("./spec/", "")
    description = example.full_description

    VCR.use_cassette(
      "#{path}/#{description}",
      example.metadata.fetch(:vcr, {})
    ) do
      example.call
    end
  end
end
