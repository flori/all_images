# AllImages is a Ruby library that provides functionality for managing and
# executing scripts across multiple Docker images.
#
# It offers a command-line interface for running automated tasks in
# containerized environments, supporting configuration-driven execution, image
# building, and interactive debugging.
#
# The library includes modules for handling configuration files, managing
# Docker image operations, and providing a user-friendly interface for
# developers to test their code across different environments without manual
# setup.
module AllImages
end

require 'all_images/version'
require 'all_images/app'
require 'all_images/config'
