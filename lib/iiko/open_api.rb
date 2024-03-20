require "openapi_parser"

module IIKO
  # OpenAPI helper
  class OpenAPI
    def initialize(path_to_schema)
      schema = JSON.parse(IO.read(path_to_schema))
      @root = OpenAPIParser.parse(schema, coerce_value: true, datetime_coerce_class: Time, strict_reference_validation: true)
    end

    def validate_request(method_path, params)
      request_operation = @root.request_operation(:post, method_path)

      raise NotImplementedError, "Method #{method_path} not found in OpenAPI schema" unless request_operation

      request_operation.validate_request_body("application/json", params.transform_keys(&:to_s))
    end
  end
end
