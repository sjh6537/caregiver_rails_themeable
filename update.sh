

rake db:migrate RAILS_ENV=production
rake assets:precompile RAILS_ENV=production
rails s -p 5000 -e production -d


