desc "Dump evaluations from user with email address :email in file :output"
task :evaluations_to_json, [:email, :output] => :environment do |task, args|
  u = User.where( email: args[:email] ).first
  r = []
  u.evaluations.each{|ev| r << ev.attributes.merge( front_side: ev.card.evaluable.content, back_side: ev.card.evaluable.tip, list_name: ev.card.list.name)}
  File.open( args[:output], 'w' ){|f| f.write(JSON.dump( r) ) }
end
