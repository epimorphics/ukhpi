# frozen_string_literal: true

# Controller for routes 'about UKHPI'
class AboutController < ApplicationController
  Log.info(
    'Requesting About Controller',
    { path: request.path, request_status: 'processing' }
  )
end
