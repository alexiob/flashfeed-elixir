defmodule Flashfeed.News.Feed do
  @moduledoc false
  defstruct uuid: nil,
            name: "",
            title: "",
            date: nil,
            url: "",
            media_type: "",
            key: "",
            checked_at: nil,
            updated_at: nil,
            title_text: "",
            main_text: "",
            redirection_url: "",
            update_date: nil

  use ExConstructor
end
