# frozen_string_literal: true

require "faraday"

require_relative "open_api"
require_relative "request"
require_relative "response"
require_relative "response_parser"

module IIKO
  # Thin wrapper for iikoCloud API [api-ru.iiko.services]
  # This gem provides developer friendly way to work with iiko API
  class Client
    ACCESS_TOKEN_METHOD = "access_token"

    def initialize(api_login:, organization_id: nil, server_uri: IIKO.config.server, timeout: IIKO.config.timeout)
      @api_login = api_login
      @organization_id = organization_id

      @access_token = nil

      @connection = Faraday.new(server_uri) do |conn|
        conn.headers["Content-Type"] = "application/json"
        conn.headers["Timeout"] = timeout.to_s
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    # Call method in iiko Cloud API
    #
    # @param [String] method
    # @param [Hash] params
    # @return [Hash]
    def call(method, params = {})
      authenticate! unless method == ACCESS_TOKEN_METHOD # Any method call except this one MUST be authenticated

      request = IIKO::Request.new(method, params, organization_id: @organization_id)

      validate_request(request)

      iiko_response = send_request_to_iiko(request)

      response = IIKO::Response.new(iiko_response)

      raise IIKO::Error, response.error_message unless response.successful?

      # Refresh access_token and try again if iiko respond with `not authenticated` when we have access_token
      return refresh_auth! && call(method, params) if response.unauthenticated? && @access_token

      ResponseParser.new(method, organization_id: @organization_id).parse(response.body)
    end

    # Fetch and save access token for future requests
    # Access token is live for about one hour and after that new token should be requested
    def authenticate!
      @access_token = call("access_token", apiLogin: @api_login)["token"]
    end

    # Reset current and fetch new authorization token
    def refresh_auth!
      @access_token = nil
      authenticate!
    end

    def send_request_to_iiko(request)
      @connection.post(request.path, request.body) do |req|
        req.headers["Authorization"] = "Bearer #{@access_token}" if @access_token
      end
    end

    def validate_request(request)
      IIKO.openapi.validate_request(request.path, request.params)
    end
  end
end
