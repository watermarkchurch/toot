module Toot
  class Rails < Rails::Railtie
    rake_tasks do
      Dir.glob(File.expand_path("../../tasks/*.rake", __FILE__)).each do |rake_file|
        load rake_file
      end
    end
  end if defined?(Rails::Railtie)
end
