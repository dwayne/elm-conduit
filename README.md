# ![Elm RealWorld Example App](/misc/elm-realworld-example-app.png)

[![RealWorld Frontend](https://img.shields.io/badge/realworld-frontend-%23783578.svg)][RealWorld]
[![Netlify Status](https://api.netlify.com/api/v1/badges/344f78b2-387c-4023-90ab-6cf07e8d8568/deploy-status)](https://app.netlify.com/sites/elm-conduit/deploys?branch=production)


> [Elm](https://elm-lang.org) codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld][RealWorld] spec and API.

### [Demo](https://elm-conduit.netlify.app)&nbsp;&nbsp;&nbsp;&nbsp;[RealWorld][RealWorld]

This codebase was created to demonstrate a fully fledged fullstack application built with [Elm](http://elm-lang.org) including CRUD operations, authentication, routing, pagination, and more.

For more information on how this works with other frontends/backends, head over to the [RealWorld][RealWorld] repo.

## Tour

You can read "[Yet Another Tour of an Open-Source Elm SPA](https://dev.to/dwayne/yet-another-tour-of-an-open-source-elm-spa-1672)" to get a full tour of the application.

## Develop

An isolated, reproducible development environment is provided with [Devbox](https://www.jetify.com/devbox).

You can enter its development environment as follows:

```bash
$ devbox shell
```

**N.B.** *To run the Bash scripts mentioned below you will need to enter the development environment.*

## Build

To build the prototype:

```bash
$ build-prototype
```

To build the sandbox:

```bash
$ build-sandbox
```

To build the development version of the application:

```bash
$ build
```

To build the production version of the application:

```bash
$ build-production
```

## Serve

To serve the prototype:

```bash
$ serve-prototype
```

To serve the sandbox:

```bash
$ serve-sandbox
```

To serve the development or production version of the application:

```bash
$ serve
```

## Deploy

To deploy the production version of the application to [Netlify](https://www.netlify.com/):

```bash
$ deploy-production
```

[RealWorld]: https://github.com/realworld-apps/realworld
