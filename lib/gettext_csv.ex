defmodule GettextCsv do
  @moduledoc """
  Common functions used by gettext_csv import and export mix tasks.
  """

  @doc """
  Returns the full path of a po file.
  """
  def po_path(base, lang, filename) do
    Path.join([base, lang, "LC_MESSAGES", filename <> ".po"])
  end

  @doc """
  Returns the pot file full path.
  """
  def get_pot_file(path) do
    cond do
      is_nil(path) || path == "" ->
        cond do
          File.exists?("priv/gettext/default.pot") ->
            Path.join(File.cwd!(), "priv/gettext/default.pot")

          true ->
            raise "Cannot find the gettext pot file. Please specify your pot file in directory using the --pot-file option"
        end

      File.exists?(path) and not File.dir?(path) ->
        path

      File.exists?(Path.join(path, "default.pot")) ->
        Path.join(path, "default.pot")

      true ->
        raise "Cannot find the gettext pot file. #{path}"
    end
  end

  @doc """
  Extract langs from opts or alternatively from priv directories of gettext.
  """
  def extract_langs(nil, base) do
    base
    |> File.ls!()
    |> Enum.filter(fn p -> File.dir?(Path.join(base, p)) end)
  end

  def extract_langs(langs, _) when is_binary(langs) do
    String.split(langs, ",")
  end
end
