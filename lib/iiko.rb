# frozen_string_literal: true

require_relative "iiko/version"
require_relative "iiko/client"
require_relative "iiko/config"

##
module IIKO
  class Error < StandardError; end

  # Create api client.
  #
  # Usage:
  # ```
  # iiko = IIKO["api_login"]
  # iiko.call("organizations") => [{id: "", name: "", ...}]
  #
  # iiko = IIKO["api_login", organization_id: "restaurant guid (:id from iiko.call('organizations'))"]
  # iiko.call("payment_types") => payment types available at restaurant
  # ```
  def self.[](api_login, organization_id = nil, **options)
    Client.new(api_login: api_login, organization_id: organization_id, **options)
  end

  def self.configure
    @config = yield config
  end

  # @return [Config]
  def self.config
    @config ||= Config.new(server: "https://api-ru.iiko.services/", timeout: 60)
  end

  def self.openapi
    @openapi ||= OpenAPI.new("schemas/openapi.json")
  end
end
