# frozen_string_literal: true

Dir[Rails.root.join('app/subscribers/**/*_subscriber.rb')].sort.each do |source|
  require source
end
