defmodule Qwynk.Accounts do
  use Ash.Domain, otp_app: :qwynk

  resources do
    resource Qwynk.Accounts.Token
    resource Qwynk.Accounts.User
    resource Qwynk.Accounts.ApiKey
  end
end
