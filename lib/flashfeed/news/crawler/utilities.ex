defmodule Flashfeed.News.Crawler.Utilities do
  @moduledoc false

  @media_type_video "video"
  @media_type_audio "audio"
  @media_type_unknown "unknown"

  def entity_key(entity, name) do
    "#{entity["outlet_name"]}-#{entity["name"]}-#{entity["country"]}-#{entity["region"]}-#{name}"
  end

  def entity_uuid() do
    "urn:uuid:#{Ecto.UUID.generate()}"
  end

  def media_type(data) do
    data = String.downcase(data)

    cond do
      data =~ @media_type_video -> @media_type_video
      data =~ @media_type_audio -> @media_type_audio
      true -> @media_type_unknown
    end
  end

  def https_url(url) do
    URI.to_string(%URI{URI.parse(url) | scheme: "https"})
  end
end
