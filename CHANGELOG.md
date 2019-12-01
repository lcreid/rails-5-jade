## [Pending Release][]

### Breaking changes

* Your contribution here!

### New features

* Your contribution here!

### Bugfixes

* Your contribution here!

## [6.1.1][2019-11-24]

### Bugfixes

* [#38] Hopefully not block `vagrant up` on Windows hosts
* [#39] Upgrade Chrome so system testing on newer versions of Rails works

## [6.1.0][] (2019-08-19)

### New features

* Rails 6.0.0 for the Ubuntu 18.04 boxes.

### Bugfixes

* Add MS SQL executable path to PATH (this got accidentally dropped
  in the last version).

## [6.0.0][] (2019-03-08)

### Breaking changes

* [#30] New box names. This requires an update to your `Vagrantfile`

### New features

* [#33] Make hostname and terminal prompt show something more informative.
* [#30] Copy .netrc to the Vagrant box when provisioning.
* New changelog format.

## V5.1.0

*   [#24] Create a Postgres role `vagrant` so the default Postgres `database.yml` just works.
*   [#26] Fix Bundler version to the last 1.x version (1.17.3).
*   Rails 5.2.1.

    *Larry Reid*

## V5.0.0

*   Ubuntu 18.04.
    Newer Redis (the one that comes with Ubuntu 18.04).
    Postgres 10.2.
    Clean up build directories to make box smaller.

    *Larry Reid*

## V4.0.3

*   Rails 5.2.0 (general availability).

    *Larry Reid*

## V4.0.2

*   Zero out space after build, to reduce the size of the raw box
    by about 500 MB.
*   Update version in README.
*   Correct earlier CHANGELOG entry.

    *Larry Reid*

## V4.0.1

*   Building libffi, needed by sass, needs more dev tools.

    *Larry Reid*

## V4.0.0

*   Rails 5.2.

    *Larry Reid*

## V3.0.0

*   Add Chrome.

    *Larry Reid*

## V1.1.1

*   Adjust location of Redis configuration file.

    *Larry Reid*

## V1.1.0

*   Add Redis 3.2.11.
    Ubuntu 16.04.03.

    *Larry Reid*

## V1.0.2

*   Add yarn.

    *Larry Reid*

## V2.0.2

*   Really fix the `dpkg` error.

    Issue #21.

    *Larry Reid*

## V2.0.1

*   Fix the `dpkg` error.

    Issue #21.

    *Larry Reid*

## V2.0.0

*   Add `rbenv`.

    Issue #20.

    *Larry Reid*

## V1.0.0

*   Rails 5.1

    *Larry Reid*

## v0.5.2

*   Fix hostname

    *Larry Reid*

*   Update Ubuntu after build

    *Larry Reid*

[Pending Release]: https://github.com/bootstrap-ruby/bootstrap_form/compare/v6.0.0...HEAD
[6.0.0]: https://github.com/bootstrap-ruby/bootstrap_form/compare/v5.1.0...v6.0.0
