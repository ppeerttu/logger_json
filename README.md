# LoggerJSON

[![Build Status](https://travis-ci.org/Nebo15/logger_json.svg?branch=master)](https://travis-ci.org/Nebo15/logger_json)
[![Module Version](https://img.shields.io/hexpm/v/logger_json.svg)](https://hex.pm/packages/logger_json)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/logger_json/)
[![Hex Download Total](https://img.shields.io/hexpm/dt/logger_json.svg)](https://hex.pm/packages/logger_json)
[![License](https://img.shields.io/hexpm/l/logger_json.svg)](https://github.com/Nebo15/logger_json/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/Nebo15/logger_json.svg)](https://github.com/Nebo15/logger_json/commits/master)

A collection of formatters and utilities for JSON-based logging for various cloud tools and platforms.

## Supported formatters

- `LoggerJSON.Formatters.Basic` - a basic JSON formatter that logs messages in a structured format,
  can be used with any JSON-based logging system, like ElasticSearch, Logstash, etc.

- `LoggerJSON.Formatters.GoogleCloud` - a formatter that logs messages in a structured format that can be
  consumed by Google Cloud Logger and Google Cloud Error Reporter.

- `LoggerJSON.Formatters.Datadog` - a formatter that logs messages in a structured format that can be consumed
  by Datadog.

## Installation

Add `logger_json` to your list of dependencies in `mix.exs`:

    def deps do
      [
        # ...
        {:logger_json, "~> 6.0"}
        # ...
      ]
    end

and install it running `mix deps.get`.

Then, enable the formatter in your `config.exs`:

    config :logger, :default_handler,
      formatter: {LoggerJSON.Formatters.Basic, []}

or during runtime (eg. in your `application.ex`):

    :logger.update_handler_config(:default, :formatter, {Basic, []})

Additionally, you may also be interested in [redirecting otp reports to Logger](https://hexdocs.pm/logger/Logger.html#module-configuration) (see "Configuration" section).

## Configuration

Configuration can be set using 2nd element of the tuple of the `:formatter` option in `Logger` configuration.
For example in `config.exs`:

    config :logger, :default_handler,
      formatter: {LoggerJSON.Formatters.GoogleCloud, metadata: :all, project_id: "logger-101"}

or during runtime:

    :logger.update_handler_config(:default, :formatter, {Basic, metadata: {:all_except, [:conn]}})

## Docs

The docs can be found at [https://hexdocs.pm/logger_json](https://hexdocs.pm/logger_json).

## Examples

### Basic

```elixir
%{
  "message" => "Hello",
  "metadata" => %{"domain" => ["elixir"]},
  "severity" => "notice",
  "time" => "2024-04-11T21:31:01.403Z"
}
```

### Google Cloud Logger

Follows the [Google Cloud Logger LogEntry](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry) format,
for more details see [special fields in structured payloads](https://cloud.google.com/logging/docs/agent/configuration#special_fields_in_structured_payloads).

```elixir
%{
  "logging.googleapis.com/operation" => %{"pid" => "#PID<0.228.0>"},
  "logging.googleapis.com/sourceLocation" => %{
    "file" => "/Users/andrew/Projects/os/logger_json/test/formatters/google_cloud_test.exs",
    "function" => "Elixir.LoggerJSON.Formatters.GoogleCloudTest.test logs an LogEntry of a given level/1",
    "line" => 44
  },
  "message" => %{"domain" => ["elixir"], "message" => "Hello"},
  "severity" => "NOTICE",
  "time" => "2024-04-11T21:32:46.957Z"
}
```

Exception that can be sent to Google Cloud Error Reporter:

```elixir
%{
  "httpRequest" => %{
    "protocol" => "HTTP/1.1",
    "referer" => "http://www.example.com/",
    "remoteIp" => "",
    "requestMethod" => "PATCH",
    "requestUrl" => "http://www.example.com/",
    "status" => 503,
    "userAgent" => "Mozilla/5.0"
  },
  "logging.googleapis.com/operation" => %{"pid" => "#PID<0.250.0>"},
  "logging.googleapis.com/sourceLocation" => %{
    "file" => "/Users/andrew/Projects/os/logger_json/test/formatters/google_cloud_test.exs",
    "function" => "Elixir.LoggerJSON.Formatters.GoogleCloudTest.test logs exception http context/1",
    "line" => 301
  },
  "message" => %{
    "@type" => "type.googleapis.com/google.devtools.clouderrorreporting.v1beta1.ReportedErrorEvent",
    "context" => %{
      "httpRequest" => %{
        "protocol" => "HTTP/1.1",
        "referer" => "http://www.example.com/",
        "remoteIp" => "",
        "requestMethod" => "PATCH",
        "requestUrl" => "http://www.example.com/",
        "status" => 503,
        "userAgent" => "Mozilla/5.0"
      },
      "reportLocation" => %{
        "filePath" => "/Users/andrew/Projects/os/logger_json/test/formatters/google_cloud_test.exs",
        "functionName" => "Elixir.LoggerJSON.Formatters.GoogleCloudTest.test logs exception http context/1",
        "lineNumber" => 301
      }
    },
    "domain" => ["elixir"],
    "message" => "Hello",
    "serviceContext" => %{"service" => "nonode@nohost"},
    "stack_trace" => "** (EXIT from #PID<0.250.0>) :foo"
  },
  "severity" => "DEBUG",
  "time" => "2024-04-11T21:34:53.503Z"
}
```

## Datadog

Adheres to the [default standard attribute list](https://docs.datadoghq.com/logs/processing/attributes_naming_convention/#default-standard-attribute-list)
as much as possible.

```elixir
%{
  "domain" => ["elixir"],
  "http" => %{
    "method" => "GET",
    "referer" => "http://www.example2.com/",
    "request_id" => nil,
    "status_code" => 200,
    "url" => "http://www.example.com/",
    "url_details" => %{
      "host" => "www.example.com",
      "path" => "/",
      "port" => 80,
      "queryString" => "",
      "scheme" => "http"
    },
    "useragent" => "Mozilla/5.0"
  },
  "logger" => %{
    "file_name" => "/Users/andrew/Projects/os/logger_json/test/formatters/datadog_test.exs",
    "line" => 239,
    "method_name" => "Elixir.LoggerJSON.Formatters.DatadogTest.test logs http context/1",
    "thread_name" => "#PID<0.225.0>"
  },
  "message" => "Hello",
  "network" => %{"client" => %{"ip" => "127.0.0.1"}},
  "syslog" => %{
    "hostname" => "MacBook-Pro",
    "severity" => "debug",
    "timestamp" => "2024-04-11T23:10:47.967Z"
  }
}
```

## Copyright and License

Copyright (c) 2016 Nebo #15

Released under the MIT License, which can be found in [LICENSE.md](./LICENSE.md).
