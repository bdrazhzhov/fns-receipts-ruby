# Fns::Receipts::Ruby

[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/bdrazhzhov/fns-receipts-ruby/blob/master/README.en.md) [![ru](https://img.shields.io/badge/lang-ru-blue.svg)](https://github.com/bdrazhzhov/fns-receipts-ruby/blob/master/README.md)

Это обертка над API сервиса ФНС, позволяющего получить полную информацию о чеках, отсканировав находящиеся на них qr-коды.

## Установка

Добавьте эту строчку в Gemfile вашего приложения:

```ruby
gem 'fns-receipts-ruby'
```

Потом выполните:

```bash
$ bundle
```

Или установите с помощью:

```bash
$ gem install fns-receipts-ruby
```

## Как использовать

Первым шагом необходимо создать сессию для пользователя. Для этого нужно отправить пользователю смс с кодом подтверждения и передать этот код в API ФНС.

### Отправляем смс с кодом подтверждения

```ruby
Fns::Client.create_session('+123456789')
```

### Отправляем код подтверждения в API ФНС

```ruby
Fns::Client.verify_session('+123456789', '1234')
```

### После подтверждения получаем следующие данные в ответ

```ruby
{
  session_id: '6538aff1f7938adb0627d753:bc1e0927-9c06-4301-851d-be705201ade2',
  refresh_token: 'aaf40aa5-b257-477b-a104-b99d0df1001d'
}
```

- `session_id` — идентификатор сессии, который необходимо использовать для получения полной информации из чека
- `refresh_token` — этот токен используется для восстановления сессии. Сами сессии API ФНС "живут" короткое время, поэтому может потребоваться восстановить ранее созданную сессию.

### Теперь можно запросить информацию о чеке

```ruby
Fns::Client.get_bill_data('6538aff1f7938adb0627d753:bc1e0927-9c06-4301-851d-be705201ade2', 't=20231016T1313&s=2701.00&fn=7281440501188798&i=115621&fp=1865575866&n=1')
```

Пример ответа API ФНС c полной информацией о чеке:

```json
{
    "status": 2,
    "statusReal": 2,
    "id": "6538c085f7938adb0627dedd",
    "kind": "kkt",
    "createdAt": "2023-11-09T11:14:46+03:00",
    "statusDescription": {},
    "qr": "t=20231016T1313&s=2701.00&fn=7281440501188798&i=115621&fp=1865575866&n=1",
    "operation": {
        "date": "2023-10-16T13:13",
        "type": 1,
        "sum": 270100
    },
    "process": [
        {
            "time": "2023-10-25T07:15:17+00:00",
            "result": 21
        },
        {
            "time": "2023-10-25T07:15:21+00:00",
            "result": 2
        }
    ],
    "query": {
        "operationType": 1,
        "sum": 270100,
        "documentId": 115621,
        "fsId": "7281440501188798",
        "fiscalSign": "1865575866",
        "date": "2023-10-16T13:13"
    },
    "ticket": {
        "document": {
            "receipt": {
                "dateTime": 1697451180,
                "buyerPhoneOrAddress": "templar8@gmail.com",
                "cashTotalSum": 0,
                "code": 3,
                "creditSum": 0,
                "ecashTotalSum": 0,
                "fiscalDocumentFormatVer": 4,
                "fiscalDocumentNumber": 115621,
                "fiscalDriveNumber": "7281440501188798",
                "fiscalSign": 1865575866,
                "internetSign": 1,
                "items": [
                    {
                        "name": "Овощерезка Borner Классика Germany 12 видов нарезки, 5 предметов: тёрка-измельчитель, 3 вставки, плододержатель, цвет: оранжевый",
                        "nds": 5,
                        "paymentAgentByProductType": 64,
                        "paymentType": 4,
                        "price": 270100,
                        "productType": 1,
                        "providerInn": "7717144513  ",
                        "quantity": 1,
                        "sum": 270100
                    }
                ],
                "kktRegId": "0006264659010484    ",
                "machineNumber": "KZN064348",
                "nds0": 270100,
                "operationType": 1,
                "prepaidSum": 270100,
                "provisionSum": 0,
                "requestNumber": 1911,
                "retailPlace": "ozon.ru",
                "retailPlaceAddress": "109316, Москва, Волгоградский проспект, 42, к 9",
                "sellerAddress": "ExchangeSupportMetazon@ozon.ru",
                "shiftNumber": 38,
                "taxationType": 1,
                "appliedTaxationType": 1,
                "totalSum": 270100,
                "user": "Общество с ограниченной ответственностью \"Интернет Решения\"",
                "userInn": "7704217370  "
            }
        }
    },
    "organization": {
        "name": "Общество с ограниченной ответственностью \"Интернет Решения\"",
        "inn": "7704217370"
    },
    "seller": {
        "name": "Общество с ограниченной ответственностью \"Интернет Решения\"",
        "inn": "7704217370"
    }
}
```

### Восстановление сессии

```ruby
Fns::Client.refresh_session('aaf40aa5-b257-477b-a104-b99d0df1001d')
```

В ответ получаем:

```ruby
{
  session_id: '6538aff1f7938adb0627d753:f23cc29b-96bd-495c-ac76-6c186feb5342',
  refresh_token: '4fea35d5-07dd-4be9-a662-08e12053137a'
}
```

Теперь новые `session_id` и `refresh_token` можно использовать для получения информации о чеке и восстановления сессии соотетсвенно.

## Помощь в разработке

Сообщения о багах и пулл реквесты приветсвуются на GitHub: https://github.com/bdrazhzhov/fns-receipts-ruby.

## Лицензия

Исходный код ПО доступен на условиях лицензии [MIT](https://opensource.org/licenses/MIT).
