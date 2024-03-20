# frozen_string_literal: true

module IIKO
  # Flat iikoCloud response
  class ResponseParser
    # @param [String] method
    # @param [String,nil] organization_id
    def initialize(method, organization_id: nil)
      @method = method.to_s
      @organization_id = organization_id
    end

    # Remove wrappers from iiko response
    def parse(data)
      return data unless should_extract_org?

      # Fetch organization data from iiko collection
      org_data = data[data_key]&.find { |e| e["organizationId"] == @organization_id }&.dig("items")

      org_data || data[data_key] || data
    end

    private

    # Key in iiko response where stored requested data. In most cases equal to method name
    def data_key
      if @method == "streets/by_city"
        "streets" # `streets/by_city` method returns data wrapped in `streets` property
      else
        @method.split("/").last.camelize(:lower)
      end
    end

    def should_extract_org?
      @organization_id && (Methods.anonymous?(@method) || Methods::PLAIN_ORG_METHODS.include?(@method))
    end
  end
end
