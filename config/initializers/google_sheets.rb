require "google_drive"

GoogleSheets = Module.new do
    class << self
        def session
            return @session if @session


            sa_json = ENV["GOOGLE_SERVICE_ACCOUNT_JSON"]
            sheet_key = ENV["GOOGLE_SHEET_KEY"]


            raise "Set GOOGLE_SERVICE_ACCOUNT_JSON and GOOGLE_SHEET_KEY" unless sa_json && sheet_key


            # If GOOGLE_SERVICE_ACCOUNT_JSON contains the JSON content, use StringIO
            if sa_json.strip.start_with?("{")
                require "stringio"
                @session = GoogleDrive::Session.from_service_account_key(StringIO.new(sa_json))
            else
                # Otherwise treat it like a path
                @session = GoogleDrive::Session.from_service_account_key(sa_json)
            end


            @spreadsheet = @session.spreadsheet_by_key(sheet_key)
            @session
        end


        def spreadsheet
            session unless defined?(@spreadsheet)
            @spreadsheet
        end


        def worksheet(index = 0)
            spreadsheet.worksheets[index]
        end
    end
end
