namespace :db do
  namespace :data do
    desc "Run data bootstrap migrations from db/data"
    task migrate: :environment do
      Rake::Task["data:migrate"].invoke
    end
  end

  Rake::Task["db:prepare"].enhance do
    Rake::Task["db:data:migrate"].invoke
  end

  Rake::Task["db:seed"].enhance do
    Rake::Task["db:data:migrate"].invoke
  end
end
