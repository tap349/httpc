# frozen_string_literal: true

module Httpc
  module Errors
    # use it when reraising gem errors caused by standard errors
    def self.format_message error
      "#{error.class.name}: #{error.message}"
    end
  end

  HttpcError = Class.new(StandardError)

  BadDownloadStatusError = Class.new(HttpcError) do
    def initialize response
      url = response.env['url']
      status = response.status

      super "response status #{status} for #{url}"
    end
  end

  DownloadError = Class.new(HttpcError)
end
