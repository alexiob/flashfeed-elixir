defmodule FlashfeedWeb.ValidationView do
  use FlashfeedWeb, :view

  def render("error.json", %{errors: errors}) do
    %{errors: errors}
  end
end
