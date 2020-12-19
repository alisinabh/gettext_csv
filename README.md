# GettextCSV

A simple tool for converting gettext po files to csv for use with spreadsheet softwares and re-importing the translated csv files to the gettext po files.

## Installation

GettextCSV can be installed by adding `gettext_csv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gettext_csv, "~> 0.1.0"}
  ]
end
```

## How to use

GettextCSV defines two mix tasks. `gettext_csv.extract` and `gettext_csv.import`.

### Extract

After installation you can extract your msgids and translations using `mix gettext_csv.extract`. Optionally you can point to your specific pot file with the `--pot-file` option.

Also you can specify which languages you want with the `--lang en,fa` options. Otherwise all the locales in your gettext directory will be used.

After that a `{filename}.csv` will be generated in your current working directory. You can share this file with other people to help you with translations.

Just remember not to mess around with the headers and column order.

### Import

After translation is done you can re-import them to your po files using `mix gettext_csv.import default.csv`. Again optionally you can point to your specific pot file using the `--pot-file` option.

Review changes made to your po files using git diff and then commit them.

## Documentations

[https://hexdocs.pm/gettext_csv](https://hexdocs.pm/gettext_csv).

## Known Issues

Currently GettextCSV does not support Plural translations and will skip them in both extract and import tasks.

