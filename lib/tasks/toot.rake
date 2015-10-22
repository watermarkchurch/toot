task :environment

namespace :toot do
  desc 'Register subscriptions with remote sources'
  task :register_subscriptions => :environment do
    Toot::RegistersSubscriptions.call
  end
end

