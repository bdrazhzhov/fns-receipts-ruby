# frozen_string_literal: true

RSpec.describe Fns::Client do
  describe '#create_session' do
    let(:phone_number) { rand.to_s }

    before do
      stub_request(:post, "#{Fns::API_BASE_URL}/auth/phone/request")
        .with(
          body: { phone: phone_number, client_secret: Fns::CLIENT_SECRET, os: Fns::DEVICE_OS },
          headers: Fns::HEADERS
        ).to_return(status: response_status)
    end

    context 'when request succeed' do
      let(:response_status) { 204 }

      it 'returns client session' do
        result = described_class.create_session(phone_number)
        expect(result).to be_nil
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }

      it 'raises an exception' do
        expect { described_class.create_session(phone_number) }.to raise_error(Fns::Error)
      end
    end
  end

  describe '#verify_session' do
    let(:status_code) { 200 }
    let(:phone_number) { rand.to_s }
    let(:code) { rand.to_s }

    before do
      stub_request(:post, "#{Fns::API_BASE_URL}/auth/phone/verify")
        .with(
          body: { phone: phone_number, client_secret: Fns::CLIENT_SECRET, os: Fns::DEVICE_OS, code: code }.to_json,
          headers: Fns::HEADERS
        ).to_return(status: response_status, body: response)
    end

    context 'when request succeed' do
      let(:response_status) { 200 }
      let(:session_id) { rand.to_s }
      let(:refresh_token) { rand.to_s }
      let(:response) do
        {
          sessionId: session_id,
          refresh_token: refresh_token,
          phone: phone_number
        }.to_json
      end
      let(:result) { described_class.verify_session(phone_number, code) }

      it 'session_id is set' do
        expect(result[:session_id]).to eq(session_id)
      end

      it 'refresh_token is set' do
        expect(result[:refresh_token]).to eq(refresh_token)
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }
      let(:response) { '' }

      it 'raises error returned by API' do
        expect { described_class.verify_session(phone_number, code) }.to raise_error(Fns::Error)
      end
    end
  end

  describe '#refresh_session' do
    let(:refresh_token) { rand.to_s }

    before do
      stub_request(:post, "#{Fns::API_BASE_URL}/mobile/users/refresh")
        .with(
          body: { refresh_token: refresh_token, client_secret: Fns::CLIENT_SECRET }.to_json,
          headers: Fns::HEADERS
        ).to_return(status: response_status, body: response)
    end

    context 'when request succeed' do
      let(:response_status) { 200 }
      let(:new_session_id) { rand.to_s }
      let(:new_refresh_token) { rand.to_s }
      let(:response) do
        {
          sessionId: new_session_id,
          refresh_token: new_refresh_token
        }.to_json
      end
      let(:result) { described_class.refresh_session(refresh_token) }

      it 'session_id is set' do
        expect(result[:session_id]).to eq(new_session_id)
      end

      it 'refresh_token is set' do
        expect(result[:refresh_token]).to eq(new_refresh_token)
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }
      let(:response) { '' }

      it 'raises error returned by API' do
        expect { described_class.refresh_session(refresh_token) }.to raise_error(Fns::Error)
      end
    end
  end

  describe '#get_bill_data' do
    let(:ticket_id) { rand.to_s }
    let(:session_id) { rand.to_s }

    before do
      allow(described_class).to receive(:get_ticket).and_return(ticket_id)

      stub_request(:get, "#{Fns::API_BASE_URL}/tickets/#{ticket_id}")
        .with(headers: Fns::HEADERS.merge(sessionId: session_id))
        .to_return(status: response_status, body: bill_data.to_json)
    end

    context 'when request succeed' do
      let(:response_status) { 200 }
      let(:bill_data) { { 'a' => 1, 'b' => 2 } }

      it 'return bill data' do
        result = described_class.get_bill_data(session_id, '')
        expect(result).to eq(bill_data)
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }
      let(:bill_data) { '' }

      it 'raises error returned by API' do
        expect { described_class.get_bill_data(session_id, '') }.to raise_error(Fns::Error)
      end
    end

    context 'when request is unauthorized' do
      let(:response_status) { 401 }
      let(:bill_data) { 'Unauthorized' }

      it 'raises Unauthorized exception' do
        expect { described_class.get_bill_data(session_id, '') }.to raise_error(Fns::Unauthorized)
      end
    end
  end

  describe '#get_ticket' do
    let(:session_id) { rand.to_s }
    let(:qr) { rand.to_s }
    let(:ticket_id) { rand.to_s }

    before do
      stub_request(:post, "#{Fns::API_BASE_URL}/ticket")
        .with(
          body: { qr: qr }.to_json,
          headers: Fns::HEADERS.merge(sessionId: session_id)
        ).to_return(status: response_status, body: result_data)
    end

    context 'when request succeed' do
      let(:response_status) { 200 }
      let(:result_data) { { id: ticket_id, kind: 'kkt' }.to_json }

      it 'return ticket id' do
        result = described_class.send(:get_ticket, session_id, qr)
        expect(result).to eq(ticket_id)
      end
    end

    context 'when request is unauthorized' do
      let(:response_status) { 401 }
      let(:result_data) { 'Unauthorized' }

      it 'raises Unauthorized exception' do
        expect { described_class.send(:get_ticket, session_id, qr) }.to raise_error(Fns::Unauthorized)
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }
      let(:result_data) { '' }

      it 'raises error returned by API' do
        expect { described_class.send(:get_ticket, session_id, qr) }.to raise_error(Fns::Error)
      end
    end
  end
end
