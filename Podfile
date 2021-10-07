# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

source 'https://github.com/jrBordet/Sources.git'
source 'https://cdn.cocoapods.org/'

def shared_pods
   pod 'RxComposableArchitecture', '3.0.0'
   pod 'SwiftLint'
end

target 'WhoSings' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

   shared_pods

	 pod 'SnapKit','4.2.0'
   pod 'RxDataSources'
   pod "SwiftPrettyPrint", "~> 1.1.0" #, :configuration => "Debug"
   pod 'SwiftCharts', :git => 'https://github.com/i-schuetz/SwiftCharts.git'
	 pod 'Charts'
	 pod 'Difference'

  target 'WhoSingsTests' do
    inherit! :search_paths
    # Pods for testing
		
    pod 'RxComposableArchitectureTests', '3.0.0'
    
    pod 'SnapshotTesting', '~> 1.7.2'
    pod 'RxBlocking'
    pod 'RxTest'
    pod 'Difference'
		
  end

end

target 'WhoSingsMock' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

   shared_pods
	 pod 'SnapKit','4.2.0'
   pod 'SwiftCharts', :git => 'https://github.com/i-schuetz/SwiftCharts.git'
   pod 'RxDataSources'
   pod "SwiftPrettyPrint", "~> 1.1.0" #, :configuration => "Debug"
	 pod 'Charts'
	 pod 'Difference'

end

target 'MusixmatchClient' do
	# Comment the next line if you don't want to use dynamic frameworks
	use_frameworks!

	 pod 'RxSwift'
	 pod 'RxCocoa'

end

target 'MusixmatchClientTests' do
	# Comment the next line if you don't want to use dynamic frameworks
	use_frameworks!

	pod 'RxBlocking'
	pod 'RxTest'
	pod 'Difference'
	
end
