module ShipmentsHelper

  def step_name(step)
    ShipmentPartsController.name_for_step(step) || step.humanize.split.map(&:capitalize).join(" ")
  end

  def freight_type_name(freight_type_code)
    dict = Dictionary.where(code: 'handling_unit_types').first
    de = dict.dictionary_entries.where(key: freight_type_code).first
    if de
      return de.name
    else
      return freight_type_code
    end
  end

  def accessorial_name(dictionary, code)
    dict = Dictionary.where(code: dictionary).first
    de = dict.dictionary_entries.where(key: code).first
    if de
      return de.name
    else
      return false
    end
  end

end
