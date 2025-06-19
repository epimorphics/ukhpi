# frozen_string_literal: true

# Simple controller for serving documentation
class DocController < ApplicationController
  def index
    Log.info(
      'Requesting Doc Controller',
      { params: params, path: request.path, request_status: 'processing' }
    )
    @view_state = LanguageState.new(UserLanguageSelection.new(params))
  end

  def ukhpi
    Log.info(
      'Requesting UKHPI Documentation',
      { params: params, path: request.path, request_status: 'processing' }
    )
    @view_state = LanguageState.new(UserLanguageSelection.new(params))
  end

  def ukhpi_dsd
    Log.info(
      'Requesting UKHPI DSD Documentation',
      { params: params, path: request.path, request_status: 'processing' }
    )
    send_file 'app/views/doc/ukhpi-dsd.ttl', type: 'text/turtle'
  end

  def ukhpi_user_guide
    Log.info(
      'Requesting UKHPI User Guide',
      { params: params, path: request.path, request_status: 'processing' }
    )
    send_file(
      'app/views/doc/ukhpi-user-guide.pdf',
      type: 'application/pdf',
      disposition: :inline
    )
  end
end
