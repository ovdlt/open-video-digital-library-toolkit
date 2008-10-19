Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec_trans.rb']
end
