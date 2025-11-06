require 'rails_helper'

RSpec.describe GeminiService do
  let(:api_key) { 'test_api_key' }
  let(:model) { 'gemini-pro' }
  let(:service) { described_class.new(api_key: api_key, model: model) }

  describe '#generate_content' do
    let(:prompt) { 'Test prompt' }
    let(:api_url) { "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent" }

    context 'when API call is successful' do
      it 'returns the generated text' do
        stub_request(:post, api_url)
          .with(
            query: { key: api_key },
            headers: { 'Content-Type' => 'application/json' },
            body: hash_including(
              contents: [
                {
                  role: 'user',
                  parts: [ { text: prompt } ]
                }
              ]
            )
          )
          .to_return(
            status: 200,
            body: {
              candidates: [
                {
                  content: {
                    parts: [
                      { text: 'Generated response from Gemini' }
                    ]
                  }
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = service.generate_content(prompt)

        expect(result).to eq('Generated response from Gemini')
      end
    end

    context 'when API returns empty response' do
      it 'returns default message' do
        stub_request(:post, api_url)
          .to_return(
            status: 200,
            body: { candidates: [] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = service.generate_content(prompt)

        expect(result).to eq('No response from Gemini.')
      end
    end

    context 'when API call fails' do
      it 'notifies Bugsnag and returns default message' do
        stub_request(:post, api_url)
          .to_return(status: 500, body: 'Internal Server Error')

        allow(Bugsnag).to receive(:notify)

        result = service.generate_content(prompt)

        expect(result).to eq('No response from Gemini.')
        expect(Bugsnag).to have_received(:notify).with(/Gemini API error/)
      end
    end

    context 'when an exception occurs' do
      it 'notifies Bugsnag and returns default message' do
        stub_request(:post, api_url)
          .with(
            query: { key: api_key },
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_raise(StandardError.new('Connection error'))

        allow(Bugsnag).to receive(:notify)

        result = service.generate_content(prompt)

        expect(result).to eq('No response from Gemini.')
        expect(Bugsnag).to have_received(:notify).with(instance_of(StandardError))
      end
    end
  end

  describe '#generate_product_confirmation' do
    let(:product) do
      {
        'sku' => 'ABC-123',
        'name' => 'Test Product',
        'price' => '19.99'
      }
    end

    it 'generates a confirmation message with product details' do
      expected_prompt = <<~PROMPT
        A new product is being added to a Google Sheet.
        Product details: SKU is "ABC-123", Name is "Test Product", and Price is 19.99.
        Generate a short, friendly confirmation message for the user, confirming the product has been added.
      PROMPT

      expect(service).to receive(:generate_content).with(expected_prompt).and_return('Product added!')

      result = service.generate_product_confirmation(product)

      expect(result).to eq('Product added!')
    end
  end
end
