defmodule BananaBank.Users do
  defdelegate create(params), to: BananaBank.Users.Create, as: :call
end
