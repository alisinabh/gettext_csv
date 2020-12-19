defmodule Mix.Tasks.GettextCsv.Extract do
  use Mix.Task

  import GettextCsv

  alias NimbleCSV.RFC4180, as: CSV

  @shortdoc "Extract po files to to csv"
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [pot_file: :string, langs: :string])

    pot_file = get_pot_file(opts[:pot_file])

    base = Path.dirname(pot_file)
    filename = Path.basename(pot_file, Path.extname(pot_file))

    langs = extract_langs(opts[:langs], base)

    pot = Gettext.PO.parse_file!(pot_file)

    pot_msg_ids =
      pot.translations
      |> Enum.filter(fn
        %Gettext.PO.Translation{} -> true
        _ -> false
      end)
      |> Enum.map(fn x -> x.msgid end)

    lang_msg_ids =
      Enum.reduce(langs, %{}, fn lang, acc ->
        po_file = po_path(base, lang, filename)
        po = Gettext.PO.parse_file!(po_file)

        po_msg_ids =
          po.translations
          |> Enum.filter(fn
            %Gettext.PO.Translation{} -> true
            _ -> false
          end)
          |> Enum.map(fn x -> {x.msgid, x.msgstr} end)
          |> Enum.into(%{})

        Map.put(acc, lang, po_msg_ids)
      end)

    csv =
      Enum.reduce(pot_msg_ids, [["msgid" | langs]], fn msg_id, acc ->
        translates = Enum.map(langs, fn lang -> lang_msg_ids[lang][msg_id] |> List.first() end)

        acc ++ [[List.first(msg_id) | translates]]
      end)

    File.write!("#{filename}.csv", CSV.dump_to_iodata(csv))

    IO.puts("CSV written to #{filename}.csv")
  end
end
