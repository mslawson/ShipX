class DeviseMailer < Devise::Mailer
  default from: "david@dhanson.org"
  include Resque::Mailer
  layout 'email'


end