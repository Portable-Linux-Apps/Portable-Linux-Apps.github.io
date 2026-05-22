<div align="center">

###### *Welcome to the most complete database of all AppImage packages and portable applications for GNU/Linux.*

# PORTABLE LINUX APPS

### *the first AUR-inspired AppImage Software Center!*

--------

# Main page "[Portable-Linux-Apps.github.io](https://portable-linux-apps.github.io)"

--------

| *[Go to the applications list](https://portable-linux-apps.github.io/apps.html)* | *[Install "AM", the package manager](https://github.com/ivan-hc/AM)* |
| - | - |
| [<img loading="lazy" src="https://github.com/user-attachments/assets/f55d4242-bd5f-4195-946c-e01c6fe5e264" width="512" height="256">](https://portable-linux-apps.github.io/apps.html) | [<img loading="lazy" src="https://raw.githubusercontent.com/ivan-hc/AM/main/sample/sample.png" width="512" height="256">](https://github.com/ivan-hc/AM) |

### Testing

To test changes to the website before pushing or while working on a pull
request, pick one of the two options below. Docker is recommended because
the container matches the GitHub Pages build environment and works on any
host Ruby version.

</div>

#### Option 1: Docker (recommended, no local Ruby needed)

Uses the official `ruby:3.3` image, which matches the Ruby version GitHub
Pages itself builds with. The first run takes a few minutes while
`bundle install` compiles native gems; the named `jekyll-bundle` volume
caches them so later runs start quickly.

```sh
# delete any host-generated lockfile so the container can regenerate one
rm -f Gemfile.lock

docker run --rm -it -p 4000:4000 \
  -v "$PWD:/srv/jekyll" -w /srv/jekyll \
  -v jekyll-bundle:/usr/local/bundle \
  ruby:3.3 \
  bash -c "bundle install && bundle exec jekyll serve --host 0.0.0.0"
```

#### Option 2: Local Jekyll

* [Install Jekyll](https://jekyllrb.com/docs/installation/)
* In a terminal, change to the repository root directory
* run `bundle install` (only needed the first time, or after `Gemfile`
  changes)
* run `bundle exec jekyll serve`

Requires **Ruby 3.0 - 3.3**. The `github-pages` gem currently pins an old
version of `jekyll-github-metadata` (2.16.1) that crashes on Ruby 3.4+
with an `instance_variable_defined?` `NameError`. If your distribution
ships Ruby 3.4 or newer, use Docker (Option 1) or install Ruby 3.3 via a
version manager such as [`rbenv`](https://github.com/rbenv/rbenv) or
[`asdf`](https://asdf-vm.com/). The `Gemfile` declares `webrick` in the
`:development` group so `jekyll serve` works on Ruby 3.0+ (GitHub Pages
production does not use `webrick`).

#### Viewing the site

You will see messages that confirm that site has generated and the server is
running. Then in your browser, navigate to http://127.0.0.1:4000 to confirm
the changes you made are what you expected. Error messages will appear in the
terminal window from where you ran Jekyll. When you change a file, the site
will rebuild automatically (it will take a few moments and you'll be informed
in the terminal when it's done). However, if you change '_config.yml', you
must kill Jekyll with ctrl-c and run it again to test the change.

--------

*© 2020-present Ivan Alessandro Sala aka 'Ivan-HC'* - I'm here just for fun!

------------------------------------------------------------------------

| [**ko-fi.com**](https://ko-fi.com/IvanAlexHC) | [**PayPal.me**](https://paypal.me/IvanAlexHC) |
| - | - |

------------------------------------------------------------------------

