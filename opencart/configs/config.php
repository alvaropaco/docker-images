<?php

// HTTP
define('HTTP_SERVER', '/');
// HTTPS
define('HTTPS_SERVER', '/');
// DIR
define('DIR_ROOT', getenv('DIR_ROOT'));
define('DIR_APPLICATION', DIR_ROOT . 'upload/catalog/');
define('DIR_SYSTEM', DIR_ROOT . 'upload/system/');
define('DIR_IMAGE', DIR_ROOT . 'upload/image/');
define('DIR_STORAGE', DIR_ROOT . 'storage/');
define('DIR_LANGUAGE', DIR_APPLICATION . 'language/');
define('DIR_TEMPLATE', DIR_APPLICATION . 'view/theme/');
define('DIR_CONFIG', DIR_SYSTEM . 'config/');
define('DIR_CACHE', DIR_STORAGE . 'cache/');
define('DIR_DOWNLOAD', DIR_STORAGE . 'download/');
define('DIR_LOGS', DIR_STORAGE . 'logs/');
define('DIR_MODIFICATION', DIR_STORAGE . 'modification/');
define('DIR_SESSION', DIR_STORAGE . 'session/');
define('DIR_UPLOAD', DIR_STORAGE . 'upload/');

// DB
define('DB_DRIVER', 'mysqli');
define('DB_HOSTNAME', getenv('DB_HOSTNAME'));
define('DB_USERNAME', 'root');
define('DB_PASSWORD', getenv('DB_PASSWORD'));
define('DB_DATABASE', getenv('DB_DATABASE'));
define('DB_PREFIX', 'oc_');
define('DB_PORT', '3306');
