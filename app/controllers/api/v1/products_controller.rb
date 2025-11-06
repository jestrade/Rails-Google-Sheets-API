module Api
  module V1
    class ProductsController < ActionController::API
      def create
        product = product_params.to_h
        unless product["sku"] || product[:sku]
        return render json: { error: "sku is required" }, status: :bad_request
        end

        service = GoogleSheetsService.new
        sku = product["sku"] || product[:sku]


        found = service.find_by_sku(sku)
        if found
          render json: { exists: true, product: found }, status: :ok
        else
          created = service.add_product(product)
          render json: { exists: false, created: created }, status: :created
        end
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end

      private

      def product_params
        params.require(:product).permit(:sku, :name, :price, :metadata)
      end
    end
  end
end
