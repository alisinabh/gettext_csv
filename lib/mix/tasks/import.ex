defmodule Mix.Tasks.GettextCsv.Import do
  use Mix.Task

  import GettextCsv

  alias NimbleCSV.RFC4180, as: CSV

  @shortdoc "Import csv to po files"
  def run(args) do
    {opts, [csv_file], _} = OptionParser.parse(args, strict: [pot_file: :string])

    pot_file = get_pot_file(opts[:pot_file])

    base = Path.dirname(pot_file)
    filename = Path.basename(pot_file, Path.extname(pot_file))

    [["msgid" | langs] | csv_data] =
      csv_file
      |> File.read!()
      |> CSV.parse_string(skip_headers: false)

    po_data =
      langs
      |> Enum.reduce(%{}, fn lang, acc ->
        po_file = po_path(base, lang, filename)
        po = Gettext.PO.parse_file!(po_file)
        Map.put(acc, lang, po)
      end)

    po_data =
      Enum.reduce(csv_data, po_data, fn row, po_data_1 ->
        [msgid | translations] = row
        translations = Enum.zip(langs, translations) |> Enum.into(%{})

        Enum.reduce(langs, po_data_1, fn lang, po_data_2 ->
          po = replace(po_data_2[lang], msgid, translations[lang])
          Map.put(po_data_2, lang, po)
        end)
      end)

    Enum.each(po_data, fn {lang, po} ->
      po_file = po_path(base, lang, filename)
      po_dump = Gettext.PO.dump(po)
      File.write!(po_file, po_dump)
      IO.puts("Written #{lang} to #{po_file}")
    end)

    IO.puts("Import finished!")
  end

  defp replace(po, msgid, translation) do
    translations =
      Enum.map(po.translations, fn
        %Gettext.PO.Translation{} = po_translation ->
          if po_translation.msgid == [msgid] do
            Map.put(po_translation, :msgstr, [translation])
          else
            po_translation
          end

        t ->
          t
      end)

    Map.put(po, :translations, translations)
  end
end
