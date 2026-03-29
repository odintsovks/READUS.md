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
                auth = component "Сервис аутентификации" "Аутентифицирует и авторизирует пользователей"
                user = component "Сервис работы с личным кабинетом" "Запрашивает данные из личного кабинета"
                message = component "Сервис работы с сообщениями" "Поддерживает API, операции CRUD для работы с сообщениями"
                branch = component "Сервис работы с ветками" "Поддерживает API, операции CRUD для работы с ветками"
                discussion = component "Сервис работы с обсуждениями" "Поддерживает API, операции CRUD для работы с обсуждениями"
                imgProcessor = component "Сервис обработки изображений" "Обрабатывает (ресайз) изображения для предпросмотра"
                videoProcessor = component "Сервис обработки видео" "Обрабатывает (сжимает) видео для предпросмотра"
                analytics = component "Сервис аналитики" "Собирает статистику, основанную на действиях пользователя"
                ranking = component "Сервис ранжирования" "Ранжирует обсуждения"
                feedBuilder = component "Сервис лент" "Создаёт персонализированные ленты"
                textProcessor = component "Обработчик текста" "Обрабатывает Markdown, защита от XSS, фильтрация"
            }
 
            database = container "База данных" "Общее хранилище для данных" "PostgreSQL" "Database" {
                user = component "Хранилище пользователей" "Хранит пользовательские данные: личный кабинет, учётные данные"
                session = component "Хранилище сеансов" "Хранит данные о пользовательских сеансах и токенах доступа"
                branch = component "Хранилище веток" "Хранит информацию о ветках"
                discussion = component "Хранилище обсуждений" "Хранит информацию об обсуждениях"
                message = component "Хранилище сообщений" "Хранит сообщения"
                analytics = component "Хранение аналитики" "Хранит собранную статистику"
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

        forum.client.main -> forum.server.feedBuilder "Запрашивает ленту"
        forum.client.login -> forum.server.auth "Аутентифицирует пользователя"
        forum.client.register -> forum.server.auth "Регистрирует пользователя"
        forum.client.profile -> forum.server.user "Запрашивает данные личного кабинета"
        forum.client.discussion -> forum.server.discussion "Запрашивает данные обсуждения, позволяет добавить реакцию"
        forum.client.discussion -> forum.server.message "Позволяет оставить комментарий"
        forum.client.editDiscussion -> forum.server.discussion "Позволяет создавать/редактировать обсуждение"
        forum.client.editDiscussion -> forum.server.branch "Позволяет создать ветку обсуждений"

        forum.server.auth -> oauth "Запрашивает аутентификацию пользователя"

        forum.server.auth -> forum.database.user "Хранит пользователя"
        forum.server.auth -> forum.database.session "Хранит сеанс"
        forum.server.branch -> forum.database.branch "Хранит ветки"
        forum.server.discussion -> forum.database.discussion "Хранит обсуждения"
        forum.server.message -> forum.database.message "Хранит сообщения"
        forum.server.analytics -> forum.database.analytics "Хранит статистику"
        forum.server.ranking -> forum.database.analytics "Запрашивает статистику"

        forum.server.feedBuilder -> forum.cache.feed "Хранит ленты"

        forum.server.imgProcessor -> forum.storage.img "Хранит изображения"
        forum.server.videoProcessor -> forum.storage.video "Хранит видео"

        forum.server.textProcessor -> forum.queue.ai "Отправляет текст на фильтрацию"
        forum.server.imgProcessor -> forum.queue.img "Отправляет изображения на обработку"
        forum.server.videoProcessor -> forum.queue.video "Отправлят видео на обработку"

        forum.server.feedBuilder -> forum.server.ranking "Запрашивает данные ранжирования"
        forum.server.discussion -> forum.server.textProcessor "Запрашивает обработку текста"
        forum.server.discussion -> forum.server.imgProcessor "Запрашивает обработку изображений"
        forum.server.discussion -> forum.server.videoProcessor "Запрашивает обработку видео"
        forum.server.message -> forum.server.textProcessor "Запрашивает обработку текста"
        forum.server.message -> forum.server.imgProcessor "Запрашивает обработку изображений"
        forum.server.message -> forum.server.videoProcessor "Запрашивает обработку видео"

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
