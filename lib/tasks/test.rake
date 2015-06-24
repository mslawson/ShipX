namespace :test do

  task :mfw => :environment do

    mfw = MyFreightWorld.new
    mfw.fetch_basic_quote

  end

end