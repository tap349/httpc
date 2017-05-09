# frozen_string_literal: true

require 'dry/struct'

module Httpc
  module Structs
    class HttpResponse < Dry::Struct
      attribute :content, Types::Strict::String
      attribute :status_code, Types::Strict::Int
      attribute :url_after_redirects, Types::String.optional
      attribute :content_type, Types::String.optional

      def success?
        status_code == 200
      end
    end
  end
end
