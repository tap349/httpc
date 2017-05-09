# frozen_string_literal: true

module Httpc
  module Helpers
    module Presence
      def blank? value
        return true if value.nil?
        return true if value.respond_to?(:empty?) && value.empty?

        false
      end

      def present? value
        !blank?(value)
      end
    end
  end
end
