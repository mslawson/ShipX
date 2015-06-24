env = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'

MY_FREIGHT_WORLD = YAML.load(File.read(File.expand_path('../../my_freight_world.yml',__FILE__)))[env]


SHIPX = YAML.load(File.read(File.expand_path('../../shipx.yml', __FILE__)))[env]
