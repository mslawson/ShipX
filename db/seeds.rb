# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ConfigurationItem.create(configuration_key: ConfigurationItem::CONFIG_KEY_SHIPX_FEE, configuration_value: '14.95')
ConfigurationItem.create(configuration_key: ConfigurationItem::CONFIG_KEY_SHIPX_RECHARGE_FEE, configuration_value: '14.95')
ConfigurationItem.create(configuration_key: ConfigurationItem::CONFIG_KEY_SHIPX_FIXED_SERVICE_FEE, configuration_value: '0.30')
ConfigurationItem.create(configuration_key: ConfigurationItem::CONFIG_KEY_SHIPX_VAR_SERVICE_FEE, configuration_value: '0.029')
