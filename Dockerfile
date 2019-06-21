FROM php:7.3.6-apache
MAINTAINER codyrigg

ENV BOOKED_DL_URL "https://sourceforge.net/projects/phpscheduleit/files/Booked/2.7/booked-2.7.6.zip"
ENV BOOKED_DL_FILE "booked-2.7.6.zip"
ENV BOOKED_APP_TITLE "Booked Scheduler"
ENV BOOKED_DEFAULT_TIMEZONE "Europe/Paris"
ENV TZ $BOOKED_DEFAULT_TIMEZONE
ENV BOOKED_ALLOW_SELF_REGISTRATION "true"
ENV BOOKED_ADMIN_EMAIL "admin@example.com"
ENV BOOKED_ADMIN_EMAIL_NAME "Booked Administrator"
ENV BOOKED_DEFAULT_PAGE_SIZE "50"
ENV BOOKED_ENABLE_EMAIL "true"
ENV BOOKED_DEFAULT_LANGUAGE "en_us"
ENV BOOKED_WEB_URL "http://localhost/Web"
ENV BOOKED_DEFAULT_HOMEPAGE "1"
ENV BOOKED_REGISTRATION_CAPTCHA_ENABLED "true"
ENV BOOKED_REGISTRATION_REQUIRE_EMAIL_ACTIVATION "false"
ENV BOOKED_REGISTRATION_AUTO_SUBSCRIBE_EMAIL "false"
ENV BOOKED_REGISTRATION_NOTIFY_ADMIN "false"
ENV BOOKED_HOME_URL "$BOOKED_WEB_URL/dashboard.php"
ENV BOOKED_SCHEDULE_USE_PER_USER_COLORS "false"
ENV BOOKED_SCHEDULE_SHOW_INACCESSIBLE_RESOURCES "true"
ENV BOOKED_SCHEDULE_RESERVATION_LABEL "{name}"
ENV BOOKED_SCHEDULE_HIDE_BLOCKED_PERIODS "false"
ENV BOOKED_ICS_SUBSCRIPTION_KEY ""
ENV BOOKED_PRIVACY_VIEW_SCHEDULES "true"
ENV BOOKED_PRIVACY_VIEW_RESERVATIONS "false"
ENV BOOKED_PRIVACY_HIDE_USER_DETAILS "false"
ENV BOOKED_PRIVACY_HIDE_RESERVATION_DETAILS "false"
ENV BOOKED_PRIVACY_ALLOW_GUEST_RESERVATIONS "false"
ENV BOOKED_RESERVATION_ENABLE_REMINDERS "false"
ENV BOOKED_RESERVATION_ALLOW_GUEST_PARTICIPATION "false"
ENV BOOKED_RESERVATION_ALLOW_WAIT_LIST "false"
ENV BOOKED_RESERVATION_CHECKIN_MINUTES_PRIOR "5"
ENV BOOKED_RESERVATION_TITLE_REQUIRED "false"
ENV BOOKED_RESERVATION_DESCRIPTION_REQUIRED "false"
ENV BOOKED_UPLOADS_ENABLE_RESERVATION_ATTACHMENTS "false"
ENV BOOKED_UPLOADS_RESERVATION_ATTACHMENT_PATH "uploads/reservation"
ENV BOOKED_UPLOADS_RESERVATION_ATTACHMENT_EXTENSIONS "txt,jpg,gif,png,doc,docx,pdf,xls,xlsx,ppt,pptx,csv"
ENV BOOKED_DATABASE_TYPE "mysql"
ENV BOOKED_DATABASE_USER "booked_user"
ENV BOOKED_DATABASE_PASSWORD "password"
ENV BOOKED_DATABASE_HOSTSPEC "ttmysqldb"
ENV BOOKED_DATABASE_NAME "bookedscheduler"
ENV BOOKED_PHPMAILER_MAILER "mail"
ENV BOOKED_PHPMAILER_SMTP_HOST ""
ENV BOOKED_PHPMAILER_SMTP_PORT "25"
ENV BOOKED_PHPMAILER_SMTP_SECURE ""
ENV BOOKED_PHPMAILER_SMTP_AUTH "true"
ENV BOOKED_PHPMAILER_SMTP_USERNAME ""
ENV BOOKED_PHPMAILER_SMTP_PASSWORD ""
ENV BOOKED_PHPMAILER_SENDMAIL_PATH "/usr/sbin/sendmail"
ENV BOOKED_PHPMAILER_SMTP_DEBUG "false"
ENV BOOKED_INSTALL_PASSWORD ""
ENV BOOKED_API_ENABLED "true"
ENV BOOKED_EMAIL_DEFAULT_FROM_ADDRESS ""
ENV BOOKED_EMAIL_DEFAULT_FROM_NAME ""
ENV BOOKED_RESERVATION_LABELS_ICS_SUMMARY "{title}"
ENV BOOKED_RESERVATION_LABELS_ICS_MY_SUMMARY "{title}"
ENV BOOKED_RESERVATION_LABELS_RSS_DESCRIPTION "<div><span>Start</span> {startdate}</div><div><span>End</span> {enddate}</div><div><span>Organizer</span> {name}</div><div><span>Description</span> {description}</div>"
ENV BOOKED_RESERVATION_LABELS_MY_CALENDAR "{resourcename} {title}"
ENV BOOKED_RESERVATION_LABELS_RESOURCE_CALENDAR "{name}"
ENV BOOKED_RESERVATION_LABELS_RESERVATION_POPUP ""
ENV BOOKED_CREDITS_ENABLED "false"
ENV BOOKED_CREDITS_ALLOW_PURCHASE "false"

