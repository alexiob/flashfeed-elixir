defmodule Flashfeed.News.Entity do
  @moduledoc false
  defstruct uuid: nil,
            name: "",
            enabled: false,
            crawler: "",
            title: "",
            country: "",
            region: "",
            url: "",
            base_url: "",
            outlet_name: "",
            outlet_title: "",
            outlet_url: "",
            icon: ""

  use ExConstructor
end
