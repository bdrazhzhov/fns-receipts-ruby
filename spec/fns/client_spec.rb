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
        result = Fns::Client.create_session(phone_number)
        expect(result).to be_a Fns::Session
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }

      it 'raises an exception' do
        expect { Fns::Client.create_session(phone_number) }.to raise_error(Fns::Error)
      end
    end
  end

  describe '#get_bill_data' do
    let(:session) { Fns::Session.new(rand.to_s) }
    let(:ticket_id) { rand.to_s }
    let(:session_id) { rand.to_s }

    before do
      allow(Fns::Client).to receive(:get_ticket).and_return(ticket_id)
      session.instance_variable_set(:@session_id, session_id)

      stub_request(:get, "#{Fns::API_BASE_URL}/tickets/#{ticket_id}")
        .with(headers: Fns::HEADERS.merge(sessionId: session_id))
        .to_return(status: response_status, body: bill_data.to_json)
    end

    context 'when request succeed' do
      let(:response_status) { 200 }
      let(:bill_data) { { 'a' => 1, 'b' => 2 } }

      it 'return bill data' do
        result = Fns::Client.get_bill_data(session, '')
        expect(result).to eq(bill_data)
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }
      let(:bill_data) { '' }

      it 'raises error returned by API' do
        expect { Fns::Client.get_bill_data(session, '') }.to raise_error(Fns::Error)
      end
    end
  end

  describe '#get_ticket' do
    let(:session) { Fns::Session.new(rand.to_s) }
    let(:session_id) { rand.to_s }
    let(:qr) { rand.to_s }
    let(:ticket_id) { rand.to_s }

    before do
      session.instance_variable_set(:@session_id, session_id)

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
        result = Fns::Client.send(:get_ticket, session, qr)
        expect(result).to eq(ticket_id)
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }
      let(:result_data) { '' }

      it 'raises error returned by API' do
        expect { Fns::Client.send(:get_ticket, session, qr) }.to raise_error(Fns::Error)
      end
    end
  end
end
