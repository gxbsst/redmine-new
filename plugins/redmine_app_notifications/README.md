# Redmine App Notifications

App notifications plugin provides simple in application notifications for Redmine. It can replace default e-mail notifications.

This plugin is forked from github。 I am going to fit it for the Private_Pub and will renew it.


## Installation and Setup

1. Follow the Redmine plugin installation steps at: http://www.redmine.org/wiki/redmine/Plugins
2. Run the plugin migrations `rake redmine:plugins:migrate RAILS_ENV=production`
3. Set the Faye server through Privat_Pub for client notifications. It is as same as chat_plugin(https://bitbucket.org/39648421/redmine_chat). 
   In redmine home directory, run: bundle install --without development test.
4. Please run bundle update private_pub if you have bundled from tigergm's github
5. In redmine home directory, run: RAILS_ENV=production rails g private_pub:install. It will generate a few template files
6. Edit private_pub.ru file in redmine home directory, such as changes to the mysql sqlite3
7. Edit private_pub.yml file in config directory, such as the server production according to the the server's ip or domain name
8. In redmine main directory, start faye server, distribute and monitor chat messages, it may be necessary preceded bundle exec. You can add "-D" in the end as backgound daemon. Run:
9. rackup private_pub.ru -s thin -E production
  Other example if you want to listen all and run as daemon:
  rackup -o 0.0.0.0 private_pub.ru -s thin -E production -D
10.  If you want to stop the server you can run this to find the service's pid and kill it:
  ps aux | grep 'rackup'
  sudo kill -9 xxxx
11. In Administration > Plugins > Configure, modify `ip_address_or_name_of_your_server` to match your server IP address or name
12. Restart your Redmine web server
13. Login and configure the plugin (Administration > Plugins > Configure)
14. Enable In App Notifications in user account settings -> preferences

## Versions

1.0.4
added the deletion for notifications

1.0.3
removed the setting of the faye address

1.0.2
seperated it from chat_plugin. it can be installed and run seperately without chat_plugin

1.0.1
fitted it for Private_Pub
added Portuguese. Thank Adriano Ceccarelli
added Chinese.
