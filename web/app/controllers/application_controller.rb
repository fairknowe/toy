# frozen_string_literal: true

class ApplicationController < ActionController::Base
    # before_action :log_request

    private

    def log_request
        Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in ApplicationController. Processing #{request.method} request to #{request.path} with params: #{request.filtered_parameters}")
    end
end
