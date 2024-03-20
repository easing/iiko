# frozen_string_literal: true

module IIKO
  # Processed iikoCloud response
  class Response
    extend Forwardable

    attr_reader :response

    delegate %i[status body env] => :response
    delegate :[] => :body

    # @param [Faraday::Response] response
    def initialize(response)
      @response = response
    end

    def api_login_disabled?
      unauthenticated? && body["errorDescription"].to_s.match?(/\ALogin (\w+) is not authorized\.\z/)
    end

    def successful? = status == 200

    def unauthenticated? = status == 401

    def error_message
      return "Api Login Locked: #{body}" if api_login_disabled?

      case status
      when 200..399 then nil
      when 400 then "Bad Request: #{body}"
      when 401 then "Unauthorized: #{body}"
      when 404 then "Not Found: (#{env.url}) => #{body}"
      when 408 then "Request Timeout: #{body}"
      when 500 then "Server Error: #{body}"
      when 504 then "Gateway Timeout #{body}"
      else
        "Unknown Error: #{status}, #{headers}, #{body}"
      end
    end
  end
end
