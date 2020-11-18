#frozen_string_literal: true

module AlmanacParityTestingServices
  class Client

    def initialize(path:, params: nil, body: nil, http_method: nil, url: nil, headers: nil)
      @path = path
      @params = params
      @body = body
      @http_method = http_method || "get"
      @url = url
      @headers = headers || {}
    end

    def run
      result = conn.send(@http_method) do |req|
        req.url(@path)
        req.headers = headers
        req.params = @params if @params.present?
        req.body = body_string if body_string.present?
      end

      raise ArgumentError, result.body if result.status >= 500

      raise UnauthenticatedError, error_message(result.body) if result.status >= 400

      Oj.load(result.body)
    end

    private

    def error_message(body)
      Oj.load(body)["errors"].first["message"]
    end

    def headers
     {
       "accept" => "application/json",
       "Content-Type" => "application/json",
     }.merge(@headers)
    end

    def conn
      @conn ||= Faraday.new(url: @url) do |connection|
        connection.adapter Faraday.default_adapter
      end
    end

    def body_string
      @body_string ||= Oj.dump(body) if @body.present?
    end

    def default_http_method
      "get"
    end

  end
end
