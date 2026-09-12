require 'test_helper'

# Unit tests on the LatestValuesCommand class.
#
# The distinction these cover is deliberate: an unavailable data API is an
# expected condition and degrades to an apology message, while an error in our
# own code is a bug and must not be hidden behind that same message.
class LatestValuesCommandTest < ActiveSupport::TestCase
  describe 'LatestValuesCommand' do
    let(:apology) do
      'Our apologies, but the latest index values are not available. Please check back again soon.'
    end

    describe 'when the data API answers' do
      it 'returns true and captures the results' do
        service = stub
        service.expects(:query).returns([ { 'ukhpi:refMonth' => '2024-01' } ])

        command = LatestValuesCommand.new
        _(command.perform_query(service)).must_equal true
        _(command.results).must_equal([ { 'ukhpi:refMonth' => '2024-01' } ])
      end
    end

    describe 'when the data API is unavailable' do
      it 'degrades to the apology message on a connection failure' do
        service = stub
        service.expects(:query).raises(Faraday::ConnectionFailed.new('Connection refused'))

        _(LatestValuesCommand.new.perform_query(service)).must_equal apology
      end

      it 'degrades to the apology message on a service exception' do
        service = stub
        service.expects(:query).raises(DataServicesApi::ServiceException.new('Bad gateway', 502))

        _(LatestValuesCommand.new.perform_query(service)).must_equal apology
      end

      it 'does not log the failure itself, since ApiRequestLogSubscriber does' do
        service = stub
        service.expects(:query).raises(Faraday::ConnectionFailed.new('Connection refused'))
        Rails.logger.expects(:error).never
        Rails.logger.expects(:warn).never

        LatestValuesCommand.new.perform_query(service)
      end
    end

    describe 'when our own code raises' do
      it 'lets a NoMethodError propagate rather than showing the apology' do
        service = stub
        service.expects(:query).raises(NoMethodError.new("undefined method 'foo'"))

        _ { LatestValuesCommand.new.perform_query(service) }.must_raise NoMethodError
      end

      it 'lets an ArgumentError propagate rather than showing the apology' do
        service = stub
        service.expects(:query).raises(ArgumentError.new('wrong number of arguments'))

        _ { LatestValuesCommand.new.perform_query(service) }.must_raise ArgumentError
      end
    end
  end
end
