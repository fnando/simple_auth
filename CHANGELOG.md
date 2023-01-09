# Changelog

## v3.1.4

- Add `authenticate(scope, condition, &block)`, so you can restrict routes
  directly from the routes definition.

## v3.1.3

- Remove session[:return_to] after using it.

## v3.1.2

- Make flash message key configurable via
  `SimpleAuth::Config#flash_message_key`.

## v3.1.1

- Catch exceptions related to record not found when session tries to load a
  record from session. You can customize the recognized exceptions by adding the
  error class to `SimpleAuth::Session.record_not_found_exceptions`.

## v3.1.0

- SimpleAuth now uses [GlobalID](https://github.com/rails/globalid) as the
  identification that's saved on the session. This should be a seamless
  migration (users will only have to re-login). This allows using any objects
  that respond to `#to_gid`, including namespaced models and POROs.

## v3.0.0

- Reimplemented library.
- Add support for scoped authentication (e.g. user and admin).

## v2.0.3

- Assign the raw password/confirmation, so we can apply validations on the raw
  value.

## v2.0.2

- The compat wasn't validating fields correctly.

## v2.0.1

- The compat mode wasn't generating the `password_digest`.

## v2.0.0

- Released version 2.0.0. This version removes support for MongoDB and switches
  to `has_secure_password` encryption method. This change requires Rails 3.1.0+.
