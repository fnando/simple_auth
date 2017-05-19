#v3.0.0
- Reimplemented library.
- Add support for scoped authentication (e.g. user and admin).

# v2.0.3

- Assign the raw password/confirmation, so we can apply validations on the raw value.

# v2.0.2

- The compat wasn't validating fields correctly.

# v2.0.1

- The compat mode wasn't generating the `password_digest`.

# v2.0.0

- Released version 2.0.0. This version removes support for MongoDB
  and switches to `has_secure_password` encryption method. This
  change requires Rails 3.1.0+.