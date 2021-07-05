defmodule CuotaProto.Util.Email do
  import Bamboo.Email

  def create_email do
    new_email(
      from: "cuotaproto@gmail.com",
      subject: "Welcome to the app.",
      html_body: "<strong>Thanks for joining!</strong>",
      text_body: "Thanks for joining!"
    )
  end
end
