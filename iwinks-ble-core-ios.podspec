Pod::Spec.new do |s|
  s.name             = 'iwinks-ble-core-ios'
  s.version          = '0.1.0'
  s.summary          = 'iWinks BluetoothLE core library'

  s.description      = <<-DESC
Library dedicated to provide developer access to Aurora BLE API.
                       DESC
  s.homepage = 'www.iwinks.io'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rafael Nobre' => 'nobre84@gmail.com' }
  s.source           = { :git => 'https://github.com/iwinks/iwinks-ble-core-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'iwinks-ble-core-ios/Classes/**/*'

  s.dependency 'RZBluetooth'

end
