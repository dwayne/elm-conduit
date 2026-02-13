# ![Elm RealWorld Example App](/misc/elm-realworld-example-app.png)

[![RealWorld Frontend](https://img.shields.io/badge/realworld-frontend-%23783578.svg)][RealWorld]
[![Netlify Status](https://api.netlify.com/api/v1/badges/344f78b2-387c-4023-90ab-6cf07e8d8568/deploy-status)](https://app.netlify.com/sites/elm-conduit/deploys?branch=production)


> [Elm](https://elm-lang.org) codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld][RealWorld] spec and API.

### [Demo](https://elm-conduit.netlify.app)&nbsp;&nbsp;&nbsp;&nbsp;[RealWorld][RealWorld]

This codebase was created to demonstrate a fully fledged fullstack application built with [Elm](http://elm-lang.org) including CRUD operations, authentication, routing, pagination, and more.

For more information on how this works with other frontends/backends, head over to the [RealWorld][RealWorld] repo.

## Tour

You can read "[Yet Another Tour of an Open-Source Elm SPA](https://dev.to/dwayne/yet-another-tour-of-an-open-source-elm-spa-1672)" to get a full tour of the application.

## Usage

### Develop

An isolated, reproducible development environment is provided with [Nix](https://nixos.org/). Enter using:

```bash
nix develop
```

### Workshop

The workshop is a simple [frontend workshop environment](https://bradfrost.com/blog/post/a-frontend-workshop-environment/) I put together to build the UI independent of the application's business logic. It was used to figure out how to structure the HTML and CSS.

To build the workshop:

```bash
nix build .#workshop -L
# or
build-workshop
# or
bw
```

To serve the workshop:

```bash
nix run .#workshop
# or
serve-workshop
# or
sw
```

### Sandbox

The sandbox was used to figure out how to structure the Elm view code.

To build the sandbox:

```bash
nix build .#sandbox -L
# or
build-sandbox
# or
bs
```

To serve the sandbox:

```bash
nix run .#sandbox
# or
serve-sandbox
# or
ss
```

### Build

To build the development version of the application:

```bash
nix build -L
# or
nix build .#dev -L
# or
build
# or
b
```

To build the production version of the application:

```bash
nix build .#prod -L
# or
build-prod
# or
bp
```

### Serve

To serve the development version of the application:

```bash
nix run
# or
nix run .#dev
# or
serve
# or
s
```

To serve the production version of the application:

```bash
nix run .#prod
# or
serve-prod
# or
sp
```

### Check

To run various checks to ensure that the flake is valid and that the development and production versions of the application can be built.

```bash
check
# or
c
```

### Chores

- Type `'f'` to run `elm-format`
- Type `'r'` to run `elm-review`
- Type `'t'` to run `elm-test`
- Type `'clean'` to remove build artifacts

### Deploy

To deploy the production version of the application to [Netlify](https://www.netlify.com/):

```bash
nix run .#deploy
# or
d
```

To simulate the deployment you can do the following:

```bash
nix run .#deploy -- -s
# or
d -- -s
```

### CI

- [`check.yml`](./.github/workflows/check.yml) runs checks on every change you push
- [`deploy.yml`](./.github/workflows/deploy.yml) deploys the production version of the application on every push to the master branch that successfully passes all checks

**N.B.** *The [Magic Nix Cache](https://determinate.systems/blog/magic-nix-cache/) is used for caching the Nix store.*

[RealWorld]: https://github.com/realworld-apps/realworld
