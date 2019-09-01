defmodule Flashfeed.News.Entity do
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
            outlet_url: ""

  use ExConstructor
end
