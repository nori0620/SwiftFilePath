SCHEME      = "SwiftFilePath"
DESTINATION = "name=iPhone Retina (4-inch),OS=8.0"

desc "unit test"
task :default do
    sh "xcodebuild test -scheme #{SCHEME} -destination \"#{DESTINATION}\" -configuration Debug | bundle exec xcpretty -c && exit ${PIPESTATUS[0]}"
    end
end
