module Toot
  class Rails < Rails::Railtie
    rake_tasks do
      Dir.glob(File.expand_path("../../tasks/*.rake", __FILE__))
    end
  end if defined?(Rails::Railtie)
end
