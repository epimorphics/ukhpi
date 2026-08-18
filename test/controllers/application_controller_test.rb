require 'test_helper'

# Unit tests on ApplicationController's unhandled-error handling
class ApplicationControllerTest < ActionController::TestCase
  describe 'ApplicationController' do
    describe '#render_unexpected_error' do
      it 'should log the exception and capture it in Sentry before rendering' do
        controller = ApplicationController.new
        exception = RuntimeError.new('boom')
        exception.set_backtrace(%w[line1 line2])

        Rails.logger.expects(:error).with(
          {
            message: 'Unhandled exception: boom (RuntimeError)',
            request_status: 'error',
            status: 500,
          }
        )
        Sentry.expects(:capture_exception).with(exception)
        controller.expects(:render_application_request_error).with do |application_request_error|
          application_request_error.is_a?(ApplicationRequestError) &&
            application_request_error.status == :internal_server_error &&
            application_request_error.message == 'boom'
        end

        controller.send(:render_unexpected_error, exception)
      end

      it 'should include the backtrace in development' do
        controller = ApplicationController.new
        exception = RuntimeError.new('boom')
        exception.set_backtrace(%w[line1 line2])
        controller.stubs(:render_application_request_error)

        Rails.env.stubs(:development?).returns(true)
        Rails.logger.expects(:error).with(
          {
            message: 'Unhandled exception: boom (RuntimeError)',
            request_status: 'error',
            status: 500,
            backtrace: "line1\nline2",
          }
        )
        Sentry.stubs(:capture_exception)

        controller.send(:render_unexpected_error, exception)
      end
    end
  end
end
