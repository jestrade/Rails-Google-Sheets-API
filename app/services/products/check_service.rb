module Products
  class CheckService
    def initialize(
      product:,
      sheets_service: GoogleSheetsService.new,
      gemini_service: GeminiService.new
    )
      @product = product
      @sheets_service = sheets_service
      @gemini_service = gemini_service
    end

    def call
      validator = Products::ValidatorService.new(@product)

      unless validator.valid?
        return {
          success: false,
          error: validator.error_message,
          status: :bad_request
        }
      end

      sku = @product["sku"]
      found_product = @sheets_service.find_by_sku(sku)

      if found_product
        {
          success: true,
          message: "Product with SKU #{sku} already exists.",
          status: :ok
        }
      else
        confirmation_message = @gemini_service.generate_product_confirmation(@product)
        @sheets_service.add_product(@product)

        {
          success: true,
          message: confirmation_message,
          status: :ok
        }
      end
    rescue => e
      Bugsnag.notify(e)
      {
        success: false,
        error: e.message,
        status: :internal_server_error
      }
    end
  end
end
