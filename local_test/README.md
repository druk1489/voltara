# local_test — локальный запуск Voltara

Чтобы тестировать Voltara у себя, не трогая GitHub:

1. Поставь Python 3 (без зависимостей, только stdlib).
2. Запусти хост из корня репозитория:
   ```
   python local_test/voltara_host.py
   ```
   Поднимется на `http://127.0.0.1:8000`.
3. В экзекьютор вставь содержимое `local_test/VoltaraLoader.lua` и выполни.

Лоадер перехватывает `game:HttpGet`/`request` и подменяет запросы к
`raw.githubusercontent.com/Vyrusspcs/weshkyv2/...` на localhost, если путь есть
в `LOCAL_MAP`. Чего там нет — уходит на GitHub (репо живое).

Правь `source/MainModule.lua`, `source/SecondModule.lua`, `server/*.lua`,
`special/*.lua` и просто перезапускай лоадер в игре — изменения подхватятся.

- `USE_LOCAL = false` в шапке лоадера — вернуть чистый запуск с GitHub.
- Другой порт: `python local_test/voltara_host.py 8080` и поменяй `HOST` в лоадере.
- Проверка хоста: открой `http://127.0.0.1:8000/health`.
