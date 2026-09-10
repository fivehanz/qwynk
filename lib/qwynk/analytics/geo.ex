defmodule Qwynk.Analytics.Geo do
  @moduledoc """
  MaxMind country lookup against a local mmdb held in `:persistent_term`.

  Every failure path returns `nil`: analytics must never be able to break a
  redirect, and the database is optional in dev and CI.
  """

  @key {__MODULE__, :db}

  @doc "Parses the mmdb at `path` into memory. A missing file is not an error."
  def load(nil), do: :ok

  def load(path) do
    case File.read(path) do
      {:ok, contents} ->
        {meta, tree, data} = MMDB2Decoder.parse_database(contents)
        :persistent_term.put(@key, {meta, tree, data})
        :ok

      {:error, reason} ->
        require Logger
        Logger.info("GeoIP database not loaded (#{path}): #{inspect(reason)}")
        :ok
    end
  end

  @spec country(binary() | nil) :: binary() | nil
  def country(nil), do: nil

  def country(ip) do
    with {meta, tree, data} <- :persistent_term.get(@key, nil),
         {:ok, address} <- :inet.parse_address(String.to_charlist(ip)),
         {:ok, result} <- MMDB2Decoder.lookup(address, meta, tree, data) do
      get_in(result, ["country", "iso_code"])
    else
      _ -> nil
    end
  end
end
