# frozen_string_literal: true

module Fns
  # Объекты этого класса хранят данные сессии запросов к ФНС
  # для одного номера клиентского телефона.
  # Чтобы создать сессию, необходимо выполнить код:
  # Fns::Client#create_session(<phone_number>)
  # Далее клиенту отправляется СМС с кодом подтверждения сессии.
  # Этот код необходимо передать в метод verify для проверки
  # После чего, с помощью метода Fns::Client#get_bill_data,
  # можно запрашивать данные чеков.
  # Сессия "живет" ограниченное время, поэтому ее можно будет
  # восстанавливать с момощгю метода refresh
  class Session
    attr_reader :session_id, :refresh_token

    def initialize(phone_number)
      @phone_number = phone_number
    end

    # Проверяет/Подтверждает клиентскую сессию с помощью
    # *verification_code*, который высалается клиенту в СМС-сообщении
    def verify(verification_code)
      response = HTTP.headers(HEADERS)
                     .post(
                       "#{API_BASE_URL}/auth/phone/verify",
                       json: {
                         phone: @phone_number,
                         client_secret: CLIENT_SECRET,
                         os: DEVICE_OS,
                         code: verification_code
                       }
                     )
      raise Fns::Error, response unless response.code == 200

      result = JSON.parse(response.to_s)

      @session_id = result['sessionId']
      @refresh_token = result['refresh_token']
    end

    # С помощью выхова этого метода можно восстановить сессию,
    # время которой уже истекло. После восстановления сессию
    # можно использовать для получения данных по чекам
    def refresh
      response = HTTP.headers(HEADERS)
                     .post(
                       "#{API_BASE_URL}/mobile/users/refresh",
                       json: {
                         refresh_token: @refresh_token,
                         client_secret: CLIENT_SECRET
                       }
                     )
      raise Fns::Error, response unless response.code == 200

      result = JSON.parse(response.to_s)

      @session_id = result['sessionId']
      @refresh_token = result['refresh_token']
    end
  end
end
