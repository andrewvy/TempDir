### TempDir

Simple Elixir Library for creating self-cleaning temp directory folders.

### Example

```elixir
iex(1)> {:ok, dir} = TempDir.start_link
{:ok, #PID<0.121.0>}

iex(2)> TempDir.get_path(dir)
"/tmp/elixir-47776-630886-4"
```

There are a couple options you can use when calling `TempDir.start_link`

- `:dir_prefix` - The directory prefix of the temporary dir. (Default: "elixir")
- `:tmp_dir` - The location in which the temporary dir is created. (Default: "/tmp")

```elixir
iex(1)> {:ok, dir} = TempDir.start_link(dir_prefix: "test")
{:ok, #PID<0.108.0>}

iex(2)> TempDir.get_path(dir)
"/tmp/test-47988-226661-1"
```

## Installation

  1. Add tempdir to your list of dependencies in `mix.exs`:

        def deps do
          [{:tempdir, "~> 0.0.1"}]
        end

  2. Ensure tempdir is started before your application:

        def application do
          [applications: [:tempdir]]
        end

