## Redmine omniauth OAuth2 / CAS / ISU

This plugin is used to authenticate Redmine users using [CAS OAuth2](https://apereo.github.io/cas/5.0.x/installation/OAuth-OpenId-Authentication.html) provider ("Authorization Code" grant type).
It is primarily intended to work with [ITMO university](http://www.ifmo.ru) ISU system [https://isu.ifmo.ru](https://isu.ifmo.ru).

Version of [CAS](https://apereo.github.io/cas): 5.0

Version of [Redmine](http://www.redmine.org/): 3.2.3

### Installation

1. Download the plugin and install required gems:

```console
cd /path/to/redmine/plugins
git clone https://github.com/pbelikov/redmine_omniauth_isu.git
cd /path/to/redmine
bundle install
```

2. __IMPORTANT!__ Plugin is primarily intended to work without proxy and to override issues with SSL-certificate.
So, if you use proxy, please go to `app/controllers/redmine_oauth_controller.rb` and comment line 7 
(which disables proxy). And if your SSL is OK, go to the same file and comment code in line 5 and part of code in line 39.
Yes, I know that this is BAD codestyle, but it'll work for sure.

3. Restart the app
```console
touch /path/to/redmine/tmp/restart.txt
```

### Configuration

* Login as a user with administrative privileges. 
* In top menu select "Administration".
* Click "Plugins"
* In plugins list, click "Configure" in the row for "Redmine Omniauth ISU plugin"
* Enter CAS URL
* Enter the Сlient ID & Client Secret, which you entered for your CAS Service (see more [here](https://apereo.github.io/cas/5.0.x/installation/OAuth-OpenId-Authentication.html)).
* Check the box near "Oauth authentication"
* Click Apply. 
 
Users can now use their CASified Account to log in to your instance of Redmine.

### Authentication Workflow

1. An unauthenticated user requests the URL to your Redmine instance.
2. User clicks the "Login via ..." buton.
3. The plugin redirects them to a CAS sign in page if they are not already signed in to their CAS account.
4. CAS redirects user back to Redmine, where the CAS OAuth plugin's controller takes over.


### Profile format

User information in CAS `/cas/oauth2.0/profile` for successful login or creation of user has following format:

```
{
    "attributes": {
        "redmine_login":"ivan",
        "redmine_attrs":"Ivan|Ivanov|ivan@example.com"
    },
    "id": 123456789
}
```

### Additional info

This plugin overrides Redmine's autoregistration feature so user is created automatically if all required fields
are provided (login, firstname, lastname, email). Uniqueness of user is checked against login.

### Inspiration

This plugin is inspired by [twinslash](https://github.com/twinslash) plugin [Redmine omniauth google](https://github.com/twinslash/redmine_omniauth_google).

## License

The MIT License (MIT)

Copyright 2017 Pavel Belikov

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
