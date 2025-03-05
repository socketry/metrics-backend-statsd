# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "metrics"
require "metrics/backend/statsd"
require "metrics/backend/statsd/server"

require "io/endpoint/unix_endpoint"

require "sus/fixtures/async"
require "async/queue"

class MyClass
	def my_method(argument)
	end
end

Metrics::Provider(MyClass) do
	MYCLASS_CALL_COUNT = Metrics.metric("my_class.call", :counter, description: "Call counter.")
	
	def my_method(argument)
		MYCLASS_CALL_COUNT.emit(1, tags: ["foo", "bar"])
		
		super
	end
end

describe Metrics do
	it "has a version number" do
		expect(Metrics::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
	
	with "mock server" do
		include Sus::Fixtures::Async::ReactorContext
		
		let(:endpoint) {IO::Endpoint.unix("/tmp/metrics-#{Process.pid}-#{Time.now.to_i}.ipc", ::Socket::SOCK_DGRAM)}
		let(:client) {Metrics::Backend::Statsd::Client.new(endpoint)}
		
		before do
			@server = Metrics::Backend::Statsd::Server.new(endpoint)
			@server_task = @server.start
		end
		
		after do
			@server_task&.stop
		end
		
		it "can invoke metric wrapper" do
			Metrics::Backend::Statsd.instance = client
			
			instance = MyClass.new
			
			instance.my_method(10)
			
			message = @server.messages.pop
			expect(message).to have_keys(
				name: be == "my_class.call",
				value: be == 1.0,
				type: be == "c",
				sample_rate: be == 1.0,
				tags: be == ["foo", "bar"]
			)
		end
	end
end
