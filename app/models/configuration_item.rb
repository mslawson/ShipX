class ConfigurationItem < ActiveRecord::Base
  CONFIG_KEY_SHIPX_FEE = 'shipx_std_fee'
  CONFIG_KEY_SHIPX_RECHARGE_FEE = 'shipx_addon_fee'
  CONFIG_KEY_SHIPX_FIXED_SERVICE_FEE = 'fixed_service_fee'
  CONFIG_KEY_SHIPX_VAR_SERVICE_FEE = 'var_service_fee'
  CONFIG_DEFAULT_CARRIER_ACCOUNT = 'default_carrier_account'

  def self.standard_shipx_fee
    if fee = self.value_for_key(CONFIG_KEY_SHIPX_FEE)
      fee.to_f
    else
      SHIPX['shipx_fee']
    end
  end

  def self.addon_shipx_fee
    if fee = self.value_for_key(CONFIG_KEY_SHIPX_RECHARGE_FEE)
      fee.to_f
    else
      SHIPX['addoncharge_fee']
    end
  end

  def self.fixed_service_fee
    if fee = self.value_for_key(CONFIG_KEY_SHIPX_FIXED_SERVICE_FEE)
      fee.to_f
    else
      SHIPX['service_fee_fixed']
    end
  end

  def self.var_service_fee
    if fee = self.value_for_key(CONFIG_KEY_SHIPX_VAR_SERVICE_FEE)
      fee.to_f
    else
      SHIPX['service_fee_pct']
    end
  end

  def self.default_merchant_account
    if acct = self.value_for_key(CONFIG_DEFAULT_CARRIER_ACCOUNT)
      acct
    else
      SHIPX['merchant']
    end
  end

  def self.value_for_key(key)
    ci = ConfigurationItem.where(configuration_key: key)
    if ci && ci.first
      ci.first.configuration_value
    else
      nil
    end
  end

  def friendly_name
    case configuration_key
      when CONFIG_KEY_SHIPX_FEE
        "Standard ShipX Fee"
      when CONFIG_KEY_SHIPX_FIXED_SERVICE_FEE
        "Processing Fee Fixed Portion"
      when CONFIG_KEY_SHIPX_VAR_SERVICE_FEE
        "Processing Fee Variable Portion"
      when CONFIG_KEY_SHIPX_RECHARGE_FEE
        "Extra Charge ShipX Fee (for carrier re-calculations)"
    end
  end

end
