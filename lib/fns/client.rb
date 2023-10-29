# frozen_string_literal: true

require 'http'
require 'json'
require_relative 'session'

module Fns
  API_BASE_URL = 'https://irkkt-mobile.nalog.ru:8888/v2'
  DEVICE_OS = 'iOS'
  CLIENT_SECRET = 'IyvrAbKt9h/8p6a7QPh8gpkXYQ4='
  CLIENT_VERSION = '2.9.0'
  HEADERS = {
    'Device-OS' => DEVICE_OS,
    'Device-Id' => '7C82010F-16CC-446B-8F66-FC4080C66521',
    clientVersion: CLIENT_VERSION,
    'Accept-Language' => 'ru-RU;q=1, en-US;q=0.9',
    'User-Agent' => "billchecker/#{CLIENT_VERSION} (iPhone; iOS 13.6; Scale/2.00)"
  }.freeze

  # Этот класс создает клиентские сесси, чтобы потом использовать
  # их для получаения данных чеков из ФНС.
  # Для создания сессии нужно использовать метод create_session,
  # котоый возвращает объект пользовательской сессии.
  # Сессию еще необходимо подтвердить кодом из СМС с помощью метода
  # verify.
  # После этого сессия может быть использована в вызове
  # Fns::Client.get_bill_data для получения данных чека
  class Client
    class << self
      # Отправляет смс с кодом подтврждения на номер
      # phone_number. Этот код необходимо использовать
      # при вызове метода verify_session. Если обращение
      # к сервису ФНС прошло успешно, возвращается nil,
      # иначе бросается исключение, содержащее данные
      # ответа от API сервиса ФНС
      #
      # @param [String] phone_number номер телефона клиента
      # @return [Fns::Session]
      def create_session(phone_number)
        response = HTTP.headers(HEADERS)
                       .post(
                         "#{API_BASE_URL}/auth/phone/request",
                         json: {
                           phone: phone_number,
                           client_secret: CLIENT_SECRET,
                           os: DEVICE_OS
                         }
                       )

        return Fns::Session.new(phone_number) if response.code == 204

        raise Fns::Error, response
      end

      # Возвращает данные чека со списком товаров, находящимся в нем
      def get_bill_data(session, qr_data)
        ticket_id = get_ticket(session, qr_data)

        response = HTTP.headers(HEADERS.merge(sessionId: session.session_id))
                       .get("#{API_BASE_URL}/tickets/#{ticket_id}")

        return JSON.parse(response.to_s) if response.code == 200

        raise Fns::Error, response
      end

      private

      def get_ticket(session, qr_data)
        response = HTTP.headers(HEADERS.merge(sessionId: session.session_id))
                       .post(
                         "#{API_BASE_URL}/ticket",
                         json: { qr: qr_data }
                       )

        if response.code == 200
          result = JSON.parse(response.to_s)
          return result['id']
        end

        raise Fns::Error, response
      end
    end
  end
end
