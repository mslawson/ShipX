namespace :import do

  task :dictionaries => [:environment] do

    # import data from dictionary calls
    # this is non-destructive and will just add any new data that appears, or update names
    mfw = MyFreightWorld.new
    mfw.import_data_dictionaries

  end

  task :tracking => [:environment] do
    mfw = MyFreightWorld.new
    Shipment.all.booked do |shipment|
      mfw.update_tracking(shipment)
    end
  end

end