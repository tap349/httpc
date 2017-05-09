# frozen_string_literal: true

require 'uri'
require 'faraday'
require 'faraday_middleware'

require 'httpc/version'
require 'httpc/types'
require 'httpc/errors'
require 'httpc/helpers/presence'
require 'httpc/structs/http_response'

module Httpc
  extend Helpers::Presence

  MAX_REDIRECT_LIMIT = 20
  OPEN_TIMEOUT = 60
  TIMEOUT = 120

  class << self
    def get url, token = nil, options = {}
      response = get_response!(url, token, options)
      check_response_status!(response)

      Structs::HttpResponse.new(
        content: response.body,
        status_code: response.status,
        url_after_redirects: url_after_redirects(response),
        content_type: content_type(response)
      )
    rescue BadDownloadStatusError
      raise
    rescue => e
      raise DownloadError, Errors.format_message(e), e.backtrace
    end

    private

    def get_response! url, token, options
      uri = URI(url)
      faraday(uri, token, options).get(uri)
    end

    def check_response_status! response
      raise(BadDownloadStatusError, response) unless response.success?
    end

    def faraday uri, token, options
      options = { ssl: { verify: false } }.merge(options)
      Faraday.new(options) do |f|
        f.use FaradayMiddleware::FollowRedirects, limit: MAX_REDIRECT_LIMIT
        # set adapter after enabling middleware to follow redirects -
        # otherwise response headers are not set for some reason
        f.adapter Faraday.default_adapter

        f.basic_auth(uri.user, uri.password) if present?(uri.userinfo)
        f.token_auth(token) unless token.nil?

        f.options.open_timeout = OPEN_TIMEOUT
        f.options.timeout = TIMEOUT
      end
    end

    def url_after_redirects response
      response.env['url'].to_s
    end

    def content_type response
      response.env['response_headers']['content-type']
    end
  end
end
