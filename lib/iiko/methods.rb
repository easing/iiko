# frozen_string_literal: true

module IIKO
  module Methods
    # Сервисные методы API, работающие вне контекста организации
    ANONYMOUS = %w[
      access_token
      organizations
    ].freeze

    V2_METHODS = [
      "menu",
      "menu/by_id"
    ].freeze

    # Методы, требующие указания `organizationId, но не оборачивающие ответ в {organizationId => result}
    PLAIN_ORG_METHODS = [
      "nomenclature",
      "combo/get_combos_info",
      "combo/calculate_combo_price"
    ].freeze

    # Методы API, работающие в контексте одной организации и принимающие обязательный параметр `<String>organizationId`
    # Остальные методы требуют массив идентификаторов `<String[]>organizationIds`
    SINGLE_ORG_METHODS = [
      "streets/by_city",

      "commands/status",

      "deliveries/create",
      "deliveries/update_order_problem",
      "deliveries/update_order_delivery_status",
      "deliveries/update_order_courier",
      "deliveries/add_items",
      "deliveries/close",
      "deliveries/cancel",
      "deliveries/change_complete_before",
      "deliveries/change_delivery_point",
      "deliveries/change_service_type",
      "deliveries/change_payments",
      "deliveries/by_id",
      "delivery_restrictions/update",

      "order/create",
      "order/add_items",
      "order/close",
      "order/change_payments",

      "loyalty/iiko/get_customer",
      "loyalty/iiko/calculate_checkin",
      "loyalty/iiko/get_manual_conditions",
      "loyalty/iiko/customer/create_or_update",
      "loyalty/iiko/customer/wallet/hold",
      "loyalty/iiko/customer/wallet/cancel_hold",
      "loyalty/iiko/program"
    ].freeze

    # @param [String] method
    # @return [TrueClass, FalseClass]
    def self.single?(method)
      PLAIN_ORG_METHODS.include?(method) || SINGLE_ORG_METHODS.include?(method)
    end

    # @param [String] method
    # @return [TrueClass, FalseClass]
    def self.anonymous?(method)
      ANONYMOUS.include?(method)
    end

    # @param [String] method
    # @return [Integer]
    def self.version_for(method)
      if V2_METHODS.include?(method)
        2
      else
        1
      end
    end
  end
end
