# Elixir CDN Assets Manager

[![Build Status](https://travis-ci.org/shufo/cdn.svg?branch=master)](https://travis-ci.org/shufo/cdn)
[![hex.pm version](https://img.shields.io/hexpm/v/cdn.svg)](https://hex.pm/packages/cdn)
[![hex.pm](https://img.shields.io/hexpm/l/cdn.svg)](https://github.com/shufo/cdn/blob/master/LICENSE)

### Content Delivery Network Package for Elixir/Phoenix.

This package provides the developer the ability to upload assets to a CDN with single mix command.  
Inspired by [Vinelab/cdn](https://github.com/Vinelab/cdn).

## Overview

<img src="https://raw.githubusercontent.com/wiki/shufo/cdn/img/upload.gif" width="600">

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add cdn to your list of dependencies in `mix.exs`:

```elixir
{:cdn, "~> 0.0.1"}
```

## Configuration

Firstly this package is relies on [ex_aws](https://github.com/CargoSense/ex_aws) then setting `ex_aws` before configuration.

```elixir
config :ex_aws,
  region: "us-east-1"
```

After that Configure your `config.exs` like this.

```elixir
config :cdn,  bucket: "myassets.bucket",
              include: [
                directories: ["priv/static", "public/bin"],
                patterns: ["**/*", "**/*.css"],
                hidden: true
              ],
              exclude: [
                directories: [],
                patterns: [],
                hidden: true
              ],
              acl: :public_read,
              cloudfront_url: "https://asset.s3.amazonaws.com",
              bypass: false
```

- `bucket`: A bucket name of s3
- `include`: Setting for upload target
  - `directories`: List of upload directory(`default`: `["priv/static"]`)
  - `patterns`: List of upload pattern(`default`: `["**/*"]`)
  - `hidden`: Include hidden files or not
- `exclude`: Exclude targets
- `acl`: Default acl for assets
- `cloudfront_url`: URL of CDN endopoint (e.g. `https://cloudfonrt.net`)
- `bypass`: Return local asset if `bypass` is `true` in cdn helper.

## Usage

### Commands

- Upload to S3

```elixir
mix cdn.push
```

- Empty bucket

```elixir
mix cdn.empty
```

### Asset Helper

Import CDN Helper to your dependency

- Phoenix

`web.ex`

```elixir
def view do
  quote do
    ...
    # Import CDN helper
    import Cdn.Helpers
    ...
  end
end
```

then you can load static file like this.

```elixir
<%= cdn(static_path(@conn, "/css/app.css")) %>

# MIX_ENV=dev
<%= cdn(static_path(@conn, "/css/app.css")) %> #=> "/css/app.css"

# MIX_ENV=prod
<%= cdn(static_path(@conn, "/css/app.css")) %> #=> "https://assets.cloudfront.net/css/app.css"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
