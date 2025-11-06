class GoogleSheetsService
    # expecting a header row: e.g. ["sku", "name", "price", "metadata"]
    def initialize(worksheet = GoogleSheets.worksheet)
        @ws = worksheet
        @headers = header_row
    end


    def header_row
        # read first row and normalize to symbols
        row = @ws.rows[0] || []
        row.map { |h| h.to_s.strip.downcase }
    end


    def find_by_sku(sku)
        sku = sku.to_s.strip
        sku_col = header_index("sku")
        return nil unless sku_col


        (2..@ws.num_rows).each do |r|
        cell = @ws[r, sku_col]
        next if cell.nil?
        return row_hash(r) if cell.to_s.strip == sku
        end


        nil
    end


    def add_product(product_hash)
        values = @headers.map { |h| product_hash[h] || product_hash[h.to_sym] }

        if @headers.empty?
            new_headers = product_hash.keys.map(&:to_s)
            @ws.insert_rows(1, [ new_headers ])
            @ws.save
            @headers = header_row
            values = @headers.map { |h| product_hash[h] || product_hash[h.to_sym] }
        end

        @ws.insert_rows(@ws.num_rows + 1, [ values ])
        @ws.save

        row_hash(@ws.num_rows)
    end

    private

    def header_index(name)
        idx = @headers.index(name.to_s.strip.downcase)
        return nil unless idx
        idx + 1 # google_drive worksheets use 1-based columns
    end


    def row_hash(row_number)
        row = (1..@headers.size).map { |c| @ws[row_number, c] }
        Hash[@headers.zip(row)]
    end
end
