Getting Ready for Development
-----------------------------

```bash
# Install RVM
\curl -L https://get.rvm.io | bash -s stable
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
