[![Build Status](CI_BADGE_URL goes here)](REPO_URL goes here)

## Introduction

The repo contains additional Credo rules to support Nimble's Elixir conventions: https://nimblehq.co/compass/development/code-conventions/elixir/

## Project Setup

### Erlang & Elixir

- Erlang 25.0.1

- Elixir 1.13.4

- Recommended version manager.

  - [asdf](https://github.com/asdf-vm/asdf)
  - [asdf-erlang](https://github.com/asdf-vm/asdf-erlang)
  - [asdf-elixir](https://github.com/asdf-vm/asdf-elixir)

### Development

- Install Elixir dependencies:

  ```sh
  mix deps.get
  ```

- Run all tests:

  ```sh
  mix test 
  ```

- Run all lint:

  ```sh
  mix codebase 
  ```

- Fix all lint:

  ```sh
  mix codebase.fix 
  ```

- Test coverage:

  ```sh
  mix coverage 
  ```

### CI/CD

The project relies entirely on [Github Actions](https://github.com/features/actions) for CI/CD via multiple workflows located under the [`.github/workflows/`](.github/workflows) directory.

Please check out the [`.github/workflows/README.md`](.github/workflows/README.md) file for further instructions.
