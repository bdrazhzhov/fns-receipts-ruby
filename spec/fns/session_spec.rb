# frozen_string_literal: true

RSpec.describe Fns::Session do
  let(:phone_number) { rand.to_s }
  let(:session) { described_class.new(phone_number) }
  let(:code) { rand.to_s }

  describe '#verify' do
    let(:status_code) { 200 }

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

      before { session.verify(code) }

      it 'session_id is set' do
        expect(session.session_id).to eq(session_id)
      end

      it 'refresh_token is set' do
        expect(session.instance_variable_get(:@refresh_token)).to eq(refresh_token)
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }
      let(:response) { '' }

      it 'raises error returned by API' do
        expect { session.verify(code) }.to raise_error(Fns::Error)
      end
    end
  end

  describe '#refresh' do
    let(:refresh_token) { rand.to_s }

    before do
      stub_request(:post, "#{Fns::API_BASE_URL}/mobile/users/refresh")
        .with(
          body: { refresh_token: refresh_token, client_secret: Fns::CLIENT_SECRET }.to_json,
          headers: Fns::HEADERS
        ).to_return(status: response_status, body: response)
      session.instance_variable_set(:@refresh_token, refresh_token)
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

      before { session.refresh }

      it 'session_id is set' do
        expect(session.session_id).to eq(new_session_id)
      end

      it 'refresh_token is set' do
        expect(session.instance_variable_get(:@refresh_token)).to eq(new_refresh_token)
      end
    end

    context 'when request failed' do
      let(:response_status) { 400 }
      let(:response) { '' }

      it 'raises error returned by API' do
        expect { session.refresh }.to raise_error(Fns::Error)
      end
    end
  end
end
