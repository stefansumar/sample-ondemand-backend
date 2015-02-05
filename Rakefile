desc "Set your API credentials"
task :set_credentials do
  print "Please enter your API key: "
  key = STDIN.gets.chomp

  print "Please enter your API secret: "
  secret = STDIN.noecho(&:gets).chomp

  code = <<-CODE.gsub(/^\s{4}/, '')
    module Credentials
      # This file was generated by the "set_credentials" rake task.
      def self.api_key
        '#{key}'
      end
    
      def self.api_secret
        '#{secret}'
      end
    end
  CODE

  File.open('credentials.rb', 'w') do |file|
    file.write(code)
  end
end
