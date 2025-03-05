# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "metrics/metric"
require "metrics/tags"

require "console"
require "io/endpoint/host_endpoint"

module Metrics
	module Backend
		module Statsd
			::Thread.attr_accessor :metrics_backend_statsd_instance
			
			class Client
				DEFAULT_ENDPOINT = IO::Endpoint.udp("localhost", 8125)
				
				def initialize(endpoint = DEFAULT_ENDPOINT)
					@endpoint = endpoint
				end
				
				def send_metric(name, value, type:, sample_rate: 1.0, tags: nil)
					return if sample_rate < 1.0 && rand > sample_rate
					
					parts = ["#{name}:#{value}|#{type}"]
					parts << "@#{sample_rate}" if sample_rate < 1.0
					parts << format_tags(tags) if tags
					
					message = parts.compact.join("|")
					
					# Basically, we don't want to block the application if the socket is not connected or otherwise unavailable:
					self.socket.sendmsg_nonblock(message, 0, exception: false)
				rescue Errno::ECONNREFUSED => error
					Console.error(self, "Failed to send metric!", error)
				end
				
				private
				
				def socket
					@socket ||= @endpoint.connect
				end
				
				def format_tags(tags)
					"##{tags.join(',')}" if tags && !tags.empty?
				end
			end
			
			def self.instance
				Thread.current.metrics_backend_statsd_instance ||= Client.new
			end
			
			def self.instance=(instance)
				Thread.current.metrics_backend_statsd_instance = instance
			end
			
			class Metric < Metrics::Metric
				def emit(value, tags: nil, sample_rate: 1.0)
					Statsd.instance.send_metric(@name, value, type: "c", sample_rate: sample_rate, tags: Tags.normalize(tags))
				end
			end
			
			class Gauge < Metric
				def emit(value, tags: nil, sample_rate: 1.0)
					Statsd.instance.send_metric(@name, value, type: "g", sample_rate: sample_rate, tags: Tags.normalize(tags))
				end
			end
			
			class Histogram < Metric
				def emit(value, tags: nil, sample_rate: 1.0)
					Statsd.instance.send_metric(@name, value, type: "h", sample_rate: sample_rate, tags: Tags.normalize(tags))
				end
			end
			
			class Distribution < Metric
				def emit(value, tags: nil, sample_rate: 1.0)
					Statsd.instance.send_metric(@name, value, type: "d", sample_rate: sample_rate, tags: Tags.normalize(tags))
				end
			end
			
			module Interface
				def metric(name, type, description: nil, unit: nil)
					klass = Metric
					
					case type
					when :counter
						# klass = Metric
					when :guage
						klass = Gauge
					when :histogram
						klass = Histogram
					when :distribution
						klass = Distribution
					end
					
					klass.new(name, type, description, unit)
				end
			end
		end
		
		Interface = Statsd::Interface
	end
end
