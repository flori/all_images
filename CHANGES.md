# Changes

## 2026-01-02 v0.11.1

- Handle `nil` configuration gracefully when retrieving images to improve
  robustness
- Escape escape sequences in config script
- Maintain backward compatibility while making the application more resilient
  to configuration issues

## 2026-01-02 v0.11.0

- Added `CHANGES.md` file to package by updating the `changelog` configuration
  in the gemspec file
- Updated `gem_hadar` dependency to version **2.16.3** or higher
- Updated Ruby version in CI configuration from `ruby:4.0-rc-alpine` to
  `ruby:4.0-alpine`
- Added `ruby:4.0-alpine` entry to `lib/all_images/config.rb` for consistent
  image definition configuration

## 2025-12-21 v0.10.0

- Updated `rubygems_version` from **3.6.9** to **4.0.2**
- Updated `gem_hadar` development dependency from **~> 2.7** to **~> 2.12**
- Enhanced README.md with comprehensive documentation including architecture
  overview, component descriptions, usage examples, installation instructions,
  configuration details, and advanced features
- Added detailed command examples and configuration file structure
  documentation
- Enhanced security considerations and error handling sections
- Accurately documented `run_all`, `run`, `debug`, `ls`, and `help` commands
- Documented Docker integration, environment variable handling, and interactive debugging
- Maintained proper documentation of YAML configuration format including
  `dockerfile`, `script`, `fail_fast`, and `images` sections
- Preserved accurate description of `SearchUI` integration for interactive
  image selection
- Changed `bundle update` command to `bundle update --all` for consistent
  dependency updates
- Added `ruby:4.0-rc-alpine` image configuration to CI pipeline
- Maintains existing Ruby version support for **3.4**, **3.3**, and **3.2**
- Improves CI coverage for upcoming Ruby **4.0** release candidate

## 2025-10-09 v0.9.0

- Bumped **gem_hadar** dependency from **2.4** to **2.7**
- Added **yaml**, **fileutils**, and **shellwords** as runtime dependencies
- Updated Dockerfile to include **openssl-dev** and use `gem update --system`
- Replaced `bundle` with `bundle update` and `bundle install --jobs=$(getconf
  _NPROCESSORS_ONLN)`
- Added **ruby:3.1-alpine** to CI image matrix
- Enabled `fail_fast: true` in CI configuration
- Updated default config as well

## 2025-09-11 v0.8.0

- Improved image matching logic by replacing direct
  `images.map(&:first).grep(...)` with a separate `image_names` variable for
  better search behavior
- Updated `tins` dependency from version **1.42** to **1** in `Rakefile` and
  `all_images.gemspec`
- Updated `gem_hadar` development dependency from version **2.2** to **2.4** in
  `Rakefile` and `all_images.gemspec`

## 2025-09-03 v0.7.0

- **Interactive Image Selection**: Integrated `SearchUI` for enhanced user
  experience when selecting Docker images
- **Improved Configuration Handling**: Better error handling and fallback
  mechanisms for configuration loading
- Removed support for Ruby **3.0** and **3.1**
- Added support for Ruby **3.4** with `ruby:3.4-alpine` image configuration
- Simplified SimpleCov setup using `GemHadar::SimpleCov.start`
- Removed obsolete `binary` option from utils config
- Added comprehensive documentation across the library
- Improved logging with `info_puts` method for colored console output

## 2024-10-14 v0.6.0

### Significant Changes
* **Add support for environment variables to all_images**
  + Require `'tins/xt/full'` and add new method `env` to set environment variables.
  + Modified the `sh` method to use environment variables from the `env` method.
  + Modified the `run_image` method to include environment variables in the Docker command.
* Update rake task to use spec instead of test
* Added `[IMAGE]` as an optional argument in the Usage message.

### Other Changes
* Reformat CHANGES.md
* Add error reporting to `sh`
  + Added require `'shellwords'`

#### Environment Variables
* Added `env` section to `.all_images.yml`
* Defined `FOO=bar` and `USER` environment variables

## 2024-09-01 v0.5.0

* **Update image processing for parallel execution**:
  + Added random suffix to image names to prevent conflicts between concurrent processes.
* Added `CHANGES.md` file

## 2024-08-08 v0.4.1

* **License File Added**: A license file was added in written form.

## 2024-02-07 v0.4.0

* Added support for outputting colors in addition to existing functionality.

## 2023-08-17 v0.3.0

* **New Feature**: Allow running scripts within a Docker container, enabling
  more flexible and isolated testing environments.

## 2023-08-17 v0.2.5

* Corrected actual checking logic.

## 2023-08-17 v0.2.4

* **Improved Error Handling**: 
  * Added checks to prevent premature failure in critical sections of the code.

## 2023-06-01 v0.2.3

* **New Features**
  + Added support for Ruby 3.2
* **Changes**
  + Bumped build version
  + Removed support for Ruby 2.5
* **Bug Fixes**
  + Repaired `fail_fast` mode

## 2023-04-19 v0.2.2

* **New Version Features**
  + Progress into the future of ruby development
  + Progress into the future
* **Significant Changes**
  + Removed development dependency (again)

## 2022-11-17 v0.2.1

* Added a new `help` command.

## 2022-11-17 v0.2.0

* **New Features**
  + Added commands to run and debug single images
  + Added a debug debugger feature

## 2022-11-17 v0.1.0

* Added `fail_fast` configuration option.

## 2022-07-11 v0.0.2

* **Security Fix**: Local config files are now properly sanitized to prevent potential security vulnerabilities.

## 2022-05-16 v0.0.1

* **Bug Fix**: Fixed bug in `required_ruby_version` functionality, which was causing issues with certain RubyGems releases.
 
### Significant Changes
* Removed buggy implementation of `required_ruby_version`
* Improved stability and compatibility with RubyGems releases

## 2022-05-15 v0.0.0

  * Start
