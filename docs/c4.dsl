workspace "READUS" "Forum" {

    !identifiers hierarchical

    model {
        user = person "Пользователь" "Пользователь форума"
 
        forum = softwareSystem "Форум" "Веб-приложение" {
            client = container "Веб-сайт" "Фронтенд, веб-сайт форума" "Vue" "Frontend" {
                main = component "Главная страница"

                discussion = component "Страница обсуждения"
                editDiscussion = component "Страница создания/редактирования обсуждения"

                login = component "Страница входа"
                register = component "Страница регистрации"
                profile = component "Личный кабинет"
            }

            server = container "Приложение-сервер" "Приложение на Spring Boot" "Java" "Backend" {
                user = component "Сервис личного кабинета" "Работа с данными пользователей"
                text = component "Сервис текстовых данных" "Поддерживает API, операции CRUD для работы с сообщениями, обсуждениями и ветками"
                media = component "Сервис медиа" "Обрабатывает (ресайз, сжатие) изображений и видео для предпросмотра"
                feed = component "Сервис лент" "Создаёт персонализированные ленты на основе статистики и ранжирования"
            }
 
            database = container "База данных" "Шардированное хранилище для данных" "PostgreSQL" "Database" {
                user = component "Хранилище пользователей" "Хранит пользовательские данные: личный кабинет, учётные данные"
                session = component "Хранилище сеансов" "Хранит данные о пользовательских сеансах и токенах доступа"
                branch = component "Хранилище веток" "Хранит информацию о ветках"
                discussion = component "Хранилище обсуждений" "Хранит информацию об обсуждениях"
                analytics = component "Хранение аналитики" "Хранит собранную статистику"
            }

            messageDatabase = container "База данных для сообщений" "Хранилище для сообщений" "Cassandra" "Database" {
                message = component "Хранилище сообщений" "Хранит сообщения"
            }

            cache = container "Кэш" "Кэш" "Redis" "Database" {
                feed = component "Кэш лент" "Хранит персонализированные вариации лент"
            }

            queue = container "Очередь" "Асинхронная очередь для обработки контента" "Kafka" "Database" {
                img = component "Очередь для изображений" "Управляет потоком изображений между сервером и обаботчиком"
                video = component "Очередь для видео" "Управляет потоком видео между сервером и обаботчиком"
                ai = component "Очередь для ИИ-обработки" "Управляет потоком пользовательского текста между сервером и ИИ-фильтром"
            }

            ffmpeg = container "FFmpeg" "Инструмент обработки видео и изображений" "ffmpeg" "Backend"
            
            ai = container "ИИ" "ИИ модель для фильтрования контента" "AI/LLM" "Backend"
 
            storage = container "Объектное хранилище" "Распределённое объектное хранилище" "S3" "Database" {
                img = component "Хранилище изображений" "Хранит загруженные изображения"
                video = component "Хранилище видео" "Хранит загруженные видео"
            }
 
        }

        oauth = softwareSystem "Social Login" "Сервис OAuth для Social Login" "External"
 
        user -> forum.client.main "Взаимодействует с веб-сайтом"

        forum.client -> forum.server "Взаимодействует с API сервера"

        forum.client.main -> forum.client.login "Переходит на страницу входа"
        forum.client.main -> forum.client.profile "Переходит в личный кабинет"
        forum.client.main -> forum.client.discussion "Переходит на страницу обсуждения"
        forum.client.main -> forum.client.editDiscussion "Переходит на страницу создания обсуждения"

        forum.client.login -> forum.client.register "Переходит на страницу регистрации"

        forum.client.discussion -> forum.client.editDiscussion "Переходит на страницу редактирования обсуждения"

        forum.client.main -> forum.server.feed "Запрашивает ленту"
        forum.client -> forum.server.user "Аутентифицирует и регистрирует пользователя, запрашивает данные личного кабинета"
        forum.client.login -> forum.server.user "Аутентифицирует пользователя"
        forum.client.register -> forum.server.user "Регистрирует пользователя"
        forum.client.profile -> forum.server.user "Запрашивает данные личного кабинета"
        forum.client -> forum.server.text "Работа с обсуждениями, реакциями, комментариями"
        forum.client.discussion -> forum.server.text "Запрашивает данные обсуждения, позволяет добавить реакцию, оставить комментарий"
        forum.client.editDiscussion -> forum.server.text "Позволяет создавать/редактировать обсуждение"

        forum.server.user -> oauth "Запрашивает аутентификацию пользователя"

        forum.server.user -> forum.database "Хранит пользователя, сеанс"
        forum.server.user -> forum.database.user "Хранит пользователя"
        forum.server.user -> forum.database.session "Хранит сеанс"
        forum.server.text -> forum.database "Хранит ветки, обсуждения"
        forum.server.text -> forum.database.branch "Хранит ветки"
        forum.server.text -> forum.database.discussion "Хранит обсуждения"
        forum.server.feed -> forum.database.analytics "Хранит статистику"

        forum.server.text -> forum.messageDatabase.message "Хранит сообщения"

        forum.server.feed -> forum.cache.feed "Хранит ленты"

        forum.server.media -> forum.storage "Хранит изображения и видео"
        forum.server.media -> forum.storage.img "Хранит изображения"
        forum.server.media -> forum.storage.video "Хранит видео"

        forum.server.text -> forum.queue.ai "Отправляет текст на фильтрацию"
        forum.server.media -> forum.queue.img "Отправляет изображения на обработку"
        forum.server.media -> forum.queue.video "Отправлят видео на обработку"

        forum.server.text -> forum.server.media "Запрашивает обработку изображений, видео"

        forum.queue -> forum.ffmpeg "Обрабатывает видео, изображения"
        forum.queue.img -> forum.ffmpeg "Обрабатывает видео"
        forum.queue.video -> forum.ffmpeg "Обрабатывает изображения"
        forum.queue.ai -> forum.ai "Обрабатывает текст"
    }
    views {
        systemContext forum "SystemContext" {
            include *
            autolayout lr
        }

        container forum "Containers" {
            include *
            autolayout lr
        }

        component forum.server "ServerComponents" {
            include *
            include user
            autolayout lr
        }

        component forum.client "FrontendComponents" {
            include *
            autolayout lr
        }

        styles {
            element "Element" {
                color #1168bd
                stroke #1168bd
                strokeWidth 7
                shape roundedbox
            }
            element "Person" {
                shape person
                color #55aa55
                stroke #55aa55
            }
            element "Database" {
                shape cylinder
            }
            element "Frontend" {
                shape WebBrowser
            }
            element "Backend" {
            }
            element "External" {
                color #ee7900
                stroke #ee7900
            }
            element "Boundary" {
                strokeWidth 5
            }
            relationship "Relationship" {
                thickness 4
            }
        }

        terminology {
            person "Пользователь"
            softwareSystem "Программная система"
            container "Контейнер"
        }

    }

    configuration {
        scope softwaresystem
    }

}
