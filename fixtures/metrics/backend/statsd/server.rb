# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "socket"
require "metrics/tags"
require "async"

module Metrics
	module Backend
		module Statsd
			class Server
				def initialize(endpoint)
					@endpoint = endpoint
					@messages = ::Thread::Queue.new
				end
				
				attr_reader :messages
				
				def start
					Async do |task|
						sockets = @endpoint.bind
						
						sockets.each do |socket|
							task.async do
								loop do
									message, _address = socket.recvfrom(65536)
									store_message(message)
								end
							end
						end
					end
				end

				def store_message(message)
					@messages.push(parse_message(message))
				end

				def parse_message(message)
					parts = message.strip.split("|")
					name, value = parts[0].split(":")
					type = parts[1]
					sample_rate = parts.find { |p| p.start_with?("@") }&.delete_prefix("@")&.to_f || 1.0
					tags = parts.find { |p| p.start_with?("#") }&.delete_prefix("#")&.split(",") || []
					
					return {name: name, value: value.to_f, type: type, sample_rate: sample_rate, tags: tags}
				end
			end
		end
	end
end
