<?php

global $civicrm_root, $civicrm_setting, $civicrm_paths;

$civicrm_root = '/compucorp/build/compuclient/profiles/compuclient/modules/contrib/civicrm';
$templateDir = '/compucorp/build/compuclient/sites/default/files/civicrm/templates_c';

define('CIVICRM_UF', 'Drupal');
define('CIVICRM_UF_DSN', 'mysql://root:root@mysql-host:3306/compuclient_drupal?new_link=true');
define('CIVICRM_DSN', 'mysql://root:root@mysql-host:3306/compuclient_civicrm?new_link=true');
define('CIVICRM_UF_BASEURL', 'http://compuclient');
define('CIVICRM_SITE_KEY', '408f89f82a0f8344760c62a81c691bf2');
define('CIVICRM_DB_CACHE_CLASS', 'ArrayCache');
define('CIVICRM_LOGGING_DSN', CIVICRM_DSN);
define('CIVICRM_TEMPLATE_COMPILEDIR', $templateDir);
define('CIVICRM_DOMAIN_ID', 1);
define('CIVICRM_CLEANURL', 1);
define('CIVICRM_GETTEXT_NATIVE', 1);
define('CIVICRM_MAIL_SMARTY', 0 );
define('CIVICRM_DB_CACHE_HOST', 'localhost');
define('CIVICRM_DB_CACHE_PORT', 11211);
define('CIVICRM_DB_CACHE_PASSWORD', '' );
define('CIVICRM_DB_CACHE_TIMEOUT', 3600 );
define('CIVICRM_DB_CACHE_PREFIX', '');
define('CIVICRM_DEADLOCK_RETRIES', 3);

// this is a duplicate of CIVICRM_TEMPLATE_COMPILEDIR but required for the directory settings page
$civicrm_setting['Directory Preferences']['customTemplateDir'] = $templateDir;

// Directory/URL overrides
$civicrm_setting['Directory Preferences']['uploadDir'] = '[civicrm.files]/upload';
$civicrm_setting['Directory Preferences']['customFileUploadDir'] = '[civicrm.files]/custom/';
$civicrm_setting['Directory Preferences']['imageUploadDir'] = '[civicrm.files]/persist/contribute/' ;
$civicrm_setting['Directory Preferences']['customTemplateDir'] = '[cms.root]/sites/all/civicrm_custom/templates';
$civicrm_setting['Directory Preferences']['customPHPPathDir'] = '[cms.root]/sites/all/civicrm_custom/php';
$civicrm_setting['Directory Preferences']['extensionsDir'] = '[cms.root]/sites/all/civicrm_extensions';
$civicrm_setting['URL Preferences']['userFrameworkResourceURL'] = '[civicrm.root]/';
$civicrm_setting['URL Preferences']['imageUploadURL'] = '[civicrm.files]/persist/contribute/';
$civicrm_setting['URL Preferences']['extensionsURL'] = $civicrm_setting['Directory Preferences']['extensionsDir'];

// Disable automatic download / installation of extensions
$civicrm_setting['Extension Preferences']['ext_repo_url'] = false;

// Disable community messages
$civicrm_setting['CiviCRM Preferences']['communityMessagesUrl'] = false;

$include_path = '.' . PATH_SEPARATOR . $civicrm_root . PATH_SEPARATOR . $civicrm_root . DIRECTORY_SEPARATOR . 'packages' . PATH_SEPARATOR . get_include_path( );
if (set_include_path( $include_path ) === false) {
  echo "Could not set the include path";
  exit();
}

require_once 'CRM/Core/ClassLoader.php';
CRM_Core_ClassLoader::singleton()->register();
