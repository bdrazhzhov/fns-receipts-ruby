# frozen_string_literal: true

module Fns
  class Error < StandardError
    attr_reader :response

    def initialize(response = nil)
      @response = response
      super
    end
  end

  class UnknownToken < Error; end
  class Unauthorized < Error; end
end
