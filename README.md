# Northflank Ruby on Rails Example

<a target="_blank" rel="noopener noreferrer" href="https://www.northflank.com">
    <img alt="Northflank" align="right" src="/media/logo.svg" width="35%" />
</a>

Deploy this example easily on [Northflank](https://www.northflank.com) by selecting the Ruby on Rails template when creating a new service.

Alternatively you can:

- Clone this repository to your Git account
- Select this repository in Northflank when creating a new service
- Wait for the app to build and visit the newly assigned URL. That's it!

#### Authorizing hosts

This application has been configured to [authorize hosts](https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization) passed via the environment variable `NF_HOSTS`. You can change this, if necessary, by manually setting the environment variable or changing `config.hosts` in the Ruby environments in `config/environments`.

### Live Demo
[https://example--ruby-on-rails--examples--nort-kcwl.code.run](https://example--ruby-on-rails--examples--nort-kcwl.code.run)

### How to run migrations

You can run a migration in the following ways:

- Run a release flow, which automatically runs a migration and then promotes the deployment only when the migration is successful
- Use a job triggered by CI
- Restart your deployment a command override
- Execute a command in a deployment's container shell

To release a new version of your application with a migration it is recommended you follow the workflow:

1. Back up your database, in case you need to roll back
2. Deploy the built image for your release to a job and run the migration
3. If the migration is successful, deploy the new release to the deployment service

[Learn more about running migrations](https://northflank.com/docs/v1/application/release/handle-runtime-migrations).

#### Migrate commands

You can [run migrate commands](https://northflank.com/docs/v1/application/run/access-running-containers-locally#execute-commands-in-a-container) in a container's shell or as a [custom command](https://northflank.com/docs/v1/application/run/override-command-entrypoint). If your image is built with buildpacks, you can specify a [custom launcher command or Procfile process](https://northflank.com/docs/v1/application/run/override-command-entrypoint#buildpack-processes).

You should specify processes and run commands using the `bundle exec` format, for example `bundle exec rails db:migrate`

#### Versions

You can specify the migration version in the command with `VERSION=<your version>`, or set `VERSION` as an [environment variable](https://northflank.com/docs/v1/application/run/inject-runtime-variables).

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
