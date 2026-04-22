# BigDataSnowflake

Лабараторная работа №1.

## Start

Для запуска используется `docker-compose`

```
docker-compose up -d
```

## Solution

### Compose file

Compose-файл состоит из 2-х контейнеров:

- `postgres`: контейнер, непосредственно с **Postgresql16**.
- `migrator`: контейнер, ответственный за раскатку миграций БД.

### Migrations

Весь `SQL` код находится в директории [`./migrations/`](./migrations/), содержит
4 миграции:

- [1](./migrations/0001_create_csv_schema.up.sql): Миграция для создания таблицы
  не нормализованной таблицы

- [2](./migrations/0002_populate_csv_schema.up.sql): Заполнение таблицы с
  предыдущего шага данными из CSV файлов.

- [3](./migrations/0003_create_snowflake_schema.up.sql): Создание таблиц фактов
  и измерений.

- [4](./migrations/0004_populate_snowflake_schema.up.sql): Заполнение таблиц
  фактов и измерений.


