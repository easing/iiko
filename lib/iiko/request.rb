# frozen_string_literal: true

require_relative "methods"

module IIKO
  # Request data
  class Request
    attr_reader :path, :params, :body

    def initialize(method, params = {}, organization_id:)
      @path = "/api/#{Methods.version_for(method)}/#{method}".freeze
      @params = default_params_for(method, organization_id).merge(params).transform_keys(&:to_s)
      @body = @params.to_json
    end

    private

    # @param [String] method Cloud API method name/path
    # @param [String] organization_id Restaurant Id
    def default_params_for(method, organization_id)
      if Methods.anonymous?(method)
        {}
      elsif Methods.single?(method)
        { organizationId: organization_id }
      else
        { organizationIds: [organization_id] }
      end
    end
  end
end
