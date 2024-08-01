defmodule Qwynk.UrlShortener do
  use Ash.Domain

  resources do
    resource Qwynk.UrlShortener.Urls do
    end

    # resource Qwynk.UrlShortener.Analytics do
    # end
  end
end
