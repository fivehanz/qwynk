defmodule Qwynk.UrlShortener.Urls do
  use Ash.Resource,
    domain: Qwynk.UrlShortener,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "urls"
    repo Qwynk.Repo
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    create :shorten do
      accept [:original_url]
      # change fn changeset ->
      #   changeset
      #   |> Ash.Changeset.change([shortened_url: Qwynk.UrlShortener.Generators.Slug.generate()])
      #   |> Qwynk.UrlShortener.Services.UrlValidator.sanitize_inputs()
      # end
    end

    read :get do
      argument :shortened_url, :string, allow_nil?: false
      get? true
      filter expr(shortened_url == ^arg(:shortened_url))
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :original_url, :string do
      allow_nil? false
    end
    attribute :shortened_url, :string do
      # generate fn _ ->
      #   Qwynk.UrlShortener.Generators.Slug.generate()
      # end
    end
  end
end
