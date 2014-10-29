class UserMailer < ActionMailer::Base

  def review_mail(user_email, user_name, list, cards)
    @user_name = user_name
    @cards = cards.map do |c|
      c.evaluable.content
    end
    @url = new_evaluation_url( list_name: list.name)
    @edit_param_url = edit_list_url( list)
    mail(from: "Pavlov <pavlov.echo.review@gmail.com>", 
         to: (Rails.env.production? ? user_email : ENV['ADMIN_EMAIL']), 
         subject: t('mailers.review_delivery.subject',list_name: list.name))
  end

  def email_confirmation_mail(user_email, token)
    @url = confirm_email_url(token: token)
    mail(from: "Pavlov <pavlov.echo.review@gmail.com>", 
         to: (Rails.env.production? ? user_email : ENV['ADMIN_EMAIL']), 
         subject: t('mailers.email_confirmation.subject'))
  end

  def password_reset_mail(user, token)
    @user = user
    @url = reset_password_url(token: token)
    mail(from: "Pavlov <pavlov.echo.review@gmail.com>", 
         to: (Rails.env.production? ? user.email : ENV['ADMIN_EMAIL']), 
         subject: t('mailers.password_reset.subject'))
  end
end
