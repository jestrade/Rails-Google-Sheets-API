# Rails Google Sheets API

[![GitHub](https://img.shields.io/github/license/jestrade/Rails-Google-Sheets-API)](https://github.com/jestrade/Rails-Google-Sheets-API)
[![Ruby](https://img.shields.io/badge/Ruby-3.4.7-red)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1.1-red)](https://rubyonrails.org/)

A lightweight Rails API service that integrates with Google Sheets to manage product inventory. It checks for existing products by SKU and creates new entries when needed, all while providing robust error tracking through Bugsnag.

## Features

- Rails 8.1 API-only application (no database required)
- Seamless Google Sheets integration via Service Account
- Real-time product lookup by SKU
- Automatic product creation for new SKUs
- Comprehensive error tracking with Bugsnag
- SSL-secured API endpoints

## Prerequisites

- Ruby 3.4.7
- Bundler
- Google Cloud Service Account with Sheets API access

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/jestrade/Rails-Google-Sheets-API.git
   cd Rails-Google-Sheets-API
   ```

2. Install dependencies:  
   ```bash
   bundle install
   ```

## Configuration

1. Create a `.env` file in the root directory with the following variables:
   ```env
   # Google Sheets Configuration
   GOOGLE_SERVICE_ACCOUNT_JSON=path/to/your/service-account.json
   GOOGLE_SHEET_KEY=your_google_sheet_id
   
   # Bugsnag Configuration
   BUGSNAG_API_KEY=your_bugsnag_api_key
   ```

2. For Google Sheets access:
   - Share your spreadsheet with the service account email (found in your service account JSON)
   - Grant at least Editor permissions

## Running the Application

Start the development server:
```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Endpoint

### Create or Find Product

```http
POST /api/v1/products
Content-Type: application/json

{
  "product": {
    "sku": "ABC-123",
    "name": "Product Name",
    "price": "19.99",
    "metadata": "Additional information"
  }
}
```

#### Example in cURL:

```bash
curl -X POST http://localhost:3000/api/v1/products \
-H "Content-Type: application/json" \
-d '{"product":{"sku":"ABC-123","name":"My product","price":"12.50","metadata":"from api"}}'
```

#### Example Responses

**Product Found (200 OK)**
```json
{
  "exists": true,
  "product": {
    "sku": "ABC-123",
    "name": "Existing Product",
    "price": "19.99",
    "metadata": "Existing product details"
  }
}
```

**Product Created (201 Created)**
```json
{
  "exists": false,
  "created": {
    "sku": "ABC-123",
    "name": "New Product",
    "price": "19.99",
    "metadata": "New product details"
  }
}
```

**Error (4xx/5xx)**
```json
{
  "error": "Error message describing the issue"
}
```

## Error Handling

The application includes comprehensive error handling:
- All unhandled exceptions are captured and reported to Bugsnag
- Google Sheets API errors are gracefully handled
- Invalid requests receive appropriate status codes and error messages

## Development Notes

### SSL Configuration
If you encounter SSL certificate verification issues with Bugsnag, the application includes a patch that adjusts the SSL verification settings. This is automatically loaded in the initializers.

### Testing
To run the test suite:
```bash
bundle exec rspec
```

### Deployment
For production deployment:
1. Set appropriate environment variables
2. Consider adding rate limiting
3. Enable proper authentication
4. Monitor performance as Google Sheets has API rate limits

## Troubleshooting

### Common Issues
- **Permission Denied**: Ensure the service account has edit access to the spreadsheet
- **Invalid JSON**: Verify the `GOOGLE_SERVICE_ACCOUNT_JSON` is valid JSON
- **SSL Errors**: The application includes a patch for common SSL verification issues

## License

[Specify your license here]

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
