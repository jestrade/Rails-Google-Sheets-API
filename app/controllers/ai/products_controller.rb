require "faraday"
require "json"

module Ai
  class ProductsController < ActionController::API
    def check
      product = product_params.to_h
      sku = product["sku"]
      if sku.blank?
        return render json: { error: "sku is required" }, status: :bad_request
      end

      service = GoogleSheetsService.new
      found_product = service.find_by_sku(sku)

      if found_product
        render json: { message: "Product with SKU #{sku} already exists." }
      else
        prompt = <<~PROMPT
          A new product is being added to a Google Sheet.
          Product details: SKU is "#{sku}", Name is "#{product["name"]}", and Price is #{product["price"]}.
          Generate a short, friendly confirmation message for the user, confirming the product has been added.
        PROMPT

        response_text = ask_gemini(prompt)
        service.add_product(product)

        render json: { message: response_text }
      end
    rescue => e
      Bugsnag.notify(e)

      render json: { error: e.message }, status: :internal_server_error
    end

    private

    def product_params
      params.require(:product).permit(:sku, :name, :price, :metadata)
    end

    def ask_gemini(prompt)
      api_key = ENV["GEMINI_API_KEY"]
      model = ENV["GEMINI_MODEL"]

      conn = Faraday.new(
        url: "https://generativelanguage.googleapis.com",
        params: { key: api_key },
        headers: { "Content-Type" => "application/json" }
      )

      body = {
        contents: [
          {
            role: "user",
            parts: [ { text: prompt } ]
          }
        ]
      }

      response = conn.post("/v1beta/models/#{model}:generateContent", body.to_json)

      if response.success?
        data = JSON.parse(response.body)
        data.dig("candidates", 0, "content", "parts", 0, "text") || "No response from Gemini."
      else
        Bugsnag.notify("Gemini API error: #{response.status} #{response.body}")
        "No response from Gemini."
      end
    rescue => e
      Bugsnag.notify(e)
      "No response from Gemini."
    end
  end
end
