# Northflank Ruby on Rails template

<a target="_blank" rel="noopener noreferrer" href="https://www.northflank.com">
    <img alt="Northflank" align="right" src="/media/logo.svg" width="35%" />
</a>

- [Create a service from template on Northflank](https://app.northflank.com/s/project/create/template-service)
- Select the Ruby on Rails template
- Wait for the app to build and visit the newly assigned URL. That's it!

You can now clone your repository locally and start making changes. Push your changes to automatically build and deploy the updated application!

[Learn more about using Northflank](https://northflank.com/docs/).

#### Authorizing hosts

This application has been configured to [authorize hosts](https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization) passed via the environment variable `NF_HOSTS`. You can change this, if necessary, by manually setting the environment variable or changing `config.hosts` in the Ruby environments in `config/environments`.

### Live Demo
[https://example--ruby-on-rails--examples--nort-kcwl.code.run](https://example--ruby-on-rails--examples--nort-kcwl.code.run)

## About Rails
[Ruby on Rails](https://rubyonrails.org/), or Rails, is a server-side web application framework written in Ruby under the MIT License. Rails is a model–view–controller framework, providing default structures for a database, a web service, and web pages.

This example project uses Rails version 7.0.4 running on Ruby version 3.1.2.

## Quick start 🚀

To follow this quick start, first install [Ruby version 3.1.2](https://www.ruby-lang.org/en/documentation/installation/). You can also use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to manage your Ruby installations (recommended).


1.  **Install Rails version 7.0.4.**

    ```shell
    gem install rails --version 7.0.4
    ```

1.  **Install packages.**

    Navigate into your new site’s directory and install gems with:

    ```shell
    # Install using bundle:
    bundle install
    ```

1.  **Start developing.**

    Run the test server with rails:

    ```shell
    rails server -p 3000
    ```

    The live development website should now be available at [http://localhost:3000](http://localhost:3000)
