# AI Chat

Приложение для общения с различными AI моделями через OpenRouter API, построенное на Flutter.

## Возможности

- 💬 Чат с различными AI моделями
- 🔄 Выбор и поиск доступных моделей
- 📊 Аналитика использования
- 💾 Сохранение истории диалогов
- 🌙 Темная тема
- 📱 Поддержка Windows и Android

## Скриншоты

[Здесь будут скриншоты приложения]

## Установка

Подробные инструкции по установке находятся в [INSTALL.md](INSTALL.md).

## Сборка

### Windows

Для сборки Windows-версии:
```bash
# Сборка приложения
flutter build windows
```
Исполняемый файл будет создан в папке `build/windows/runner/Release/`.

### Android

Для сборки Android APK доступно несколько вариантов:

```bash
# Сборка debug APK (для тестирования)
flutter build apk --debug

# Сборка release APK (для публикации)
flutter build apk --release

# Сборка split APKs по ABI (уменьшает размер установки)
flutter build apk --split-per-abi
```

APK файлы будут созданы в следующих папках:
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- Split APKs: 
  - `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
  - `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
  - `build/app/outputs/flutter-apk/app-x86_64-release.apk`

## Использование

1. Запустите приложение
2. Выберите модель AI из выпадающего списка
3. Введите сообщение в поле ввода и нажмите "Отправка"
4. Используйте кнопки управления для:
   - Сохранения истории диалога
   - Просмотра аналитики
   - Очистки истории

## Структура проекта

```
ai_chat_flutter/
├── lib/                    # Исходный код
│   ├── main.dart          # Главный файл приложения
│   ├── api/               # API клиенты
│   ├── screens/           # Экраны приложения
│   ├── widgets/           # UI компоненты
│   ├── models/            # Модели данных
│   ├── providers/         # Провайдеры состояния
│   └── services/          # Сервисы
├── assets/                # Ресурсы приложения
├── android/              # Android конфигурация
├── windows/             # Windows конфигурация
└── pubspec.yaml         # Flutter зависимости
```

## Разработка

### Установка окружения разработчика

1. Установите Flutter SDK следуя [официальной инструкции](https://flutter.dev/docs/get-started/install)
2. Установите все необходимые зависимости:
```bash
flutter pub get
```

### Запуск для разработки

```bash
# Запуск приложения в режиме разработки
flutter run
```

### Линтинг и форматирование

```bash
# Форматирование кода
flutter format lib/

# Проверка кода
flutter analyze
```

## Лицензия

[MIT License](LICENSE)

## Благодарности

- [Flutter](https://flutter.dev/) - UI фреймворк от Google
- [OpenRouter](https://openrouter.ai/) - API для доступа к AI моделям
