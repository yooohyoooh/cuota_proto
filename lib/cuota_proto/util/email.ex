defmodule CuotaProto.Util.Email do
  import Bamboo.Email

  def create_email do
    new_email(
      to: "french.papu7@gmail.com",
      from: "support@myapp.com",
      subject: "Welcome to the app.",
      html_body: "<strong>Thanks for joining!</strong>",
      text_body: "Thanks for joining!"
    )
  end
end
