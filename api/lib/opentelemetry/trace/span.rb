# frozen_string_literal: true

# Copyright 2019 OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Trace
    # Span represents a single operation within a trace. Spans can be nested to
    # form a trace tree. Often, a trace contains a root span that describes the
    # end-to-end latency and, optionally, one or more sub-spans for its
    # sub-operations.
    #
    # Once Span {Tracer#start_span is created} - Span operations can be used to
    # add additional properties to it like attributes, links, events, name and
    # resulting status. Span cannot be used to retrieve these properties. This
    # prevents the mis-use of spans as an in-process information propagation
    # mechanism.
    #
    # {Span} must be ended by calling {#finish}.
    class Span
      # Retrieve the spans SpanContext
      #
      # The returned value may be used even after the Span is finished.
      #
      # @return [SpanContext]
      attr_reader :context

      # Spans must be created using {Tracer}. This is for internal use only.
      #
      # @api private
      def initialize(span_context: nil)
        @context = span_context || SpanContext.new
      end

      # Return the flag whether this span is recording events
      #
      # @return [Boolean] true if this Span is active and recording information
      #   like events with the #add_event operation and attributes using
      #   #set_attribute.
      def recording_events?
        false
      end

      # Set attribute
      #
      # Note that the OpenTelemetry project
      # {https://github.com/open-telemetry/opentelemetry-specification/blob/master/semantic-conventions.md
      # documents} certain "standard attributes" that have prescribed semantic
      # meanings.
      #
      # @param [String] key
      # @param [String, Boolean, Numeric] value
      #
      # @return [self] returns itself
      def set_attribute(key, value)
        raise ArgumentError unless Internal.valid_key?(key)
        raise ArgumentError unless Internal.valid_value?(value)

        self
      end
      alias []= set_attribute

      # Add an Event to Span
      #
      # Note that the OpenTelemetry project
      # {https://github.com/open-telemetry/opentelemetry-specification/blob/master/semantic-conventions.md
      # documents} certain "standard event names and keys" which have
      # prescribed semantic meanings.
      #
      # @param [String, Callable] name_or_event_formatter The name of the event
      #   or an EventFormatter, a lazily evaluated callable that returns an
      #   {Event} instance.
      # @param [optional Hash<String, Object>] attrs One or more key:value pairs, where
      #   the keys must be strings and the values may be string, boolean or
      #   numeric type. This argument should only be used when passing in a
      #   name, not an EventFormatter.
      # @param [Time] timestamp optional timestamp for the event.
      #
      # @return [self] returns itself
      def add_event(name_or_event_formatter, attrs = nil, timestamp: nil)
        raise ArgumentError unless name_or_event_formatter.is_a?(String) || name_or_event_formatter.is_a?(Proc)
        raise ArgumentError unless Internal.valid_attributes?(attrs)
        raise ArgumentError if name_or_event_formatter.is_a?(Proc) && !attrs.nil?

        self
      end

      # Adds a link to another Span from this Span. The linked Span can be from
      # the same or different trace. See {Link} for a description.
      #
      # @param [SpanContext, Callable] span_context_or_link_formatter The
      #   {SpanContext} context of the Span to link with this Span or a
      #   LinkFormatter, a lazily evaluated callable that returns a {Link}
      #   instance.
      # @param [optional Hash<String, Object>] attrs Map of attributes associated with
      #   this link. Attributes are key:value pairs where key is a string and
      #   value is one of string, boolean or numeric type. This argument should
      #   only be used when passing in a {SpanContext}, not a LinkFormatter.
      #
      # @return [self] returns itself
      def add_link(span_context_or_link_formatter, attrs = nil)
        raise ArgumentError unless span_context_or_link_formatter.instance_of?(SpanContext) || span_context_or_link_formatter.is_a?(Proc)
        raise ArgumentError unless Internal.valid_attributes?(attrs)
        raise ArgumentError if span_context_or_link_formatter.is_a?(Proc) && !attrs.nil?

        self
      end

      # Sets the Status to the Span
      #
      # If used, this will override the default Span status. Default is OK.
      #
      # Only the value of the last call will be recorded, and implementations
      # are free to ignore previous calls.
      #
      # @param [Status] status The new status, which overrides the default Span
      #   status, which is OK.
      #
      # @return [void]
      def status=(status)
        raise ArgumentError unless status.is_a?(Status)
      end

      # Updates the Span name
      #
      # Upon this update, any sampling behavior based on Span name will depend
      # on the implementation.
      #
      # @param [String] new_name The new operation name, which supersedes
      #   whatever was passed in when the Span was started
      #
      # @return [void]
      def name=(new_name)
        raise ArgumentError if new_name.nil?
      end

      # Finishes the Span
      #
      # Implementations MUST ignore all subsequent calls to {#finish} (there
      # might be exceptions when Tracer is streaming event and has no mutable
      # state associated with the Span).
      #
      # Call to {#finish} MUST not have any effects on child spans. Those may
      # still be running and can be ended later.
      #
      # This API MUST be non-blocking.
      #
      # @param [Time] end_timestamp optional end timestamp for the span.
      #
      # @return [self] returns itself
      def finish(end_timestamp: nil)
        self
      end
    end
  end
end
