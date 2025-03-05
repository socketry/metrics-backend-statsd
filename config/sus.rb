# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

ENV["METRICS_BACKEND"] ||= "metrics/backend/statsd"

require "covered/sus"
include Covered::Sus
