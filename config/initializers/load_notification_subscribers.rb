# frozen_string_literal: true

Rails.root.glob('app/subscribers/**/*_subscriber.rb').sort.each do |source|
  require source
end
