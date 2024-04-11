defmodule LoggerJSON.Formatter.Metadata do
  @ignored_metadata_keys ~w[ansi_color initial_call crash_reason pid gl mfa report_cb time]a

  @doc """
  Takes current metadata option value and updates it to exclude the given keys.
  """
  def update_metadata_selector(:all, processed_keys),
    do: {:all_except, processed_keys}

  def update_metadata_selector({:all_except, except_keys}, processed_keys),
    do: {:all_except, except_keys ++ processed_keys}

  def update_metadata_selector(keys, _processed_keys),
    do: keys

  @doc """
  Takes metadata and returns a map with the given keys.

  The `keys` can be either a list of keys or one of the following terms:

    * `:all` - all metadata keys except the ones already processed by the formatter;
    * `{:all_except, keys}` - all metadata keys except the ones given in the list and
    the ones already processed by the formatter.
  """
  def take_metadata(meta, {:all_except, keys}) do
    meta
    |> Map.drop(keys ++ @ignored_metadata_keys)
    |> Enum.into(%{})
  end

  def take_metadata(meta, :all) do
    meta
    |> Map.drop(@ignored_metadata_keys)
    |> Enum.into(%{})
  end

  def take_metadata(_meta, []) do
    %{}
  end

  def take_metadata(meta, keys) when is_list(keys) do
    Map.take(meta, keys)
  end

  @doc """
  Takes a map and a list of mappings and transforms the keys of the map according to the them.

  Transformers can override each other results but the last one in this list wins
  """
  def transform_metadata_keys(output, md, mappings) do
    Enum.reduce(mappings, output, fn {key, {new_key, transformer}}, acc ->
      if Keyword.has_key?(md, key) do
        new_value = transformer.(Keyword.get(md, key))
        Map.put(acc, new_key, new_value)
      else
        acc
      end
    end)
  end
end
