env = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'
REDIS_CONFIG = YAML.load(File.read(File.expand_path('../../redis.yml', __FILE__)))[env]


Resque.redis = REDIS_CONFIG
Resque.inline = Rails.env == 'development'