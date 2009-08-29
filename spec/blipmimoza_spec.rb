require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Blipmimoza" do
  # TODO: Full test coverage ;-)
  before :all do
    @blipmimoza = Blipmimoza.new(ENV['blipuser'], ENV['blippass'])
  end
  it 'should raise an error if invalid credentials were specified' do
    lambda {Blipmimoza.new('pokapulpit', 'test')}.should raise_error RestClient::Unauthorized
  end

  it 'should raise an error if invalid resource was specified' do
    lambda {@blipmimoza.messages_from :facebook}.should raise_error ArgumentError
  end
end
