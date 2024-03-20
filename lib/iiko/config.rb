# frozen_string_literal: true

module IIKO
  Config = Struct.new(
    :server,
    :timeout,
    keyword_init: true
  )
end
