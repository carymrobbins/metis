```bash
rvm get head && rvm reload
rvm install 2.0.0
rvm get stable
rvm use 2.0.0@metis --create --default
# If on osx, you may need to
rvm osx-ssl-certs update all
bundle update
bundle install
rake db:migrate
```
