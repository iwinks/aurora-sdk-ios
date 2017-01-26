Pod::Spec.new do |s|
  s.name             = 'AuroraDreamband'
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

  s.source_files = 'AuroraDreamband/Classes/**/*'

  s.dependency 'RZBluetooth'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |s|
  end

  s.subspec 'Simulation' do |s|
    s.source_files = 'AuroraDreamband/Simulation/**/*'

    s.dependency 'RZBluetooth/Mock'
  end

  s.subspec 'Testing' do |s|
    s.dependency 'RZBluetooth/Test'
  end
end
