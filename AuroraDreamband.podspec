Pod::Spec.new do |s|
  s.name             = 'AuroraDreamband'
  s.version          = '0.1.0'
  s.summary          = 'iWinks BluetoothLE core library'

  s.description      = <<-DESC
    For developers looking for the most control, SDKs are provided to interact with Aurora directly.
    Execute commands, receive events, and configure profiles without worrying about all the boilerplate and connection logic.
    Available for iOS, Android, and NodeJS, these are the same SDKs powering the official Aurora apps.
                       DESC
  s.homepage = 'https://sleepwithaurora.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rafael Nobre' => 'nobre84@gmail.com' }
  s.source           = { :git => 'https://github.com/iwinks/aurora-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'AuroraDreamband/Classes/**/*'

  s.dependency 'RZBluetooth', '~> 1.0'
  s.dependency 'PromiseKit', '~> 4.0'
  s.dependency 'AwaitKit', '~> 3.0'
  s.dependency 'heatshrink-objc'

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
