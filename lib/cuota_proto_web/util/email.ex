defmodule CuotaProto.Util.Email do
  import Bamboo.Email

  def create_email do
    new_email(
      from: "yasaki418@gmail.com",
      subject: "7月5日テスト",
      html_body: "<strong>このメールは7月5日のテスト用です</strong>",
      text_body: "このメールは7月5日のテスト用です"
    )
  end
end
