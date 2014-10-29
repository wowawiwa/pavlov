desc "Test task"
task :send_review_mails => :environment do
  List.send_review_mails
end
