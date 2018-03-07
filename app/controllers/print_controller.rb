# frozen-string-literal: true

# Controller for the action of generating a printable view of the data
class PrintController < ApplicationController
  def show
    return unless validate_params?

    if params[:location].is_a?(Array)
      print_multiple_locations
    else
      print_single_location
    end
  end

  private

  # Create a download file for just a single location
  def print_single_location
    user_selections = UserSelections.new(params)
    query_command = QueryCommand.new(user_selections)
    query_command.perform_query

    format_print_results(query_command)
  end

  def print_multiple_locations
    pparams = params.permit(*UserSelections::PERMITTED, location: [])
    location_gss = pparams.delete('location')
    locations = location_gss.map { |gss| Locations.lookup_gss(gss).uri }

    query_commands = locations.map do |location|
      query_params = ActionController::Parameters.new(location: location).merge(pparams)
      QueryCommand.new(UserSelections.new(query_params))
    end

    format_print_results(query_commands)
  end

  def format_print_results(query_commands)
    respond_to do |format|
      format.html do
        @view_state = PrintPresenter.new(query_commands)
        render layout: 'print'
      end
    end
  end

  # Check that we have the params we expect
  def validate_params?
    true # TODO: add validation
  end
end
