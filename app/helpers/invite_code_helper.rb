module InviteCodeHelper

  def invite_code_activated?
    !!ENV['INVITE_CODE']
  end

  def valid_invite_code?(invite_code)
    ENV['INVITE_CODE'] == invite_code
  end
end