COPY php.ini /usr/local/etc/php/

RUN apt-get update && \
    apt-get install -y vim \
    curl \
    unzip \
    mysql-client \
    libpng-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libicu-dev \
    g++

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN docker-php-ext-configure intl \
    && docker-php-ext-install intl

RUN docker-php-ext-install -j$(nproc) mysqli pdo pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN cd /var/www && curl -L -Os $BOOKED_DL_URL && \
    unzip $BOOKED_DL_FILE && \
    cp booked/config/config.dist.php booked/config/config.php
RUN sed -i -e '/app.title/ s/=.*/= getenv('BOOKED_APP_TITLE');/' /var/www/booked/config/config.php && \
sed -i -e '/default.timezone/ s/=.*/= getenv('BOOKED_DEFAULT_TIMEZONE');/' /var/www/booked/config/config.php && \
sed -i -e '/allow.self.registration/ s/=.*/= getenv('BOOKED_ALLOW_SELF_REGISTRATION');/' /var/www/booked/config/config.php && \
sed -i -e '/admin.email/ s/=.*/= getenv('BOOKED_ADMIN_EMAIL');/' /var/www/booked/config/config.php && \
sed -i -e '/admin.email.name/ s/=.*/= getenv('BOOKED_ADMIN_EMAIL_NAME');/' /var/www/booked/config/config.php && \
sed -i -e '/default.page.size/ s/=.*/= getenv('BOOKED_DEFAULT_PAGE_SIZE');/' /var/www/booked/config/config.php && \
sed -i -e '/enable.email/ s/=.*/= getenv('BOOKED_ENABLE_EMAIL');/' /var/www/booked/config/config.php && \
sed -i -e '/default.language/ s/=.*/= getenv('BOOKED_DEFAULT_LANGUAGE');/' /var/www/booked/config/config.php && \
sed -i -e '/script.url/ s/=.*/= getenv('BOOKED_WEB_URL');/' /var/www/booked/config/config.php && \
sed -i -e '/registration.captcha.enabled/ s/=.*/= getenv('BOOKED_REGISTRATION_CAPTCHA_ENABLED');/' /var/www/booked/config/config.php && \
sed -i -e '/registration.require.email.activation/ s/=.*/= getenv('BOOKED_REGISTRATION_REQUIRE_EMAIL_ACTIVATION');/' /var/www/booked/config/config.php && \
sed -i -e '/registration.auto.subscribe.email/ s/=.*/= getenv('BOOKED_REGISTRATION_AUTO_SUBSCRIBE_EMAIL');/' /var/www/booked/config/config.php && \
sed -i -e '/registration.notify.admin/ s/=.*/= getenv('BOOKED_REGISTRATION_NOTIFY_ADMIN');/' /var/www/booked/config/config.php && \
sed -i -e '/home.url/ s/=.*/= getenv('BOOKED_HOME_URL');/' /var/www/booked/config/config.php && \
sed -i -e '/logout.url/ s/=.*/= getenv('BOOKED_WEB_URL');/' /var/www/booked/config/config.php && \
sed -i -e '/default.homepage/ s/=.*/= getenv('BOOKED_DEFAULT_HOMEPAGE');/' /var/www/booked/config/config.php && \
sed -i -e '/schedule'\''\]\['\''use.per.user.colors/ s/=.*/= getenv('BOOKED_SCHEDULE_USE_PER_USER_COLORS');/' /var/www/booked/config/config.php && \
sed -i -e '/schedule'\''\]\['\''show.inaccessible.resources/ s/=.*/= getenv('BOOKED_SCHEDULE_SHOW_INACCESSIBLE_RESOURCES');/' /var/www/booked/config/config.php && \
sed -i -e '/schedule'\''\]\['\''reservation.label/ s/=.*/= getenv('BOOKED_SCHEDULE_RESERVATION_LABEL');/' /var/www/booked/config/config.php && \
sed -i -e '/schedule'\''\]\['\''hide.blocked.periods/ s/=.*/= getenv('BOOKED_SCHEDULE_HIDE_BLOCKED_PERIODS');/' /var/www/booked/config/config.php && \
sed -i -e '/ics'\''\]\['\''subscription.key/ s/=.*/= getenv('BOOKED_ICS_SUBSCRIPTION_KEY');/' /var/www/booked/config/config.php && \
sed -i -e '/privacy'\''\]\['\''view.schedules/ s/=.*/= getenv('BOOKED_PRIVACY_VIEW_SCHEDULES');/' /var/www/booked/config/config.php && \
sed -i -e '/privacy'\''\]\['\''view.reservations/ s/=.*/= getenv('BOOKED_PRIVACY_VIEW_RESERVATIONS');/' /var/www/booked/config/config.php && \
sed -i -e '/privacy'\''\]\['\''hide.user.details/ s/=.*/= getenv('BOOKED_PRIVACY_HIDE_USER_DETAILS');/' /var/www/booked/config/config.php && \
sed -i -e '/privacy'\''\]\['\''hide.reservation.details/ s/=.*/= getenv('BOOKED_PRIVACY_HIDE_RESERVATION_DETAILS');/' /var/www/booked/config/config.php && \
sed -i -e '/privacy'\''\]\['\''allow.guest.reservations/ s/=.*/= getenv('BOOKED_PRIVACY_ALLOW_GUEST_RESERVATIONS');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation'\''\]\['\''enable.reminders/ s/=.*/= getenv('BOOKED_RESERVATION_ENABLE_REMINDERS');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation'\''\]\['\''allow.guest.reservations/ s/=.*/= getenv('BOOKED_RESERVATION_ALLOW_GUEST_PARTICIPATION');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation'\''\]\['\''allow.wait.list/ s/=.*/= getenv('BOOKED_RESERVATION_ALLOW_WAIT_LIST');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation'\''\]\['\''checkin.minutes.prior/ s/=.*/= getenv('BOOKED_RESERVATION_CHECKIN_MINUTES_PRIOR');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation'\''\]\['\''title.required/ s/=.*/= getenv('BOOKED_RESERVATION_TITLE_REQUIRED');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation'\''\]\['\''description.required/ s/=.*/= getenv('BOOKED_RESERVATION_DESCRIPTION_REQUIRED');/' /var/www/booked/config/config.php && \
sed -i -e '/uploads'\''\]\['\''enable.reservation.attachments/ s/=.*/= getenv('BOOKED_UPLOADS_ENABLE_RESERVATION_ATTACHMENTS');/' /var/www/booked/config/config.php && \
sed -i -e '/uploads'\''\]\['\''reservation.attachment.path/ s/=.*/= getenv('BOOKED_UPLOADS_RESERVATION_ATTACHMENT_PATH');/' /var/www/booked/config/config.php && \
sed -i -e '/uploads'\''\]\['\''reservation.attachment.extensions/ s/=.*/= getenv('BOOKED_UPLOADS_RESERVATION_ATTACHMENT_EXTENSIONS');/' /var/www/booked/config/config.php && \
sed -i -e '/database'\''\]\['\''type/ s/=.*/= getenv('BOOKED_DATABASE_TYPE');/' /var/www/booked/config/config.php && \
sed -i -e '/database'\''\]\['\''user/ s/=.*/= getenv('BOOKED_DATABASE_USER');/' /var/www/booked/config/config.php && \
sed -i -e '/database'\''\]\['\''password/ s/=.*/= getenv('BOOKED_DATABASE_PASSWORD');/' /var/www/booked/config/config.php && \
sed -i -e '/database'\''\]\['\''hostspec/ s/=.*/= getenv('BOOKED_DATABASE_HOSTSPEC');/' /var/www/booked/config/config.php && \
sed -i -e '/database'\''\]\['\''name/ s/=.*/= getenv('BOOKED_DATABASE_NAME');/' /var/www/booked/config/config.php && \
sed -i -e '/phpmailer'\''\]\['\''mailer/ s/=.*/= getenv('BOOKED_PHPMAILER_MAILER');/' /var/www/booked/config/config.php && \
sed -i -e '/phpmailer'\''\]\['\''smtp.host/ s/=.*/= getenv('BOOKED_PHPMAILER_SMTP_HOST');/' /var/www/booked/config/config.php && \
sed -i -e '/phpmailer'\''\]\['\''smtp.port/ s/=.*/= getenv('BOOKED_PHPMAILER_SMTP_PORT');/' /var/www/booked/config/config.php && \
sed -i -e '/phpmailer'\''\]\['\''smtp.secure/ s/=.*/= getenv('BOOKED_PHPMAILER_SMTP_SECURE');/' /var/www/booked/config/config.php && \
sed -i -e '/phpmailer'\''\]\['\''smtp.auth/ s/=.*/= getenv('BOOKED_PHPMAILER_SMTP_AUTH');/' /var/www/booked/config/config.php && \
sed -i -e '/phpmailer'\''\]\['\''smtp.username/ s/=.*/= getenv('BOOKED_PHPMAILER_SMTP_USERNAME');/' /var/www/booked/config/config.php && \
sed -i -e '/phpmailer'\''\]\['\''smtp.password/ s/=.*/= getenv('BOOKED_PHPMAILER_SMTP_PASSWORD');/' /var/www/booked/config/config.php && \
sed -i -e '/phpmailer'\''\]\['\''sendmail.path/ s/=.*/= getenv('BOOKED_PHPMAILER_SENDMAIL_PATH');/' /var/www/booked/config/config.php && \
sed -i -e '/phpmailer'\''\]\['\''smtp.debug/ s/=.*/= getenv('BOOKED_PHPMAILER_SMTP_DEBUG');/' /var/www/booked/config/config.php && \
sed -i -e '/install.password/ s/=.*/= getenv('BOOKED_INSTALL_PASSWORD');/' /var/www/booked/config/config.php && \
sed -i -e '/api'\''\]\['\''enabled/ s/=.*/= getenv('BOOKED_API_ENABLED');/' /var/www/booked/config/config.php && \
sed -i -e '/email'\''\]\['\''default.from.address/ s/=.*/= getenv('BOOKED_EMAIL_DEFAULT_FROM_ADDRESS');/' /var/www/booked/config/config.php && \
sed -i -e '/email'\''\]\['\''default.from.name/ s/=.*/= getenv('BOOKED_EMAIL_DEFAULT_FROM_NAME');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation.labels'\''\]\['\''ics.summary/ s/=.*/= getenv('BOOKED_RESERVATION_LABELS_ICS_SUMMARY');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation.labels'\''\]\['\''ics.my.summary/ s/=.*/= getenv('BOOKED_RESERVATION_LABELS_ICS_MY_SUMMARY');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation.labels'\''\]\['\''rss.description/ s/=.*/= getenv('BOOKED_RESERVATION_LABELS_RSS_DESCRIPTION');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation.labels'\''\]\['\''my.calendary/ s/=.*/= getenv('BOOKED_RESERVATION_LABELS_MY_CALENDAR');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation.labels'\''\]\['\''resource.calendar/ s/=.*/= getenv('BOOKED_RESERVATION_LABELS_RESOURCE_CALENDAR');/' /var/www/booked/config/config.php && \
sed -i -e '/reservation.labels'\''\]\['\''reservation.popup/ s/=.*/= getenv('BOOKED_RESERVATION_LABELS_RESERVATION_POPUP');/' /var/www/booked/config/config.php && \
sed -i -e '/credits'\''\]\['\''enable/ s/=.*/= getenv('BOOKED_CREDITS_ENABLED');/' /var/www/booked/config/config.php && \
sed -i -e '/credits'\''\]\['\''allow.purchase/ s/=.*/= getenv('BOOKED_CREDITS_ALLOW_PURCHASE');/' /var/www/booked/config/config.php
#RUN if [ $BOOKED_UPCOMING_RESERVATIONS <> "13" ] ; then '$lastDate = $now->AddDays(13-$dayOfWeek-1);' -> '$lastDate = $now->AddDays(60-$dayOfWeek-1);' - UpcomingReservationsPresenter.php
#CMD sh -c 'if [ "$feature_enabled" = true ]; then echo "Feature activated"; else echo "Feature not activated"; fi'
#RUN if [ $BOOKED_UPCOMING_RESERVATIONS <> "13" ] ; then '$lastDate = $now->AddDays(13-$dayOfWeek-1);' -> '$lastDate = $now->AddDays(60-$dayOfWeek-1);' - UpcomingReservationsPresenter.php
RUN chown www-data: /var/www/booked -R && \
    chmod 0755 /var/www/booked -R
RUN cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/booked.conf && \
    sed -i 's,/var/www/html,/var/www/booked,g' /etc/apache2/sites-available/booked.conf && \
    sed -i 's,${APACHE_LOG_DIR},/var/log/apache2,g' /etc/apache2/sites-available/booked.conf && \
    a2ensite booked.conf && a2dissite 000-default.conf && a2enmod rewrite

WORKDIR /var/www/booked

EXPOSE 80

CMD ["apache2-foreground"]
