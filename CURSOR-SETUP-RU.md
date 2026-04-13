# Установка в workspace (Cursor + OpenClaw)

## Где лежит скилл

Склонируйте [этот репозиторий](https://github.com/wordprais/yandex-metrika-assistant) в удобное место на диске или добавьте как подмодуль.  
В Cursor навыки часто кладут в **`.cursor/skills/yandex-metrika-assistant`** — путь задайте сами, главное чтобы папка совпадала с путём в `openclaw plugins install`.

## OpenClaw (плагин)

Из каталога с клоном (подставьте свой путь):

```powershell
openclaw plugins install "C:\path\to\yandex-metrika-assistant"
```

Включите плагин **`yandex-metrika-assistant`** в `plugins.entries`, перезапустите gateway при необходимости.

### Поля конфига плагина

| Поле | Значение |
|------|----------|
| **oauthClientId** | Client ID из [oauth.yandex.ru](https://oauth.yandex.ru/) (ваше приложение) |
| **oauthToken** | храните в **`local.oauth.env`** → `YANDEX_METRIKA_OAUTH_TOKEN` (файл в `.gitignore`) или только в секрете плагина |
| **defaultCounterId** | опционально: `ids=` по умолчанию, если пользователь не указал счётчик |

Альтернатива токену в конфиге: переменная окружения **`YANDEX_METRIKA_OAUTH_TOKEN`**.

## Ссылка для получения токена (неявный поток `response_type=token`)

Подставьте **свой** `client_id` и при необходимости сузьте `scope` под галочки в кабинете OAuth:

```
https://oauth.yandex.ru/authorize?response_type=token&client_id=<YOUR_CLIENT_ID>&redirect_uri=https%3A%2F%2Foauth.yandex.ru%2Fverification_code&scope=metrika%3Aread%20metrika%3Awrite
```

**Redirect URI** в приложении OAuth должен совпадать: `https://oauth.yandex.ru/verification_code`

Если в кабинете не включены все scope — уберите лишние из параметра `scope` в ссылке (иначе `invalid_scope`).

## Локальные OAuth-переменные (Client ID / secret / redirect)

Секреты **не** коммитьте: в `.gitignore` указан файл **`local.oauth.env`**.  
Шаблон без секретов: **`local.oauth.env.example`** — скопируйте в `local.oauth.env` и заполните.

Загрузка в текущую сессию PowerShell (из корня навыка):

```powershell
Set-Location "C:\path\to\yandex-metrika-assistant"
. .\scripts\load-yandex-oauth-env.ps1
```

## Скрипт обмена `code` → token (PowerShell)

После `load-yandex-oauth-env.ps1` (или ручной установки `YANDEX_OAUTH_*`):

```powershell
.\scripts\exchange-yandex-oauth-code.ps1
```

## Полная документация в репозитории

- [INSTALL-FOR-HUMANS-RU.md](./docs/INSTALL-FOR-HUMANS-RU.md)
- [INSTRUCTION-GET-TOKEN-RU.md](./docs/INSTRUCTION-GET-TOKEN-RU.md)

Исходник идей и апстрим: [Horosheff/yandex-metrika-assistant](https://github.com/Horosheff/yandex-metrika-assistant) (MIT). Этот репозиторий — ветка с контактами **Андрея Русских** (Telegram, Instagram).

## Безопасность

**Client secret** не коммитьте и не вставляйте в открытые чаты. Если секрет уже был в переписке — в [Яндекс OAuth](https://oauth.yandex.ru/) создайте новый секрет или приложение и обновите переменные/конфиг.
