SCHEME      = "SwiftFilePath"
DESTINATION = "name=iPhone 5,OS=8.1"

desc "unit test"
task :default do
  sh "xcodebuild test -scheme #{SCHEME} -destination \"#{DESTINATION}\" -configuration Debug | bundle exec xcpretty -c && exit ${PIPESTATUS[0]}"
end
