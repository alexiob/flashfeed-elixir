defmodule FlashfeedWeb.UtilitiesView do
  use FlashfeedWeb, :view

  def render("version.txt", %{name: name, version: version}) do
    "#{name}-#{version}"
  end
end
