ENV['RAILS_ENV'] = "development" unless ENV['RAILS_ENV']
AWS_CONFIG = YAML.load(File.read("#{Rails.root}/config/aws.yml"))[ENV['RAILS_ENV']]

AWS.config({
     :access_key_id => AWS_CONFIG['aws_key'],
     :secret_access_key => AWS_CONFIG['aws_secret'],
})

ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id => AWS_CONFIG['aws_key'],
  :secret_access_key => AWS_CONFIG['aws_secret']